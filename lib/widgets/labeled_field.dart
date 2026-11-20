import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// Campo de texto com o rótulo acima, como nos formulários do web.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.autofillHints,
    this.readOnly = false,
    this.onTap,
    this.onSubmitted,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.ink700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          autofillHints: autofillHints,
          readOnly: readOnly,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: AppColors.ink900),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
