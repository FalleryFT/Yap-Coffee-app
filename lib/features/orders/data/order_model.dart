enum OrderStatus { belumDiambil, belumDibayar, selesai, dibatalkan }

class OrderLine {
  final String name;
  final int qty;
  final String? notes;
  final String? imageAsset;
  final int price;

  const OrderLine({
    required this.name,
    required this.qty,
    required this.price,
    this.notes,
    this.imageAsset,
  });
}

class OrderModel {
  final String id;
  final OrderStatus status;
  final String dateLabel;
  final String pickupDate;
  final String pickupLocation;
  final String pickupTime;
  final String batchName;
  final String pickupPoint;
  final String pickupDetail;
  final String pickupArea;
  final String routeGuide;
  final List<OrderLine> items;
  final int total;

  const OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    this.dateLabel = '',
    this.pickupDate = '',
    this.pickupLocation = '',
    this.pickupTime = '',
    this.batchName = '',
    this.pickupPoint = '',
    this.pickupDetail = '',
    this.pickupArea = '',
    this.routeGuide = '',
  });

  bool get isActive =>
      status == OrderStatus.belumDiambil || status == OrderStatus.belumDibayar;

  String get formattedTotal => formatRupiah(total);
}

String formatRupiah(int value) {
  final text = value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return 'Rp $text';
}

class OrderData {
  OrderData._();

  static const List<OrderModel> orders = [
    // ===== Pesanan Aktif =====
    OrderModel(
      id: 'WK-8493',
      status: OrderStatus.belumDiambil,
      pickupDate: '10 September 2026',
      pickupLocation: 'Drop Box Gazebo Tengah Lantai 1',
      pickupTime: '08:00 - 14:00',
      batchName: 'Kloter Pagi Kampus',
      pickupPoint: 'Gedung Sipil UB – Gazebo Tengah Lantai 1',
      pickupDetail: 'Drop Box Gazebo Tengah Lantai 1',
      pickupArea: 'Area Kampus Universitas Brawijaya',
      routeGuide:
          'Masuk via Gerbang Veteran UB, lurus ke arah Gedung FT Sipil, gazebo tepat di taman tengah lantai 1 samping kantin.',
      items: [
        OrderLine(
          name: 'Yap Latte',
          qty: 2,
          price: 22000,
          notes: 'Less Sugar, Extra Shot',
          imageAsset: 'assets/images/yap_latte.png',
        ),
        OrderLine(
          name: 'Classic Croissant',
          qty: 1,
          price: 25000,
          notes: 'Hangatkan',
          imageAsset: 'assets/images/butter_croissant.png',
        ),
      ],
      total: 78590,
    ),
    OrderModel(
      id: 'WK-8492',
      status: OrderStatus.belumDibayar,
      pickupDate: '10 September 2026',
      pickupLocation: 'Drop Box Gazebo Tengah Lantai 1',
      pickupTime: '08:00 - 14:00',
      batchName: 'Kloter Pagi Kampus',
      pickupPoint: 'Gedung Sipil UB – Gazebo Tengah Lantai 1',
      pickupDetail: 'Drop Box Gazebo Tengah Lantai 1',
      pickupArea: 'Area Kampus Universitas Brawijaya',
      routeGuide:
          'Masuk via Gerbang Veteran UB, lurus ke arah Gedung FT Sipil, gazebo tepat di taman tengah lantai 1 samping kantin.',
      items: [
        OrderLine(
          name: 'Yap Latte',
          qty: 2,
          price: 22000,
          notes: 'Less Sugar, Extra Shot',
          imageAsset: 'assets/images/yap_latte.png',
        ),
        OrderLine(
          name: 'Classic Croissant',
          qty: 1,
          price: 25000,
          notes: 'Hangatkan',
          imageAsset: 'assets/images/butter_croissant.png',
        ),
      ],
      total: 78590,
    ),

    // ===== Riwayat =====
    OrderModel(
      id: 'WK-82910',
      status: OrderStatus.selesai,
      dateLabel: '12 Okt 2023, 14:30',
      items: [
        OrderLine(name: 'Yap Latte', qty: 1, price: 18000),
        OrderLine(name: 'Roti Bakar Coklat', qty: 1, price: 15000),
      ],
      total: 33000,
    ),
    OrderModel(
      id: 'WK-82845',
      status: OrderStatus.selesai,
      dateLabel: '10 Okt 2023, 08:15',
      items: [
        OrderLine(name: 'Americano Dingin', qty: 2, price: 30000),
        OrderLine(name: 'Donat Kampung', qty: 1, price: 8000),
      ],
      total: 38000,
    ),
    OrderModel(
      id: 'WK-82102',
      status: OrderStatus.dibatalkan,
      dateLabel: '05 Okt 2023, 16:40',
      items: [
        OrderLine(name: 'Kopi Susu Gula Aren', qty: 1, price: 20000),
      ],
      total: 20000,
    ),
  ];
}