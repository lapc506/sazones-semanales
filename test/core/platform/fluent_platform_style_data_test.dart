import 'package:flutter_test/flutter_test.dart';
import 'package:sazones_semanales/core/platform/fluent_platform_extensions.dart';
import 'package:sazones_semanales/core/platform/fluent_platform_style_data.dart';

void main() {
  group('FluentPlatformStyleData', () {
    test('default constructor creates instance with default values', () {
      final styleData = FluentPlatformStyleData();

      expect(styleData.android, equals(ExtendedPlatformStyle.Material));
      expect(styleData.ios, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.macos, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.windows, equals(ExtendedPlatformStyle.Fluent));
      expect(styleData.web, equals(ExtendedPlatformStyle.Material));
      expect(styleData.fuchsia, equals(ExtendedPlatformStyle.Material));
      expect(styleData.linux, equals(ExtendedPlatformStyle.Material));
    });

    test('material constructor creates instance with all Material styles', () {
      final styleData = FluentPlatformStyleData.material();

      expect(styleData.android, equals(ExtendedPlatformStyle.Material));
      expect(styleData.ios, equals(ExtendedPlatformStyle.Material));
      expect(styleData.macos, equals(ExtendedPlatformStyle.Material));
      expect(styleData.windows, equals(ExtendedPlatformStyle.Material));
      expect(styleData.web, equals(ExtendedPlatformStyle.Material));
      expect(styleData.fuchsia, equals(ExtendedPlatformStyle.Material));
      expect(styleData.linux, equals(ExtendedPlatformStyle.Material));
    });

    test('cupertino constructor creates instance with all Cupertino styles',
        () {
      final styleData = FluentPlatformStyleData.cupertino();

      expect(styleData.android, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.ios, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.macos, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.windows, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.web, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.fuchsia, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.linux, equals(ExtendedPlatformStyle.Cupertino));
    });

    test(
        'fluentOnWindows constructor creates instance with Fluent for Windows only',
        () {
      final styleData = FluentPlatformStyleData.fluentOnWindows();

      expect(styleData.android, equals(ExtendedPlatformStyle.Material));
      expect(styleData.ios, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.macos, equals(ExtendedPlatformStyle.Cupertino));
      expect(styleData.windows, equals(ExtendedPlatformStyle.Fluent));
      expect(styleData.web, equals(ExtendedPlatformStyle.Material));
      expect(styleData.fuchsia, equals(ExtendedPlatformStyle.Material));
      expect(styleData.linux, equals(ExtendedPlatformStyle.Material));
    });

    test('copyWith creates a new instance with updated values', () {
      final styleData = FluentPlatformStyleData();
      final updatedStyleData = styleData.copyWith(
        android: ExtendedPlatformStyle.Cupertino,
        windows: ExtendedPlatformStyle.Material,
      );

      expect(updatedStyleData.android, equals(ExtendedPlatformStyle.Cupertino));
      expect(updatedStyleData.ios,
          equals(ExtendedPlatformStyle.Cupertino)); // Unchanged
      expect(updatedStyleData.macos,
          equals(ExtendedPlatformStyle.Cupertino)); // Unchanged
      expect(updatedStyleData.windows, equals(ExtendedPlatformStyle.Material));
      expect(updatedStyleData.web,
          equals(ExtendedPlatformStyle.Material)); // Unchanged
      expect(updatedStyleData.fuchsia,
          equals(ExtendedPlatformStyle.Material)); // Unchanged
      expect(updatedStyleData.linux,
          equals(ExtendedPlatformStyle.Material)); // Unchanged
    });

    test('equality operator works correctly', () {
      final styleData1 = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Material,
        windows: ExtendedPlatformStyle.Fluent,
      );

      final styleData2 = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Material,
        windows: ExtendedPlatformStyle.Fluent,
      );

      final styleData3 = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Cupertino,
        windows: ExtendedPlatformStyle.Fluent,
      );

      expect(styleData1 == styleData2, isTrue);
      expect(styleData1 == styleData3, isFalse);
    });

    test('hashCode is consistent with equality', () {
      final styleData1 = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Material,
        windows: ExtendedPlatformStyle.Fluent,
      );

      final styleData2 = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Material,
        windows: ExtendedPlatformStyle.Fluent,
      );

      expect(styleData1.hashCode, equals(styleData2.hashCode));
    });

    test('toString returns a descriptive string', () {
      final styleData = FluentPlatformStyleData(
        android: ExtendedPlatformStyle.Material,
        windows: ExtendedPlatformStyle.Fluent,
      );

      final stringRepresentation = styleData.toString();
      expect(stringRepresentation,
          contains('android: ExtendedPlatformStyle.Material'));
      expect(stringRepresentation,
          contains('windows: ExtendedPlatformStyle.Fluent'));
    });

    // Note: We can't easily test currentPlatformStyle, shouldUseFluent, shouldUseMaterial,
    // and shouldUseCupertino because they depend on the actual platform the test is running on.
    // We would need to mock defaultTargetPlatform and kIsWeb, which is challenging in a unit test.
  });
}
