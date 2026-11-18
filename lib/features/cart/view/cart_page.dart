import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/primary_button.dart';
import '../../checkout/view/checkout_page.dart';
import '../../menu/component/add_to_cart_sheet.dart';
import '../component/cart_empty_state.dart';
import '../component/cart_item_card.dart';
import '../component/cart_summary_card.dart';
import '../model/cart_item.dart';
import '../viewmodel/cart_view_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartViewModel _cart = CartViewModel.instance;

  void _onUbahTapped(CartItem item) {
    final original = item.originalItem;
    if (original == null) {
      AppNotification.info(context, 'Ubah varian untuk ${item.name}');
      return;
    }

    AddToCartSheet.show(
      context,
      item: original,
      // Sheet dibuka dengan pilihan yang sudah ada, bukan pilihan bawaan.
      initialQuantity: item.quantity,
      initialSize: item.size,
      initialSugar: item.sugar,
      initialAddonIds: item.addons.map((a) => a.id).toSet(),
      confirmLabel: 'Simpan Perubahan',
      onAddToCart: (coffeeItem, quantity, size, sugar, addons) {
        _cart.updateOptions(
          item,
          size: size,
          sugar: sugar,
          addons: addons,
          quantity: quantity,
        );
        AppNotification.success(context, 'Pesanan ${item.name} diperbarui.');
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
    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        final items = _cart.items;

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
                                _cart.updateQuantity(item, delta),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                        child: CartSummaryCard(cart: _cart),
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
      },
    );
  }
}
