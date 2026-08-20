import 'package:flutter/foundation.dart';

import '../../repo/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository repository;

  LoginViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      await repository.login(username: username, password: password);

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }
}
