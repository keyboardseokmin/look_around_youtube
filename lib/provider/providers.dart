import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/data/youtube_data.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../data/repository/headless_webview.dart';
import '../data/repository/webview.dart';
import 'music_provider.dart';

// 보이는 웹뷰
final webViewProvider = Provider<WebView>(WebView.new);
// 보이지 않는 웹뷰
final headlessWebViewProvider = ChangeNotifierProvider<HeadlessWebView>(HeadlessWebView.new);
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