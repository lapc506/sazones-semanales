import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../platform/fluent_platform_extensions.dart';
import 'platform_widget_builder.dart' as local;

/// A widget that adapts to the current platform style, including Fluent UI for Windows.
///
/// This widget extends the concept of platform-specific widgets from flutter_platform_widgets
/// to include Fluent UI widgets for Windows platform.
class MultiPlatformWidget<T extends Widget> extends StatelessWidget {
  /// The builder that provides platform-specific implementations.
  final local.PlatformWidgetBuilder<T> builder;

  /// Creates a new [MultiPlatformWidget].
  ///
  /// The [builder] parameter is required and provides platform-specific implementations.
  const MultiPlatformWidget({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get the platform style from the PlatformProvider
    final platformProvider = PlatformProvider.of(context);
    final platformStyle = platformProvider?.settings.platformStyle;

    // Convert the standard PlatformStyle to our extended version
    ExtendedPlatformStyle? extendedStyle;

    if (platformStyle != null) {
      // Determine the platform
      final platform = platformProvider?.platform ?? Theme.of(context).platform;

      switch (platform) {
        case TargetPlatform.android:
          extendedStyle = platformStyle.android.toExtended();
          break;
        case TargetPlatform.iOS:
          extendedStyle = platformStyle.ios.toExtended();
          break;
        case TargetPlatform.macOS:
          extendedStyle = platformStyle.macos.toExtended();
          break;
        case TargetPlatform.windows:
          // Check if we have a custom style for Windows
          if (platformStyle.windows == PlatformStyle.Material) {
            extendedStyle = ExtendedPlatformStyle.Material;
          } else if (platformStyle.windows == PlatformStyle.Cupertino) {
            extendedStyle = ExtendedPlatformStyle.Cupertino;
          } else {
            // Default to Fluent for Windows
            extendedStyle = ExtendedPlatformStyle.Fluent;
          }
          break;
        case TargetPlatform.linux:
          extendedStyle = platformStyle.linux.toExtended();
          break;
        case TargetPlatform.fuchsia:
          extendedStyle = platformStyle.fuchsia.toExtended();
          break;
      }
    }

    // If no extended style is determined, use the default platform style
    extendedStyle ??= _getDefaultPlatformStyle(Theme.of(context).platform);

    // Build the appropriate widget based on the platform style
    switch (extendedStyle) {
      case ExtendedPlatformStyle.Material:
        return builder.buildMaterial(context);
      case ExtendedPlatformStyle.Cupertino:
        return builder.buildCupertino(context);
      case ExtendedPlatformStyle.Fluent:
        return builder.buildFluent(context);
    }
  }

  /// Gets the default platform style based on the target platform.
  ExtendedPlatformStyle _getDefaultPlatformStyle(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ExtendedPlatformStyle.Cupertino;
      case TargetPlatform.windows:
        return ExtendedPlatformStyle.Fluent;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        return ExtendedPlatformStyle.Material;
    }
  }
}
