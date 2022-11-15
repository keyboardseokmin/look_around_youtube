// import 'dart:async';
//
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//
// import '../data/datasource/remote/scrape_youtube.dart';
// import '../injection_container.dart';
// import '../web_control.dart';
// import 'bloc.dart';
//
// class LoginBloc implements Bloc {
//   final _api = getIt<ScrapYoutube>();
//   final webControl = getIt<WebControl>();
//   // WebView 관련
//   InAppWebViewController? webViewController;
//   final URLRequest initUri = URLRequest(url: Uri.parse('https://m.youtube.com/feed/'));
//   final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//       crossPlatform: InAppWebViewOptions(
//         useShouldOverrideUrlLoading: true,
//         mediaPlaybackRequiresUserGesture: false,
//       ),
//       android: AndroidInAppWebViewOptions(
//         useHybridComposition: true,
//       ),
//       ios: IOSInAppWebViewOptions(
//         allowsInlineMediaPlayback: true,
//       )
//   );
//
//   // webView page load 후 로직 처리
//   void parseUrlAction(InAppWebViewController controller, Uri url) async {
//     final type = _api.getLoadType(url);
//
//     if (type == LoadUrlType.signIn) {
//       _api.parseGoSignInMenu(controller);
//     } else if (type == null) {
//       _api.isLoggedIn(webControl.webViewController);
//     }
//   }
//
//   @override
//   void deactivate() {
//   }
//
//   @override
//   void dispose() {
//   }
// }