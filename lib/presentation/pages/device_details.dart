import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placas_app/controllers/device_controller.dart';
import 'package:placas_app/controllers/reading_controller.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/model/reading.dart';
import 'package:placas_app/presentation/pages/data_visualization.dart';

class DeviceDetailsPage extends StatefulWidget {
  final Device device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  final _deviceController = DeviceController();
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
      limit: 5,
    );

    setState(() {
      _readings = readings;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dispositivo'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este dispositivo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _deviceController.deleteDevice(
                deviceId: widget.device.id,
                context: context,
              );
              if (success && mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestReading = _readings.isNotEmpty ? _readings.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReadings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
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
                        const Text(
                          'Información del Dispositivo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Código Único:'),
                            Row(
                              children: [
                                Text(widget.device.uniqueCode),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  onPressed: () => _copyToClipboard(
                                    widget.device.uniqueCode,
                                    'Código copiado al portapapeles',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Clave API:'),
                            Row(
                              children: [
                                Text(
                                  '${widget.device.apiKey.substring(0, 8)}...',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  onPressed: () => _copyToClipboard(
                                    widget.device.apiKey,
                                    'Clave API copiada al portapapeles',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Última Lectura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : latestReading == null
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No hay lecturas disponibles',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Icon(
                                            Icons.thermostat,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Temperatura'),
                                          Text(
                                            '${latestReading.temperature.toStringAsFixed(1)}°C',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Icon(
                                            Icons.water_drop,
                                            size: 48,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Humedad'),
                                          Text(
                                            '${latestReading.humidity.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Última actualización: ${latestReading.timestamp.toLocal().toString().substring(0, 19)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DataVisualizationPage(
                            device: widget.device,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver Historial de Datos'),
                  ),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración para Arduino',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Para configurar tu placa ESP32, utiliza el código único y la clave API en tu sketch de Arduino.',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Consulta la documentación para obtener ejemplos de código.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
