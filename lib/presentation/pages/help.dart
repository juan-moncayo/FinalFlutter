import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpCard(
            title: 'Primeros Pasos',
            icon: Icons.start,
            color: Colors.green,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(1, 'Registrar una cuenta',
                    'Crea una cuenta con tu correo y contraseña.'),
                _buildStep(2, 'Agregar un dispositivo',
                    'Pulsa el botón "+" para agregar un dispositivo.'),
                _buildStep(3, 'Configurar el dispositivo',
                    'Usa el código generado para configurar tu ESP32.'),
                _buildStep(4, 'Visualizar datos',
                    'Pulsa en un dispositivo para ver sus lecturas.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            title: 'Preguntas Frecuentes',
            icon: Icons.question_answer,
            color: Colors.blue,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFAQItem(
                  '¿Cómo agrego un nuevo dispositivo?',
                  'Pulsa el botón "+" en la pantalla principal, ingresa un nombre y usa el código generado.',
                ),
                _buildFAQItem(
                  '¿Cómo veo las lecturas de mi dispositivo?',
                  'Pulsa sobre el dispositivo en la pantalla principal.',
                ),
                _buildFAQItem(
                  '¿Qué significan las alertas?',
                  'Las alertas se activan cuando la temperatura está fuera del rango 20-30°C o cuando la humedad está fuera del rango 70-100%.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            title: 'Solución de Problemas',
            icon: Icons.build,
            color: Colors.orange,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTroubleshootingItem(
                  'No puedo iniciar sesión',
                  'Verifica tus credenciales. Si olvidaste tu contraseña, contacta al administrador.',
                ),
                _buildTroubleshootingItem(
                  'Mi dispositivo no envía datos',
                  'Verifica la conexión a internet y el código de configuración.',
                ),
                _buildTroubleshootingItem(
                  'La aplicación se cierra inesperadamente',
                  'Actualiza a la última versión. Si persiste, contacta al soporte.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            title: 'Contacto',
            icon: Icons.contact_support,
            color: Colors.purple,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Correo Electrónico'),
                  subtitle: const Text('soporte@ejemplo.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Teléfono'),
                  subtitle: const Text('+1 234 567 890'),
                ),
                ListTile(
                  leading: const Icon(Icons.web),
                  title: const Text('Sitio Web'),
                  subtitle: const Text('www.ejemplo.com'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem(String problem, String solution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(problem,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(solution, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
