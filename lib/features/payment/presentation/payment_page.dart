import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../cart/data/cart_manager.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.orderLines});

  /// Contoh: ['2x Yap Latte', '1x Classic Croissant']
  final List<String> orderLines;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const int _paymentSeconds = 10 * 60;

  // Data dummy
  static const String _queueNumber = '#A-042';
  static const String _customerName = 'Budi Santoso';

  Timer? _timer;
  int _remaining = _paymentSeconds;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _timer?.cancel();
        showAppSnackBar(context, 'Waktu pembayaran habis');
        Navigator.of(context).pop();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Dummy: menekan Download langsung dianggap pembayaran berhasil.
  void _onDownload() {
    _timer?.cancel();
    CartManager.instance.clearCart();
    setState(() => _paid = true);
  }

  void _onBack() {
    if (_paid) {
      // Setelah sukses, kembali ke halaman awal (Home)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
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
          icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
          onPressed: _onBack,
        ),
        title: const Text(
          'Yap Coffee',
          style: TextStyle(
            color: AppColors.espresso,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.cardLine),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: _paid ? _buildSuccess() : _buildPending(),
      ),
    );
  }

  // ------------------------------------------------------------- Menunggu

  Widget _buildPending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDeadlineCard(),
        const SizedBox(height: 24),
        _buildTicketCard(child: _buildQrBox()),
        const SizedBox(height: 24),
        Center(child: _buildDownloadButton()),
        const SizedBox(height: 24),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildDeadlineCard() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 22, color: AppColors.espresso),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'BATAS PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                    color: AppColors.bark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Selesaikan dalam 10 menit',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.buttonDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 15, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  _timerText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrBox() {
    return Container(
      width: 192,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Text(
            'Pengambilan Pesanan',
            style: TextStyle(fontSize: 11, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: CustomPaint(painter: _DummyQrPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: _onDownload,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.buttonDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Download Barcode'),
            SizedBox(width: 10),
            Icon(Icons.file_download_outlined, size: 16),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- Sukses

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Siap Diambil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.espresso,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Pembayaran Sukses',
            style: TextStyle(fontSize: 14, color: AppColors.bark),
          ),
        ),
        const SizedBox(height: 18),
        _buildStatusCard(),
        const SizedBox(height: 24),
        _buildTicketCard(child: _buildSuccessImage()),
        const SizedBox(height: 24),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'pembayaran terselesaikan',
            style: TextStyle(fontSize: 14, color: AppColors.ink),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE8C4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.statusOlive,
                ),
                SizedBox(width: 6),
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.statusOlive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessImage() {
    return Container(
      width: 192,
      height: 192,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      // Simpan gambar stiker di assets/images/payment_success.png
      child: Image.asset(
        'assets/images/payment_success.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.statusOlive,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------- Shared

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardLine),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }

  /// Kartu tiket: strip cokelat di atas, nomor antrean, [center], nama pemesan.
  Widget _buildTicketCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.10),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 9, color: AppColors.chipBrown),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              children: [
                const Text(
                  'NOMOR ANTREAN',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: AppColors.bark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  _queueNumber,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espresso,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),
                child,
                const SizedBox(height: 18),
                const Text(
                  'Pesanan atas nama:',
                  style: TextStyle(fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                const Text(
                  _customerName,
                  style: TextStyle(fontSize: 14, color: AppColors.mocha),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: 12),
          for (final line in widget.orderLines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                line,
                style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
              ),
            ),
        ],
      ),
    );
  }
}

/// QR dummy (bukan kode asli): tiga penanda sudut + pola acak yang tetap.
class _DummyQrPainter extends CustomPainter {
  static const int _cells = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _cells;
    final paint = Paint()..color = AppColors.ink;
    final rnd = Random(42);

    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) ||
        (x >= _cells - 8 && y < 8) ||
        (x < 8 && y >= _cells - 8);

    for (int y = 0; y < _cells; y++) {
      for (int x = 0; x < _cells; x++) {
        if (inFinder(x, y)) continue;
        if (rnd.nextDouble() < 0.5) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            paint,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(
        Rect.fromLTWH(o.dx, o.dy, 7 * cell, 7 * cell),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + cell, o.dy + cell, 5 * cell, 5 * cell),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + 2 * cell, o.dy + 2 * cell, 3 * cell, 3 * cell),
        paint,
      );
    }

    finder(0, 0);
    finder(_cells - 7, 0);
    finder(0, _cells - 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}