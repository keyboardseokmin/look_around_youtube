import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/providers.dart';
import '../datasource/remote/scrape_youtube.dart';

class HeadlessWebViewUser {
  late final HeadlessInAppWebView headlessWebView;
  late final InAppWebViewController webViewController;

  final Ref ref;

  HeadlessWebViewUser(this.ref) {
    headlessWebView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        webViewController = controller;
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

  // webView page load 후 로직 처리
  void parseUrlAction(InAppWebViewController controller, Uri? url) async {
    final scrapYoutube = ref.read(scrapYoutubeProvider);

    final type = scrapYoutube.getLoadType(url);
    if (type == null) return;

    switch (type) {
      case LoadUrlType.userInfo:
        final info = await scrapYoutube.parseGetUserInfo(webViewController);
        ref.read(userProvider.notifier).state = UserData(nickname: info[0], id: info[1], photo: info[2]);
        break;
      default:
        break;
    }
  }

  void getUserInfo() {
    ref.read(scrapYoutubeProvider).getUserInfo(webViewController);
  }
}