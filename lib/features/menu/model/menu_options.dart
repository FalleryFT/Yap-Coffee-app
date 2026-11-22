import '../../../core/utils/currency.dart';

/// Ukuran gelas, contoh "Reguler 16 oz" atau "Large 22 oz + Rp 5.000". Diatur admin per menu di web (halaman Menu).
class SizeOption {
  const SizeOption({
    required this.label,
    required this.detail,
    required this.extraPrice,
    this.isDefault = false,
  });

  final String label;

  /// Keterangan tambahan, contoh "16 oz". Boleh kosong.
  final String detail;

  /// Tambahan harga per gelas.
  final int extraPrice;
  final bool isDefault;

  factory SizeOption.fromApi(Map<String, dynamic> json) {
    return SizeOption(
      label: json['label'] as String,
      detail: (json['detail'] as String?) ?? '',
      extraPrice: (json['extraPrice'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] == true,
    );
  }

  /// Teks di bawah nama ukuran: "16 oz", "+ Rp 5.000 (22 oz)", atau "+ Rp 3.000".
  String get caption {
    if (extraPrice > 0 && detail.isNotEmpty) {
      return '+ ${rupiah(extraPrice)} ($detail)';
    }
    if (extraPrice > 0) return '+ ${rupiah(extraPrice)}';
    return detail;
  }
}

/// Tingkat manis, contoh "Less Sugar". Diatur admin per menu di web (halaman Menu).
class SugarOption {
  const SugarOption({required this.label, this.isDefault = false});

  final String label;
  final bool isDefault;

  factory SugarOption.fromApi(Map<String, dynamic> json) {
    return SugarOption(
      label: json['label'] as String,
      isDefault: json['isDefault'] == true,
    );
  }
}