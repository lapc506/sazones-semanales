import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sazones_semanales/domain/services/speech_recognition_service.dart';
import 'package:sazones_semanales/infrastructure/services/speech_recognition_service_impl.dart';

void main() {
  late SpeechRecognitionService service;
  
  setUp(() {
    // Create a mock BuildContext for testing
    final mockContext = MaterialApp(home: Container()).createState().context;
    service = SpeechRecognitionServiceImpl(mockContext);
  });
  
  group('SpeechRecognitionService', () {
    test('parseConsumptionCommand should parse simple commands correctly', () {
      // Test simple command with one product
      final result1 = service.parseConsumptionCommand('Voy a usar 2 manzanas');
      expect(result1, {'manzana': 2});
      
      // Test simple command with multiple products
      final result2 = service.parseConsumptionCommand('Voy a usar 2 manzanas y 3 limones');
      expect(result2, {'manzana': 2, 'limon': 3});
    });
    
    test('parseConsumptionCommand should handle different verb forms', () {
      // Test with "consumir"
      final result1 = service.parseConsumptionCommand('Voy a consumir 1 tomate');
      expect(result1, {'tomate': 1});
      
      // Test with "gastar"
      final result2 = service.parseConsumptionCommand('Voy a gastar 3 huevos');
      expect(result2, {'huevo': 3});
      
      // Test with future tense
      final result3 = service.parseConsumptionCommand('Consumiré 2 cebollas');
      expect(result3, {'cebolla': 2});
    });
    
    test('parseConsumptionCommand should handle accents and case insensitivity', () {
      // Test with accents
      final result1 = service.parseConsumptionCommand('Voy a usar 2 plátanos');
      expect(result1, {'platano': 2});
      
      // Test with uppercase
      final result2 = service.parseConsumptionCommand('VOY A USAR 1 MANZANA');
      expect(result2, {'manzana': 1});
    });
    
    test('parseConsumptionCommand should handle direct quantity mentions', () {
      // Test direct quantity mention
      final result = service.parseConsumptionCommand('2 tomates y 3 cebollas');
      expect(result, {'tomate': 2, 'cebolla': 3});
    });
    
    test('parseConsumptionCommand should aggregate quantities of the same product', () {
      // Test aggregation of quantities
      final result = service.parseConsumptionCommand('Voy a usar 2 manzanas y 1 manzana más');
      expect(result, {'manzana': 3});
    });
  });
}