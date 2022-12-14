import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/data/youtube_data.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../data/datasource/local/subscribe_data_wrapper.dart';
import '../data/datasource/local/subscribes_data_source.dart';
import '../data/repository/headless_webview.dart';
import '../data/repository/headless_webview_user.dart';
import '../data/repository/webview.dart';
import 'music_provider.dart';

// 보이는 웹뷰
final webViewProvider = Provider<WebView>(WebView.new);
// 보이지 않는 웹뷰
final headlessWebViewProvider = ChangeNotifierProvider<HeadlessWebView>(HeadlessWebView.new);
final headlessWebViewUserProvider = Provider<HeadlessWebViewUser>(HeadlessWebViewUser.new);
// youtube 로그인 상태 확인
final isLoggedInProvider = StateProvider<LoginState>((ref) => LoginState.unknown);
// 음악 재생 관련
final musicProvider = Provider(Music.new);
final startSecondAtVideoProvider = StateProvider((ref) => 25);
final videoJumpSecondProvider = StateProvider((ref) => 10);
final playerStateProvider = StateProvider<PlayerState>((ref) => PlayerState.unknown);
final currentIndexProvider = StateProvider<int?>((ref) => null);
// 읽어온 영상 리스트
final videoListProvider = StateProvider<List<YoutubeVideoData>>((ref) => <YoutubeVideoData>[]);
// 유저 정보
final userProvider = StateProvider<UserData>((ref) => UserData(nickname: '', id: '', photo: ''));
// 뒤로가기 제어
final backKeyPressed = StateProvider<bool>((ref) => false);
// 바텀버튼 확장
final isOptionShowed = StateProvider<bool>((ref) => false);
// 구독 리스트 hive
final subscribeDataSource = Provider<SubscribeDataSource>(SubscribeDataSource.new);
// 구독 리스트
final subscribeList = StateProvider<List<SubscribeDataWrapper>>((ref) => <SubscribeDataWrapper>[]);
// 필터 된 영상 리스트
final filteredVideoList = StateProvider<List<YoutubeVideoData>>((ref) {
  final checked = ref.watch(subscribeList)
      .where((element) => !element.check)
      .map((e) => e.name);
  final filteredList = ref.watch(videoListProvider)
      .where((element) => checked.contains(element.channel));
  return List<YoutubeVideoData>.from(filteredList);
});
// 페이지네이션 인디케이터
final showBottomIndicator = StateProvider<bool>((ref) => false);
// 페이지네이션 끝
final isEndOfPage = StateProvider<bool>((ref) => false);
// 페이지네이션 할지 결정할 스크롤 높이
final paginationScrollHeight = StateProvider<int>((ref) => 0);
// 페이지네이션 동작 중
final doingPagination = StateProvider<bool>((ref) => false);

class UserData {
  late final String nickname;
  late final String id;
  late final String photo;

  UserData({required this.nickname, required this.id, required this.photo});

  bool isEmpty() {
    if (nickname == "" && id == "" && photo == "") {
      return true;
    }
    return false;
  }
}