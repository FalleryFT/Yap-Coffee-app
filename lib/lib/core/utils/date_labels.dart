/// Format tanggal berbahasa Indonesia tanpa paket intl.
/// Masukan dari API berbentuk 'YYYY-MM-DD' atau 'YYYY-MM-DD HH:mm:ss'.
const List<String> _dayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

const List<String> _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const List<String> _monthLong = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _two(int n) => n.toString().padLeft(2, '0');

class DateLabels {
  DateLabels._();

  static DateTime? parse(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  static String dayShort(DateTime d) => _dayShort[d.weekday - 1];

  static String monthShort(DateTime d) => _monthShort[d.month - 1];

  static String dayOfMonth(DateTime d) => _two(d.day);

  /// "10 September 2026"
  static String longDate(String? value) {
    final d = parse(value);
    if (d == null) return value ?? '';
    return '${d.day} ${_monthLong[d.month - 1]} ${d.year}';
  }

  /// "3 Nov 2026, 06:30"
  static String dateTime(String? value) {
    final d = parse(value);
    if (d == null) return value ?? '';
    return '${d.day} ${_monthShort[d.month - 1]} ${d.year}, ${_two(d.hour)}:${_two(d.minute)}';
  }

  /// "Bergabung sejak Oktober 2024"
  static String joined(String? value) {
    final d = parse(value);
    if (d == null) return '';
    return 'Bergabung sejak ${_monthLong[d.month - 1]} ${d.year}';
  }

  /// "Terakhir diperbarui 2 bulan lalu"; null berarti sandi belum pernah diganti lewat aplikasi.
  static String passwordUpdated(String? value, {DateTime? now}) {
    final d = parse(value);
    if (d == null) return 'Belum pernah diperbarui';

    final diff = (now ?? DateTime.now()).difference(d);
    // Selisih jam server dan perangkat bisa membuat angka negatif; anggap "baru saja".
    if (diff.inMinutes < 1) return 'Terakhir diperbarui baru saja';
    if (diff.inMinutes < 60) return 'Terakhir diperbarui ${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return 'Terakhir diperbarui ${diff.inHours} jam lalu';
    if (diff.inDays < 30) return 'Terakhir diperbarui ${diff.inDays} hari lalu';
    return 'Terakhir diperbarui ${diff.inDays ~/ 30} bulan lalu';
  }
}
