import 'package:flutter/material.dart';
import '../platform/fluent_platform_detector.dart';
import '../platform/fluent_platform_extensions.dart';

/// A utility class for selecting the appropriate widget based on the platform style.
class FluentWidgetSelector {
  /// Selects the appropriate widget based on the platform style.
  ///
  /// This method returns the appropriate widget based on the platform style:
  /// - Fluent: [fluentBuilder]
  /// - Material: [materialBuilder]
  /// - Cupertino: [cupertinoBuilder]
  ///
  /// If a builder for a specific platform is not provided, it falls back to the next available builder
  /// in the following order: material, fluent, cupertino.
  static Widget select(
    BuildContext context, {
    required WidgetBuilder materialBuilder,
    WidgetBuilder? cupertinoBuilder,
    WidgetBuilder? fluentBuilder,
  }) {
    final platformStyle = FluentPlatformDetector.getPlatformStyle(context);

    switch (platformStyle) {
      case ExtendedPlatformStyle.Fluent:
        return fluentBuilder?.call(context) ?? materialBuilder(context);
      case ExtendedPlatformStyle.Cupertino:
        return cupertinoBuilder?.call(context) ?? materialBuilder(context);
      case ExtendedPlatformStyle.Material:
        return materialBuilder(context);
    }
  }

  /// Selects the appropriate value based on the platform style.
  ///
  /// This method returns the appropriate value based on the platform style:
  /// - Fluent: [fluent]
  /// - Material: [material]
  /// - Cupertino: [cupertino]
  ///
  /// If a value for a specific platform is not provided, it falls back to the next available value
  /// in the following order: material, fluent, cupertino.
  static T selectValue<T>(
    BuildContext context, {
    required T material,
    T? cupertino,
    T? fluent,
  }) {
    final platformStyle = FluentPlatformDetector.getPlatformStyle(context);

    switch (platformStyle) {
      case ExtendedPlatformStyle.Fluent:
        return fluent ?? material;
      case ExtendedPlatformStyle.Cupertino:
        return cupertino ?? material;
      case ExtendedPlatformStyle.Material:
        return material;
    }
  }

  /// Selects the appropriate widget based on the platform style with a fallback.
  ///
  /// This method is similar to [select], but it provides a fallback widget in case
  /// the selected widget builder throws an exception.
  static Widget selectWithFallback(
    BuildContext context, {
    required WidgetBuilder materialBuilder,
    WidgetBuilder? cupertinoBuilder,
    WidgetBuilder? fluentBuilder,
    WidgetBuilder? fallbackBuilder,
  }) {
    try {
      return select(
        context,
        materialBuilder: materialBuilder,
        cupertinoBuilder: cupertinoBuilder,
        fluentBuilder: fluentBuilder,
      );
    } catch (e) {
      if (fallbackBuilder != null) {
        return fallbackBuilder(context);
      } else {
        return materialBuilder(context);
      }
    }
  }
}
