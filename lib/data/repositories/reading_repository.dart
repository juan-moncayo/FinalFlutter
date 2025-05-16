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
          Query.equal('deviceId', deviceId),
          Query.orderDesc('timestamp'),
          Query.limit(limit),
        ],
      );

      return response.documents
          .map((doc) => Reading.fromJson(doc.data))
          .toList();
    } catch (e) {
      print('Error en getDeviceReadings: $e');
      rethrow;
    }
  }
}
