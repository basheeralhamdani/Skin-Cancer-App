import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final String? labelText; // It's better to use labelText
  final TextInputType inputType;
  final bool isPassword;
  final TextEditingController controller;
  final IconData? icon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon; // Added for password toggles

  const CustomInputField({
    super.key,
    required this.hintText,
    this.labelText,
    required this.inputType,
    required this.controller,
    this.isPassword = false,
    this.icon,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Get the theme data
    final theme = Theme.of(context);

    // This widget now intelligently uses the theme you already defined.
    // It doesn't need to declare its own colors or borders.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword,
        validator: validator,
        onChanged: onChanged,
        // The text style is now inherited from the theme.
        // No need for a hardcoded `TextStyle`.
        decoration: InputDecoration(
          // Use labelText for better accessibility and floating label behavior
          labelText: labelText ?? hintText,
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffixIcon,
          // All other properties like `fillColor`, `border`, `contentPadding`
          // are automatically applied from the `inputDecorationTheme` in your AppTheme.
          // There is no need to specify them here!
        ),
      ),
    );
  }
}
