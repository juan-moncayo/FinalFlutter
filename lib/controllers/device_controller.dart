import 'package:flutter/material.dart';
import 'package:placas_app/data/repositories/device_repository.dart';
import 'package:placas_app/model/device.dart';

class DeviceController {
  final DeviceRepository _deviceRepository = DeviceRepository();

  Future<Device?> createDevice({
    required String name,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      final device = await _deviceRepository.createDevice(
        name: name,
        userId: userId,
      );
      return device;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear dispositivo: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<List<Device>> getUserDevices({
    required String userId,
    required BuildContext context,
  }) async {
    try {
      return await _deviceRepository.getUserDevices(userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al obtener dispositivos: ${e.toString()}')),
      );
      return [];
    }
  }

  Future<Device?> getDevice({
    required String deviceId,
    required BuildContext context,
  }) async {
    try {
      return await _deviceRepository.getDevice(deviceId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al obtener dispositivo: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<bool> deleteDevice({
    required String deviceId,
    required BuildContext context,
  }) async {
    try {
      await _deviceRepository.deleteDevice(deviceId);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar dispositivo: ${e.toString()}')),
      );
      return false;
    }
  }
}
