/// Format angka menjadi rupiah, contoh: 22000 -> "Rp 22.000".
String rupiah(int amount) {
  final text = amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return 'Rp $text';
}
