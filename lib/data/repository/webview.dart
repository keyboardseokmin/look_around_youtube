import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/providers.dart';
import '../datasource/remote/scrape_youtube.dart';

class WebView {
  final Ref ref;

  WebView(this.ref);

  // WebView 관련
  InAppWebViewController? webViewController;
  final URLRequest initUri = URLRequest(url: Uri.parse('https://m.youtube.com/feed/'));
  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      )
  );

  // webView page load 후 로직 처리
  void parseUrlAction(InAppWebViewController controller, Uri url) async {
    final scrapYoutube = ref.read(scrapYoutubeProvider);
    final headlessWebView = ref.read(headlessWebViewProvider);

    final type = scrapYoutube.getLoadType(url);

    if (type == LoadUrlType.signIn) {
      scrapYoutube.parseGoSignInMenu(controller);
    } else if (type == null) {
      scrapYoutube.isLoggedIn(headlessWebView.webViewController);
    }
  }

  void signIn() {
    if (webViewController != null) {
      ref.read(scrapYoutubeProvider).goSignInMenu(webViewController!);
    }
  }
}