import 'package:flutter/material.dart';
import 'package:placas_app/controllers/reading_controller.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/model/reading.dart';
import 'dart:math' as math;

class DataVisualizationPage extends StatefulWidget {
  final Device device;

  const DataVisualizationPage({super.key, required this.device});

  @override
  State<DataVisualizationPage> createState() => _DataVisualizationPageState();
}

class _DataVisualizationPageState extends State<DataVisualizationPage> {
  final _readingController = ReadingController();
  List<Reading> _readings = [];
  bool _isLoading = true;

  // Umbrales fijos para las alertas (mismos valores que en dashboard.dart)
  static const double TEMP_MAX = 30.0;
  static const double TEMP_MIN = 20.0;
  static const double HUM_MAX = 100.0;
  static const double HUM_MIN = 70.0;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  // Verificar si una lectura está en alerta
  bool _isReadingInAlert(double temp, double hum) {
    return temp > TEMP_MAX || temp < TEMP_MIN || hum > HUM_MAX || hum < HUM_MIN;
  }

  // Obtener mensaje de alerta según los valores
  String _getAlertMessage(double temp, double hum) {
    List<String> alerts = [];

    if (temp > TEMP_MAX) alerts.add('Temperatura alta');
    if (temp < TEMP_MIN) alerts.add('Temperatura baja');
    if (hum > HUM_MAX) alerts.add('Humedad alta');
    if (hum < HUM_MIN) alerts.add('Humedad baja');

    return alerts.join(', ');
  }

  Future<void> _loadReadings() async {
    setState(() {
      _isLoading = true;
    });

    final readings = await _readingController.getDeviceReadings(
      deviceId: widget.device.id,
      context: context,
      limit: 50,
    );

    setState(() {
      _readings = readings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos de ${widget.device.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _readings.isEmpty
              ? _buildEmptyState()
              : _buildDataContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReadings,
        child: const Icon(Icons.refresh),
        tooltip: 'Actualizar datos',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No hay datos disponibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Este dispositivo aún no ha enviado lecturas',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReadings,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent() {
    final latestReading = _readings.isNotEmpty ? _readings.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de estado actual
          if (latestReading != null) _buildCurrentStatusCard(latestReading),
          const SizedBox(height: 24),

          // Tarjetas de resumen
          const Text(
            'Resumen de Datos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Temperatura Promedio',
                  value: _calculateAverageTemperature(),
                  unit: '°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Humedad Promedio',
                  value: _calculateAverageHumidity(),
                  unit: '%',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Temperatura Máxima',
                  value: _calculateMaxTemperature(),
                  unit: '°C',
                  icon: Icons.trending_up,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Temperatura Mínima',
                  value: _calculateMinTemperature(),
                  unit: '°C',
                  icon: Icons.trending_down,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Historial de lecturas
          const Text(
            'Historial de Lecturas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(10, _readings.length),
            itemBuilder: (context, index) {
              final reading = _readings[index];
              final isAlert =
                  _isReadingInAlert(reading.temperature, reading.humidity);
              final alertMessage = isAlert
                  ? _getAlertMessage(reading.temperature, reading.humidity)
                  : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    isAlert ? Icons.warning : Icons.check_circle,
                    color: isAlert ? Colors.red : Colors.green,
                  ),
                  title: Text(
                    'Temp: ${reading.temperature.toStringAsFixed(1)}°C | Hum: ${reading.humidity.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAlert ? Colors.red : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.timestamp.toLocal().toString().substring(0, 19),
                      ),
                      if (isAlert)
                        Text(
                          'Alerta: $alertMessage',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  isThreeLine: isAlert,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(Reading reading) {
    final isAlert = _isReadingInAlert(reading.temperature, reading.humidity);
    final alertMessage =
        isAlert ? _getAlertMessage(reading.temperature, reading.humidity) : '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isAlert
                ? [Colors.orange.shade300, Colors.red.shade400]
                : [Colors.blue.shade300, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estado Actual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAlert ? 'ALERTA' : 'NORMAL',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (isAlert) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alertMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.thermostat,
                    label: 'Temperatura',
                    value: '${reading.temperature.toStringAsFixed(1)}°C',
                    isAlert: reading.temperature > TEMP_MAX ||
                        reading.temperature < TEMP_MIN,
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.water_drop,
                    label: 'Humedad',
                    value: '${reading.humidity.toStringAsFixed(1)}%',
                    isAlert: reading.humidity > HUM_MAX ||
                        reading.humidity < HUM_MIN,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    bool isAlert = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: isAlert ? TextDecoration.underline : null,
                decorationColor: Colors.white,
                decorationThickness: 2,
              ),
            ),
            if (isAlert)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.warning, color: Colors.white, size: 18),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final isAlert = (title.contains('Temperatura') &&
            (value > TEMP_MAX || value < TEMP_MIN)) ||
        (title.contains('Humedad') && (value > HUM_MAX || value < HUM_MIN));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isAlert ? Colors.red : color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isAlert ? Colors.red : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isAlert ? Colors.red : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageTemperature() {
    if (_readings.isEmpty) return 0;
    final sum =
        _readings.fold(0.0, (sum, reading) => sum + reading.temperature);
    return sum / _readings.length;
  }

  double _calculateAverageHumidity() {
    if (_readings.isEmpty) return 0;
    final sum = _readings.fold(0.0, (sum, reading) => sum + reading.humidity);
    return sum / _readings.length;
  }

  double _calculateMaxTemperature() {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.temperature).reduce(math.max);
  }

  double _calculateMinTemperature() {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.temperature).reduce(math.min);
  }
}
