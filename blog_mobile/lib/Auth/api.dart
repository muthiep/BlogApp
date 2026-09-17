import 'package:flutter/foundation.dart';
class Api {
  static const String _port = '3001';
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    return 'http://10.0.2.2:$_port/api';
  }

  static String get posts => '$baseUrl/posts';
  static String get categories => '$baseUrl/categories';
  static String get register => '$baseUrl/users/register';
  static String get login => '$baseUrl/users/login';
  static String get uploadPostImage => '$baseUrl/posts/upload';

  static String postById(int id) => '$posts/$id';
  static String categoryById(int id) => '$categories/$id';
}
