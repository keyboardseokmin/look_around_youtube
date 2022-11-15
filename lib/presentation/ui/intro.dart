import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/data/repository/headless_webview.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import '../../provider/providers.dart';
import 'navigation_screen.dart';


class Intro extends ConsumerWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 이동 listen
    ref.listen(isLoggedInProvider, (previous, next) {
      switch (next) {
        case LoginState.unknown:
          break;
        case LoginState.loggedIn:
          _moveToBottomTabScreen(context, 0);
          break;
        case LoginState.loggedOut:
          _moveToBottomTabScreen(context, 1);
          break;
      }
    });
    // 웹뷰 동작 중이 아니면 시작
    final headlessWebView = ref.read(headlessWebViewProvider);
    if (!headlessWebView.headlessWebView.isRunning()) {
      headlessWebView.headlessWebView.run();
    }
    // 사용 가능할때 login 상태 체크
    ref.listen<HeadlessWebView>(headlessWebViewProvider, (previous, next) {
      if (next.readyToWork) {
        headlessWebView.isLoggedIn();
      }
    });
    // lottie size 결정
    final screenSize = MediaQuery.of(context).size;
    final lottieSize = (screenSize.width > screenSize.height ? screenSize.height : screenSize.width) / 1.5;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(child:
              Lottie.asset(
                'assets/lottie/dancing_note.json',
                width: lottieSize,
                height: lottieSize,
                fit: BoxFit.fill
              )
            ),
          ],
        ),
      ),
    );
  }

  void _moveToBottomTabScreen(BuildContext context, int initialIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: NavigationScreen(initialIndex: initialIndex)
        )
      );
    });
  }
}