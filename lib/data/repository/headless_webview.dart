import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/data/datasource/remote/scrape_youtube.dart';

import '../../provider/providers.dart';
import '../youtube_data.dart';

enum LoginState {unknown, loggedIn, loggedOut}

class HeadlessWebView extends ChangeNotifier {
  late final HeadlessInAppWebView headlessWebView;
  late final InAppWebViewController webViewController;

  final Ref ref;
  bool readyToWork = false;
  final youtubeUrlPrefix = "watch?v=";

  HeadlessWebView(this.ref) {
    headlessWebView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        webViewController = controller;
        // controller 사용가능
        readyToWork = true;
        notifyListeners();
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
      case LoadUrlType.isLogin:
        final result = await scrapYoutube.parseIsLoggedIn(webViewController);
        ref.read(isLoggedInProvider.notifier).state = result? LoginState.loggedIn: LoginState.loggedOut;
        break;
      case LoadUrlType.listOfVideo:
        final lists = await scrapYoutube.parseGetListOfVideo(webViewController);

        // 페이지 높이 초기화
        final scrollHeight = await scrapYoutube.getScrollHeight(webViewController);
        ref.read(paginationScrollHeight.notifier).update((state) => scrollHeight);

        ref.read(videoListProvider.notifier).state = _getListOfYoutubeVideo(lists);
        // 페이지가 더 있다는 뜻
        if (lists.length > 15 ) {
          await startPagination();
        }
        break;
      case LoadUrlType.logOut:
        ref.read(isLoggedInProvider.notifier).state = LoginState.loggedOut;
        break;
      default:
        break;
    }
  }

  List<YoutubeVideoData> _getListOfYoutubeVideo(List<dynamic> list) {
    final result = <YoutubeVideoData>[];
    for (final video in list) {
      if (video is List) {
        if (video.length > 3) {
          // 유튜브 영상이 아니라 shorts 는 걸러냄, 향후 player 버전에서 지원할 가능성 있음
          if (!video[3].toString().contains(youtubeUrlPrefix)) continue;
          // 실시간 방송은 스크래핑에서 info.length 가 2라서 채널과 시간값이 0이 들어감
          if (video[1] == "" && video[2] == "") continue;
          result.add(YoutubeVideoData(
            key: GlobalKey(),
            title: video[0],
            channel: video[1],
            publishedAt: video[2],
            videoUrl: video[3]
          ));
        }
      }
    }
    return result;
  }

  Future<void> startPagination() async {
    final scrollHeight = await ref.read(scrapYoutubeProvider).moveToScrollBottom(webViewController);
    final lists = await ref.read(scrapYoutubeProvider).loadPagination(webViewController);

    // 페이지 높이 초기화
    ref.read(paginationScrollHeight.notifier).update((state) => scrollHeight);
    ref.read(videoListProvider.notifier).state = _getListOfYoutubeVideo(lists);

    // 페이지네이션 끝
    ref.read(doingPagination.notifier).update((state) => false);
    ref.read(showBottomIndicator.notifier).update((state) => false);
  }

  void isLoggedIn() {
    ref.read(scrapYoutubeProvider).isLoggedIn(webViewController);
  }

  void getListOfVideo() {
    ref.read(scrapYoutubeProvider).getListOfVideo(webViewController);
  }

  void logOut() {
    ref.read(scrapYoutubeProvider).logOut(webViewController);
  }

  void moveToScrollBottom() async {
    await ref.read(scrapYoutubeProvider).moveToScrollBottom(webViewController);
  }
}