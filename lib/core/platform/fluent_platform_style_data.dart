import 'package:flutter/foundation.dart';
import 'fluent_platform_extensions.dart';

/// Extended PlatformStyleData that supports fluent_ui integration
/// This class extends the concept of platform-specific styling to include
/// Fluent Design System for Windows platform
class FluentPlatformStyleData {
  final ExtendedPlatformStyle android;
  final ExtendedPlatformStyle ios;
  final ExtendedPlatformStyle macos;
  final ExtendedPlatformStyle windows;
  final ExtendedPlatformStyle web;
  final ExtendedPlatformStyle fuchsia;
  final ExtendedPlatformStyle linux;

  const FluentPlatformStyleData({
    this.android = ExtendedPlatformStyle.Material,
    this.ios = ExtendedPlatformStyle.Cupertino,
    this.macos = ExtendedPlatformStyle.Cupertino,
    this.windows = ExtendedPlatformStyle.Fluent,
    this.web = ExtendedPlatformStyle.Material,
    this.fuchsia = ExtendedPlatformStyle.Material,
    this.linux = ExtendedPlatformStyle.Material,
  });

  /// Creates a FluentPlatformStyleData with all platforms using Material style
  const FluentPlatformStyleData.material()
      : android = ExtendedPlatformStyle.Material,
        ios = ExtendedPlatformStyle.Material,
        macos = ExtendedPlatformStyle.Material,
        windows = ExtendedPlatformStyle.Material,
        web = ExtendedPlatformStyle.Material,
        fuchsia = ExtendedPlatformStyle.Material,
        linux = ExtendedPlatformStyle.Material;

  /// Creates a FluentPlatformStyleData with all platforms using Cupertino style
  const FluentPlatformStyleData.cupertino()
      : android = ExtendedPlatformStyle.Cupertino,
        ios = ExtendedPlatformStyle.Cupertino,
        macos = ExtendedPlatformStyle.Cupertino,
        windows = ExtendedPlatformStyle.Cupertino,
        web = ExtendedPlatformStyle.Cupertino,
        fuchsia = ExtendedPlatformStyle.Cupertino,
        linux = ExtendedPlatformStyle.Cupertino;

  /// Creates a FluentPlatformStyleData with Windows using Fluent and others using defaults
  const FluentPlatformStyleData.fluentOnWindows()
      : android = ExtendedPlatformStyle.Material,
        ios = ExtendedPlatformStyle.Cupertino,
        macos = ExtendedPlatformStyle.Cupertino,
        windows = ExtendedPlatformStyle.Fluent,
        web = ExtendedPlatformStyle.Material,
        fuchsia = ExtendedPlatformStyle.Material,
        linux = ExtendedPlatformStyle.Material;

  /// Gets the appropriate style for the current platform
  ExtendedPlatformStyle get currentPlatformStyle {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.fuchsia:
        return fuchsia;
      case TargetPlatform.linux:
        return linux;
    }
  }

  /// Checks if the current platform should use fluent style
  bool get shouldUseFluent => currentPlatformStyle.isFluent;

  /// Checks if the current platform should use material style
  bool get shouldUseMaterial => currentPlatformStyle.isMaterial;

  /// Checks if the current platform should use cupertino style
  bool get shouldUseCupertino => currentPlatformStyle.isCupertino;

  /// Creates a copy of this FluentPlatformStyleData with updated values
  FluentPlatformStyleData copyWith({
    ExtendedPlatformStyle? android,
    ExtendedPlatformStyle? ios,
    ExtendedPlatformStyle? macos,
    ExtendedPlatformStyle? windows,
    ExtendedPlatformStyle? web,
    ExtendedPlatformStyle? fuchsia,
    ExtendedPlatformStyle? linux,
  }) {
    return FluentPlatformStyleData(
      android: android ?? this.android,
      ios: ios ?? this.ios,
      macos: macos ?? this.macos,
      windows: windows ?? this.windows,
      web: web ?? this.web,
      fuchsia: fuchsia ?? this.fuchsia,
      linux: linux ?? this.linux,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FluentPlatformStyleData &&
        other.android == android &&
        other.ios == ios &&
        other.macos == macos &&
        other.windows == windows &&
        other.web == web &&
        other.fuchsia == fuchsia &&
        other.linux == linux;
  }

  @override
  int get hashCode {
    return android.hashCode ^
        ios.hashCode ^
        macos.hashCode ^
        windows.hashCode ^
        web.hashCode ^
        fuchsia.hashCode ^
        linux.hashCode;
  }

  @override
  String toString() {
    return 'FluentPlatformStyleData('
        'android: $android, '
        'ios: $ios, '
        'macos: $macos, '
        'windows: $windows, '
        'web: $web, '
        'fuchsia: $fuchsia, '
        'linux: $linux)';
  }
}
