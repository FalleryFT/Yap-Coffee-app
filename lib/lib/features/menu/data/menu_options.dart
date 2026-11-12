import '../../../core/utils/currency.dart';

/// Ukuran gelas, contoh "Reguler 16 oz" atau "Large 22 oz + Rp 5.000". Diatur admin di web (Pengaturan).
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

/// Tingkat manis, contoh "Less Sugar". Diatur admin di web (Pengaturan).
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

/// Pilihan ukuran dan tingkat manis dari GET /api/menu → options.
class MenuOptions {
  const MenuOptions({required this.sizes, required this.sugarLevels});

  final List<SizeOption> sizes;
  final List<SugarOption> sugarLevels;

  /// Dipakai bila server belum mengirim `options` (server lama) atau daftarnya kosong.
  static const MenuOptions fallback = MenuOptions(
    sizes: [
      SizeOption(label: 'Reguler', detail: '16 oz', extraPrice: 0, isDefault: true),
      SizeOption(label: 'Large', detail: '22 oz', extraPrice: 5000),
    ],
    sugarLevels: [
      SugarOption(label: 'Normal'),
      SugarOption(label: 'Less Sugar', isDefault: true),
      SugarOption(label: 'No Sugar'),
    ],
  );

  factory MenuOptions.fromApi(Map<String, dynamic> json) {
    final sizes = ((json['sizes'] as List?) ?? const [])
        .map((e) => SizeOption.fromApi(e as Map<String, dynamic>))
        .toList();
    final sugar = ((json['sugarLevels'] as List?) ?? const [])
        .map((e) => SugarOption.fromApi(e as Map<String, dynamic>))
        .toList();
    if (sizes.isEmpty || sugar.isEmpty) return fallback;
    return MenuOptions(sizes: sizes, sugarLevels: sugar);
  }

  SizeOption get defaultSize =>
      sizes.firstWhere((s) => s.isDefault, orElse: () => sizes.first);

  SugarOption get defaultSugar =>
      sugarLevels.firstWhere((s) => s.isDefault, orElse: () => sugarLevels.first);

  /// Pilihan dengan nama ini; bila sudah tidak ada (admin mengubah daftar), yang bawaan.
  SizeOption sizeByLabel(String? label) =>
      sizes.firstWhere((s) => s.label == label, orElse: () => defaultSize);

  SugarOption sugarByLabel(String? label) => sugarLevels.firstWhere(
        (s) => s.label == label,
        orElse: () => defaultSugar,
      );

  /// Ringkasan untuk halaman detail menu.
  String get summary {
    final sizeText = sizes
        .map((s) => s.caption.isEmpty ? s.label : '${s.label} (${s.caption})')
        .join(', ');
    final sugarText = sugarLevels.map((s) => s.label).join(', ');
    return 'Ukuran: $sizeText.\nTingkat manis: $sugarText.';
  }
}
