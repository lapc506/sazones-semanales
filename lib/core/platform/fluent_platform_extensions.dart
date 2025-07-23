// ignore_for_file: constant_identifier_names

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Extended PlatformStyle enum that includes Fluent Design System support
/// for Windows platform integration
enum ExtendedPlatformStyle {
  Material,
  Cupertino,
  Fluent,
}

/// Extension methods for PlatformStyle to support fluent_ui integration
extension FluentPlatformStyleExtension on PlatformStyle {
  /// Converts standard PlatformStyle to ExtendedPlatformStyle
  ExtendedPlatformStyle toExtended() {
    switch (this) {
      case PlatformStyle.Material:
        return ExtendedPlatformStyle.Material;
      case PlatformStyle.Cupertino:
        return ExtendedPlatformStyle.Cupertino;
    }
  }
}

/// Extension methods for ExtendedPlatformStyle
extension ExtendedPlatformStyleExtension on ExtendedPlatformStyle {
  /// Converts ExtendedPlatformStyle back to standard PlatformStyle
  /// Returns Material for fluent style to maintain compatibility
  PlatformStyle toStandard() {
    switch (this) {
      case ExtendedPlatformStyle.Material:
        return PlatformStyle.Material;
      case ExtendedPlatformStyle.Cupertino:
        return PlatformStyle.Cupertino;
      case ExtendedPlatformStyle.Fluent:
        return PlatformStyle.Material; // Fallback for compatibility
    }
  }

  /// Checks if the current style is fluent
  bool get isFluent => this == ExtendedPlatformStyle.Fluent;

  /// Checks if the current style is material
  bool get isMaterial => this == ExtendedPlatformStyle.Material;

  /// Checks if the current style is cupertino
  bool get isCupertino => this == ExtendedPlatformStyle.Cupertino;
}
