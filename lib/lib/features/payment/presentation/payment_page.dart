import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/data/home_store.dart';
import '../../orders/data/order_model.dart';
import '../../orders/data/order_store.dart';
import '../component/payment_deadline_card.dart';
import '../component/payment_qr_box.dart';
import '../component/payment_status_card.dart';
import '../component/payment_summary_card.dart';
import '../component/payment_ticket_card.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.order});

  /// Pesanan yang baru dibuat (atau yang belum dibayar dari daftar Pesanan).
  final OrderModel order;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Duration _pollInterval = Duration(seconds: 5);

  final OrderRepository _repository = OrderStore.instance.repository;

  late OrderModel _order = widget.order;

  /// Batas bayar dihitung dari sisa waktu menurut server, bukan dari jam perangkat.
  late DateTime _deadline =
      DateTime.now().add(Duration(seconds: widget.order.paymentSecondsLeft));

  String _customerName = '';
  Timer? _timer;
  Timer? _poller;
  bool _paying = false;
  bool _refreshing = false;

  bool get _paid =>
      _order.status != OrderStatus.belumDibayar &&
      _order.status != OrderStatus.dibatalkan;

  int get _remaining {
    final seconds = _deadline.difference(DateTime.now()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  @override
  void initState() {
    super.initState();
    _loadCustomerName();

    if (_paid) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paid) return;
      if (_remaining <= 0) {
        _refresh();
        return;
      }
      setState(() {});
    });
    // Pelunasan lewat penyedia pembayaran terjadi di luar aplikasi, jadi status dicek berkala.
    _poller = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  void _stopTimers() {
    _timer?.cancel();
    _poller?.cancel();
  }

  Future<void> _loadCustomerName() async {
    try {
      final me = await AuthRepository().me();
      if (mounted) setState(() => _customerName = me.name);
    } on ApiException {
      // Nama hanya hiasan tiket; tidak mengganggu pembayaran.
    }
  }

  /// Menyamakan status dan sisa waktu dengan server. Server yang memutuskan lunas atau kedaluwarsa.
  Future<void> _refresh() async {
    if (_refreshing || !mounted) return;
    _refreshing = true;
    try {
      final latest = await _repository.get(_order.id);
      if (!mounted) return;
      _applyOrder(latest);
    } on ApiException {
      // Gangguan jaringan sesaat; coba lagi pada putaran berikutnya.
    } finally {
      _refreshing = false;
    }
  }

  void _applyOrder(OrderModel latest) {
    OrderStore.instance.upsert(latest);

    if (latest.status == OrderStatus.dibatalkan) {
      _stopTimers();
      AppNotification.warning(context, 'Waktu pembayaran habis');
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _order = latest;
      if (latest.status == OrderStatus.belumDibayar) {
        _deadline = DateTime.now().add(Duration(seconds: latest.paymentSecondsLeft));
      }
    });
    if (_paid) _stopTimers();
  }

  String get _timerText {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Pelunasan simulasi untuk uji coba (server PAYMENT_SIMULATED=true).
  Future<void> _onPay() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      final paid = await _repository.pay(_order.id);
      if (!mounted) return;
      _applyOrder(paid);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppNotification.error(context, e.message);
      if (e.statusCode == 409) _refresh();
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  List<String> get _orderLines =>
      _order.items.map((it) => '${it.qty}x ${it.name}').toList();

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
        // Nama outlet dari pengaturan admin; 'Yap Coffee' selama belum termuat.
        title: Text(
          HomeStore.instance.store?.name.isNotEmpty == true
              ? HomeStore.instance.store!.name
              : 'Yap Coffee',
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
          queueNumber: _order.id,
          customerName: _customerName,
          child: const PaymentQrBox(),
        ),
        const SizedBox(height: 24),
        Center(child: _buildDownloadButton()),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: _orderLines),
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
        onPressed: _paying ? null : _onPay,
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
          queueNumber: _order.id,
          customerName: _customerName,
          child: _buildSuccessImage(),
        ),
        const SizedBox(height: 24),
        PaymentSummaryCard(orderLines: _orderLines),
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
