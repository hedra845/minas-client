import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:minas_client/widgets/slider.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/models/payment_method_model.dart';
import 'package:minas_client/services/payment_methods_service.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:minas_client/services/deposit_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaymentIconsCache {
  static final CacheManager manager = CacheManager(
    Config(
      'payment_icons_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );
}

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String value_selected = '';
  List<PaymentMethod> paymentMethods = [];
  bool isLoading = true;
  String? errorMessage;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Image handling
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await AuthService.isLoggedIn();
      if (!isAuthenticated) {
        setState(() {
          errorMessage = 'يرجى تسجيل الدخول أولاً - Please login first';
          isLoading = false;
        });
        return;
      }

      final response = await PaymentMethodsService.getPaymentMethods();
      setState(() {
        paymentMethods = response.paymentMethods;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showImageSourceDialog(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مصدر الصورة - Choose Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'المعرض - Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.gallery);
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'الكاميرا - Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.camera);
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isDarkMode ? AppColors.primary : AppColors.primary,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      // Request appropriate permission
      PermissionStatus permission;
      if (source == ImageSource.camera) {
        permission = await Permission.camera.request();
      } else {
        // For gallery, try multiple permission types

        // Try photos permission first (Android 13+)
        permission = await Permission.photos.request();

        // If photos permission not granted, try storage (older Android)
        if (permission != PermissionStatus.granted) {
          permission = await Permission.storage.request();
        }

        // If still not granted, try media images (Android 13+ alternative)
        if (permission != PermissionStatus.granted) {
          try {
            permission = await Permission.mediaLibrary.request();
          } catch (e) {
            // Media library permission not available
          }
        }
      }

      if (permission != PermissionStatus.granted) {
        if (permission == PermissionStatus.permanentlyDenied) {
          // Show dialog to open settings
          _showPermissionDeniedDialog(source.name);
          return;
        } else {
          throw Exception(
            'تم رفض الإذن - Permission denied. Please allow access to ${source.name}.',
          );
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Check if file exists
        if (!await imageFile.exists()) {
          throw Exception('Selected image file not found');
        }

        final bytes = await imageFile.readAsBytes();

        // Check file size (max 5MB for file upload)
        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception(
            'Image size too large. Please select a smaller image (max 5MB).',
          );
        }

        // Show info for large images
        if (bytes.length > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'صورة كبيرة - Large image. قد يستغرق الرفع وقتاً أطول - Upload may take longer.',
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }

        setState(() {
          _selectedImage = imageFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم اختيار الصورة بنجاح - Image selected successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {}
    } catch (e) {
      String errorMessage = 'خطأ في اختيار الصورة - Error picking image';

      if (e.toString().contains('Permission denied')) {
        errorMessage =
            'تم رفض الإذن - Permission denied. Please allow access to ${source.name} in settings.';
      } else if (e.toString().contains('Image picker not available')) {
        errorMessage =
            'محدد الصور غير متاح - Image picker not available on this device.';
      } else if (e.toString().contains('too large')) {
        errorMessage =
            'الصورة كبيرة جداً - Image too large. Please select a smaller image.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'لم يتم العثور على الصورة - Image file not found.';
      } else {
        errorMessage = 'خطأ في اختيار الصورة - Error: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildPaymentMethodImage(String imageUrl, bool isDarkMode) {
    if (imageUrl.isEmpty) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Container(
          color:
              isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
          child: Icon(
            Icons.payment,
            size: 16,
            color:
                isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    // Check if it's an SVG file
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SizedBox(
        width: 30,
        height: 30,
        child: FutureBuilder<Uint8List?>(
          future: () async {
            try {
              final cacheManager = PaymentIconsCache.manager;
              final fileInfo = await cacheManager.getFileFromCache(imageUrl);
              if (fileInfo != null && await fileInfo.file.exists()) {
                return await fileInfo.file.readAsBytes();
              }
              final file = await cacheManager.getSingleFile(imageUrl);
              return await file.readAsBytes();
            } catch (_) {
              return null;
            }
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color:
                    isDarkMode
                        ? AppColors.darkInputFill
                        : AppColors.lightInputFill,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }
            final bytes = snapshot.data;
            if (bytes == null) {
              return Container(
                color:
                    isDarkMode
                        ? AppColors.darkInputFill
                        : AppColors.lightInputFill,
                child: Icon(
                  Icons.payment,
                  size: 16,
                  color:
                      isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                ),
              );
            }
            return SvgPicture.memory(bytes, fit: BoxFit.contain);
          },
        ),
      );
    }

    // For JPG, PNG, and other raster images
    return SizedBox(
      width: 30,
      height: 30,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheManager: PaymentIconsCache.manager,
        fit: BoxFit.contain,
        placeholder:
            (context, url) => Container(
              color:
                  isDarkMode
                      ? AppColors.darkInputFill
                      : AppColors.lightInputFill,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              color:
                  isDarkMode
                      ? AppColors.darkInputFill
                      : AppColors.lightInputFill,
              child: Icon(
                Icons.payment,
                size: 16,
                color:
                    isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
            ),
      ),
    );
  }

  void _showPermissionDeniedDialog(String sourceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إذن مطلوب - Permission Required'),
          content: Text(
            'تم رفض الإذن للوصول إلى $sourceName. يرجى السماح بالوصول في إعدادات التطبيق.\n\n'
            'Permission denied for $sourceName access. Please allow access in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء - Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('فتح الإعدادات - Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitDeposit() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال الاسم - Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال المبلغ - Please enter amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (value_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار طريقة الدفع - Please select payment method',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Always require image
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى رفع صورة الإيصال - Please upload receipt image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount < 1) {
        throw Exception(
          'المبلغ يجب أن يكون أكبر من 1 - Amount must be greater than 1',
        );
      }

      final methodId = int.tryParse(value_selected);
      if (methodId == null) {
        throw Exception('طريقة دفع غير صحيحة - Invalid payment method');
      }

      await DepositService.submitDeposit(
        amount: amount,
        method: methodId,
        name: _nameController.text.trim(),
        imageFile: _selectedImage!,
      );

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال طلب الإيداع بنجاح - Deposit request submitted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _nameController.clear();
      _amountController.clear();
      setState(() {
        value_selected = '';
        _selectedImage = null;
      });
    } catch (e) {
      // Handle authentication errors - redirect to login
      if (e.toString().contains('انتهت صلاحية الجلسة') ||
          e.toString().contains('Session Expired') ||
          e.toString().contains('Access Denied')) {
        _handleAuthenticationError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _handleAuthenticationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('انتهت صلاحية الجلسة - Session Expired'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'تسجيل الدخول - Login',
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

  // Helper method to get the selected payment method
  PaymentMethod? _getSelectedPaymentMethod() {
    if (value_selected.isEmpty) return null;

    try {
      final methodId = int.parse(value_selected);
      return paymentMethods.firstWhere(
        (method) => method.id == methodId,
        orElse: () => throw StateError('Payment method not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if payment identifier number should be shown
  bool _shouldShowPaymentIdentifier() {
    final selectedMethod = _getSelectedPaymentMethod();
    if (selectedMethod == null) {
      return false; // Hide by default if no method selected
    }

    // Show payment identifier number only if payment_identifier is NOT null
    return selectedMethod.paymentIdentifier != null;
  }

  // Get the payment identifier number to display
  String _getPaymentIdentifierNumber() {
    final selectedMethod = _getSelectedPaymentMethod();
    return selectedMethod?.paymentIdentifier ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Conditionally show payment identifier section
            if (_shouldShowPaymentIdentifier()) ...[
              Text(
                'copy_number_text'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getPaymentIdentifierNumber(),
                    style: TextStyle(
                      color: isDarkMode ? AppColors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: _getPaymentIdentifierNumber()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم نسخ الرقم',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? AppColors.white
                                      : AppColors.primary,
                            ),
                          ),
                          backgroundColor:
                              isDarkMode
                                  ? AppColors.darkBorder
                                  : AppColors.white,
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/copy_icon.svg',
                      color: isDarkMode ? AppColors.white : AppColors.primary,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              constraints: BoxConstraints(maxHeight: 150, minHeight: 100),
              child: SvgPicture.asset(
                'assets/images/deposit.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              "inp_full_name".tr(),
              'assets/images/name_icon.svg',
              isDarkMode,
              controller: _nameController,
            ),
            const SizedBox(height: 8),
            _buildDropdown(isDarkMode),
            const SizedBox(height: 8),
            _buildTextField(
              "inp_Quantity".tr(),
              'assets/images/money_icon.svg',
              isDarkMode,
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            // Upload button (always shown)
            GestureDetector(
              onTap: () => _showImageSourceDialog(isDarkMode),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? AppColors.white : AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color:
                      isDarkMode
                          ? AppColors.darkInputFill
                          : AppColors.lightInputFill,
                ),
                alignment: Alignment.center,
                child:
                    _selectedImage != null
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تم اختيار الصورة - Image Selected',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          "button_text_upload".tr(),
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.white
                                    : AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),
            _buildGradientButton(
              'button_send_request'.tr(),
              isDarkMode,
              onPressed: _submitDeposit,
            ),
            const SizedBox(height: 6),
            _buildGreyButton('button_cancel_request'.tr(), isDarkMode),
            const SizedBox(height: 12),
            const SvgImageSlider(),
            const SizedBox(height: 12),
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

  Widget _buildTextField(
    String hint,
    String icon,
    bool isDarkMode, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor:
            isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
        prefixIcon: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: SvgPicture.asset(
            icon,
            width: 10,
            height: 10,
            color:
                isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.white : AppColors.primary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.white : AppColors.primary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.white : AppColors.primary,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color:
              isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildDropdown(bool isDarkMode) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
          border: Border.all(
            color: isDarkMode ? AppColors.white : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "loading".tr(),
            style: TextStyle(
              color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
        border: Border.all(
          color: isDarkMode ? AppColors.white : AppColors.primary,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: PopupMenuButton<String>(
        color: isDarkMode ? AppColors.darkInputFill : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value_selected.isEmpty
                    ? "dropdown_pyment".tr()
                    : paymentMethods
                        .where(
                          (method) => method.id.toString() == value_selected,
                        )
                        .isNotEmpty
                    ? paymentMethods
                        .firstWhere(
                          (method) => method.id.toString() == value_selected,
                        )
                        .name
                        .getLocalizedName(context.locale.languageCode)
                    : "dropdown_pyment".tr(),
                style: TextStyle(
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                  fontSize: 14,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/images/drop_down_icon.svg',
              color:
                  isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
            ),
          ],
        ),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry<String>> items = [
            PopupMenuItem<String>(
              value: "",
              child: SizedBox(
                height: 50,
                width: 250,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "dropdown_pyment".tr(),
                    style: TextStyle(
                      color:
                          isDarkMode ? AppColors.darkText : AppColors.lightText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ];

          items.addAll(
            paymentMethods.map((method) {
              final currentLocale = context.locale.languageCode;
              final methodName = method.name.getLocalizedName(currentLocale);
              final methodValue = method.id.toString();
              return PopupMenuItem<String>(
                value: methodValue,
                child: SizedBox(
                  height: 50,
                  width: 250,
                  child: Row(
                    children: [
                      // Display payment method image
                      if (method.image.isNotEmpty)
                        Container(
                          width: 30,
                          height: 30,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _buildPaymentMethodImage(
                              method.image,
                              isDarkMode,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 30,
                          height: 30,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color:
                                isDarkMode
                                    ? AppColors.darkInputFill
                                    : AppColors.lightInputFill,
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.payment,
                            size: 16,
                            color:
                                isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                        ),
                      const SizedBox(width: 5),
                      // Display payment method name
                      Expanded(
                        child: Text(
                          methodName,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );

          return items;
        },
        onSelected: (String value) {
          setState(() {
            value_selected = value;
          });
        },
      ),
    );
  }

  Widget _buildGradientButton(
    String text,
    bool isDarkMode, {
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري الإرسال... - Submitting...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
      ),
    );
  }

  Widget _buildGreyButton(String text, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          foregroundColor:
              isDarkMode ? AppColors.darkText : AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
