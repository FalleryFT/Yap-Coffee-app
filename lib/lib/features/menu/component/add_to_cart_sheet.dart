import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_notification.dart';
import '../../cart/data/cart_manager.dart';
import '../data/coffee_item_model.dart';
import '../data/menu_options.dart';
import '../data/menu_store.dart';
import 'menu_option_controls.dart';
import 'selected_item_summary_card.dart';

/// Dipanggil saat pelanggan menekan tombol konfirmasi di sheet.
typedef AddToCartCallback = void Function(
  CoffeeItem item,
  int quantity,
  SizeOption size,
  SugarOption sugar,
  List<MenuAddon> addons,
);

/// Sheet pilihan ukuran, tingkat manis, tambahan, dan jumlah sebelum masuk keranjang.
/// Ukuran dan tingkat manis mengikuti yang diatur admin (MenuStore.options).
class AddToCartSheet extends StatefulWidget {
  final CoffeeItem item;
  final AddToCartCallback? onAddToCart;

  /// Pilihan awal; dipakai saat mengubah baris yang sudah ada di keranjang.
  /// Null = pilihan bawaan dari admin.
  final int initialQuantity;
  final SizeOption? initialSize;
  final SugarOption? initialSugar;
  final Set<int> initialAddonIds;
  final String confirmLabel;

  const AddToCartSheet({
    super.key,
    required this.item,
    this.onAddToCart,
    this.initialQuantity = 1,
    this.initialSize,
    this.initialSugar,
    this.initialAddonIds = const {},
    this.confirmLabel = 'Masukan Keranjang',
  });

  static Future<void> show(
    BuildContext context, {
    required CoffeeItem item,
    AddToCartCallback? onAddToCart,
    int initialQuantity = 1,
    SizeOption? initialSize,
    SugarOption? initialSugar,
    Set<int> initialAddonIds = const {},
    String confirmLabel = 'Masukan Keranjang',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartSheet(
        item: item,
        onAddToCart: onAddToCart,
        initialQuantity: initialQuantity,
        initialSize: initialSize,
        initialSugar: initialSugar,
        initialAddonIds: initialAddonIds,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  final MenuOptions _options = MenuStore.instance.options;

  late int _quantity = widget.initialQuantity;
  late SizeOption _selectedSize = widget.initialSize == null
      ? _options.defaultSize
      : _options.sizeByLabel(widget.initialSize!.label);
  late SugarOption _selectedSugar = widget.initialSugar == null
      ? _options.defaultSugar
      : _options.sugarByLabel(widget.initialSugar!.label);
  late final Set<int> _selectedAddonIds = {...widget.initialAddonIds};

  List<MenuAddon> get _selectedAddons => widget.item.addons
      .where((a) => _selectedAddonIds.contains(a.id))
      .toList();

  int get _calculatedPrice =>
      CartManager.unitPriceFor(
        widget.item,
        _selectedSize,
        _selectedAddons,
      ) *
      _quantity;

  String get _variantSummary => CartManager.variantFor(
        widget.item,
        _selectedSize,
        _selectedSugar,
        _selectedAddons,
      );

  void _toggleAddon(MenuAddon addon) {
    setState(() {
      if (!_selectedAddonIds.remove(addon.id)) {
        _selectedAddonIds.add(addon.id);
      }
    });
  }

  void _onAddPressed() {
    widget.onAddToCart?.call(
      widget.item,
      _quantity,
      _selectedSize,
      _selectedSugar,
      _selectedAddons,
    );
    Navigator.of(context).pop();
  }

  /// Ukuran gelas membesar mengikuti urutan daftar dari admin.
  double _iconSizeFor(int index) => 20.0 + (index * 3).clamp(0, 12);

  @override
  Widget build(BuildContext context) {
    const sectionTitle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      // Dengan banyak pilihan, isi sheet bisa lebih tinggi dari layar kecil; gulir bila perlu.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SelectedItemSummaryCard(
              item: widget.item,
              variant: _variantSummary,
              totalPrice: _calculatedPrice,
              quantity: _quantity,
              onDecrement: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              onIncrement: () => setState(() => _quantity++),
            ),
            if (widget.item.hasOptions) ...[
              const SizedBox(height: 22),
              const Text('Pilih Ukuran', style: sectionTitle),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Sampai 3 ukuran sebaris; lebih dari itu dua per baris.
                  final perRow =
                      _options.sizes.length <= 3 ? _options.sizes.length : 2;
                  const gap = 12.0;
                  final width =
                      (constraints.maxWidth - gap * (perRow - 1)) / perRow;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (int i = 0; i < _options.sizes.length; i++)
                        SizedBox(
                          width: width,
                          child: CupSizeOption(
                            title: _options.sizes[i].label,
                            detail: _options.sizes[i].caption,
                            iconSize: _iconSizeFor(i),
                            isSelected:
                                _selectedSize.label == _options.sizes[i].label,
                            onTap: () => setState(
                              () => _selectedSize = _options.sizes[i],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              const Text('Tingkat Manis', style: sectionTitle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final sugar in _options.sugarLevels)
                    SugarLevelChip(
                      label: sugar.label,
                      isSelected: _selectedSugar.label == sugar.label,
                      onTap: () => setState(() => _selectedSugar = sugar),
                    ),
                ],
              ),
            ],
            if (widget.item.addons.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text('Tambahan (opsional)', style: sectionTitle),
              const SizedBox(height: 10),
              for (final addon in widget.item.addons) ...[
                AddonOptionTile(
                  label: addon.label,
                  extraPrice: addon.extraPrice,
                  isSelected: _selectedAddonIds.contains(addon.id),
                  onTap: () => _toggleAddon(addon),
                ),
                const SizedBox(height: 8),
              ],
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.confirmLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alur standar: buka sheet, tambahkan ke keranjang, lalu tampilkan
/// notifikasi "ditambahkan ke keranjang" di atas layar.
Future<void> openAddToCartSheet(BuildContext context, CoffeeItem item) async {
  if (item.soldOut) {
    AppNotification.warning(context, '${item.name} sedang habis.');
    return;
  }
  return AddToCartSheet.show(
    context,
    item: item,
    onAddToCart: (coffeeItem, quantity, size, sugar, addons) {
      CartManager.instance.addCoffeeItem(
        item: coffeeItem,
        quantity: quantity,
        size: size,
        sugar: sugar,
        addons: addons,
      );
      AppNotification.cartAdded(
        context,
        itemName: coffeeItem.name,
        variant: CartManager.variantFor(coffeeItem, size, sugar, addons),
      );
    },
  );
}
