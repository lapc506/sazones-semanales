import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:sazones_semanales/core/theme/fluent_theme_adapter.dart';

void main() {
  group('FluentThemeAdapter', () {
    test('fromMaterialTheme converts Material theme to Fluent theme', () {
      final materialTheme = ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.green,
        ),
        brightness: Brightness.light,
      );

      final fluentTheme = FluentThemeAdapter.fromMaterialTheme(materialTheme);

      expect(fluentTheme, isA<fluent.FluentThemeData>());
      expect(fluentTheme.brightness, equals(Brightness.light));
      expect(fluentTheme.activeColor, equals(Colors.blue));
    });

    test(
        'fromSystemTheme creates a Fluent theme with default values when system theme is not available',
        () {
      final fluentTheme = FluentThemeAdapter.fromSystemTheme();

      expect(fluentTheme, isA<fluent.FluentThemeData>());
      expect(fluentTheme.brightness, equals(Brightness.light));
    });

    test(
        'fromMaterialAndSystemTheme returns material-based theme when system accent is not used',
        () {
      final materialTheme = ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.purple,
          secondary: Colors.orange,
        ),
        brightness: Brightness.light,
      );

      final fluentTheme = FluentThemeAdapter.fromMaterialAndSystemTheme(
        materialTheme,
        useSystemAccentColor: false,
      );

      expect(fluentTheme, isA<fluent.FluentThemeData>());
      expect(fluentTheme.activeColor, equals(Colors.purple));
    });
  });
}
