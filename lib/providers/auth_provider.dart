import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _loading = false;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get isLoggedIn => _profile != null;
  bool get isLawyer => _profile?.isLawyer ?? false;

  void setProfile(UserProfile? profile) {
    _profile = profile;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
