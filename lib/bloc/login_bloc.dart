import 'dart:async';

import 'bloc.dart';

class LoginBloc implements Bloc {

  late final StreamController<bool> _isLoginController;
  Stream<bool> get isLoginStream => _isLoginController.stream;

  @override
  void deactivate() {
  }

  @override
  void dispose() {
  }
}