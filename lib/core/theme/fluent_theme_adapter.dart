import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:system_theme/system_theme.dart';

import 'fluent_color_extensions.dart';

/// A utility class that adapts Material themes to Fluent UI themes.
///
/// This adapter provides methods to convert Material [ThemeData] to Fluent [FluentThemeData],
/// as well as methods to create Fluent themes from system settings.
class FluentThemeAdapter {
  /// Converts a Material [ThemeData] to a Fluent [FluentThemeData].
  ///
  /// This method maps the color scheme and other properties from Material to their
  /// Fluent UI equivalents, ensuring visual consistency when switching between platforms.
  static fluent.FluentThemeData fromMaterialTheme(ThemeData materialTheme) {
    // Use FluentColorExtensions to convert Material color to Fluent accent color
    final accentColor = FluentColorExtensions.colorToAccentColor(
        materialTheme.colorScheme.primary);

    return fluent.FluentThemeData(
      brightness: materialTheme.brightness,
      accentColor: accentColor,
      visualDensity: materialTheme.visualDensity,

      // Text themes
      typography: fluent.Typography.fromBrightness(
        brightness: materialTheme.brightness,
      ),

      // Colors
      activeColor: materialTheme.colorScheme.primary,
      inactiveColor:
          materialTheme.colorScheme.onSurface.withAlpha((255 * 0.4).round()),
      scaffoldBackgroundColor: materialTheme.scaffoldBackgroundColor,
      micaBackgroundColor: materialTheme.scaffoldBackgroundColor,
      acrylicBackgroundColor: materialTheme.scaffoldBackgroundColor,

      // Component themes
      buttonTheme: fluent.ButtonThemeData(
        defaultButtonStyle: fluent.ButtonStyle(
          backgroundColor: fluent.WidgetStateProperty.resolveWith((states) {
            if (states.isPressed) {
              return materialTheme.colorScheme.primary
                  .withAlpha((255 * 0.8).round());
            } else if (states.isHovered) {
              return materialTheme.colorScheme.primary
                  .withAlpha((255 * 0.9).round());
            }
            return materialTheme.colorScheme.primary;
          }),
          foregroundColor: fluent.WidgetStateProperty.resolveWith((states) {
            return materialTheme.colorScheme.onPrimary;
          }),
        ),
      ),

      navigationPaneTheme: fluent.NavigationPaneThemeData(
        backgroundColor: materialTheme.colorScheme.surface,
        highlightColor: materialTheme.colorScheme.primary,
      ),

      checkboxTheme: fluent.CheckboxThemeData(
        checkedDecoration: fluent.WidgetStateProperty.resolveWith((states) {
          return fluent.BoxDecoration(
            color: materialTheme.colorScheme.primary,
          );
        }),
      ),

      toggleSwitchTheme: fluent.ToggleSwitchThemeData(
        // Use the correct properties based on the fluent_ui version
        checkedDecoration: fluent.WidgetStateProperty.resolveWith((states) {
          return fluent.BoxDecoration(
            color: materialTheme.colorScheme.primary,
          );
        }),
      ),

      // Dialog themes
      dialogTheme: fluent.ContentDialogThemeData(
        decoration: fluent.BoxDecoration(
          color: materialTheme.dialogTheme.backgroundColor ??
              (materialTheme.brightness == Brightness.light
                  ? Colors.white
                  : Color(0xFF424242)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Tooltip theme
      tooltipTheme: fluent.TooltipThemeData(
        decoration: fluent.BoxDecoration(
          color: materialTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: materialTheme.colorScheme.outline),
        ),
        textStyle: materialTheme.textTheme.bodySmall?.copyWith(
          color: materialTheme.colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Creates a Fluent [FluentThemeData] from the system theme settings.
  ///
  /// This method uses the [SystemTheme] package to access Windows system accent colors
  /// and creates a Fluent theme that matches the system preferences.
  static fluent.FluentThemeData fromSystemTheme({
    Brightness brightness = Brightness.light,
  }) {
    // Check if SystemTheme is available and initialized
    bool isSystemThemeAvailable = true;
    try {
      // Try to access SystemTheme to see if it's available
      final _ = SystemTheme.accentColor;
    } catch (e) {
      // SystemTheme might not be available on all platforms
      isSystemThemeAvailable = false;
    }

    if (!isSystemThemeAvailable) {
      // Return a default theme if system theme is not available
      final defaultAccentColor =
          FluentColorExtensions.colorToAccentColor(fluent.Colors.blue);

      return fluent.FluentThemeData(
        brightness: brightness,
        accentColor: defaultAccentColor,
      );
    }

    // Get system accent color
    Color systemAccentColor;
    try {
      systemAccentColor = SystemTheme.accentColor.accent;
    } catch (e) {
      // Fallback if accent color is not available
      systemAccentColor = fluent.Colors.blue;
    }

    final accentColor =
        FluentColorExtensions.colorToAccentColor(systemAccentColor);

    return fluent.FluentThemeData(
      brightness: brightness,
      accentColor: accentColor,
      visualDensity: fluent.VisualDensity.standard,

      // Use system accent color for various components
      activeColor: systemAccentColor,
      inactiveColor: brightness == Brightness.light
          ? const Color(0xFF757575)
          : const Color(0xFFAAAAAA),

      // Background colors based on brightness
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF9F9F9)
          : const Color(0xFF202020),
      micaBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF9F9F9)
          : const Color(0xFF202020),
      acrylicBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF9F9F9)
          : const Color(0xFF202020),
    );
  }

  /// Creates a Fluent [FluentThemeData] that combines both Material theme and system theme.
  ///
  /// This method uses the Material theme as a base and enhances it with system accent colors
  /// when available, providing the best of both worlds.
  static fluent.FluentThemeData fromMaterialAndSystemTheme(
    ThemeData materialTheme, {
    bool useSystemAccentColor = true,
  }) {
    final fluentTheme = fromMaterialTheme(materialTheme);

    if (!useSystemAccentColor) {
      return fluentTheme;
    }

    // Check if SystemTheme is available
    try {
      // Try to access SystemTheme to see if it's available and initialized
      // Just accessing a property will throw if SystemTheme is not available
      final _ = SystemTheme.accentColor;
    } catch (e) {
      // SystemTheme might not be available on all platforms
      return fluentTheme;
    }

    // If we got here, SystemTheme is available
    Color systemAccentColor;
    try {
      systemAccentColor = SystemTheme.accentColor.accent;
    } catch (e) {
      // Fallback if accent color is not available
      return fluentTheme;
    }

    final accentColor =
        FluentColorExtensions.colorToAccentColor(systemAccentColor);

    return fluentTheme.copyWith(
      accentColor: accentColor,
      activeColor: systemAccentColor,
    );
  }
}
