import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'fluent_platform_extensions.dart';

/// A utility class for detecting platform and determining the appropriate platform style.
class FluentPlatformDetector {
  /// Determines if the current platform is Windows.
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// Determines if the current platform is iOS or macOS.
  static bool get isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Determines if the current platform is Android, Fuchsia, or Linux.
  static bool get isMaterial =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.fuchsia ||
      defaultTargetPlatform == TargetPlatform.linux;

  /// Determines if the current platform is Web.
  static bool get isWeb => kIsWeb;

  /// Gets the default platform style for the current platform.
  ///
  /// This method returns the default platform style based on the current platform:
  /// - Windows: Fluent
  /// - iOS/macOS: Cupertino
  /// - Android/Fuchsia/Linux: Material
  /// - Web: Material
  static ExtendedPlatformStyle getDefaultPlatformStyle() {
    if (isWindows) {
      return ExtendedPlatformStyle.Fluent;
    } else if (isApple) {
      return ExtendedPlatformStyle.Cupertino;
    } else {
      return ExtendedPlatformStyle.Material;
    }
  }

  /// Gets the platform style from the given context.
  ///
  /// This method retrieves the platform style from the [PlatformProvider] if available,
  /// otherwise it falls back to the default platform style.
  static ExtendedPlatformStyle getPlatformStyle(BuildContext context) {
    final platformProvider = PlatformProvider.of(context);
    if (platformProvider == null) {
      return getDefaultPlatformStyle();
    }

    final platform = platformProvider.platform ?? Theme.of(context).platform;
    final platformStyle = platformProvider.settings.platformStyle;

    switch (platform) {
      case TargetPlatform.android:
        return platformStyle.android.toExtended();
      case TargetPlatform.iOS:
        return platformStyle.ios.toExtended();
      case TargetPlatform.macOS:
        return platformStyle.macos.toExtended();
      case TargetPlatform.windows:
        // Check if we have a custom style for Windows
        if (platformStyle.windows == PlatformStyle.Material) {
          return ExtendedPlatformStyle.Material;
        } else if (platformStyle.windows == PlatformStyle.Cupertino) {
          return ExtendedPlatformStyle.Cupertino;
        } else {
          // Default to Fluent for Windows
          return ExtendedPlatformStyle.Fluent;
        }
      case TargetPlatform.linux:
        return platformStyle.linux.toExtended();
      case TargetPlatform.fuchsia:
        return platformStyle.fuchsia.toExtended();
    }
  }

  /// Determines if the given context should use Fluent style.
  ///
  /// This method checks if the platform style for the given context is Fluent.
  static bool shouldUseFluent(BuildContext context) {
    return getPlatformStyle(context) == ExtendedPlatformStyle.Fluent;
  }

  /// Determines if the given context should use Material style.
  ///
  /// This method checks if the platform style for the given context is Material.
  static bool shouldUseMaterial(BuildContext context) {
    return getPlatformStyle(context) == ExtendedPlatformStyle.Material;
  }

  /// Determines if the given context should use Cupertino style.
  ///
  /// This method checks if the platform style for the given context is Cupertino.
  static bool shouldUseCupertino(BuildContext context) {
    return getPlatformStyle(context) == ExtendedPlatformStyle.Cupertino;
  }
}
