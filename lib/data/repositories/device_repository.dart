import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/core/constants/appwrite_constants.dart';
import 'package:placas_app/model/device.dart';

class DeviceRepository {
  final Databases _databases = AppwriteConfig.databases;

  String _generateUniqueCode() {
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
  }) async {
    try {
      final uniqueCode = _generateUniqueCode();
      final apiKey = _generateApiKey();

      final response = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'unique_code': uniqueCode,
          'api_key': apiKey,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return Device.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Device>> getUserDevices(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.devicesCollectionId,
        queries: [Query.equal('user_id', userId)],
      );

      return response.documents
          .map((doc) => Device.fromJson(doc.data))
          .toList();
    } catch (e) {
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
      rethrow;
    }
  }
}
