import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/datasource/remote/youtube_rest_api.dart';
import '../data/datasource/youtube_channel_data.dart';
import '../injection_container.dart';
import 'bloc.dart';

class HomeBloc implements Bloc {
  final _dio = getIt<Dio>();
  final _youtubeApi = getIt<YoutubeRestApi>();
  final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/youtube',
    ]
  );

  final _currentUserController = StreamController<GoogleSignInAccount?>();
  GoogleSignInAccount? _currentUser;
  Sink<GoogleSignInAccount?> get currentUser => _currentUserController.sink;
  Stream<GoogleSignInAccount?> get currentUserStream => _currentUserController.stream;

  final _videoList = StreamController<List<YoutubeChannelData>>();
  Stream<List<YoutubeChannelData>> get videoListStream => _videoList.stream;

  HomeBloc() {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;
      currentUser.add(account);

      var authHeaders = await account?.authHeaders;
      if (authHeaders != null) {
        _setTokenToHeader(authHeaders);

        _videoList.sink.add(await _youtubeApi.getSubscriptions());
      }
    });

    _googleSignIn.signInSilently();
  }

  @override
  void dispose() {
    _currentUserController.close();
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
}