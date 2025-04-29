// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sazones_semanales/src/backend/config/config.dart';
import 'package:sazones_semanales/src/backend/database/database_service.dart';
import 'package:sazones_semanales/src/frontend/views/home/homepage_view.dart';
import 'package:sazones_semanales/src/frontend/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.init();

  await DatabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.flutterAppName,
      theme: AppTheme.light,
      home: HomePageView(),
    );
  }
}
