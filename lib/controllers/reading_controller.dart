import 'package:flutter/material.dart';
import 'package:placas_app/data/repositories/reading_repository.dart';
import 'package:placas_app/model/reading.dart';

class ReadingController {
  final ReadingRepository _readingRepository = ReadingRepository();

  Future<List<Reading>> getDeviceReadings({
    required String deviceId,
    required BuildContext context,
    int limit = 50,
  }) async {
    try {
      return await _readingRepository.getDeviceReadings(deviceId, limit: limit);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener lecturas: ${e.toString()}')),
      );
      return [];
    }
  }
}
