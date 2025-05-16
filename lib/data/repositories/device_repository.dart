import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/core/constants/appwrite_constants.dart';
import 'package:placas_app/model/device.dart';

class DeviceRepository {
  final Databases _databases = AppwriteConfig.databases;

  String _generateDeviceCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _generateApiKey() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      32,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<Device> createDevice({
    required String name,
    required String userId,
    String? description,
    String? location,
  }) async {
    try {
      final deviceCode = _generateDeviceCode();
      final apiKey = _generateApiKey();
      final now = DateTime.now().toIso8601String();

      print('Intentando crear dispositivo con: Name: $name, UserId: $userId');

      final data = {
        'name': name,
        'deviceCode': deviceCode,
        'apiKey': apiKey,
        'userId': userId,
        'status': 'inactive',
        'lastReading': now,
        'createdAt': now,
        'updatedAt': now,
      };

      if (description != null) data['description'] = description;
      if (location != null) data['location'] = location;

      print('Datos a enviar: $data');

      final response = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        documentId: ID.unique(),
        data: data,
      );

      print('Dispositivo creado con éxito: ${response.data}');

      return Device.fromJson(response.data);
    } catch (e) {
      print('Error al crear dispositivo: $e');
      rethrow;
    }
  }

  Future<List<Device>> getUserDevices(String userId) async {
    try {
      print('Buscando dispositivos para el usuario: $userId');

      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      print('Dispositivos encontrados: ${response.documents.length}');

      return response.documents
          .map((doc) => Device.fromJson(doc.data))
          .toList();
    } catch (e) {
      print('Error al obtener dispositivos: $e');
      rethrow;
    }
  }

  Future<Device> getDevice(String deviceId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        documentId: deviceId,
      );

      return Device.fromJson(response.data);
    } catch (e) {
      print('Error al obtener dispositivo: $e');
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        documentId: deviceId,
      );
    } catch (e) {
      print('Error al eliminar dispositivo: $e');
      rethrow;
    }
  }
}
