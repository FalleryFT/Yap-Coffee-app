import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_order_summary_card.dart';
import '../../../core/widgets/app_quantity_stepper.dart';
import '../../../core/widgets/primary_button.dart';
import '../../checkout/presentation/checkout_page.dart';
import '../../menu/presentation/add_to_cart_bottom_sheet.dart';
import '../data/cart_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartManager _cartManager = CartManager.instance;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onUbahTapped(CartItem item) {
    final original = item.originalItem;
    if (original == null) {
      AppNotification.info(context, 'Ubah varian untuk ${item.name}');
      return;
    }

    AddToCartSheet.show(
      context,
      item: original,
      onAddToCart: (coffeeItem, quantity, size, sugar) {
        _cartManager.updateVariant(
          item,
          '${size.label}, ${sugar.label}',
          coffeeItem.price + size.extraPrice,
        );
        item.quantity = quantity;
        AppNotification.success(context, 'Varian ${item.name} diperbarui.');
      },
    );
  }

  void _openCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartManager.items;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.espresso,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: AppColors.espresso,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: items.isEmpty
          ? CartEmptyState(onShop: () => Navigator.of(context).pop())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CartItemCard(
                        item: item,
                        onUbahTapped: () => _onUbahTapped(item),
                        onQuantityChanged: (delta) =>
                            _cartManager.updateQuantity(item, delta),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: CartSummaryCard(cart: _cartManager),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: PrimaryButton(
                      label: 'Lanjut ke Checkout',
                      onPressed: _openCheckout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Keranjang Belanja Kosong',
      message: 'Pilih racikan kopi terbaikmu dan tambahkan ke keranjang.',
      actionLabel: 'Mulai Belanja',
      onAction: onShop,
    );
  }
}

/// Satu baris keranjang: gambar, nama, varian, harga, pengatur jumlah.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onUbahTapped,
    required this.onQuantityChanged,
  });

  final CartItem item;
  final VoidCallback onUbahTapped;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageAsset,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEE9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: Color(0xFF50453C),
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onUbahTapped,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 2),
                          child: Text(
                            'Ubah',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.bark,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        rupiah(item.price),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.espresso,
                        ),
                      ),
                      AppQuantityStepper(
                        quantity: item.quantity,
                        onDecrement: () => onQuantityChanged(-1),
                        onIncrement: () => onQuantityChanged(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan biaya keranjang (subtotal, pajak, layanan, total).
class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({super.key, required this.cart});

  final CartManager cart;

  @override
  Widget build(BuildContext context) {
    return OrderSummaryCard(
      rows: [
        SummaryRow('Subtotal', rupiah(cart.subtotal)),
        SummaryRow('Pajak (11%)', rupiah(cart.tax)),
        SummaryRow('Biaya Layanan', rupiah(cart.serviceFee)),
      ],
      totalLabel: 'Total',
      totalValue: rupiah(cart.grandTotal),
      titleFontSize: 15.5,
      labelFontSize: 13.5,
      totalFontSize: 18,
    );
  }
}
