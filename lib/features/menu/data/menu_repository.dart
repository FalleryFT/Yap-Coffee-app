import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/coffee_item_model.dart';
import '../model/menu_options.dart';

/// Satu-satunya jalur HTTP fitur menu: GET /api/menu.
class MenuRepository {
  MenuRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<MenuCatalog> fetchCatalog() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/menu');
      final data = res.data!['data'] as Map<String, dynamic>;
      return MenuCatalog(
        categories: (data['categories'] as List).map((e) => e as String).toList(),
        items: (data['items'] as List)
            .map((e) => CoffeeItem.fromApi(e as Map<String, dynamic>))
            .toList(),
        options: data['options'] is Map<String, dynamic>
            ? MenuOptions.fromApi(data['options'] as Map<String, dynamic>)
            : MenuOptions.fallback,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
