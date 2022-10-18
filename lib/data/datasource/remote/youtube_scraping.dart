import 'package:flutter/cupertino.dart';

class YoutubeScraping {
  goSignInMenu(InAppWebViewController controller) async {
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
      
      return await p;
      """
    );

    return result?.value;
  }

  getListOfVideo(InAppWebViewController controller) async {
    var result = await controller.callAsyncJavaScript(functionBody:
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