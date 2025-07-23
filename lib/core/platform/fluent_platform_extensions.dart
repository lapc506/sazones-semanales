import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Extended PlatformStyle enum that includes Fluent Design System support
/// for Windows platform integration
enum ExtendedPlatformStyle {
  material,
  cupertino,
  fluent,
}

/// Extension methods for PlatformStyle to support fluent_ui integration
extension FluentPlatformStyleExtension on PlatformStyle {
  /// Converts standard PlatformStyle to ExtendedPlatformStyle
  ExtendedPlatformStyle toExtended() {
    switch (this) {
      case PlatformStyle.Material:
        return ExtendedPlatformStyle.material;
      case PlatformStyle.Cupertino:
        return ExtendedPlatformStyle.cupertino;
    }
  }
}

/// Extension methods for ExtendedPlatformStyle
extension ExtendedPlatformStyleExtension on ExtendedPlatformStyle {
  /// Converts ExtendedPlatformStyle back to standard PlatformStyle
  /// Returns Material for fluent style to maintain compatibility
  PlatformStyle toStandard() {
    switch (this) {
      case ExtendedPlatformStyle.material:
        return PlatformStyle.Material;
      case ExtendedPlatformStyle.cupertino:
        return PlatformStyle.Cupertino;
      case ExtendedPlatformStyle.fluent:
        return PlatformStyle.Material; // Fallback for compatibility
    }
  }

  /// Checks if the current style is fluent
  bool get isFluent => this == ExtendedPlatformStyle.fluent;

  /// Checks if the current style is material
  bool get isMaterial => this == ExtendedPlatformStyle.material;

  /// Checks if the current style is cupertino
  bool get isCupertino => this == ExtendedPlatformStyle.cupertino;
}