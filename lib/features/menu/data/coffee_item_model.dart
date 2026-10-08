class CoffeeItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final double? rating;
  final String imageAsset;
  final String? modalImageAsset;
  final bool isFavorite;
  final bool isDarkPlusButton;

  const CoffeeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.rating,
    required this.imageAsset,
    this.modalImageAsset,
    this.isFavorite = false,
    this.isDarkPlusButton = false,
  });

  String get formattedPrice {
    final str = price.toString();
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
}

class CoffeeData {
  CoffeeData._();

  static const List<CoffeeItem> homeFavorites = [
    CoffeeItem(
      id: 'yap-latte',
      name: 'Yap Latte',
      description: 'Signature palm sugar',
      price: 22000,
      category: 'Es Kopi Susu',
      imageAsset: 'assets/images/yap_latte.png',
      modalImageAsset: 'assets/images/modal_yap_latte.png',
      isFavorite: true,
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'v60-gayo',
      name: 'V60 Gayo Beans',
      description: 'Fruity, bright notes',
      price: 30000,
      category: 'Manual Brew',
      imageAsset: 'assets/images/v60_gayo.png',
      isFavorite: true,
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'matcha-latte',
      name: 'Matcha Latte Dingin',
      description: 'Premium Uji matcha',
      price: 28000,
      category: 'Non-Coffee',
      imageAsset: 'assets/images/matcha_latte.png',
      isFavorite: true,
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'butter-croissant',
      name: 'Butter Croissant',
      description: 'Warm & flaky',
      price: 25000,
      category: 'Makanan Ringan',
      imageAsset: 'assets/images/butter_croissant.png',
      isFavorite: true,
      isDarkPlusButton: false,
    ),
  ];

  static const List<CoffeeItem> menuCatalog = [
    CoffeeItem(
      id: 'es-kopi-susu',
      name: 'Es Kopi Susu Gula Aren',
      description: 'Double shot robusta-arabika dipadu susu segar & aren',
      price: 22000,
      category: 'Espresso-Based',
      rating: 4.9,
      imageAsset: 'assets/images/es_kopi_susu.png',
      modalImageAsset: 'assets/images/modal_yap_latte.png',
      isDarkPlusButton: true,
    ),
    CoffeeItem(
      id: 'americano-hot',
      name: 'Americano Hot',
      description: 'House blend espresso dengan air panas murni',
      price: 18000,
      category: 'Espresso-Based',
      rating: 4.7,
      imageAsset: 'assets/images/americano_hot.png',
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'cappuccino',
      name: 'Cappuccino',
      description: 'Espresso bold dengan microfoam susu lembut',
      price: 25000,
      category: 'Espresso-Based',
      rating: 4.8,
      imageAsset: 'assets/images/cappuccino.png',
      isDarkPlusButton: true,
    ),
    CoffeeItem(
      id: 'v60-pour-over',
      name: 'V60 Pour Over',
      description: 'Seduhan manual pour over dengan rasa bersih & berkarakter',
      price: 30000,
      category: 'Manual Brew',
      rating: 5.0,
      imageAsset: 'assets/images/v60_pour_over.png',
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'yap-latte-menu',
      name: 'Yap Latte',
      description: 'Signature palm sugar dengan susu gurih',
      price: 22000,
      category: 'Espresso-Based',
      rating: 4.9,
      imageAsset: 'assets/images/yap_latte.png',
      modalImageAsset: 'assets/images/modal_yap_latte.png',
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'v60-gayo-menu',
      name: 'V60 Gayo Beans',
      description: 'Arabika Aceh Gayo fermentasi anaerobik',
      price: 30000,
      category: 'Manual Brew',
      rating: 4.9,
      imageAsset: 'assets/images/v60_gayo.png',
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'matcha-latte-menu',
      name: 'Matcha Latte Dingin',
      description: 'Matcha Uji ceremonial grade dengan fresh milk',
      price: 28000,
      category: 'Non-Coffee',
      rating: 4.8,
      imageAsset: 'assets/images/matcha_latte.png',
      isDarkPlusButton: false,
    ),
    CoffeeItem(
      id: 'butter-croissant-menu',
      name: 'Butter Croissant',
      description: 'Pastry mentega renyah hangat & wangi',
      price: 25000,
      category: 'Makanan Ringan',
      rating: 4.7,
      imageAsset: 'assets/images/butter_croissant.png',
      isDarkPlusButton: false,
    ),
  ];
}
