import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/coffee_item_model.dart';

enum CupSize { reguler, large }

enum SugarLevel { normal, lessSugar, noSugar }

class AddToCartBottomSheet extends StatefulWidget {
  final CoffeeItem item;
  final void Function(
    CoffeeItem item,
    int quantity,
    CupSize size,
    SugarLevel sugar,
  )? onAddToCart;

  const AddToCartBottomSheet({
    super.key,
    required this.item,
    this.onAddToCart,
  });

  static Future<void> show(
    BuildContext context, {
    required CoffeeItem item,
    void Function(CoffeeItem item, int quantity, CupSize size, SugarLevel sugar)?
        onAddToCart,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        item: item,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  int _quantity = 1;
  CupSize _selectedSize = CupSize.reguler;
  SugarLevel _selectedSugar = SugarLevel.lessSugar;

  int get _calculatedPrice {
    final basePrice = widget.item.price;
    final sizeExtra = _selectedSize == CupSize.large ? 5000 : 0;
    return (basePrice + sizeExtra) * _quantity;
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

  String get _variantSummary {
    final sizeText = _selectedSize == CupSize.reguler ? 'Reguler' : 'Large';
    final sugarText = switch (_selectedSugar) {
      SugarLevel.normal => 'Normal',
      SugarLevel.lessSugar => 'Less Sugar',
      SugarLevel.noSugar => 'No Sugar',
    };
    return '$sizeText, $sugarText';
  }

  @override
  Widget build(BuildContext context) {
    final imageToUse = widget.item.modalImageAsset ?? widget.item.imageAsset;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambahkan Menu',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECE7DE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imageToUse,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _variantSummary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatCurrency(_calculatedPrice),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          // Stepper
                          Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EDE6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDDD7CC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Icon(
                                      Icons.remove,
                                      size: 15,
                                      color: Color(0xFF4C3C30),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _quantity++),
                                  borderRadius: BorderRadius.circular(14),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Icon(
                                      Icons.add,
                                      size: 15,
                                      color: Color(0xFF4C3C30),
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
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Section "Pilih Ukuran"
          const Text(
            'Pilih Ukuran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSizeCard(
                  size: CupSize.reguler,
                  title: 'Reguler',
                  detail: '16 oz',
                  icon: Icons.coffee_rounded,
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSizeCard(
                  size: CupSize.large,
                  title: 'Large',
                  detail: '+ Rp 5.000 (22 oz)',
                  icon: Icons.coffee_rounded,
                  iconSize: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Section "Tingkat Manis"
          const Text(
            'Tingkat Manis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSugarChip(SugarLevel.normal, 'Normal'),
              const SizedBox(width: 10),
              _buildSugarChip(SugarLevel.lessSugar, 'Less Sugar'),
              const SizedBox(width: 10),
              _buildSugarChip(SugarLevel.noSugar, 'No Sugar'),
            ],
          ),
          const SizedBox(height: 26),

          // Bottom Button "Masukan Keranjang"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onAddToCart?.call(
                  widget.item,
                  _quantity,
                  _selectedSize,
                  _selectedSugar,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.item.name} ($_variantSummary) ditambahkan ke keranjang!',
                    ),
                    backgroundColor: AppColors.buttonDark,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Masukan Keranjang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeCard({
    required CupSize size,
    required String title,
    required String detail,
    required IconData icon,
    required double iconSize,
  }) {
    final isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: isSelected ? const Color(0xFF2C190D) : const Color(0xFF5E4B3E),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSugarChip(SugarLevel level, String label) {
    final isSelected = _selectedSugar == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedSugar = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDark : const Color(0xFF3C2C20),
          ),
        ),
      ),
    );
  }
}
