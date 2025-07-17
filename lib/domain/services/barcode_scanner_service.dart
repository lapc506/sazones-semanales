/// Interface for barcode scanner service
abstract class BarcodeScannerService {
  /// Scans a barcode using the device camera
  /// 
  /// Returns the scanned barcode as a string or null if scanning was cancelled
  Future<String?> scanBarcode();
  
  /// Validates if the provided barcode string is in a valid format
  /// 
  /// Returns true if the barcode is valid, false otherwise
  bool isValidBarcode(String barcode);
  
  /// Returns the type of barcode (EAN-13, UPC-A, etc.)
  /// 
  /// Returns null if the barcode format is not recognized
  String? getBarcodeType(String barcode);
}