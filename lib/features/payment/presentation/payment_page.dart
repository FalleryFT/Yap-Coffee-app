import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../cart/data/cart_manager.dart';
import '../component/payment_deadline_card.dart';
import '../component/payment_qr_box.dart';
import '../component/payment_status_card.dart';
import '../component/payment_summary_card.dart';
import '../component/payment_ticket_card.dart';

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
        AppNotification.warning(context, 'Waktu pembayaran habis');
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
        PaymentDeadlineCard(timerText: _timerText),
        const SizedBox(height: 24),
        PaymentTicketCard(
          queueNumber: _queueNumber,
          customerName: _customerName,
          child: const PaymentQrBox(),
        ),
        const SizedBox(height: 24),
        Center(child: _buildDownloadButton()),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: widget.orderLines),
      ],
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        const PaymentStatusCard(),
        const SizedBox(height: 24),
        PaymentTicketCard(
          queueNumber: _queueNumber,
          customerName: _customerName,
          child: _buildSuccessImage(),
        ),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: widget.orderLines),
      ],
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
      child: Image.asset(
        'assets/images/Untitled.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/Untitled.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/payment_success.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
