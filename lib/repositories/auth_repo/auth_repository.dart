import 'package:bidout/repositories/auth_repo/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final FlutterSecureStorage storage;
  final AuthProvider authProvider;

  AuthRepository({required this.storage, required this.authProvider});

  Future<void> signIn({required String email, required String password}) async {

  }

  Future<void> signOut() async {
    await storage.deleteAll();
  }

  Future<bool> isSignedIn() async {
    return await storage.containsKey(key: 'email');
  }
  
}