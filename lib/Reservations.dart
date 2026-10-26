import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart' show GradientFABE;
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/providers/user_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/models/reservation_model.dart';
import 'package:minas_client/services/reservation_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:minas_client/services/download_service.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  // API related state
  final ReservationService _reservationService = ReservationService();
  ReservationResponse? _reservationResponse;
  List<ReservationModel> _reservations = [];
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasSearched = false;

  // Pagination state
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;

  // Filter state
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  int? _selectedService;
  String _selectedStatus = "";
  bool _hasActiveFilters = false;

  // Status options for filtering - using translation keys
  List<Map<String, String>> get _statusOptions => [
    {"value": "", "label": "all_status".tr()},
    {"value": "created", "label": "created".tr()},
    {"value": "paid", "label": "paid".tr()},
    {"value": "cancelled", "label": "cancelled".tr()},
    {"value": "refunded", "label": "refunded".tr()},
    {"value": "completed", "label": "completed".tr()},
  ];

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadReservations();
    _setupScrollListener();

    // Load user data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  Future<void> _checkAuthenticationAndLoadReservations() async {
    final isAuthenticated = await _reservationService.isAuthenticated();
    if (!isAuthenticated) {
      setState(() {
        _errorMessage = 'authentication_required'.tr();
        _isLoading = false;
      });
      return;
    }
    _loadReservations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreReservations();
      }
    });
  }

  Future<void> _loadReservations({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _reservations.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _reservationService.getReservations(
        page: _currentPage,
        date: _selectedDate?.toIso8601String(),
        service: _selectedService,
        status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
      );

      setState(() {
        _reservationResponse = response;

        if (isRefresh || _currentPage == 1) {
          _reservations = response.reservations.data;
          _services = response.services;
        } else {
          _reservations.addAll(response.reservations.data);
        }

        _hasNextPage = response.reservations.nextPageUrl != null;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      // Handle authentication errors
      if (e.toString().contains('Authentication failed')) {
        _handleAuthenticationError();
      }
    }
  }

  Future<void> _loadMoreReservations() async {
    if (_isLoadingMore || !_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final response = await _reservationService.getReservations(
        page: _currentPage,
        date: _selectedDate?.toIso8601String(),
        service: _selectedService,
        status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
      );

      setState(() {
        _reservations.addAll(response.reservations.data);
        _hasNextPage = response.reservations.nextPageUrl != null;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page increment on error
      });

      // Handle authentication errors
      if (e.toString().contains('Authentication failed')) {
        _handleAuthenticationError();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more reservations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _updateActiveFiltersState();
    setState(() {
      _hasSearched = true;
    });
    _loadReservations(isRefresh: true).then((_) {
      // Show SnackBar if no results found after search
      if (_hasSearched && _reservations.isEmpty && mounted) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDarkMode = themeProvider.isDarkMode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('no_results_found'.tr()),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'clear_filters'.tr(),
              textColor: isDarkMode ? AppColors.white : app_colors.primary,
              onPressed: _clearAllFilters,
            ),
          ),
        );
      }
    });
  }

  void _updateActiveFiltersState() {
    setState(() {
      _hasActiveFilters =
          _dateController.text.isNotEmpty ||
          _selectedService != null ||
          _selectedStatus.isNotEmpty;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
      _selectedService = null;
      _selectedStatus = "";
      _hasActiveFilters = false;
      _hasSearched = false;
    });
    _loadReservations(isRefresh: true);
  }

  void _handleAuthenticationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('session_expired'.tr()),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'login_button'.tr(),
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  void _openDatePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select_Date".tr()),
          content: SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _dateController.text =
                      '${date.day}/${date.month}/${date.year}';
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel_button".tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ok_button".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: RefreshIndicator(
        onRefresh: () => _loadReservations(isRefresh: true),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'all_bookings'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      if (_errorMessage!.contains(
                            'authentication_required'.tr(),
                          ) ||
                          _errorMessage!.contains('session_expired'.tr()))
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: Text('login_button'.tr()),
                        )
                      else
                        TextButton(
                          onPressed: () => _loadReservations(isRefresh: true),
                          child: Text('Retry'),
                        ),
                    ],
                  ),
                ),

              // Filter Header with Clear Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'filters'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? AppColors.white : AppColors.primary,
                        ),
                      ),
                      if (_hasActiveFilters && _selectedService != null)
                        Text(
                          'Filtered by: ${_services.firstWhere((s) => s.id == _selectedService, orElse: () => ServiceModel(id: _selectedService, name: LocalizedName(ar: 'Unknown', en: 'Unknown'))).name.getLocalizedName(context.locale.languageCode)}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? AppColors.white
                                    : app_colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: Icon(
                        Icons.clear_all,
                        size: 16,
                        color:
                            isDarkMode ? AppColors.white : app_colors.primary,
                      ),
                      label: Text(
                        'clear_filters'.tr(),
                        style: TextStyle(
                          color:
                              isDarkMode ? AppColors.white : app_colors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Filters
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedService,
                          decoration: InputDecoration(
                            labelText: 'service'.tr(),
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('all_services'.tr()),
                            ),
                            ..._services.map(
                              (service) => DropdownMenuItem<int>(
                                value: service.id,
                                child: Text(
                                  service.name.getLocalizedName(
                                    context.locale.languageCode,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedService = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'status'.tr(),
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          items:
                              _statusOptions.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status['value'],
                                  child: Text(status['label']!),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value ?? "";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'date'.tr(),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: IconButton(
                            onPressed: () => _openDatePickerDialog(),
                            icon: Icon(
                              Icons.calendar_month_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Search Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: Icon(Icons.search, color: Colors.white),
                      label: Text(
                        'search'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Booking Cards
              Expanded(
                child:
                    _isLoading && _reservations.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _reservations.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasSearched
                                    ? Icons.search_off
                                    : Icons.bookmark_border,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _hasSearched
                                    ? 'no_results_found'.tr()
                                    : 'no_reservations_found'.tr(),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_hasSearched) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'try_different_filters'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              _reservations.length + (_hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _reservations.length) {
                              // Loading indicator for more items
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return BookingCard(
                              reservation: _reservations[index],
                              currencySymbol:
                                  _reservationResponse
                                              ?.reservations
                                              .data
                                              .isNotEmpty ==
                                          true
                                      ? _reservationResponse!
                                          .reservations
                                          .data
                                          .first
                                          .company
                                          .currency
                                          .symbol
                                      : '',
                              locale: locale,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: GradientFABE(),
    );
  }
}

class BookingCard extends StatelessWidget {
  final ReservationModel reservation;
  final String currencySymbol;
  final Locale locale;

  const BookingCard({
    super.key,
    required this.reservation,
    required this.currencySymbol,
    required this.locale,
  });

  Future<void> _downloadAttachment(String url, BuildContext context) async {
    try {
      // Check if it's a PDF file
      if (DownloadService.isPdfFile(url)) {
        // Download the PDF file
        await DownloadService.downloadReservationAttachment(
          attachmentUrl: url,
          reservationId: reservation.id.toString(),
          context: context,
        );
      } else {
        // For non-PDF files, use URL launcher
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open attachment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'created':
        return theme.colorScheme.primaryContainer;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return theme.colorScheme.secondaryContainer;
    }
  }

  Color _getStatusTextColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'created':
        return theme.colorScheme.onPrimaryContainer;
      case 'completed':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return theme.colorScheme.onSecondaryContainer;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 'created'.tr();
      case 'paid':
        return 'paid'.tr();
      case 'cancelled':
        return 'cancelled'.tr();
      case 'refunded':
        return 'refunded'.tr();
      case 'completed':
        return 'completed'.tr();
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(reservation.date);

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'date'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${'service'.tr()}: ${reservation.service.name.getLocalizedName(locale.languageCode)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(formattedDate, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'status'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status, theme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusLabel(reservation.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusTextColor(reservation.status, theme),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${'booking_number'.tr()}: ${reservation.pnrNumber}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${'cost'.tr()}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reservation.cost.toStringAsFixed(2)} $currencySymbol',
                  ),
                ),
                const Spacer(),
                if (reservation.attachment != null)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          () => _downloadAttachment(
                            reservation.attachment!,
                            context,
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/reservation_icon.svg',
                            color: theme.colorScheme.onPrimary,
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'download_attachment'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
