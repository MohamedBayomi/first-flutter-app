import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../config/mongodb_config.dart';

class MongoDbService {
  /// Gets the base URL for API calls.
  /// In web (browser), uses relative paths to hit Vercel API routes.
  /// In non-web (mobile/desktop), uses the full Vercel deployment URL.
  static String get _baseUrl {
    if (kIsWeb) {
      return ''; // relative path works on same domain
    }
    return MongoDbConfig.apiBaseUrl;
  }

  /// Fetches the current click count.
  static Future<int> getClickCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/get-clicks'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['value'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increments the click count by 1 and returns the new value.
  static Future<int> incrementClickCount() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/increment-clicks'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['value'] as int? ?? -1;
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
