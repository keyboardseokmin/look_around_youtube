
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:look_around_youtube/presentation/ui/login_screen.dart';
import 'package:look_around_youtube/presentation/ui/music_screen.dart';

import '../../data/repository/headless_webview.dart';
import '../../provider/providers.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(isLoggedInProvider);

    switch(loginState) {
      case LoginState.unknown:
        return const SpinKitWave(
          color: Colors.black87,
          size: 55.0,
        );
      case LoginState.loggedIn:
        return const MusicScreen();
      case LoginState.loggedOut:
        return const LoginScreen();
    }
  }
}