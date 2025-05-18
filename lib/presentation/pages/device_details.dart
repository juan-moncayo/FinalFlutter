import 'package:flutter/material.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/presentation/pages/data_visualization.dart';

class DeviceDetailsPage extends StatelessWidget {
  final Device device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Dispositivo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID:', device.id),
                    _buildInfoRow('Nombre:', device.name),
                    _buildInfoRow('Código:', device.deviceCode),
                    _buildInfoRow('Estado:', device.status ?? 'No disponible'),
                    _buildInfoRow(
                      'Última lectura:',
                      device.lastReading != null
                          ? device.lastReading!.toLocal().toString()
                          : 'No disponible',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DataVisualizationPage(device: device),
                  ),
                );
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('Ver Lecturas'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
