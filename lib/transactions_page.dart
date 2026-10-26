import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/models/transaction_model.dart';
import 'package:minas_client/services/transactions_service.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:minas_client/image_viewer_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  // API related state
  final TransactionsService _transactionsService = TransactionsService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadTransactions();
  }

  Future<void> _checkAuthenticationAndLoadTransactions() async {
    // Check if user has a valid token
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'authentication_required'.tr();
        _isLoading = false;
      });
      return;
    }
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _transactions.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _transactionsService.getTransactions();

      setState(() {
        _transactions = response.transactions;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      // Handle authentication errors - redirect to login
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Access denied') ||
          e.toString().contains('No authentication token')) {
        _handleAuthenticationError();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final isRTL = locale.languageCode == 'ar';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: RefreshIndicator(
        onRefresh: () => _loadTransactions(isRefresh: true),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isRTL ? 'كل المعاملات' : 'All Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/plus-circle-outline.svg',
                    color: isDarkMode ? AppColors.white : AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/form_deposit');
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    TextButton(
                      onPressed: () => _loadTransactions(isRefresh: true),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),

            Expanded(
              child:
                  _isLoading && _transactions.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _transactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_transactions_found'.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          return TransactionCard(
                            transaction: _transactions[index],
                            locale: locale,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: GradientFABE(),
    );
  }
}

class TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final Locale locale;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.locale,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _permissionRequested = false;

  void _showTransactionImage(
    BuildContext context,
    String transactionImageKey,
    bool isRTL,
  ) {
    // Check if transactionImageKey is empty
    if (transactionImageKey.isEmpty) {
      _showErrorDialog(
        context,
        isRTL ? 'لا توجد صورة للمعاملة' : 'No transaction image available',
        isRTL,
      );
      return;
    }

    // Check if the key already contains the full URL
    String imageUrl;
    if (transactionImageKey.startsWith('https://')) {
      imageUrl = transactionImageKey;
    } else {
      imageUrl = 'https://minasagency.com/storage/$transactionImageKey';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRTL ? 'عرض المعاملة' : 'View Transaction',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Image
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    isRTL
                                        ? 'جاري تحميل الصورة...'
                                        : 'Loading image...',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isRTL
                                      ? 'فشل في تحميل الصورة'
                                      : 'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isRTL
                                      ? 'تحقق من اتصال الإنترنت'
                                      : 'Check your internet connection',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Footer with actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                        label: Text(isRTL ? 'إغلاق' : 'Close'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to full screen image viewer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ImageViewerPage(
                                    imageUrl: imageUrl,
                                    title:
                                        isRTL
                                            ? 'عرض المعاملة'
                                            : 'View Transaction',
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fullscreen),
                        label: Text(isRTL ? 'عرض كامل' : 'Full Screen'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAttachment(
    BuildContext context,
    String transactionAttachment,
    bool isRTL,
  ) async {
    try {
      // Check if transactionAttachment is empty
      if (transactionAttachment.isEmpty) {
        _showErrorDialog(
          context,
          isRTL ? 'لا يوجد مرفق للتنزيل' : 'No attachment to download',
          isRTL,
        );
        return;
      }

      // Check storage permission - only request once per session
      PermissionStatus storageStatus = await Permission.storage.status;
      PermissionStatus manageStorageStatus =
          await Permission.manageExternalStorage.status;

      // Only request permission if not already granted and not requested before in this session
      if ((!storageStatus.isGranted && !manageStorageStatus.isGranted) &&
          !_permissionRequested) {
        _permissionRequested = true;

        if (storageStatus.isDenied &&
            storageStatus != PermissionStatus.permanentlyDenied) {
          storageStatus = await Permission.storage.request();
        } else if (manageStorageStatus.isDenied &&
            manageStorageStatus != PermissionStatus.permanentlyDenied) {
          manageStorageStatus =
              await Permission.manageExternalStorage.request();
        }
      }

      // Check if any storage permission is granted
      if (!storageStatus.isGranted && !manageStorageStatus.isGranted) {
        if (storageStatus == PermissionStatus.permanentlyDenied ||
            manageStorageStatus == PermissionStatus.permanentlyDenied) {
          _showErrorDialog(
            context,
            isRTL
                ? 'تم رفض إذن التخزين نهائياً. يرجى تفعيله من إعدادات التطبيق'
                : 'Storage permission permanently denied. Please enable it in app settings',
            isRTL,
          );
        } else {
          _showErrorDialog(
            context,
            isRTL
                ? 'مطلوب إذن التخزين لتنزيل الملف'
                : 'Storage permission required to download file',
            isRTL,
          );
        }
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(isRTL ? 'جاري التنزيل...' : 'Downloading...'),
              ],
            ),
          );
        },
      );

      // Get download directory (use app's internal directory to avoid permission issues)
      final directory = await getApplicationDocumentsDirectory();

      // Get file extension from URL or use default
      String fileExtension = '';
      if (transactionAttachment.contains('.')) {
        fileExtension = transactionAttachment.split('.').last;
      } else {
        fileExtension = 'pdf'; // Default extension
      }

      final fileName =
          'transaction_attachment_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '${directory.path}/$fileName';

      // Download file using Dio with proper headers
      final dio = Dio();

      // Check if the attachment already contains the full URL
      String url;
      if (transactionAttachment.startsWith('https://')) {
        url = transactionAttachment;
      } else {
        url = 'https://minasagency.com/storage/$transactionAttachment';
      }

      // Add timeout and headers
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      try {
        await dio.download(
          url,
          filePath,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': '*/*',
            },
          ),
          onReceiveProgress: (received, total) {
            // Progress tracking removed for cleaner code
          },
        );
      } catch (dioError) {
        // Alternative download using http package
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Check if file exists and has content
      final file = File(filePath);
      if (!await file.exists()) {
        _showErrorDialog(
          context,
          isRTL
              ? 'فشل في تنزيل الملف - الملف غير موجود'
              : 'Failed to download file - file does not exist',
          isRTL,
        );
        return;
      }

      final fileSize = await file.length();

      if (fileSize == 0) {
        _showErrorDialog(
          context,
          isRTL
              ? 'فشل في تنزيل الملف - الملف فارغ'
              : 'Failed to download file - file is empty',
          isRTL,
        );
        return;
      }

      // Open the downloaded file
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        _showErrorDialog(
          context,
          isRTL
              ? 'تم تنزيل الملف بنجاح ولكن فشل في فتحه.\nمسار الملف: $filePath'
              : 'File downloaded successfully but failed to open.\nFile path: $filePath',
          isRTL,
        );
      } else {
        _showSuccessDialog(
          context,
          isRTL
              ? 'تم تنزيل المرفق بنجاح'
              : 'Attachment downloaded successfully',
          isRTL,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      String errorMessage = e.toString();
      if (errorMessage.contains('404')) {
        errorMessage =
            isRTL ? 'الملف غير موجود على الخادم' : 'File not found on server';
      } else if (errorMessage.contains('403')) {
        errorMessage =
            isRTL ? 'غير مسموح بالوصول للملف' : 'Access denied to file';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = isRTL ? 'انتهت مهلة الاتصال' : 'Connection timeout';
      }

      _showErrorDialog(
        context,
        isRTL
            ? 'فشل في تنزيل المرفق: $errorMessage'
            : 'Failed to download attachment: $errorMessage',
        isRTL,
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message, bool isRTL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isRTL ? 'خطأ' : 'Error',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'موافق' : 'OK',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message, bool isRTL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isRTL ? 'نجح' : 'Success',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'موافق' : 'OK',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = widget.locale.languageCode == 'ar';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/Vector.svg',
                  color: theme.colorScheme.outline,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isRTL
                        ? widget.transaction.localizedType
                        : widget.transaction.type,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.transaction.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: widget.transaction.statusColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRTL
                            ? widget.transaction.localizedStatus
                            : widget.transaction.status,
                        style: TextStyle(
                          color: widget.transaction.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: app_colors.divider_color),
            Row(
              children: [
                Text(
                  isRTL ? 'الكمية:' : 'Amount:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(widget.transaction.formattedAmount),
                const Spacer(),
                Text(
                  widget.transaction.transactionId,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  isRTL ? 'طريقة الدفع:' : 'Payment Method:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.transaction.paymentMethod?.name.getLocalizedName(
                        isRTL ? 'ar' : 'en',
                      ) ??
                      (isRTL ? 'غير محدد' : 'Not specified'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  isRTL ? 'التاريخ:' : 'Date:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(widget.transaction.formattedDate),
                const Spacer(),
                Text(
                  isRTL ? 'الوقت:' : 'Time:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(widget.transaction.formattedTime),
              ],
            ),
            if (widget.transaction.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    isRTL ? 'الوصف:' : 'Description:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.transaction.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.transaction.hasAttachment) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Display the transaction image
                      _showTransactionImage(
                        context,
                        widget.transaction.transactionImage,
                        isRTL,
                      );
                    },
                    icon: Icon(
                      Icons.image,
                      size: 16,
                      color:
                          isDarkMode ? Colors.white : theme.colorScheme.primary,
                    ),
                    label: Text(
                      isRTL ? 'عرض المعاملة' : 'View Transaction',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode
                                ? Colors.white
                                : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Download the transaction attachment
                      _downloadAttachment(
                        context,
                        widget.transaction.transactionAttachment,
                        isRTL,
                      );
                    },
                    icon: Icon(
                      Icons.download,
                      size: 16,
                      color:
                          isDarkMode ? Colors.white : theme.colorScheme.primary,
                    ),
                    label: Text(
                      isRTL ? 'تنزيل المرفق' : 'Download',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode
                                ? Colors.white
                                : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
