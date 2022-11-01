import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'data/datasource/remote/youtube_scraping.dart';
import 'injection_container.dart';

class WebControl {
  late final HeadlessInAppWebView headlessWebView;
  late final InAppWebViewController webViewController;

  WebControl() {
    headlessWebView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        webViewController = controller;
        // controller 사용가능
        _readyToUse.add(true);
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      onLoadStop: (controller, url) {
        parseUrlAction(controller, url);
      },
    );
  }

  final _youtubeScraping = getIt<YoutubeScraping>();

  // webViewController 준비 완료
  final _readyToUse = StreamController<bool>();
  Stream<bool> get readyToUse => _readyToUse.stream;
  // 로그인 상태인지 확인
  final _isLoggedInController = StreamController<bool>.broadcast();
  Stream<bool> get isLoggedInStream => _isLoggedInController.stream;
  // 구독 video list 불러오기
  final _videoList = StreamController<List>();

  // webView page load 후 로직 처리
  void parseUrlAction(InAppWebViewController controller, Uri? url) async {
    final type = _youtubeScraping.getLoadType(url);
    if (type == null) return;

    switch (type) {
      case LoadUrlType.isLogin:
        _isLoggedInController.add(await _youtubeScraping.parseIsLoggedIn(webViewController));
        break;
      case LoadUrlType.signIn:
        break;
      case LoadUrlType.listOfVideo:
        final test = await _youtubeScraping.parseGetListOfVideo(webViewController);
        break;
      case LoadUrlType.userInfo:
        break;
      case LoadUrlType.logOut:
        _isLoggedInController.add(false);
        break;
    }
  }
}