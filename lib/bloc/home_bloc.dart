import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_scraping.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../data/datasource/remote/youtube_rest_api.dart';
import '../data/datasource/youtube_data.dart';
import '../injection_container.dart';
import 'bloc.dart';

class HomeBloc implements Bloc {
  final _dio = getIt<Dio>();
  final _youtubeApi = getIt<YoutubeRestApi>();
  final _youtubeScraping = getIt<YoutubeScraping>();

  final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/youtube',
    ]
  );
  final youtubeUrlPrefix = "https://youtube.com/watch?v=";
  final youtubeVideoList = <YoutubeVideoData>[];

  // Youtube Player 관련
  final YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId: '',
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      enableCaption: false,
    ),
  );

  final _showYoutubeVideo = StreamController<bool>();
  Stream<bool> get showYoutubeVideoStream => _showYoutubeVideo.stream;

  final _currentUserController = StreamController<GoogleSignInAccount?>();
  GoogleSignInAccount? _currentUser;
  Sink<GoogleSignInAccount?> get currentUser => _currentUserController.sink;
  Stream<GoogleSignInAccount?> get currentUserStream => _currentUserController.stream;

  final _videoList = StreamController<List<YoutubeChannelData>>();
  Stream<List<YoutubeChannelData>> get videoListStream => _videoList.stream;

  HomeBloc() {
    // _googleSignIn.onCurrentUserChanged.listen((account) async {
    //   _currentUser = account;
    //   currentUser.add(account);
    //
    //   var authHeaders = await account?.authHeaders;
    //   if (authHeaders != null) {
    //     _setTokenToHeader(authHeaders);
    //     // _videoList.sink.add(await _youtubeApi.getSubscriptions());
    //
    //     loadData();
    //   }
    // });

    // _googleSignIn.signInSilently();
  }

  @override
  void deactivate() {
    controller.pause();
  }

  @override
  void dispose() {
    controller.dispose();
    _currentUserController.close();
  }

  void loadData() async {
    final videoSubscriptions = await _youtubeApi.getSubscriptions();
    if (videoSubscriptions.isEmpty) return;
    final channels = getNewVideoCountInChannel(videoSubscriptions);

    final videos = <YoutubeVideoData>[];
    for (final channel in channels) {
      videos.addAll(await _youtubeApi.getNewVideos(channel.channelId, channel.newItemCount));
    }

    youtubeVideoList.clear();
    youtubeVideoList.addAll(videos);
    controller.load(youtubeVideoList.first.videoId);

    _showYoutubeVideo.sink.add(true);
  }

  void _setTokenToHeader(Map<String, String> test) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // 헤더에 토큰 추가
      options.headers.addAll(test);
      return handler.next(options);
    }, onError: (error, handler) async {
      // 인증 오류: AccessToken 만료
      if (error.response?.statusCode == ResponseCodeYoutube.tokenFired.intValue) {
        // RefreshToken 을 이용해서 AccessToken 을 다시 받아와야하지만
        // 라이브러리 지원이 안되므로 logout 후 silently login 처리
        _dio.interceptors.clear();
        await _googleSignIn.signOut();
        await _googleSignIn.signInSilently();
      }

      return handler.next(error);
    }));
  }

  void googleSignIn() => _googleSignIn.signIn();
  void googleSignOut() => _googleSignIn.signOut();
  bool isEmptyCurrentUser() => _currentUser == null;
  Future getSubscriptions() => _youtubeApi.getSubscriptions();

  List<YoutubeChannelData> getNewVideoCountInChannel(List<YoutubeChannelData> subscribeChannels) {
    final hasNewVideoChannels = <YoutubeChannelData>[];

    for (var channel in subscribeChannels) {
      if (channel.newItemCount > 0) {
        hasNewVideoChannels.add(channel);
      }
    }

    return hasNewVideoChannels;
  }
}