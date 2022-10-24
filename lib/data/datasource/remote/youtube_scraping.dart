import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum LoadUrlType { isLogin, signIn, listOfVideo, userInfo }

class YoutubeScraping {
  final Map<String, LoadUrlType> _loadUrlType = {};
  void loadUrlWrapping(InAppWebViewController controller, URLRequest urlRequest, LoadUrlType type) {
    _loadUrlType[urlRequest.url.toString()] = type;
    controller.loadUrl(urlRequest: urlRequest);
  }

  LoadUrlType? getLoadType(Uri? url) {
    var urlString = url.toString();
    if (urlString[urlString.length - 1] != '/') {
      urlString = '$urlString/';
    }
    final type = _loadUrlType[urlString];
    _loadUrlType.remove(urlString);
    return type;
  }

  void isLoggedIn(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    loadUrlWrapping(controller, url, LoadUrlType.isLogin);
  }

  Future<bool> parseIsLoggedIn(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
    """
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
          // video list 유무로 로그인 상태 판단
          var elementVideos = window.document.getElementsByClassName('channel-list-sub-menu-avatars');
          if (elementVideos.length < 1) {
            // video 가 하나도 없으면 로그인 진행
            resolve(false);
          } else {
            // video 가 있으면 스크래핑 진행
            resolve(true);
          }
        }, 1000);
      });
      
      return await p;
      """
    );

    return result?.value;
  }

  void goSignInMenu(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    loadUrlWrapping(controller, url, LoadUrlType.signIn);
  }

  parseGoSignInMenu(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
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
      
      return await p;
      """
    );

    return result?.value;
  }

  void getListOfVideo(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    loadUrlWrapping(controller, url, LoadUrlType.listOfVideo);
  }

  parseGetListOfVideo(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
      """
        var elements = window.document.getElementsByClassName('item');
        var metadata = [];
        
        for (i=0; i < elements.length; i++) {
          var elementTitle = elements[i].getElementsByClassName('media-item-headline');
          var title = "";
          if (elementTitle.length > 0) {
            title = elementTitle[0].textContent;
          }
          
          var info = elements[i].getElementsByClassName('ytm-badge-and-byline-item-byline');
          var channel = "";
          var createAt = "";
          if (info.length > 2) {
            channel = info[0].textContent;
            createAt = info[2].textContent;
          }
          
          var elementLink = elements[i].getElementsByClassName('media-item-thumbnail-container');
          var link = "";
          if (elementLink.length > 0) {
            link = elementLink[0].href;
          }
          
          metadata.push([title, channel, createAt, link]);
        }
        
        return metadata;
      """
    );

    return result?.value;
  }

  void getUserInfo(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/library/'));
    loadUrlWrapping(controller, url, LoadUrlType.userInfo);
  }

  parseGetUserInfo(InAppWebViewController controller) async {

    final result = await controller.callAsyncJavaScript(functionBody:
      """
      var buttons = window.document.getElementsByClassName('topbar-menu-button-avatar-button');
      if (buttons.length > 1) {
        buttons[1].click();
        
        var p = new Promise(function(resolve, reject) {
          setTimeout(function() {
            var accountButton = window.document.getElementsByClassName('active-account-name');
            if (accountButton.length > 0) {
              accountButton[0].click();
              
              setTimeout(function() {
                var info = window.document.getElementsByClassName('google-account-header-renderer');
                if (info.length > 0) {
                  var dived = info[0].getElementsByTagName('div');
                  if (dived.length > 1) {
                    resolve([dived[0].textContent, dived[1].textContent]);
                  } else if (dived.length > 0) {
                    resolve([dived[0].textContent, ""]);
                  }
                }
              }, 1000);
            }
          }, 500);
        });
        
        return await p;
      }
      """
    );

    return result?.value;
  }

  void moveScrollToEnd(InAppWebViewController controller) async {
    final result = await controller.evaluateJavascript(source:
      """
      var result = window.document.querySelector('.page-container').offsetHeight;
      
      return 1;
      """
    );

    debugPrint('');
  }
}