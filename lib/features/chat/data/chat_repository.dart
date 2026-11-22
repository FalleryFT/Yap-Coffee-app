import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/chat_message.dart';

class ChatRepository {
  ChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// Mengirim pertanyaan beserta maksimal 6 pesan terakhir sebagai riwayat.
  Future<String> ask(String message, List<ChatMessage> history) async {
    final recent =
        history.length > 6 ? history.sublist(history.length - 6) : history;

    try {
      final res = await _dio.post(
        '/chat',
        data: {
          'pesan': message,
          'riwayat': recent.map((m) => m.toJson()).toList(),
        },
        // Model berjalan di CPU, jadi jawaban bisa lebih lama dari timeout bawaan (15 detik).
        options: Options(
          receiveTimeout: const Duration(seconds: 130),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final body = res.data;
      final data = body is Map ? body['data'] : null;
      final answer = data is Map ? data['jawaban'] : null;
      if (answer is! String || answer.trim().isEmpty) {
        throw const ApiException('Jawaban asisten tidak valid.');
      }
      return answer.trim();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}