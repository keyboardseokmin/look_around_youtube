import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:look_around_youtube/data/datasource/remote/youtube_rest_api.dart';
import 'package:look_around_youtube/ui/app_colors.dart';
import 'injection_container.dart' as ic;


final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'https://www.googleapis.com/auth/youtube',
  ]
);

void main() async {
  ic.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w700BitterFont = GoogleFonts.bitter(
      fontWeight: FontWeight.w700,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Look around Youtube',
      theme: ThemeData(
        primarySwatch: AppColors.black,
        primaryColor: AppColors.black,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          secondary: AppColors.green,
          primary: AppColors.black,
        ),
        scaffoldBackgroundColor: AppColors.grey,
        backgroundColor: AppColors.grey,
        primaryTextTheme: TextTheme(
          headline6: w700BitterFont,
        ),
        textTheme: TextTheme(
          subtitle1: w700BitterFont.apply(color: AppColors.black),
          headline6: w700BitterFont.apply(color: AppColors.black),
          bodyText2: TextStyle(color: AppColors.black),
        ),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: IDButton()),
                Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: OutlinedButton(onPressed: () {}, child: const Text('Settings'))),
              ],
            ),
            const VideoList(),
          ],
        ),
      ),
    );
  }
}

class IDButton extends StatefulWidget {
  const IDButton({Key? key}) : super(key: key);

  @override
  State<IDButton> createState() => _IDButtonState();
}

class _IDButtonState extends State<IDButton> {
  GoogleSignInAccount? _currentUser;
  final Dio _dio = ic.getIt<Dio>();

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((account) async {
      setState(() {
        _currentUser = account;
      });

      var authHeaders = await account?.authHeaders;
      if (authHeaders != null) {
        setTokenToHeader(authHeaders);
      }
    });

    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          if (_currentUser == null) {
            await _googleSignIn.signIn();
          } else {
            _googleSignIn.signOut();
          }
        },
        child: (_currentUser == null)?
        const Text("SignIn Youtube"):
        Text(_currentUser!.email)
    );
  }

  void setTokenToHeader(Map<String, String> test) {
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
}

class VideoList extends StatefulWidget {
  const VideoList({Key? key}) : super(key: key);

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final youtubeApi = ic.getIt<YoutubeRestApi>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: youtubeApi.getSubscriptions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            const snackBar = SnackBar(content: Text('에러: 구독 정보를 가져올 수 없습니다'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
          return Container();
        } else if (snapshot.hasData == false) {
          return const CircularProgressIndicator();
        } else {
          return const Text('성공');
        }
      }
    );
  }
}
