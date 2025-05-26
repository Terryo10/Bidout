import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';

class AuthProvider {
  final FlutterSecureStorage storage;

  AuthProvider({required this.storage});

  Future signIn({required String email, required String password}) async {
    try {
       final response = await http.post(
      Uri.parse(AppUrls.signIn),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to sign in');
    }
    } catch (e) {
      throw Exception('Failed to sign in');
    }
  }
}