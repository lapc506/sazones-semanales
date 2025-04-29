import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sazones_semanales/src/backend/database/database_service.dart';
import 'package:sazones_semanales/src/frontend/views/home/homepage_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.development");

  await DatabaseService.init(); // 👈 Inicializa la DB de forma ordenada

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePageView(title: 'Flutter Demo Home Page'),
    );
  }
}
