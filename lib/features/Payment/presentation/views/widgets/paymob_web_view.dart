import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows the Paymob hosted checkout. Card / wallet details are entered on
/// Paymob's page, so they never pass through the app or our servers.
class PaymobWebView extends StatefulWidget {
  const PaymobWebView({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.onReturn,
  });

  final String checkoutUrl;

  /// Navigating to a URL starting with this means "the customer finished".
  final String returnUrl;
  final VoidCallback onReturn;

  @override
  State<PaymobWebView> createState() => _PaymobWebViewState();
}

class _PaymobWebViewState extends State<PaymobWebView> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;

  bool _isReturnUrl(String url) => url.startsWith(widget.returnUrl);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              widget.onReturn();
              return NavigationDecision.prevent;
            }
            // Only web pages: no custom schemes / intents.
            final scheme = Uri.tryParse(request.url)?.scheme;
            if (scheme != 'https' && scheme != 'http') return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (_isReturnUrl(url)) widget.onReturn();
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              if (mounted) setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              const Text('Could not load the payment page', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(onPressed: _reload, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress / 100,
            color: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
            minHeight: 3,
          ),
      ],
    );
  }
}
