import '../../../core/utils/date_labels.dart';

/// Satu kloter pengambilan yang masih bisa dipesan (GET /api/schedules).
class PickupSchedule {
  const PickupSchedule({
    required this.id,
    required this.name,
    required this.date,
    required this.start,
    required this.end,
    required this.cutOff,
    required this.location,
    required this.locationDetail,
    this.mapsUrl,
  });

  final int id;
  final String name;

  /// 'YYYY-MM-DD'
  final String date;
  final String start;
  final String end;
  final String cutOff;
  final String location;
  final String locationDetail;
  final String? mapsUrl;

  factory PickupSchedule.fromJson(Map<String, dynamic> json) {
    return PickupSchedule(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      date: json['date'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      cutOff: json['cutOff'] as String,
      location: json['location'] as String? ?? '',
      locationDetail: json['locationDetail'] as String? ?? '',
      mapsUrl: json['mapsUrl'] as String?,
    );
  }

  String get windowLabel => '$start - $end WIB';

  DateTime? get day => DateLabels.parse(date);
}
