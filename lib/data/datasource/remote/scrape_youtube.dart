import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scrapYoutubeProvider = Provider((ref) => ScrapYoutube());

enum LoadUrlType { isLogin, signIn, logOut, listOfVideo, userInfo, subscribeList }

class ScrapYoutube {
  final Map<String, LoadUrlType> _loadUrlType = {};
  final _loggedOutUrl = 'https://m.youtube.com/?noapp=1/';

  // loadUrl 시 어떤 타입의 call 인지 저장
  void wrapperLoadUrl(InAppWebViewController controller, URLRequest urlRequest, LoadUrlType type) {
    // logout 시 google account 페이지로 접속
    if (type == LoadUrlType.logOut) {
      _loadUrlType[_loggedOutUrl] = type;
    } else {
      _loadUrlType[urlRequest.url.toString()] = type;
    }
    controller.loadUrl(urlRequest: urlRequest);
  }

  // 해당 url call 타입 확인
  LoadUrlType? getLoadType(Uri? url) {
    var urlString = url.toString();
    if (urlString[urlString.length - 1] != '/') {
      urlString = '$urlString/';
    }

    return _loadUrlType.remove(urlString);
  }

  // 사용하는 곳이 없는 레거시 코드, 혹시 몰라서 남겨둠
  // 로그인 상태면 false 로그아웃 상태면 로그인 화면 이동 후 true
  void isLoginAndSignIn(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    wrapperLoadUrl(controller, url, LoadUrlType.signIn);
  }
  Future<bool> parseIsLoginAndSignIn(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
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

  // 로그인 상태 확인
  void isLoggedIn(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    wrapperLoadUrl(controller, url, LoadUrlType.isLogin);
  }
  Future<bool> parseIsLoggedIn(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
      """
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
          // video list 유무로 로그인 상태 판단
          var elementVideos = window.document.getElementsByClassName('channel-list-sub-menu-avatars');
          if (elementVideos.length < 1) {
            // video 가 하나도 없으면 비로그인 상태
            resolve(false);
          } else {
            // video 가 있으면 로그인 상태
            resolve(true);
          }
        }, 1000);
      });
      
      return await p;
      """
    );

    return result?.value;
  }

  // 로그인 메뉴로 이동
  void goSignInMenu(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/'));
    wrapperLoadUrl(controller, url, LoadUrlType.signIn);
  }
  void parseGoSignInMenu(InAppWebViewController controller) async {
    await controller.callAsyncJavaScript(functionBody:
      """
        var buttons = window.document.getElementsByClassName('icon-button');
        if (buttons.length > 2) {
          buttons[2].click();
          // 우측 상단 점세개 서브 메뉴
          setTimeout(function() {
            var buttons = window.document.getElementsByClassName('compact-link-endpoint');
            if (buttons.length > 0) {
              buttons[0].click();
            }
          }, 750);
        }
      """
    );
  }

  // 로그아웃
  void logOut(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/logout/'));
    wrapperLoadUrl(controller, url, LoadUrlType.logOut);
  }

  // 스크롤 높이 반환
  Future<int> getScrollHeight(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
    """
      // var element = window.document.getElementById('app');
      // return element.scrollHeight;
      return document.body.scrollHeight;
    """
    );

    return result?.value;
  }

  // 스크롤 바텀으로
  Future<int> moveToScrollBottom(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
    """
      window.scrollTo(0, document.body.scrollHeight);

      // var p = new Promise(function(resolve, reject) {
      //   setTimeout(function() {
      //     var elements = window.document.getElementsByClassName('item');
      //     resolve(elements.length);
      //   }, 5000);
      // });
      
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
          resolve(document.body.scrollHeight);
        }, 5000);
      });
      
      return await p;
    """
    );

    return result?.value;
  }

  // pagination load
  Future<List<dynamic>> loadPagination(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
    """
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
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
            resolve(metadata);
          }
        }, 1000);
      });
      
      return await p;
    """
    );

    return result?.value;
  }

  // 비디오 리스트 가져오기
  void getListOfVideo(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/subscriptions/'));
    wrapperLoadUrl(controller, url, LoadUrlType.listOfVideo);
  }
  Future<List<dynamic>> parseGetListOfVideo(InAppWebViewController controller) async {
    sleep(const Duration(seconds: 2));
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

  // 유저 정보 가져오기
  void getUserInfo(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/library/'));
    wrapperLoadUrl(controller, url, LoadUrlType.userInfo);
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
                var tempPhoto1 = window.document.getElementsByClassName('account-item-icon');
                var photoUrl = "";
                if (tempPhoto1.length > 0) {
                  var tempPhoto2 = tempPhoto1[0].getElementsByTagName('img');
                  if (tempPhoto2.length > 0) {
                    photoUrl = tempPhoto2[0].src;
                  }
                }
                if (info.length > 0) {
                  var dived = info[0].getElementsByTagName('div');
                  if (dived.length > 1) {
                    resolve([dived[0].textContent, dived[1].textContent, photoUrl]);
                  } else if (dived.length > 0) {
                    resolve([dived[0].textContent, "", photoUrl]);
                  }
                }
              }, 1000);
            }
          }, 1000);
        });
        
        return await p;
      }
      """
    );

    return result?.value;
  }

  // 구독 목록 가져오기
  void getSubscribeList(InAppWebViewController controller) {
    var url = URLRequest(url: Uri.parse('https://m.youtube.com/feed/channels/'));
    wrapperLoadUrl(controller, url, LoadUrlType.subscribeList);
  }
  Future<List<dynamic>> parseGetSubscribeList(InAppWebViewController controller) async {
    final result = await controller.callAsyncJavaScript(functionBody:
      """
      var p = new Promise(function(resolve, reject) {
        setTimeout(function() {
          var titles = window.document.getElementsByClassName('channel-list-item-title');
          var titlesStr = [];
          for (i=0; i < titles.length; i++) {
            titlesStr.push(titles[i].textContent);
          }
          
          resolve(titlesStr);
        }, 1000);
      });
      
      return await p;
      """
    );

    return result?.value;
  }
}