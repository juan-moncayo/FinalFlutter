import 'package:flutter/material.dart';
import 'package:placas_app/controllers/reading_controller.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/model/reading.dart';

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

  @override
  void initState() {
    super.initState();
    _loadReadings();
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _readings.isEmpty
              ? const Center(
                  child: Text('No hay datos disponibles para este dispositivo'),
                )
              : RefreshIndicator(
                  onRefresh: _loadReadings,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryCard(
                              'Temperatura Promedio',
                              _calculateAverageTemperature(),
                              '°C',
                              Colors.red,
                              Icons.thermostat,
                            ),
                            _buildSummaryCard(
                              'Humedad Promedio',
                              _calculateAverageHumidity(),
                              '%',
                              Colors.blue,
                              Icons.water_drop,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _readings.length,
                          itemBuilder: (context, index) {
                            final reading = _readings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Temp: ${reading.temperature.toStringAsFixed(1)}°C | Hum: ${reading.humidity.toStringAsFixed(1)}%',
                                ),
                                subtitle: Text(
                                  reading.timestamp
                                      .toLocal()
                                      .toString()
                                      .substring(0, 19),
                                ),
                                leading: const Icon(Icons.sensors),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageTemperature() {
    if (_readings.isEmpty) return 0;
    final sum = _readings.fold(
      0.0,
      (sum, reading) => sum + reading.temperature,
    );
    return sum / _readings.length;
  }

  double _calculateAverageHumidity() {
    if (_readings.isEmpty) return 0;
    final sum = _readings.fold(
      0.0,
      (sum, reading) => sum + reading.humidity,
    );
    return sum / _readings.length;
  }
}
