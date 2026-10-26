import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minas_client/webview_page.dart';

class GradientFABE extends StatelessWidget {
  const GradientFABE({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        shape: BoxShape.rectangle,
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const WebViewPage(
                    url: 'https://minasagency.com/',
                    title: 'Minas Agency',
                  ),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SvgPicture.asset(
          'assets/images/chat_icon.svg',
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
