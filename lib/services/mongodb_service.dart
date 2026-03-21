import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/mongodb_config.dart';

class MongoDbService {
  static const String _counterKey = 'number of clicks';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'api-key': MongoDbConfig.apiKey,
      };

  static Map<String, String> get _baseBody => {
        'dataSource': MongoDbConfig.dataSource,
        'database': MongoDbConfig.database,
        'collection': MongoDbConfig.collection,
      };

  /// Fetches the current click count from MongoDB.
  /// Returns 0 if the document doesn't exist yet.
  static Future<int> getClickCount() async {
    final url = Uri.parse('${MongoDbConfig.dataApiUrl}/action/findOne');

    final body = {
      ..._baseBody,
      'filter': {'key': _counterKey},
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['document'] != null) {
          return data['document']['value'] as int? ?? 0;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increments the click count in MongoDB by 1 using upsert.
  /// Creates the document if it doesn't exist.
  /// Returns the new count.
  static Future<int> incrementClickCount() async {
    final url = Uri.parse('${MongoDbConfig.dataApiUrl}/action/updateOne');

    final body = {
      ..._baseBody,
      'filter': {'key': _counterKey},
      'update': {
        '\$inc': {'value': 1},
        '\$setOnInsert': {'key': _counterKey},
      },
      'upsert': true,
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // After incrementing, fetch the updated count
        return await getClickCount();
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
