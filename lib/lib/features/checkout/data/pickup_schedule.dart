import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
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

class ScheduleRepository {
  ScheduleRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<PickupSchedule>> fetchOpen() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/schedules');
      return (res.data!['data'] as List)
          .map((e) => PickupSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
