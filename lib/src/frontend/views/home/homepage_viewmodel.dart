import 'package:flutter/material.dart';
import 'package:sazones_semanales/src/backend/config/config.dart';
import 'package:sazones_semanales/src/backend/database/database_service.dart';

class HomePageViewModel extends State<StatefulWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fetchDataFromDB() async {
    final results = await DatabaseService.connection
        .execute('SELECT * FROM sazones_semanales_postgres');

    for (final row in results) {
      print(row);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.flutterAppName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $_counter'),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Incrementar'),
            ),
            ElevatedButton(
              onPressed: fetchDataFromDB,
              child: const Text('Cargar datos DB'),
            ),
          ],
        ),
      ),
    );
  }
}
