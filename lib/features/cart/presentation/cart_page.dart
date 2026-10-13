import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _onUbahTapped(CartItem item) {
    if (item.originalItem != null) {
      AddToCartBottomSheet.show(
        context,
        item: item.originalItem!,
        onAddToCart: (coffeeItem, quantity, size, sugar) {
          final sizeText = size == CupSize.reguler ? 'Reguler' : 'Large';
          final sugarText = switch (sugar) {
            SugarLevel.normal => 'Normal',
            SugarLevel.lessSugar => 'Less Sugar',
            SugarLevel.noSugar => 'No Sugar',
          };
          final extraPrice = size == CupSize.large ? 5000 : 0;
          final unitPrice = coffeeItem.price + extraPrice;

          _cartManager.updateVariant(item, '$sizeText, $sugarText', unitPrice);
          item.quantity = quantity;
          setState(() {});
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubah varian untuk ${item.name}'),
          backgroundColor: AppColors.espresso,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartManager.items;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF432406),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Color(0xFF432406),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // List of Cart Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(item);
                    },
                  ),

                  // Order Summary Card ("Ringkasan Pesanan")
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: _buildOrderSummaryCard(),
                  ),

                  // Checkout Action Button ("Lanjut ke Checkout")
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: _buildCheckoutButton(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EEE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: Color(0xFF50453C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Belanja Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1C19),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih racikan kopi terbaikmu dan tambahkan ke keranjang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF50453C),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF432406),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Image (96x96, rx: 8)
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

          // Details Column
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and "Ubah" Row
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
                            color: Color(0xFF1B1C19),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onUbahTapped(item),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 2),
                          child: Text(
                            'Ubah',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1B1C19),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Variant Subtitle
                  Text(
                    item.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF50453C),
                    ),
                  ),

                  // Price and Stepper Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatCurrency(item.price),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF432406),
                        ),
                      ),

                      // Stepper Pill (width: 89, height: 31, rx: 15.5, fill: #F5F3EE, stroke: #E6CCB2)
                      Container(
                        width: 89,
                        height: 31,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3EE),
                          borderRadius: BorderRadius.circular(15.5),
                          border: Border.all(
                            color: const Color(0xFFE6CCB2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _cartManager.updateQuantity(item, -1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Icon(
                                  Icons.remove,
                                  size: 14,
                                  color: Color(0xFF432406),
                                ),
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1C19),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _cartManager.updateQuantity(item, 1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Color(0xFF432406),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildOrderSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 58, 26, 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1C19),
            ),
          ),
          const SizedBox(height: 16),

          // Subtotal
          _buildSummaryRow('Subtotal', _formatCurrency(_cartManager.subtotal)),
          const SizedBox(height: 12),

          // Pajak (11%)
          _buildSummaryRow('Pajak (11%)', _formatCurrency(_cartManager.tax)),
          const SizedBox(height: 12),

          // Biaya Layanan
          _buildSummaryRow('Biaya Layanan', _formatCurrency(_cartManager.serviceFee)),
          const SizedBox(height: 16),

          // Divider Line (height 1, fill #E4E2DD)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE4E2DD),
          ),
          const SizedBox(height: 16),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1C19),
                ),
              ),
              Text(
                _formatCurrency(_cartManager.grandTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF432406),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF50453C),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF50453C),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Menuju checkout (${_formatCurrency(_cartManager.grandTotal)})...',
              ),
              backgroundColor: const Color(0xFF432406),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF432406),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color.fromRGBO(93, 58, 26, 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Lanjut ke Checkout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
