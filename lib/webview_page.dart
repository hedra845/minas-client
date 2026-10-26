import 'package:flutter/material.dart';
import 'package:minas_client/widgets/quick_actions_drawer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:minas_client/theme/theme_provider.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = 'Website',
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      drawer: QuickActionsDrawer(isDarkMode: isDarkMode),
      appBar: MinasAppBar(
        isDarkMode: isDarkMode,
        themeProvider: themeProvider,
        title: widget.title,
      ),
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppColors.primary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري التحميل... - Loading...',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error message
          if (_errorMessage != null && !_isLoading)
            Container(
              color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خطأ في تحميل الصفحة - Error loading page',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isLoading = true;
                        });
                        _controller.reload();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('إعادة المحاولة - Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
