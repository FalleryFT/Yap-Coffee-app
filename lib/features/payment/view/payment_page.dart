import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../orders/model/order_model.dart';
import '../component/payment_deadline_card.dart';
import '../component/payment_qr_box.dart';
import '../component/payment_status_card.dart';
import '../component/payment_summary_card.dart';
import '../component/payment_ticket_card.dart';
import '../viewmodel/payment_view_model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.order});

  /// Pesanan yang baru dibuat (atau yang belum dibayar dari daftar Pesanan).
  final OrderModel order;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final PaymentViewModel _payment = PaymentViewModel(order: widget.order);

  bool _handledCancel = false;

  @override
  void initState() {
    super.initState();
    _payment.addListener(_onPaymentChanged);
    _payment.start();
  }

  @override
  void dispose() {
    _payment.removeListener(_onPaymentChanged);
    _payment.dispose();
    super.dispose();
  }

  /// Snackbar dan navigasi tetap di halaman; ViewModel hanya memberi tahu keadaannya.
  void _onPaymentChanged() {
    if (!mounted) return;

    final error = _payment.errorMessage;
    if (error != null) {
      _payment.clearError();
      AppNotification.error(context, error);
    }

    if (_payment.cancelled && !_handledCancel) {
      _handledCancel = true;
      AppNotification.warning(context, 'Waktu pembayaran habis');
      Navigator.of(context).pop();
    }
  }

  void _onBack() {
    if (_payment.paid) {
      // Setelah sukses, kembali ke halaman awal (Home)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _payment,
      builder: (context, _) => Scaffold(
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
          // Nama outlet dari pengaturan admin; 'Yap Coffee' selama belum termuat.
          title: Text(
            _payment.storeName,
            style: const TextStyle(
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
          child: _payment.paid ? _buildSuccess() : _buildPending(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- Menunggu

  Widget _buildPending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentDeadlineCard(timerText: _payment.timerText),
        const SizedBox(height: 24),
        PaymentTicketCard(
          queueNumber: _payment.order.id,
          customerName: _payment.customerName,
          child: const PaymentQrBox(),
        ),
        const SizedBox(height: 24),
        Center(child: _buildDownloadButton()),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: _payment.orderLines),
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
        onPressed: _payment.paying ? null : _payment.pay,
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
            Text('Bayar (Simulasi)'),
            SizedBox(width: 10),
            Icon(Icons.qr_code_2_rounded, size: 16),
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
          queueNumber: _payment.order.id,
          customerName: _payment.customerName,
          child: _buildSuccessImage(),
        ),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: _payment.orderLines),
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
