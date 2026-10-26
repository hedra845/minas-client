import 'package:flutter/material.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/providers/user_provider.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/models/offer_model.dart';
import 'package:minas_client/services/offers_service.dart';
import 'package:minas_client/image_viewer_page.dart';
import 'package:minas_client/webview_page.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  // API related state
  final OffersService _offersService = OffersService();
  List<OfferModel> _offers = [];
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;

  // Filter state
  int? _selectedService;
  bool _hasActiveFilters = false;
  bool _hasSearched = false;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadOffers();
    _setupScrollListener();

    // Load user data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreOffers();
      }
    });
  }

  Future<void> _checkAuthenticationAndLoadOffers() async {
    final isAuthenticated = await _offersService.isAuthenticated();
    if (!isAuthenticated) {
      setState(() {
        _errorMessage = 'authentication_required'.tr();
        _isLoading = false;
      });
      return;
    }
    _loadOffers();
  }

  Future<void> _loadOffers({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _offers.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _offersService.getOffers(
        page: _currentPage,
        serviceId: _selectedService,
      );

      setState(() {
        _services = response.services;

        // Filter offers by selected service on client side if needed
        List<OfferModel> filteredOffers = response.serviceoffers.data;
        if (_selectedService != null && _selectedService != 0) {
          filteredOffers =
              response.serviceoffers.data
                  .where((offer) => offer.serviceId == _selectedService)
                  .toList();
        }

        if (isRefresh || _currentPage == 1) {
          _offers = filteredOffers;
        } else {
          _offers.addAll(filteredOffers);
        }

        // Check if there are more pages based on total items and current page
        final totalPages =
            (response.serviceoffers.total / response.serviceoffers.perPage)
                .ceil();
        _hasNextPage = _currentPage < totalPages;
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

  Future<void> _loadMoreOffers() async {
    if (_isLoadingMore || !_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;

      final response = await _offersService.getOffers(
        page: _currentPage,
        serviceId: _selectedService,
      );

      setState(() {
        // Filter offers by selected service on client side if needed
        List<OfferModel> filteredOffers = response.serviceoffers.data;
        if (_selectedService != null && _selectedService != 0) {
          filteredOffers =
              response.serviceoffers.data
                  .where((offer) => offer.serviceId == _selectedService)
                  .toList();
        }

        _offers.addAll(filteredOffers);
        // Check if there are more pages based on total items and current page
        final totalPages =
            (response.serviceoffers.total / response.serviceoffers.perPage)
                .ceil();
        _hasNextPage = _currentPage < totalPages;
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
            content: Text('Failed to load more offers: $e'),
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

    _loadOffers(isRefresh: true)
        .then((_) {
          // Show SnackBar if no results found after search
          if (_hasSearched && _offers.isEmpty && mounted) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            final isDarkMode = themeProvider.isDarkMode;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('no_results_found'.tr()),
                backgroundColor:
                    isDarkMode ? AppColors.darkSurface : Colors.orange,
                action: SnackBarAction(
                  label: 'clear_filters'.tr(),
                  textColor: isDarkMode ? AppColors.white : AppColors.primary,
                  onPressed: _clearAllFilters,
                ),
              ),
            );
          }
        })
        .catchError((error) {
          if (mounted) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            final isDarkMode = themeProvider.isDarkMode;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error applying filters: $error'),
                backgroundColor:
                    isDarkMode ? AppColors.darkSurface : Colors.red,
              ),
            );
          }
        });
  }

  void _updateActiveFiltersState() {
    setState(() {
      _hasActiveFilters = _selectedService != null;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedService = null;
      _hasActiveFilters = false;
      _hasSearched = false;
    });
    _loadOffers(isRefresh: true);
  }

  void _handleAuthenticationError() {
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final isDarkMode = themeProvider.isDarkMode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('session_expired'.tr()),
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.red,
          action: SnackBarAction(
            label: 'login_button'.tr(),
            textColor: isDarkMode ? AppColors.white : app_colors.primary,
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
        onRefresh: () => _loadOffers(isRefresh: true),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'offers'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.outline,
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
                    color:
                        isDarkMode
                            ? AppColors.darkSurface.withOpacity(0.3)
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color:  Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.white
                                    : Colors.red.shade800,
                          ),
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
                          onPressed: () => _loadOffers(isRefresh: true),
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
                               isDarkMode ? AppColors.white : app_colors.primary,
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
                           isDarkMode ? AppColors.white : app_colors.primary
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
                  // Service Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
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
                      // Search Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _applyFilters,
                          icon: Icon(
                            Icons.search,
                            color:
                                isDarkMode
                                    ? AppColors.white
                                    : AppColors.primary,
                          ),
                          label: Text(
                            'search'.tr(),
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? AppColors.white
                                      : AppColors.primary,
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
                ],
              ),
              const SizedBox(height: 16),

              // Offers Cards
              Expanded(
                child:
                    _isLoading && _offers.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _offers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasSearched
                                    ? Icons.search_off
                                    : Icons.local_offer_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _hasSearched
                                    ? 'no_results_found'.tr()
                                    : 'no_offers_found'.tr(),
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
                          itemCount: _offers.length + (_hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _offers.length) {
                              // Loading indicator for more items
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return OfferCard(
                              offer: _offers[index],
                              locale: locale,
                              serviceDisplayName:
                                  (() {
                                    final svc = _services.firstWhere(
                                      (s) => s.id == _offers[index].serviceId,
                                      orElse:
                                          () => ServiceModel(
                                            id: _offers[index].serviceId,
                                            name: LocalizedName(
                                              ar: _offers[index].serviceName,
                                              en: _offers[index].serviceName,
                                            ),
                                          ),
                                    );
                                    return svc.name.getLocalizedName(
                                      locale.languageCode,
                                    );
                                  })(),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: GradientFABE(),
    );
  }
}

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final Locale locale;
  final String serviceDisplayName;

  const OfferCard({
    super.key,
    required this.offer,
    required this.locale,
    required this.serviceDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (offer.image != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ImageViewerPage(
                              imageUrl: offer.image!,
                              title: offer.title.getLocalizedName(
                                context.locale.languageCode,
                              ),
                            ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child:
                      offer.image != null
                          ? Image.network(
                            offer.image!,
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/amman.jpg',
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/amman.jpg',
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              if (offer.isExpired)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'expired'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   offer.serviceName,
                    //   style: theme.textTheme.bodyMedium?.copyWith(
                    //     color: Colors.white,
                    //     shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.title.getLocalizedName(
                          context.locale.languageCode,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        serviceDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      offer.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? AppColors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (offer.expireDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'valid_until'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(offer.expireDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  offer.isExpired
                                      ? (isDarkMode
                                          ? AppColors.darkSurface
                                          : Colors.red)
                                      : null,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Debug: Test if button is working

                      // Show immediate feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening booking page...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Navigate to minasagency.com in WebView
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => WebViewPage(
                                  url: 'https://minasagency.com',
                                  title: 'Minas Agency',
                                ),
                          ),
                        );
                      } catch (e) {
                        final themeProvider = Provider.of<ThemeProvider>(
                          context,
                        );
                        final isDarkMode = themeProvider.isDarkMode;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error opening booking page: $e'),
                            backgroundColor:
                                isDarkMode ? AppColors.darkSurface : Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'book_now'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                isDarkMode
                                    ? AppColors.white
                                    : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
