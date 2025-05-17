import 'package:flutter/material.dart';
import 'package:placas_app/controllers/auth_controller.dart';
import 'package:placas_app/controllers/device_controller.dart';
import 'package:placas_app/controllers/reading_controller.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/presentation/pages/data_visualization.dart';
import 'package:placas_app/presentation/pages/device_details.dart';
import 'package:placas_app/presentation/pages/login.dart';
import 'package:placas_app/presentation/pages/profile.dart';
import 'package:placas_app/presentation/pages/help.dart';
import 'package:placas_app/presentation/pages/alert_settings.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authController = AuthController();
  final _deviceController = DeviceController();
  final _readingController = ReadingController();
  final _nameController = TextEditingController();
  List<Device> _devices = [];
  Map<String, Map<String, dynamic>> _lastReadings = {};
  bool _isLoading = true;
  bool _isAddingDevice = false;
  int _alertCount = 0;

  // Umbrales fijos para las alertas (mismos valores que en AlertSettingsPage)
  static const double TEMP_MAX = 30.0;
  static const double TEMP_MIN = 20.0;
  static const double HUM_MAX = 100.0;
  static const double HUM_MIN = 70.0;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Verificar si una lectura está en alerta
  bool _isReadingInAlert(double temp, double hum) {
    return temp > TEMP_MAX || temp < TEMP_MIN || hum > HUM_MAX || hum < HUM_MIN;
  }

  Future<void> _loadLastReading(String deviceId) async {
    try {
      final readings = await _readingController.getDeviceReadings(
        deviceId: deviceId,
        context: context,
        limit: 1,
      );

      if (readings.isNotEmpty && mounted) {
        final temp = readings[0].temperature;
        final hum = readings[0].humidity;
        final isAlert = _isReadingInAlert(temp, hum);

        setState(() {
          _lastReadings[deviceId] = {
            'temperature': temp,
            'humidity': hum,
            'isAlert': isAlert,
            'timestamp': readings[0].timestamp,
          };
          _updateAlertCount();
        });
      }
    } catch (e) {
      print('Error al cargar la última lectura: $e');
    }
  }

  void _updateAlertCount() {
    int count = 0;
    _lastReadings.forEach((_, data) {
      if (data['isAlert'] == true) count++;
    });
    setState(() => _alertCount = count);
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _alertCount = 0;
    });

    final user = await _authController.getCurrentUser(context);
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    final devices = await _deviceController.getUserDevices(
      userId: user.id,
      context: context,
    );

    if (mounted) {
      setState(() {
        _devices = devices;
        _isLoading = false;
      });

      for (var device in devices) {
        _loadLastReading(device.id);
      }
    }
  }

  void _showAddDeviceDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Dispositivo'),
        content: TextField(
          controller: _nameController,
          decoration:
              const InputDecoration(labelText: 'Nombre del Dispositivo'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _isAddingDevice ? null : () => _addDevice(context),
            child: _isAddingDevice
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo con las alertas activas
  void _showAlertsDialog() {
    List<Widget> alertWidgets = [];

    for (var device in _devices) {
      if (_lastReadings.containsKey(device.id) &&
          _lastReadings[device.id]!['isAlert'] == true) {
        final temp = _lastReadings[device.id]!['temperature'];
        final hum = _lastReadings[device.id]!['humidity'];

        String alertMessage = '';
        if (temp > TEMP_MAX) alertMessage += '¡Temperatura alta! ';
        if (temp < TEMP_MIN) alertMessage += '¡Temperatura baja! ';
        if (hum > HUM_MAX) alertMessage += '¡Humedad alta! ';
        if (hum < HUM_MIN) alertMessage += '¡Humedad baja! ';

        alertWidgets.add(
          ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.red),
            title: Text(device.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alertMessage, style: const TextStyle(color: Colors.red)),
                Text(
                    'Temp: ${temp.toStringAsFixed(1)}°C, Hum: ${hum.toStringAsFixed(1)}%'),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => DataVisualizationPage(device: device)),
              );
            },
          ),
        );

        alertWidgets.add(const Divider());
      }
    }

    if (alertWidgets.isNotEmpty) {
      // Eliminar el último divisor
      alertWidgets.removeLast();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Text('Alertas Activas'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: alertWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addDevice(BuildContext dialogContext) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un nombre para el dispositivo')),
      );
      return;
    }

    setState(() => _isAddingDevice = true);

    final user = await _authController.getCurrentUser(context);
    if (user != null) {
      final device = await _deviceController.createDevice(
        name: _nameController.text,
        userId: user.id,
        context: context,
      );

      setState(() => _isAddingDevice = false);

      if (device != null) {
        Navigator.of(dialogContext).pop();
        _loadDevices();
      }
    } else {
      setState(() => _isAddingDevice = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo obtener la información del usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          // Campanita con contador de alertas
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _alertCount > 0 ? _showAlertsDialog : null,
                tooltip: 'Alertas',
              ),
              if (_alertCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_alertCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpPage()),
            ),
            tooltip: 'Ayuda',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                  break;
                case 'logout':
                  _authController.logout(context);
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18),
                    SizedBox(width: 8),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? _buildEmptyState()
              : _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No tienes dispositivos registrados',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddDeviceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Dispositivo'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          final hasReading = _lastReadings.containsKey(device.id);
          final isAlert =
              hasReading && _lastReadings[device.id]!['isAlert'] == true;

          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(
                        Icons.devices,
                        size: 40,
                        color: device.status == 'active'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      if (isAlert)
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.warning,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    device.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isAlert ? Colors.red : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: ${device.deviceCode}'),
                      if (isAlert)
                        const Text('¡ALERTA! Valores fuera de rango',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'details':
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) =>
                                      DeviceDetailsPage(device: device)))
                              .then((_) => _loadDevices());
                          break;
                        case 'alerts':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    AlertSettingsPage(device: device)),
                          );
                          break;
                        case 'data':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DataVisualizationPage(device: device)),
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'alerts',
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active, size: 18),
                            SizedBox(width: 8),
                            Text('Ver Alertas'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'data',
                        child: Row(
                          children: [
                            Icon(Icons.show_chart, size: 18),
                            SizedBox(width: 8),
                            Text('Ver Datos'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasReading) _buildReadingSection(device),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadingSection(Device device) {
    final temp = _lastReadings[device.id]!['temperature'];
    final hum = _lastReadings[device.id]!['humidity'];
    final isAlert = _lastReadings[device.id]!['isAlert'] == true;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildReadingIndicator(
            icon: Icons.thermostat,
            value: '${temp.toStringAsFixed(1)}°C',
            color: (temp > TEMP_MAX || temp < TEMP_MIN)
                ? Colors.red
                : Colors.orange,
          ),
          _buildReadingIndicator(
            icon: Icons.water_drop,
            value: '${hum.toStringAsFixed(1)}%',
            color: (hum > HUM_MAX || hum < HUM_MIN) ? Colors.red : Colors.blue,
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => DataVisualizationPage(device: device)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAlert ? Colors.red : null,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Ver Datos'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingIndicator({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
