import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

/// Utility class for converting between Material and Fluent UI colors.
/// 
/// This class provides static methods to avoid extension conflicts with
/// the built-in fluent_ui extensions.
class FluentColorExtensions {
  /// Converts a Material [Color] to a Fluent UI [AccentColor].
  /// 
  /// This method creates a proper accent color with light and dark variants
  /// based on the original color, suitable for Fluent UI theming.
  static fluent.AccentColor colorToAccentColor(Color color) {
    // Create a swatch of colors based on the original color
    return fluent.AccentColor.swatch({
      'darkest': _adjustBrightness(color, -0.4),
      'darker': _adjustBrightness(color, -0.2),
      'dark': _adjustBrightness(color, -0.1),
      'normal': color,
      'light': _adjustBrightness(color, 0.1),
      'lighter': _adjustBrightness(color, 0.2),
      'lightest': _adjustBrightness(color, 0.4),
    });
  }
  
  /// Creates a Fluent UI [WidgetStateProperty] color from a Material [Color].
  /// 
  /// This method creates a widget state property with different colors for different states
  /// (normal, pressed, hovered, etc.) based on the original color.
  static fluent.WidgetStateProperty<Color> colorToButtonState(Color color) {
    return fluent.WidgetStateProperty.resolveWith((states) {
      if (states.isPressed) {
        return _adjustBrightness(color, -0.2);
      } else if (states.isHovered) {
        return _adjustBrightness(color, 0.1);
      }
      return color;
    });
  }
  
  /// Creates a Fluent UI [WidgetStateProperty] for text from a Material [Color].
  /// 
  /// This method creates a widget state property for text with different colors for different states
  /// based on the original color, with appropriate contrast adjustments.
  static fluent.WidgetStateProperty<Color> colorToTextButtonState(
    Color color, {
    bool inverted = false
  }) {
    final baseColor = inverted ? Colors.white : color;
    
    return fluent.WidgetStateProperty.resolveWith((states) {
      if (states.isDisabled) {
        return baseColor.withAlpha((255 * 0.5).round());
      } else if (states.isPressed) {
        return _adjustBrightness(baseColor, inverted ? 0.2 : -0.2);
      } else if (states.isHovered) {
        return _adjustBrightness(baseColor, inverted ? -0.1 : 0.1);
      }
      return baseColor;
    });
  }
  
  /// Converts a Fluent UI [AccentColor] to a Material [MaterialColor].
  /// 
  /// This method creates a Material color swatch based on the Fluent accent color.
  static MaterialColor accentColorToMaterialColor(fluent.AccentColor accentColor) {
    final color = accentColor.normal;
    
    return MaterialColor(color.value, {
      50: _adjustBrightness(color, 0.4),
      100: _adjustBrightness(color, 0.3),
      200: _adjustBrightness(color, 0.2),
      300: _adjustBrightness(color, 0.1),
      400: _adjustBrightness(color, 0.05),
      500: color,
      600: _adjustBrightness(color, -0.05),
      700: _adjustBrightness(color, -0.1),
      800: _adjustBrightness(color, -0.2),
      900: _adjustBrightness(color, -0.3),
    });
  }
  
  /// Adjusts the brightness of a color by the given factor.
  /// 
  /// A positive factor makes the color lighter, while a negative factor makes it darker.
  /// The factor should be between -1.0 and 1.0.
  static Color _adjustBrightness(Color color, double factor) {
    assert(factor >= -1.0 && factor <= 1.0);
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
}