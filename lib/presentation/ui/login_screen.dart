import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../data/repository/headless_webview.dart';
import '../../provider/providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(isLoggedInProvider);

    switch(loginState) {
      case LoginState.unknown:
        return const SpinKitWave(
          color: Colors.black87,
          size: 55.0,
        );
      case LoginState.loggedIn:
        return _buildUserScreen(ref);
      case LoginState.loggedOut:
        return _buildLoginScreen(ref);
    }
  }

  Widget _buildUserScreen(WidgetRef ref) {
    final headlessWebView = ref.read(headlessWebViewProvider);

    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(onPressed: () {
                headlessWebView.logOut();
              }, child: const Text('Logout')),
              const Text(''),
              const Text('')
            ])
    );
  }

  Widget _buildLoginScreen(WidgetRef ref) {
    final webView = ref.read(webViewProvider);
    
    return Expanded(
        child: InAppWebView(
          initialOptions: webView.options,
          onWebViewCreated: (controller) {
            webView.webViewController = controller;
            webView.signIn();
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onLoadStop: (controller, url) {
            if (url != null) {
              webView.parseUrlAction(controller, url);
            }
          },
        )
    );
  }
}
