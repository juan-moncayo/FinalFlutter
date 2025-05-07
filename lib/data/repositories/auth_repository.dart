import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/model/user.dart';

class AuthRepository {
  final Account _account = AppwriteConfig.account;

  Future<User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final models.User response = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      return User(id: response.$id, name: response.name, email: response.email);
    } catch (e) {
      rethrow;
    }
  }

  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _account.createSession(
        userId: email, // Assuming email is used as userId
        secret: password, // Assuming password is used as secret
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final models.User response = await _account.get();
      return User(id: response.$id, name: response.name, email: response.email);
    } catch (e) {
      rethrow;
    }
  }
}
