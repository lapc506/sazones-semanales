import 'package:flutter_test/flutter_test.dart';
import 'package:sazones_semanales/core/config/fluent_configuration.dart';

void main() {
  group('FluentConfiguration', () {
    test('default constructor creates instance with default values', () {
      final config = FluentConfiguration();

      expect(config.useSystemAccentColor, isTrue);
      expect(config.enableAcrylicEffects, isTrue);
      expect(config.navigationStyle, equals(FluentNavigationStyle.automatic));
      expect(config.useRevealFocus, isTrue);
      expect(config.useRevealHover, isTrue);
    });

    test('copyWith creates a new instance with updated values', () {
      final config = FluentConfiguration();
      final updatedConfig = config.copyWith(
        useSystemAccentColor: false,
        navigationStyle: FluentNavigationStyle.compact,
      );

      expect(updatedConfig.useSystemAccentColor, isFalse);
      expect(updatedConfig.enableAcrylicEffects, isTrue); // Unchanged
      expect(
          updatedConfig.navigationStyle, equals(FluentNavigationStyle.compact));
      expect(updatedConfig.useRevealFocus, isTrue); // Unchanged
      expect(updatedConfig.useRevealHover, isTrue); // Unchanged
    });

    test('equality operator works correctly', () {
      final config1 = FluentConfiguration(
        useSystemAccentColor: true,
        enableAcrylicEffects: false,
        navigationStyle: FluentNavigationStyle.left,
      );

      final config2 = FluentConfiguration(
        useSystemAccentColor: true,
        enableAcrylicEffects: false,
        navigationStyle: FluentNavigationStyle.left,
      );

      final config3 = FluentConfiguration(
        useSystemAccentColor: false,
        enableAcrylicEffects: false,
        navigationStyle: FluentNavigationStyle.left,
      );

      expect(config1 == config2, isTrue);
      expect(config1 == config3, isFalse);
    });

    test('hashCode is consistent with equality', () {
      final config1 = FluentConfiguration(
        useSystemAccentColor: true,
        enableAcrylicEffects: false,
      );

      final config2 = FluentConfiguration(
        useSystemAccentColor: true,
        enableAcrylicEffects: false,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString returns a descriptive string', () {
      final config = FluentConfiguration(
        useSystemAccentColor: true,
        enableAcrylicEffects: false,
      );

      final stringRepresentation = config.toString();
      expect(stringRepresentation, contains('useSystemAccentColor: true'));
      expect(stringRepresentation, contains('enableAcrylicEffects: false'));
    });
  });
}
