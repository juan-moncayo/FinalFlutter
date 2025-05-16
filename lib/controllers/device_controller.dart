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
      print('Iniciando creación de dispositivo: $name para usuario: $userId');
      final device = await _deviceRepository.createDevice(
        name: name,
        userId: userId,
      );
      print('Dispositivo creado exitosamente: ${device.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo creado exitosamente')),
      );

      return device;
    } catch (e) {
      print('Error en DeviceController.createDevice: $e');

      String errorMessage = 'Error al crear dispositivo';

      if (e.toString().contains('Permission denied')) {
        errorMessage =
            'Permiso denegado. Verifica los permisos de la colección.';
      } else if (e.toString().contains('not found')) {
        errorMessage =
            'Base de datos o colección no encontrada. Verifica la configuración.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<List<Device>> getUserDevices({
    required String userId,
    required BuildContext context,
  }) async {
    try {
      print('Obteniendo dispositivos para usuario: $userId');
      final devices = await _deviceRepository.getUserDevices(userId);
      print('Dispositivos obtenidos: ${devices.length}');
      return devices;
    } catch (e) {
      print('Error en DeviceController.getUserDevices: $e');

      String errorMessage = 'Error al obtener dispositivos';

      if (e.toString().contains('Permission denied')) {
        errorMessage =
            'Permiso denegado. Verifica los permisos de la colección.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.toString()}')),
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
      print('Error en DeviceController.getDevice: $e');
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
      print('Error en DeviceController.deleteDevice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar dispositivo: ${e.toString()}')),
      );
      return false;
    }
  }
}
