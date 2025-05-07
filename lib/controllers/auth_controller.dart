import 'package:flutter/material.dart';
import 'package:placas_app/data/repositories/auth_repository.dart';
import 'package:placas_app/model/user.dart';

class AuthController {
  final AuthRepository _authRepository = AuthRepository();
  User? currentUser;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      currentUser = await _authRepository.createAccount(
        email: email,
        password: password,
        name: name,
      );

      await _authRepository.login(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: ${e.toString()}')),
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _authRepository.login(
        email: email,
        password: password,
      );

      currentUser = await _authRepository.getCurrentUser();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
      return false;
    }
  }

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

  Future<User?> getCurrentUser(BuildContext context) async {
    try {
      if (currentUser == null) {
        currentUser = await _authRepository.getCurrentUser();
      }
      return currentUser;
    } catch (e) {
      return null;
    }
  }
}
