import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

/// Abstract interface for building platform-specific widgets.
///
/// This interface extends the concept of platform-specific widgets to include
/// Fluent UI widgets for Windows platform alongside Material and Cupertino widgets.
abstract class PlatformWidgetBuilder<T extends Widget> {
  /// Builds a Material-styled widget.
  ///
  /// This method is called when the platform style is set to Material.
  T buildMaterial(BuildContext context);

  /// Builds a Cupertino-styled widget.
  ///
  /// This method is called when the platform style is set to Cupertino.
  T buildCupertino(BuildContext context);

  /// Builds a Fluent UI-styled widget.
  ///
  /// This method is called when the platform style is set to Fluent.
  /// This is typically used on Windows platform.
  T buildFluent(BuildContext context);
}

/// A mixin that provides default implementations for platform-specific widget building.
///
/// This mixin can be used by classes that implement [PlatformWidgetBuilder] to provide
/// default implementations for some of the platform-specific build methods.
mixin PlatformWidgetBuilderMixin<T extends Widget>
    implements PlatformWidgetBuilder<T> {
  /// Default implementation that falls back to Material style.
  ///
  /// Override this method to provide a custom Cupertino implementation.
  @override
  T buildCupertino(BuildContext context) => buildMaterial(context);

  /// Default implementation that falls back to Material style.
  ///
  /// Override this method to provide a custom Fluent implementation.
  @override
  T buildFluent(BuildContext context) => buildMaterial(context);
}

/// A mixin that provides Fluent-specific widget building with Material fallback.
///
/// This mixin is useful for widgets that have a Fluent implementation but want to
/// fall back to Material for other platforms.
mixin FluentWidgetBuilderMixin<T extends Widget>
    implements PlatformWidgetBuilder<T> {
  /// Default implementation that falls back to Fluent style.
  ///
  /// Override this method to provide a custom Material implementation.
  @override
  T buildMaterial(BuildContext context) => buildFluent(context);

  /// Default implementation that falls back to Fluent style.
  ///
  /// Override this method to provide a custom Cupertino implementation.
  @override
  T buildCupertino(BuildContext context) => buildFluent(context);
}

/// A utility class for converting between Flutter and Fluent UI widgets.
///
/// This class provides methods to convert between Flutter widgets and their
/// Fluent UI equivalents.
class FluentWidgetConverter {
  /// Converts a Flutter [Color] to a Fluent UI [Color].
  static Color flutterToFluentColor(Color color) => color;

  /// Converts a Fluent UI [Color] to a Flutter [Color].
  static Color fluentToFlutterColor(Color color) => color;

  /// Converts Flutter [EdgeInsets] to Fluent UI [EdgeInsets].
  static EdgeInsets flutterToFluentEdgeInsets(EdgeInsets insets) => insets;

  /// Converts Fluent UI [EdgeInsets] to Flutter [EdgeInsets].
  static EdgeInsets fluentToFlutterEdgeInsets(EdgeInsets insets) => insets;

  /// Converts a Flutter [TextStyle] to a Fluent UI [TextStyle].
  static TextStyle flutterToFluentTextStyle(TextStyle style) => style;

  /// Converts a Fluent UI [TextStyle] to a Flutter [TextStyle].
  static TextStyle fluentToFlutterTextStyle(TextStyle style) => style;

  /// Converts a Flutter [BorderRadius] to a Fluent UI [BorderRadius].
  static BorderRadius flutterToFluentBorderRadius(BorderRadius radius) =>
      radius;

  /// Converts a Fluent UI [BorderRadius] to a Flutter [BorderRadius].
  static BorderRadius fluentToFlutterBorderRadius(BorderRadius radius) =>
      radius;
}
