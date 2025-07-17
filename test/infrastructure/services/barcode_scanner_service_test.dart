import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sazones_semanales/domain/services/barcode_scanner_service.dart';
import 'package:sazones_semanales/infrastructure/services/barcode_scanner_service_impl.dart';

void main() {
  late BarcodeScannerService service;
  
  setUp(() {
    // Create a mock BuildContext for testing
    final mockContext = MaterialApp(home: Container()).createState().context;
    service = BarcodeScannerServiceImpl(mockContext);
  });
  
  group('BarcodeScannerService', () {
    test('isValidBarcode should validate EAN-13 correctly', () {
      // Valid EAN-13 codes
      expect(service.isValidBarcode('7501234567890'), isTrue);
      expect(service.isValidBarcode('9780201379624'), isTrue);
      
      // Invalid EAN-13 codes
      expect(service.isValidBarcode('750123456789'), isFalse); // Too short
      expect(service.isValidBarcode('75012345678901'), isFalse); // Too long
      expect(service.isValidBarcode('7501234A67890'), isFalse); // Contains letter
    });
    
    test('isValidBarcode should validate UPC-A correctly', () {
      // Valid UPC-A codes
      expect(service.isValidBarcode('123456789012'), isTrue);
      expect(service.isValidBarcode('036000291452'), isTrue);
      
      // Invalid UPC-A codes
      expect(service.isValidBarcode('12345678901'), isFalse); // Too short
      expect(service.isValidBarcode('1234567890123'), isFalse); // Too long
      expect(service.isValidBarcode('12345A789012'), isFalse); // Contains letter
    });
    
    test('getBarcodeType should identify barcode types correctly', () {
      expect(service.getBarcodeType('7501234567890'), equals('EAN-13'));
      expect(service.getBarcodeType('123456789012'), equals('UPC-A'));
      expect(service.getBarcodeType('12345678'), equals('EAN-8'));
      expect(service.getBarcodeType('ABC-123'), equals('CODE-39'));
      expect(service.getBarcodeType('http://example.com'), equals('QR'));
    });
  });
}