import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:look_around_youtube/data/youtube_data.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../data/repository/headless_webview.dart';
import 'music_provider.dart';

// youtube 로그인 상태 확인
final isLoggedInProvider = StateProvider<LoginState>((ref) => LoginState.unknown);
// 보이지 않는 웹뷰
final headlessWebViewProvider = ChangeNotifierProvider<HeadlessWebView>(HeadlessWebView.new);
// 음악 재생 관련
final musicProvider = Provider(Music.new);
final startSecondAtVideoProvider = StateProvider((ref) => 25);
final videoJumpSecondProvider = StateProvider((ref) => 10);
final playerState = StateProvider<PlayerState>((ref) => PlayerState.unknown);
final currentIndex = StateProvider<int?>((ref) => null);
// 읽어온 영상 리스트
final videoListProvider = StateProvider<List<YoutubeVideoData>>((ref) => <YoutubeVideoData>[]);