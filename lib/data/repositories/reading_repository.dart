import 'package:appwrite/appwrite.dart';
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/core/constants/appwrite_constants.dart';
import 'package:placas_app/model/reading.dart';

class ReadingRepository {
  final Databases _databases = AppwriteConfig.databases;

  Future<List<Reading>> getDeviceReadings(
    String deviceId, {
    int limit = 50,
  }) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.readingsCollectionId,
        queries: [
          Query.equal('device_id', deviceId),
          Query.orderDesc('timestamp'),
          Query.limit(limit),
        ],
      );

      return response.documents
          .map((doc) => Reading.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Reading> createReading({
    required String deviceId,
    required double temperature,
    required double humidity,
  }) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.readingsCollectionId,
        documentId: ID.unique(),
        data: {
          'device_id': deviceId,
          'temperature': temperature,
          'humidity': humidity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Reading.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
