import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webView = ref.read(webViewProvider);

    return SafeArea(
      child: Expanded(
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
      ),
    );
  }
}
