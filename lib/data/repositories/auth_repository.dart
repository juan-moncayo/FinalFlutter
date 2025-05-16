import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/model/user.dart';

class AuthRepository {
  final Account _account = AppwriteConfig.account;

  // Crear cuenta (registro)
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
      print('Error en createAccount: $e');
      rethrow;
    }
  }

  // Iniciar sesión
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      // Para Appwrite 15.0.2
      return await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      print('Error en logout: $e');
      rethrow;
    }
  }

  // Obtener usuario actual
  Future<User> getCurrentUser() async {
    try {
      final models.User response = await _account.get();
      return User(id: response.$id, name: response.name, email: response.email);
    } catch (e) {
      print('Error en getCurrentUser: $e');
      rethrow;
    }
  }
}
