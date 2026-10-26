import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const PageWrapper({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = child;

    if (useSafeArea) {
      content = SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.only(top: 60), // Add top spacing
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      body: content,
    );
  }
}

// Helper widget for pages that need custom app bar with top spacing
class PageWithCustomAppBar extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final Widget? bottomNavigationBar;

  const PageWithCustomAppBar({
    super.key,
    required this.appBar,
    required this.body,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Column(
        children: [
          // Add top spacing
          const SizedBox(height: 60),
          // Custom app bar
          appBar,
          // Body content
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
