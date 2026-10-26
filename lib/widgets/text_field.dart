import 'package:flutter/material.dart';
import 'package:minas_client/constans/colors.dart';

Widget buildTextField(
  String hint,
  TextEditingController controller,
  bool isPassword,
  dynamic icon,
  Function()? onTap,
) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);

      if (isPassword) {
        return _PasswordField(hint: hint, controller: controller);
      }

      return TextField(
        controller: controller,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          hoverColor: theme.colorScheme.surfaceContainerHighest,
          fillColor: AppColors.darkTextSecondary.withOpacity(0.05),
          focusColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.onSurface, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      );
    },
  );
}

class _PasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;

  const _PasswordField({required this.hint, required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.primary,
          ),
        ),
        filled: true,
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        fillColor: AppColors.darkTextSecondary.withOpacity(0.05),
        focusColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
