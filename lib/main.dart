import 'package:flutter/material.dart';
import 'package:placas_app/core/config/appwrite_config.dart';
import 'package:placas_app/presentation/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppwriteConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}
