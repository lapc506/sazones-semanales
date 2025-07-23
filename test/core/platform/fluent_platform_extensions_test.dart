import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sazones_semanales/core/platform/fluent_platform_extensions.dart';

void main() {
  group('FluentPlatformStyleExtension', () {
    test('toExtended converts Material style correctly', () {
      final materialStyle = PlatformStyle.Material;
      final extendedStyle = materialStyle.toExtended();

      expect(extendedStyle, equals(ExtendedPlatformStyle.Material));
    });

    test('toExtended converts Cupertino style correctly', () {
      final cupertinoStyle = PlatformStyle.Cupertino;
      final extendedStyle = cupertinoStyle.toExtended();

      expect(extendedStyle, equals(ExtendedPlatformStyle.Cupertino));
    });
  });

  group('ExtendedPlatformStyleExtension', () {
    test('toStandard converts Material style correctly', () {
      final extendedStyle = ExtendedPlatformStyle.Material;
      final standardStyle = extendedStyle.toStandard();

      expect(standardStyle, equals(PlatformStyle.Material));
    });

    test('toStandard converts Cupertino style correctly', () {
      final extendedStyle = ExtendedPlatformStyle.Cupertino;
      final standardStyle = extendedStyle.toStandard();

      expect(standardStyle, equals(PlatformStyle.Cupertino));
    });

    test('toStandard converts Fluent style to Material for compatibility', () {
      final extendedStyle = ExtendedPlatformStyle.Fluent;
      final standardStyle = extendedStyle.toStandard();

      expect(standardStyle, equals(PlatformStyle.Material));
    });

    test('isFluent returns true only for Fluent style', () {
      expect(ExtendedPlatformStyle.Fluent.isFluent, isTrue);
      expect(ExtendedPlatformStyle.Material.isFluent, isFalse);
      expect(ExtendedPlatformStyle.Cupertino.isFluent, isFalse);
    });

    test('isMaterial returns true only for Material style', () {
      expect(ExtendedPlatformStyle.Material.isMaterial, isTrue);
      expect(ExtendedPlatformStyle.Fluent.isMaterial, isFalse);
      expect(ExtendedPlatformStyle.Cupertino.isMaterial, isFalse);
    });

    test('isCupertino returns true only for Cupertino style', () {
      expect(ExtendedPlatformStyle.Cupertino.isCupertino, isTrue);
      expect(ExtendedPlatformStyle.Material.isCupertino, isFalse);
      expect(ExtendedPlatformStyle.Fluent.isCupertino, isFalse);
    });
  });
}
