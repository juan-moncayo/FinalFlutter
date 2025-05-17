import 'package:flutter/material.dart';
import 'package:placas_app/model/device.dart';

class AlertSettingsPage extends StatelessWidget {
  final Device device;

  // Valores predeterminados fijos
  static const double TEMP_MAX = 30.0;
  static const double TEMP_MIN = 20.0;
  static const double HUM_MAX = 100.0;
  static const double HUM_MIN = 70.0;

  const AlertSettingsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas: ${device.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Información de Alertas',
              icon: Icons.info_outline,
              color: Colors.blue,
              content: const Text(
                'Las alertas están configuradas con valores predeterminados para garantizar '
                'el correcto funcionamiento de los dispositivos. Estos valores no pueden ser modificados.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                'Umbrales de Temperatura', Icons.thermostat, Colors.orange),
            const SizedBox(height: 8),
            _buildThresholdCard(
              title: 'Temperatura Alta',
              description: 'Alerta cuando la temperatura supere este valor',
              value: TEMP_MAX,
              unit: '°C',
              color: Colors.red,
            ),
            _buildThresholdCard(
              title: 'Temperatura Baja',
              description:
                  'Alerta cuando la temperatura esté por debajo de este valor',
              value: TEMP_MIN,
              unit: '°C',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                'Umbrales de Humedad', Icons.water_drop, Colors.blue),
            const SizedBox(height: 8),
            _buildThresholdCard(
              title: 'Humedad Alta',
              description: 'Alerta cuando la humedad supere este valor',
              value: HUM_MAX,
              unit: '%',
              color: Colors.blue,
            ),
            _buildThresholdCard(
              title: 'Humedad Baja',
              description:
                  'Alerta cuando la humedad esté por debajo de este valor',
              value: HUM_MIN,
              unit: '%',
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                'Notificaciones', Icons.notifications, Colors.purple),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Activar Notificaciones'),
                    subtitle: const Text('Recibir alertas al superar umbrales'),
                    value: true,
                    onChanged: null, // Deshabilitado
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Alertas en la Aplicación'),
                    subtitle: const Text('Mostrar alertas en la campanita'),
                    value: true,
                    onChanged: null, // Deshabilitado
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildThresholdCard({
    required String title,
    required String description,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
