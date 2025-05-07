import 'package:flutter/material.dart';
import 'package:placas_app/controllers/auth_controller.dart';
import 'package:placas_app/controllers/device_controller.dart';
import 'package:placas_app/model/device.dart';
import 'package:placas_app/presentation/pages/device_details.dart';
import 'package:placas_app/presentation/pages/login.dart';
import 'package:placas_app/presentation/pages/profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authController = AuthController();
  final _deviceController = DeviceController();
  final _nameController = TextEditingController();
  List<Device> _devices = [];
  bool _isLoading = true;

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

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
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

    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Dispositivo'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Dispositivo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.clear();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final user = await _authController.getCurrentUser(context);
                if (user != null) {
                  await _deviceController.createDevice(
                    name: _nameController.text,
                    userId: user.id,
                    context: context,
                  );
                  _nameController.clear();
                  Navigator.of(context).pop();
                  _loadDevices();
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authController.logout(context);
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No tienes dispositivos registrados',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddDeviceDialog,
                        child: const Text('Agregar Dispositivo'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDevices,
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(device.name),
                          subtitle: Text('Código: ${device.uniqueCode}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DeviceDetailsPage(device: device),
                                  ),
                                )
                                .then((_) => _loadDevices());
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
