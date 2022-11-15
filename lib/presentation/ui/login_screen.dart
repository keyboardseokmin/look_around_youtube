//
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:look_around_youtube/bloc/login_bloc.dart';
//
// import '../bloc/bloc_provider.dart';
// import '../data/datasource/remote/scrape_youtube.dart';
// import '../web_control.dart';
//
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bloc = BlocProvider.of<LoginBloc>(context);
//
//     api.isLoggedIn(webControl.webViewController);
//
//     return Scaffold(
//       body: SafeArea(
//         child: StreamBuilder<bool>(
//           stream: webControl.isLoggedInStream,
//           builder: (context, snapshot) {
//             if (snapshot.data == false) {
//               // 로그아웃 상태로 로그인 웹뷰 표시
//               return Expanded(
//                 child: InAppWebView(
//                   initialOptions: bloc.options,
//                   onWebViewCreated: (controller) {
//                     bloc.webViewController = controller;
//                     api.goSignInMenu(controller);
//                   },
//                   androidOnPermissionRequest: (controller, origin, resources) async {
//                     return PermissionRequestResponse(
//                       resources: resources,
//                       action: PermissionRequestResponseAction.GRANT);
//                   },
//                   onLoadStop: (controller, url) {
//                     if (url != null) {
//                       bloc.parseUrlAction(controller, url);
//                     }
//                   },
//                 )
//               );
//             } else if (snapshot.data == true) {
//               // 로그인 상태로 각종 정보 및 로그아웃 버튼 표시
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     OutlinedButton(onPressed: () {
//                       api.logOut(webControl.webViewController);
//                     }, child: const Text('Logout')),
//                     const Text(''),
//                     const Text('')
//                   ])
//               );
//             } else {
//               return const SpinKitWave(
//                 color: Colors.black87,
//                 size: 55.0,
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
