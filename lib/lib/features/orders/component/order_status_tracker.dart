import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../data/order_model.dart';
import 'order_status_chip.dart';

/// Kemajuan pesanan dalam empat tahap: Dibayar → Diproses → Siap Diambil → Selesai.
/// Pesanan dibatalkan menampilkan keterangan saja.
class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({super.key, required this.status});

  final OrderStatus status;

  static const List<String> _steps = [
    'Dibayar',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  static const Color _done = AppColors.statusOlive;
  static const Color _idle = Color(0xFFD9D2C6);

  /// Indeks tahap yang sedang berjalan; -1 bila belum ada yang tercapai.
  int get _current => switch (status) {
        OrderStatus.belumDibayar => -1,
        OrderStatus.menunggu => 0,
        OrderStatus.diproses => 1,
        OrderStatus.siapDiambil => 2,
        OrderStatus.selesai => 3,
        OrderStatus.dibatalkan => -1,
      };

  String get _caption => switch (status) {
        OrderStatus.belumDibayar => 'Menunggu pembayaran.',
        OrderStatus.menunggu => 'Pesanan diterima dan menunggu diproses barista.',
        OrderStatus.diproses => 'Barista sedang menyiapkan pesananmu.',
        OrderStatus.siapDiambil =>
          'Pesananmu sudah siap. Silakan ambil di titik pengambilan.',
        OrderStatus.selesai => 'Pesanan sudah diambil. Terima kasih!',
        OrderStatus.dibatalkan => 'Pesanan ini dibatalkan.',
      };

  @override
  Widget build(BuildContext context) {
    final cancelled = status == OrderStatus.dibatalkan;

    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pesanan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              OrderStatusChip(status: status),
            ],
          ),
          if (!cancelled) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _steps.length; i++) _stepView(i),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text(
            _caption,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.bark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepView(int index) {
    final reached = index <= _current;
    final isCurrent = index == _current;
    final isDone = index < _current;
    final isFirst = index == 0;
    final isLast = index == _steps.length - 1;

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: isFirst
                      ? Colors.transparent
                      : (reached ? _done : _idle),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? _done : Colors.white,
                  border: Border.all(color: reached ? _done : _idle, width: 2),
                ),
                child: reached
                    ? Icon(
                        isDone ? Icons.check_rounded : Icons.circle,
                        size: isDone ? 16 : 8,
                        color: Colors.white,
                      )
                    : null,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: isLast
                      ? Colors.transparent
                      : (index < _current ? _done : _idle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _steps[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: reached ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
