import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../chat/component/chat_fab.dart';
import 'floating_cart_button.dart';

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

enum _Target { cart, chat }

/// Lapisan tombol melayang: keranjang dan chat AI.
///
/// - Keduanya bisa digeser dalam batas area body (di bawah header halaman dan
///   di atas bottom nav bar) lalu menempel ke pojok terdekat saat dilepas.
/// - [topReserved] adalah tinggi header halaman aktif (logo, judul, dll),
///   sehingga tombol di pojok atas tidak menabrak header.
/// - Tombol chat selalu tampil. Jika keranjang tampil dan berada di pojok
///   yang sama, chat otomatis berada tepat di atas keranjang (di bawahnya
///   bila pojoknya di atas). Jika tidak ada keranjang, chat menempati pojok
///   itu sendiri.
///
/// Harus dipakai langsung sebagai anak [Stack] karena memakai [Positioned.fill].
class FloatingButtonsLayer extends StatefulWidget {
  final bool showCart;
  final int cartItemCount;
  final VoidCallback onCartTap;

  /// Tinggi header halaman aktif, di bawah status bar.
  final double topReserved;

  const FloatingButtonsLayer({
    super.key,
    required this.showCart,
    required this.cartItemCount,
    required this.onCartTap,
    this.topReserved = 0,
  });

  @override
  State<FloatingButtonsLayer> createState() => _FloatingButtonsLayerState();
}

class _FloatingButtonsLayerState extends State<FloatingButtonsLayer> {
  static const double _cartSize = FloatingCartButton.size;
  static const double _chatSize = 52;

  static const double _sideMargin = 16;

  /// Jarak tambahan di bawah header halaman.
  static const double _topMargin = 8;

  /// Body berhenti tepat di atas bottom nav bar, jadi jarak ini membuat
  /// tombol pojok bawah pas di atas nav bar dan tidak menutupinya.
  static const double _bottomMargin = 16;

  /// Jarak chat ke keranjang saat bertumpuk.
  static const double _stackGap = 12;

  static const double _flingFactor = 0.12;

  _Corner _cartCorner = _Corner.bottomRight;
  _Corner _chatCorner = _Corner.bottomRight;

  _Target? _dragTarget;
  Offset _dragPosition = Offset.zero;
  Offset _dragOrigin = Offset.zero;
  Offset _dragStartGlobal = Offset.zero;

  double _sizeOf(_Target target) =>
      target == _Target.cart ? _cartSize : _chatSize;

  /// Tombol yang lebih kecil dipusatkan terhadap "slot" selebar keranjang
  /// supaya sumbu tengahnya sejajar.
  double _inset(double size) => (_cartSize - size) / 2;

  bool _isTop(_Corner c) => c == _Corner.topLeft || c == _Corner.topRight;

  bool _isLeft(_Corner c) => c == _Corner.topLeft || c == _Corner.bottomLeft;

  double _clampAxis(double value, double min, double max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Offset _clamp(Offset p, double size, Size area, double topInset) {
    final inset = _inset(size);
    return Offset(
      _clampAxis(
        p.dx,
        _sideMargin + inset,
        area.width - size - _sideMargin - inset,
      ),
      _clampAxis(
        p.dy,
        topInset + inset,
        area.height - size - _bottomMargin - inset,
      ),
    );
  }

  Offset _cornerPos(_Corner c, double size, Size area, double topInset) {
    final inset = _inset(size);
    return _clamp(
      Offset(
        _isLeft(c)
            ? _sideMargin + inset
            : area.width - size - _sideMargin - inset,
        _isTop(c)
            ? topInset + inset
            : area.height - size - _bottomMargin - inset,
      ),
      size,
      area,
      topInset,
    );
  }

  /// Posisi diam tombol chat: di pojoknya, atau bertumpuk dengan keranjang
  /// bila keduanya berada di pojok yang sama.
  Offset _chatRestPos(bool cartShown, Size area, double topInset) {
    final base = _cornerPos(_chatCorner, _chatSize, area, topInset);
    if (!cartShown || _chatCorner != _cartCorner) return base;

    final cart = _cornerPos(_cartCorner, _cartSize, area, topInset);
    final dy = _isTop(_chatCorner)
        ? cart.dy + _cartSize + _stackGap
        : cart.dy - _chatSize - _stackGap;
    return Offset(base.dx, dy);
  }

  void _startDrag(_Target target, Offset position, Offset globalPosition) {
    setState(() {
      _dragTarget = target;
      _dragPosition = position;
      _dragOrigin = position;
      _dragStartGlobal = globalPosition;
    });
  }

  void _updateDrag(Offset globalPosition, Size area, double topInset) {
    final target = _dragTarget;
    if (target == null) return;
    final raw = _dragOrigin + (globalPosition - _dragStartGlobal);
    setState(() {
      _dragPosition = _clamp(raw, _sizeOf(target), area, topInset);
    });
  }

  /// Pilih pojok terdekat dari posisi lepas (ditambah efek lemparan).
  void _endDrag(Offset velocity, Size area) {
    final target = _dragTarget;
    if (target == null) return;

    final size = _sizeOf(target);
    final projected = _dragPosition + velocity * _flingFactor;
    final isLeft = projected.dx + size / 2 < area.width / 2;
    final isTop = projected.dy + size / 2 < area.height / 2;

    final corner = isTop
        ? (isLeft ? _Corner.topLeft : _Corner.topRight)
        : (isLeft ? _Corner.bottomLeft : _Corner.bottomRight);

    HapticFeedback.selectionClick();
    setState(() {
      if (target == _Target.cart) {
        _cartCorner = corner;
      } else {
        _chatCorner = corner;
      }
      _dragTarget = null;
    });
  }

  Widget _draggable({
    required _Target target,
    required Offset position,
    required Size area,
    required double topInset,
    required Widget child,
  }) {
    final dragging = _dragTarget == target;

    return AnimatedPositioned(
      key: ValueKey(target),
      // Saat digeser mengikuti jari tanpa animasi; saat dilepas (atau saat
      // pindah tab dengan header berbeda) meluncur halus.
      duration: dragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (d) => _startDrag(target, position, d.globalPosition),
        onPanUpdate: (d) => _updateDrag(d.globalPosition, area, topInset),
        onPanEnd: (d) => _endDrag(d.velocity.pixelsPerSecond, area),
        onPanCancel: () => _endDrag(Offset.zero, area),
        child: AnimatedScale(
          scale: dragging ? 1.1 : 1,
          duration: const Duration(milliseconds: 150),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset =
        MediaQuery.paddingOf(context).top + widget.topReserved + _topMargin;

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final area = constraints.biggest;
          final cartShown = widget.showCart;

          final cartPos = _dragTarget == _Target.cart
              ? _dragPosition
              : _cornerPos(_cartCorner, _cartSize, area, topInset);
          final chatPos = _dragTarget == _Target.chat
              ? _dragPosition
              : _chatRestPos(cartShown, area, topInset);

          final cart = cartShown
              ? _draggable(
                  target: _Target.cart,
                  position: cartPos,
                  area: area,
                  topInset: topInset,
                  child: FloatingCartButton(
                    itemCount: widget.cartItemCount,
                    onTap: widget.onCartTap,
                  ),
                )
              : null;

          final chat = _draggable(
            target: _Target.chat,
            position: chatPos,
            area: area,
            topInset: topInset,
            child: const ChatFab(size: _chatSize, tooltip: null),
          );

          // Tombol yang sedang digeser selalu di lapisan paling atas.
          final cartOnTop = _dragTarget == _Target.cart;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (cartOnTop) chat,
              if (cart != null) cart,
              if (!cartOnTop) chat,
            ],
          );
        },
      ),
    );
  }
}