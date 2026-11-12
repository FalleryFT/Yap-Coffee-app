import '../../../core/utils/date_labels.dart';
import '../../menu/data/coffee_item_model.dart';

/// Tahap pesanan dari sisi pelanggan. Setelah lunas, tahapnya mengikuti status dapur
/// yang diubah barista: menunggu → diproses (meramu) → siap diambil → selesai.
enum OrderStatus {
  belumDibayar,
  menunggu,
  diproses,
  siapDiambil,
  selesai,
  dibatalkan,
}

class OrderLine {
  final String name;
  final int qty;
  final String? notes;
  final String? imageAsset;
  final String? imageUrl;

  /// Total harga baris ini (harga satuan × jumlah).
  final int price;

  const OrderLine({
    required this.name,
    required this.qty,
    required this.price,
    this.notes,
    this.imageAsset,
    this.imageUrl,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    final qty = (json['qty'] as num).toInt();
    final unitPrice = (json['unitPrice'] as num).toInt();
    final notes = json['notes'] as String?;
    final image = resolveMenuImage(json['image'] as String?);
    return OrderLine(
      name: json['name'] as String,
      qty: qty,
      price: unitPrice * qty,
      notes: (notes == null || notes.isEmpty) ? null : notes,
      imageAsset: image.asset,
      imageUrl: image.url,
    );
  }
}

class OrderModel {
  /// Kode pesanan, contoh WK-8493. Dipakai juga sebagai pengenal di API.
  final String id;
  final OrderStatus status;

  /// Pesanan sudah ditandai "siap ambil" oleh barista.
  final bool ready;
  final String dateLabel;
  final String pickupDate;
  final String pickupLocation;
  final String pickupTime;
  final String batchName;
  final String pickupPoint;
  final String pickupDetail;
  final String pickupArea;
  final String routeGuide;
  final String? mapsUrl;

  /// Titik di peta aplikasi (diatur admin pada jadwal); null bila belum diisi.
  final double? latitude;
  final double? longitude;
  final List<OrderLine> items;
  final int total;

  /// Sisa waktu bayar (detik) saat data diterima. Hanya bermakna bila [status] = belumDibayar.
  final int paymentSecondsLeft;

  const OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    this.ready = false,
    this.dateLabel = '',
    this.pickupDate = '',
    this.pickupLocation = '',
    this.pickupTime = '',
    this.batchName = '',
    this.pickupPoint = '',
    this.pickupDetail = '',
    this.pickupArea = '',
    this.routeGuide = '',
    this.mapsUrl,
    this.latitude,
    this.longitude,
    this.paymentSecondsLeft = 0,
  });

  /// Dari satu objek pesanan pada GET /api/orders atau POST /api/orders.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pickup = json['pickup'] as Map<String, dynamic>;
    final payment = json['payment'] as Map<String, dynamic>;
    final location = pickup['location'] as String? ?? '';
    final detail = pickup['locationDetail'] as String? ?? '';

    return OrderModel(
      id: json['id'] as String,
      status: _statusFrom(
        json['status'] as String?,
        json['kitchenStatus'] as String?,
      ),
      ready: json['ready'] == true,
      dateLabel: DateLabels.dateTime(json['createdAt'] as String?),
      pickupDate: DateLabels.longDate(pickup['date'] as String?),
      pickupLocation: location,
      pickupTime: '${pickup['start']} - ${pickup['end']}',
      batchName: pickup['batchName'] as String? ?? '',
      // Server: location = titik pengambilan (contoh "Drop Box Gazebo Tengah Lantai 1"),
      // locationDetail = gedung dan area (contoh "Gedung FT Sipil UB, area Kampus UB").
      pickupPoint: location,
      pickupDetail: '',
      pickupArea: detail,
      routeGuide: '',
      mapsUrl: pickup['mapsUrl'] as String?,
      latitude: (pickup['latitude'] as num?)?.toDouble(),
      longitude: (pickup['longitude'] as num?)?.toDouble(),
      items: (json['items'] as List)
          .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      paymentSecondsLeft: (payment['secondsLeft'] as num?)?.toInt() ?? 0,
    );
  }

  /// [value] = status pelanggan dari server; [kitchen] = status dapur (menunggu | meramu | siap_ambil).
  static OrderStatus _statusFrom(String? value, String? kitchen) =>
      switch (value) {
        'belum_dibayar' => OrderStatus.belumDibayar,
        'belum_diambil' => switch (kitchen) {
            'meramu' => OrderStatus.diproses,
            'siap_ambil' => OrderStatus.siapDiambil,
            _ => OrderStatus.menunggu,
          },
        'selesai' => OrderStatus.selesai,
        'dibatalkan' => OrderStatus.dibatalkan,
        _ => OrderStatus.belumDibayar,
      };

  /// Masih berjalan: belum dibayar sampai siap diambil.
  bool get isActive =>
      status != OrderStatus.selesai && status != OrderStatus.dibatalkan;

  /// Tautan Google Maps ke titik pengambilan. Memakai tautan dari jadwal bila admin mengisinya;
  /// bila kosong, dicari dari nama titik dan areanya.
  String get mapsLink {
    final url = mapsUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    final query =
        [pickupLocation, pickupArea].where((e) => e.isNotEmpty).join(', ');
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
  }

  String get formattedTotal => formatRupiah(total);
}

String formatRupiah(int value) {
  final text = value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return 'Rp $text';
}
