import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YoutubeScraping {
  InAppWebViewController? webViewController;
  URLRequest initUri = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  void parseUrlAction(InAppWebViewController controller, Uri? url) {
    switch (url.toString()) {
      case 'https://m.youtube.com/feed/subscriptions':
        goSignInMenu(controller);
        break;
      default:
        break;
    }
  }

  void goSignInMenu(InAppWebViewController controller) async {
    var result = await controller.callAsyncJavaScript(functionBody:
      // 되는 기기가 있고 안되는 기기가 있음
      // "window.document.querySelector('[aria-label=\"Account\"]').click();"
      """
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
          // video list 유무로 로그인 상태 판단
          var elementVideos = window.document.getElementsByClassName('channel-list-sub-menu-avatars');
          if (elementVideos.length < 1) {
            // video 가 하나도 없으면 로그인 진행
            var buttons = window.document.getElementsByClassName('icon-button');
            if (buttons.length > 2) {
              buttons[2].click();
              // 우측 상단 점세개 서브 메뉴
              setTimeout(function() {
                var buttons = window.document.getElementsByClassName('menu-item-button');
                if (buttons.length > 1) {
                  buttons[0].click();
                }
              }, 500);
            }
            resolve(true);
          } else {
            // video 가 있으면 스크래핑 진행
            resolve(false);
          }
        }, 1000);
      });
      await p;
      return p;
      """
    );

    debugPrint('\n\n\n\n\n');
    debugPrint(result.runtimeType.toString());
    debugPrint(result?.value.toString());
  }
}