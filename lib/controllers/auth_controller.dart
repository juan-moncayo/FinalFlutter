import 'package:flutter/material.dart';
import 'package:placas_app/data/repositories/auth_repository.dart';
import 'package:placas_app/model/user.dart';

class AuthController {
  final AuthRepository _authRepository = AuthRepository();
  User? currentUser;

  // Método para registrar un nuevo usuario
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Paso 1: Crear la cuenta
      currentUser = await _authRepository.createAccount(
        email: email,
        password: password,
        name: name,
      );

      // Paso 2: Iniciar sesión con las credenciales
      await _authRepository.login(
        email: email,
        password: password,
      );

      // Actualizar el usuario actual
      currentUser = await _authRepository.getCurrentUser();

      return true;
    } catch (e) {
      String errorMessage = 'Error al registrarse';

      // Personalizar mensaje de error según el tipo
      if (e.toString().contains('already exists')) {
        errorMessage = 'El correo electrónico ya está registrado';
      } else if (e.toString().contains('password')) {
        errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.toString()}')),
      );
      return false;
    }
  }

  // Método para iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Iniciar sesión
      await _authRepository.login(
        email: email,
        password: password,
      );

      // Obtener datos del usuario actual
      currentUser = await _authRepository.getCurrentUser();
      return true;
    } catch (e) {
      String errorMessage = 'Error al iniciar sesión';

      // Personalizar mensaje de error
      if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Credenciales inválidas';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.toString()}')),
      );
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> logout(BuildContext context) async {
    try {
      await _authRepository.logout();
      currentUser = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  // Método para obtener el usuario actual
  Future<User?> getCurrentUser(BuildContext context) async {
    try {
      if (currentUser == null) {
        currentUser = await _authRepository.getCurrentUser();
      }
      return currentUser;
    } catch (e) {
      // No mostrar error si no hay sesión activa
      return null;
    }
  }
}
