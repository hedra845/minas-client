import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/models/payment_method_model.dart';
import 'package:minas_client/services/payment_methods_service.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

/// Custom image cache service for caching network images
class ImageCacheService {
  static final Map<String, ui.Image> _imageCache = {};
  static final Map<String, bool> _loadingImages = {};

  /// Load and cache an image from URL
  static Future<ui.Image?> loadAndCacheImage(String imageUrl) async {
    // Return cached image if available
    if (_imageCache.containsKey(imageUrl)) {
      return _imageCache[imageUrl];
    }

    // Prevent duplicate loading
    if (_loadingImages[imageUrl] == true) {
      ('⏳ Image already loading: $imageUrl');
      return null;
    }

    try {
      _loadingImages[imageUrl] = true;
      ('🔄 Loading image from network: $imageUrl');

      // Check if it's an SVG file - we can't cache SVG with ui.Image
      if (imageUrl.toLowerCase().endsWith('.svg')) {
        (
          '⚠️ SVG files cannot be cached with ui.Image, skipping cache: $imageUrl',
        );
        _loadingImages[imageUrl] = false;
        return null;
      }

      // Deprecated network fetch via http removed; use CacheManager upstream
      return null;
    } catch (e) {
      ('❌ Error loading image: $e');
      ('❌ Image URL: $imageUrl');
      return null;
    } finally {
      _loadingImages[imageUrl] = false;
    }
  }

  /// Clear image cache
  static void clearCache() {
    ('🗑️ Clearing image cache...');
    _imageCache.clear();
    _loadingImages.clear();
  }

  /// Clear specific image from cache
  static void clearImageFromCache(String imageUrl) {
    if (_imageCache.containsKey(imageUrl)) {
      _imageCache[imageUrl]?.dispose();
      _imageCache.remove(imageUrl);
      ('🗑️ Removed image from cache: $imageUrl');
    }
  }

  /// Get cache size
  static int getCacheSize() {
    return _imageCache.length;
  }
}

/// Custom painter for displaying cached images
class CachedImagePainter extends CustomPainter {
  final ui.Image image;

  CachedImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true;

    // Calculate the scaling to fit the image within the size while maintaining aspect ratio
    final imageAspectRatio = image.width / image.height;
    final canvasAspectRatio = size.width / size.height;

    Rect srcRect;
    Rect dstRect;

    if (imageAspectRatio > canvasAspectRatio) {
      // Image is wider than canvas
      final scale = size.width / image.width;
      final scaledHeight = image.height * scale;
      srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      dstRect = Rect.fromLTWH(
        0,
        (size.height - scaledHeight) / 2,
        size.width,
        scaledHeight,
      );
    } else {
      // Image is taller than canvas
      final scale = size.height / image.height;
      final scaledWidth = image.width * scale;
      srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      dstRect = Rect.fromLTWH(
        (size.width - scaledWidth) / 2,
        0,
        scaledWidth,
        size.height,
      );
    }

    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(CachedImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

class PaymentIconsCache {
  static final CacheManager manager = CacheManager(
    Config(
      'payment_icons_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );
}

class SvgImageSlider extends StatefulWidget {
  const SvgImageSlider({super.key});

  @override
  State<SvgImageSlider> createState() => _SvgImageSliderState();
}

class _SvgImageSliderState extends State<SvgImageSlider> {
  List<PaymentMethod> paymentMethods = [];
  bool isLoading = true;
  bool hasError = false;

  // Static cache to prevent reloading payment methods
  static List<PaymentMethod>? _cachedPaymentMethods;
  static bool _isLoadingFromCache = false;

  // Fallback payment methods in case API fail

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void didUpdateWidget(SvgImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the widget key has changed
    if (oldWidget.key != widget.key) {
      _loadPaymentMethods();
    }
  }

  void _refreshPaymentMethods() {
    _loadPaymentMethods();
  }

  Widget _buildImageWithFallback(String imageUrl, bool isDarkMode, int index) {
    // Check if we have a valid URL
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      ('⚠️ Invalid image URL for index $index: $imageUrl');
      return _buildFallbackIcon(Icons.payment, isDarkMode);
    }

    // Load image with format detection

    // Try image loading with delay
    return _buildDelayedNetworkImage(
      imageUrl,
      isDarkMode,
      delay: index * 100, // Reduced staggered delay for faster loading
    );
  }

  Future<void> _loadPaymentMethods() async {
    try {
      // Check if we have cached payment methods
      if (_cachedPaymentMethods != null) {
        (
          '✅ Using cached payment methods: ${_cachedPaymentMethods!.length} methods',
        );
        if (mounted) {
          setState(() {
            paymentMethods = _cachedPaymentMethods!;
            isLoading = false;
            hasError = false;
          });
        }
        return;
      }

      // Prevent multiple simultaneous loads
      if (_isLoadingFromCache) {
        ('⏳ Payment methods already loading, waiting...');
        // Wait for the current load to complete
        while (_isLoadingFromCache) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // Try again with cached data
        if (_cachedPaymentMethods != null) {
          if (mounted) {
            setState(() {
              paymentMethods = _cachedPaymentMethods!;
              isLoading = false;
              hasError = false;
            });
          }
          return;
        }
      }

      _isLoadingFromCache = true;

      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Add a small delay to prevent overwhelming the UI
      await Future.delayed(const Duration(milliseconds: 100));

      ('🔄 Starting to fetch payment methods from API...');

      // Check if user is authenticated
      final isAuthenticated = await AuthService.isLoggedIn();
      if (!isAuthenticated) {
        ('❌ User not authenticated, skipping payment methods load');
        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
            paymentMethods = [];
          });
        }
        _isLoadingFromCache = false;
        return;
      }

      final methods =
          await PaymentMethodsService.getPaymentMethodsWithFallback();

      ('📦 Received ${methods.length} payment methods from API');

      // Test if we have any valid image URLs
      int validImages = 0;
      for (final method in methods) {
        if (method.image.isNotEmpty && method.image.startsWith('http')) {
          validImages++;
        }
      }
      (
        '🖼️ Found $validImages valid image URLs out of ${methods.length} methods',
      );

      // Cache the payment methods
      _cachedPaymentMethods = methods;

      if (mounted) {
        setState(() {
          paymentMethods = methods;
          isLoading = false;
          hasError =
              false; // Don't treat empty list as error, just show empty state
        });

        ('✅ Payment methods loaded successfully: ${methods.length} methods',);
        ('✅ Loading state: isLoading=$isLoading, hasError=$hasError');
      }
    } catch (e) {
      ('❌ Error loading payment methods: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          paymentMethods = [];
        });
      }
    } finally {
      _isLoadingFromCache = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isArabic = languageProvider.isArabic;

    // Debug: Print payment methods to console
    (
      'SvgImageSlider: Loading ${paymentMethods.length} payment methods from API',
    );

    // Debug: Print each payment method details
    for (int i = 0; i < paymentMethods.length; i++) {
      final method = paymentMethods[i];
      (
        'Payment Method $i: ${method.name.ar} / ${method.name.en} - ${method.image}',
      );
      ('Image URL validation: ${method.image.isNotEmpty ? "Valid" : "Empty"}',);
      if (method.image.isNotEmpty) {
        ('Image URL: ${method.image}');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'طرق الدفع المتاحة' : 'Available Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              if (!isLoading && paymentMethods.isNotEmpty)
                Text(
                  '${paymentMethods.length} ${isArabic ? 'طريقة دفع' : 'Payment Methods'}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          child: _buildCarousel(
            themeProvider,
            languageProvider,
            isDarkMode,
            isArabic,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
    bool isDarkMode,
    bool isArabic,
  ) {
    if (isLoading) {
      return _buildLoadingState(isDarkMode);
    }

    if (hasError) {
      return _buildErrorState(isDarkMode, isArabic);
    }

    if (paymentMethods.isEmpty) {
      return _buildEmptyState(isDarkMode, isArabic);
    }

    return CarouselSlider(
      items:
          paymentMethods.asMap().entries.map((entry) {
            final index = entry.key;
            final method = entry.value;
            return Builder(
              key: ValueKey('payment_method_${method.id}_$index'),
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                    border: Border.all(
                      color:
                          isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? AppColors.darkInputFill
                                    : AppColors.lightInputFill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildImageWithFallback(
                              method.image,
                              isDarkMode,
                              index,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          method.name.getLocalizedName(isArabic ? 'ar' : 'en'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
      options: CarouselOptions(
        height: 200,
        autoPlay: false, // Disabled automatic scrolling
        enlargeCenterPage: true,
        viewportFraction: 0.4,
        enableInfiniteScroll:
            true, // Keep infinite scroll for manual navigation
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? AppColors.primary : AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading payment methods...',
            style: TextStyle(
              color:
                  isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color:
                isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'خطأ في تحميل طرق الدفع'
                : 'Error loading payment methods',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            child: ElevatedButton(
              onPressed: () {
                _refreshPaymentMethods();
              },
              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color:
                isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد طرق دفع متاحة' : 'No payment methods available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'يرجى المحاولة لاحقاً' : 'Please try again later',
            style: TextStyle(
              color:
                  isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _refreshPaymentMethods();
            },
            child: Text(isArabic ? 'تحديث' : 'Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayedNetworkImage(
    String imageUrl,
    bool isDarkMode, {
    int delay = 0,
  }) {
    // Check if it's an SVG file - load from disk cache and render from memory
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return FutureBuilder<Uint8List?>(
        future: Future.delayed(Duration(milliseconds: 100 + delay)).then((
          _,
        ) async {
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
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator(isDarkMode);
          }
          final bytes = snapshot.data;
          if (bytes == null) {
            return _buildFallbackIcon(Icons.payment, isDarkMode);
          }
          return SvgPicture.memory(
            bytes,
            key: ValueKey('svg_mem_$imageUrl'),
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          );
        },
      );
    }

    // For non-SVG images, use CachedNetworkImage with a disk cache
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: PaymentIconsCache.manager,
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildLoadingIndicator(isDarkMode),
      errorWidget:
          (context, url, error) =>
              _buildFallbackIcon(Icons.payment, isDarkMode),
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDarkMode ? AppColors.primary : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(IconData icon, bool isDarkMode) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isDarkMode ? AppColors.primary : AppColors.primary,
        size: 30,
      ),
    );
  }
}
