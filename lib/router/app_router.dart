import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/avukat/screens/home_screen.dart';
import '../features/avukat/screens/case_detail_screen.dart';
import '../features/avukat/screens/case_form_screen.dart';
import '../features/avukat/screens/expense_form_screen.dart';
import '../features/muvekkil/screens/home_screen.dart';
import '../features/muvekkil/screens/case_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../models/case_model.dart';

/// Uygulama genelinde tüm navigasyon işlemlerini yöneten sınıf
class AppRouter {
  /// Giriş ekranına yönlendirir (geri dönüş olmadan)
  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Kayıt ekranına yönlendirir
  static void goToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  /// Avukat ana ekranına yönlendirir (geri dönüş olmadan)
  static void goToAvukatHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AvukatHomeScreen()),
      (route) => false,
    );
  }

  /// Müvekkil ana ekranına yönlendirir (geri dönüş olmadan)
  static void goToMuvekkilHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MuvekkilHomeScreen()),
      (route) => false,
    );
  }

  /// Avukat dosya detay ekranına yönlendirir
  static void goToAvukatCaseDetail(BuildContext context, CaseModel caseModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaseDetailScreen(caseModel: caseModel),
      ),
    );
  }

  /// Müvekkil dosya detay ekranına yönlendirir
  static void goToMuvekkilCaseDetail(BuildContext context, CaseModel caseModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MuvekkilCaseDetailScreen(caseModel: caseModel),
      ),
    );
  }

  /// Dosya ekleme/düzenleme formuna yönlendirir
  static void goToCaseForm(BuildContext context, {String? caseId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaseFormScreen(caseId: caseId),
      ),
    );
  }

  /// Masraf ekleme formuna yönlendirir
  static void goToExpenseForm(BuildContext context, String caseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(caseId: caseId),
      ),
    );
  }

  /// Profil ekranına yönlendirir
  static void goToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}
