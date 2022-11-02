import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:look_around_youtube/bloc/bloc_provider.dart';
import 'package:look_around_youtube/bloc/home_bloc.dart';
import 'package:look_around_youtube/bloc/login_bloc.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_scraping.dart';
import 'package:look_around_youtube/injection_container.dart';
import 'package:look_around_youtube/ui/home_screen.dart';
import 'package:look_around_youtube/web_control.dart';
import 'package:page_transition/page_transition.dart';

import 'login_screen.dart';
import 'navigation_screen.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    final webControl = getIt<WebControl>();
    final api = getIt<YoutubeScraping>();

    if (!webControl.headlessWebView.isRunning()) {
      webControl.headlessWebView.run();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: Text("Look Around Youtube")),
            Center(child:
              StreamBuilder<bool>(
                stream: webControl.readyToUse,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    api.isLoggedIn(webControl.webViewController);
                  }

                  return StreamBuilder<bool>(
                    stream: webControl.isLoggedInStream,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        // 영상 리스트 화면으로
                        _moveToBottomTabScreen(context, 0);
                        return Container();
                      } else if (snapshot.data == false) {
                        // login 화면으로
                        _moveToBottomTabScreen(context, 1);
                        return Container();
                      } else {
                        return const SpinKitWave(
                          color: Colors.black87,
                          size: 50.0,
                        );
                      }
                    }
                  );
                },
              )
            )
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