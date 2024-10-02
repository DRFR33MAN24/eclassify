import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackWebView extends StatefulWidget {
  final String authorizationUrl;
  final String reference;
  final Function(String) onSuccess;
  final Function(String) onFailed;
  final Function() onCancel;

  const PaystackWebView({
    Key? key,
    required this.authorizationUrl,
    required this.reference,
    required this.onSuccess,
    required this.onFailed,
    required this.onCancel,
  }) : super(key: key);

  @override
  _PaystackWebViewState createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = request.url;
            if (uri.contains("Completed") ||
                uri.contains("completed") ||
                uri.toLowerCase().contains("success")) {
              widget.onSuccess(widget.reference ?? '');
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close the WebView
              return NavigationDecision.prevent;
            } else if (uri.contains("Failed") || uri.contains("failed")) {
              widget.onFailed(widget.reference ?? '');

              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close the WebView
              return NavigationDecision.prevent;
            } else {
              widget.onCancel();


              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close the WebView
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paystack Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
