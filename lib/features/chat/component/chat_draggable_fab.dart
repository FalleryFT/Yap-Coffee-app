import 'package:flutter/material.dart';

import 'chat_fab.dart';

/// Tombol chat melayang yang bisa digeser langsung dengan jari.
///
/// Widget ini mengisi seluruh area Stack induknya ([Positioned.fill]) tetapi
/// hanya menerima sentuhan pada tombolnya, sehingga scroll di bawahnya tetap
/// berjalan normal. Tap membuka halaman chat, geser memindahkan tombol.
class ChatDraggableFab extends StatefulWidget {
  const ChatDraggableFab({super.key});

  @override
  State<ChatDraggableFab> createState() => _ChatDraggableFabState();
}

class _ChatDraggableFabState extends State<ChatDraggableFab> {
  /// FloatingActionButton.small berukuran 40x40.
  static const double _fabSize = 40;

  /// Jarak minimal tombol dari tepi layar.
  static const double _margin = 12;

  /// Sudut kiri-atas tombol; null berarti masih di posisi awal.
  Offset? _position;

  /// Posisi tombol saat geseran dimulai, dipakai sebagai acuan geseran.
  Offset _dragOrigin = Offset.zero;

  /// Posisi jari (global) saat geseran dimulai.
  Offset _dragStartGlobal = Offset.zero;

  bool _dragging = false;

  /// Posisi awal: sejajar tengah dengan tombol keranjang di MainShellPage
  /// (keranjang: right 18, bottom 80, ukuran 52x52).
  Offset _initialPosition(Size area) => Offset(
    area.width - 24 - _fabSize,
    area.height - 144 - _fabSize,
  );

  double _clampAxis(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Menjaga tombol tetap di dalam area, tidak menutupi status bar atau tepi layar.
  Offset _clamp(Offset position, Size area) {
    final topInset = MediaQuery.paddingOf(context).top + _margin;
    final maxX = area.width - _fabSize - _margin;
    final maxY = area.height - _fabSize - _margin;
    return Offset(
      _clampAxis(position.dx, _margin, maxX < _margin ? _margin : maxX),
      _clampAxis(position.dy, topInset, maxY < topInset ? topInset : maxY),
    );
  }

  void _startDrag(Offset position, Offset globalPosition) {
    setState(() {
      _dragging = true;
      _dragOrigin = position;
      _dragStartGlobal = globalPosition;
    });
  }

  void _updateDrag(Offset globalPosition, Size area) {
    final offsetFromOrigin = globalPosition - _dragStartGlobal;
    setState(() => _position = _clamp(_dragOrigin + offsetFromOrigin, area));
  }

  void _endDrag() {
    if (!_dragging) return;
    setState(() => _dragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final area = constraints.biggest;
          final position = _clamp(_position ?? _initialPosition(area), area);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) =>
                      _startDrag(position, details.globalPosition),
                  onPanUpdate: (details) =>
                      _updateDrag(details.globalPosition, area),
                  onPanEnd: (_) => _endDrag(),
                  onPanCancel: _endDrag,
                  child: Semantics(
                    label: 'Tanya asisten',
                    hint: 'Geser tombol untuk memindahkannya',
                    child: AnimatedScale(
                      scale: _dragging ? 1.15 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: const ChatFab(tooltip: null),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
