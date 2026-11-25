import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/external_links.dart';
import '../model/snap_session.dart';

/// Halaman pembayaran bawaan Midtrans (Snap) di dalam WebView.
///
/// Ditutup dengan `true` bila Midtrans mengarahkan ke finish URL (pelanggan selesai
/// atau memilih metode yang menunggu pembayaran), dan `false`/null bila ditutup manual.
/// Hasil sebenarnya (lunas atau tidak) tidak dibaca dari URL, tetapi dari server.
class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({super.key, required this.session});

  final SnapSession session;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.session.redirectUrl));
  }

  bool _isFinishUrl(Uri uri) {
    final finish = Uri.tryParse(widget.session.finishUrl);
    if (finish == null) return false;
    return uri.host == finish.host && uri.path == finish.path;
  }

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) async {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;

    if (_isFinishUrl(uri)) {
      _close(true);
      return NavigationDecision.prevent;
    }

    // Aplikasi e-wallet (GoPay, ShopeePay, dll.) dibuka lewat skema khusus, bukan http.
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      await openExternalUrl(request.url);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _close(bool finished) {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop(finished);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.espresso),
          onPressed: () => _close(false),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: AppColors.espresso,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress < 100
              ? LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  color: AppColors.espresso,
                  backgroundColor: AppColors.cardLine,
                )
              : const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
        ),
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
