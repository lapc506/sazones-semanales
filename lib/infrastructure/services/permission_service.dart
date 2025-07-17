import 'package:permission_handler/permission_handler.dart';

/// Service for handling permissions
class PermissionService {
  /// Requests camera permission
  /// 
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  /// Checks if camera permission is granted
  /// 
  /// Returns true if permission is granted, false otherwise
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  /// Requests microphone permission
  /// 
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  /// Checks if microphone permission is granted
  /// 
  /// Returns true if permission is granted, false otherwise
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
  
  /// Opens app settings
  static Future<bool> openSettings() async {
    // Use the openAppSettings function from the permission_handler package
    return await openAppSettings();
  }
}