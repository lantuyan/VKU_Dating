import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomWebView extends StatefulWidget {
  final String selectedUrl;

  const CustomWebView({super.key, required this.selectedUrl});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");

    var endparam = params[1].split("&");

    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(widget.selectedUrl)),
      onLoadStop: (c, url) {
        if (kDebugMode) {
          print(url);
        }
        if (url.toString().contains("#access_token")) {
          succeed(url.toString());
        }

        if (url.toString().contains(
            "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
          denied();
        }
      },
    );
  }
}
