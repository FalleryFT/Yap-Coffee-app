import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Kotak QR dummy untuk pengambilan pesanan.
class PaymentQrBox extends StatelessWidget {
  const PaymentQrBox({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: CustomPaint(painter: DummyQrPainter()),
          ),
        ],
      ),
    );
  }
}

/// QR dummy (bukan kode asli): tiga penanda sudut + pola acak yang tetap.
class DummyQrPainter extends CustomPainter {
  static const int _cells = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _cells;
    final paint = Paint()..color = AppColors.ink;
    final rnd = _StableRandom(42);

    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) ||
        (x >= _cells - 8 && y < 8) ||
        (x < 8 && y >= _cells - 8);

    for (int y = 0; y < _cells; y++) {
      for (int x = 0; x < _cells; x++) {
        if (inFinder(x, y)) continue;
        if (rnd.next() < 0.5) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            paint,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, 7 * cell, 7 * cell), paint);
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

/// Generator acak sederhana dengan seed tetap (tanpa import dart:math).
class _StableRandom {
  _StableRandom(this._seed);

  int _seed;

  double next() {
    _seed = (_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return _seed / 0x7FFFFFFF;
  }
}
