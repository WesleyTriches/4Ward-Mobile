import 'package:flutter/material.dart';

/// Paleta do 4Ward, espelhando as variáveis CSS do web (app/globals.css).
abstract final class AppColors {
  // Marca
  static const brand50 = Color(0xFFE8F5F6);
  static const brand100 = Color(0xFFCFEAED);
  static const brand500 = Color(0xFF1A8F9C);
  static const brand600 = Color(0xFF0F7B8A);
  static const brand700 = Color(0xFF0C6571);

  // Neutros
  static const ink900 = Color(0xFF0F172A);
  static const ink700 = Color(0xFF334155);
  static const ink600 = Color(0xFF475569);
  static const ink500 = Color(0xFF64748B);
  static const ink400 = Color(0xFF94A3B8);
  static const line = Color(0xFFE2E8F0);
  static const lineSoft = Color(0xFFF1F5F9);
  static const inputBorder = Color(0xFFCBD5E1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF8FAFC);

  // Estados
  static const success50 = Color(0xFFECFDF5);
  static const success500 = Color(0xFF10B981);
  static const success700 = Color(0xFF047857);
  static const danger50 = Color(0xFFFFF1F2);
  static const danger500 = Color(0xFFF43F5E);
  static const danger600 = Color(0xFFE11D48);
  static const danger700 = Color(0xFFBE123C);
  static const warning50 = Color(0xFFFFFBEB);
  static const warning500 = Color(0xFFF59E0B);
  static const warning700 = Color(0xFFB45309);
}
