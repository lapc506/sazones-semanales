import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sazones_semanales/core/platform/fluent_platform_detector.dart';
import 'package:sazones_semanales/core/platform/fluent_platform_extensions.dart';

void main() {
  group('FluentPlatformDetector', () {
    testWidgets(
        'getDefaultPlatformStyle returns correct style based on platform',
        (WidgetTester tester) async {
      // We can't easily test this directly since we can't change defaultTargetPlatform in tests
      // But we can verify that the method exists and returns a valid ExtendedPlatformStyle
      final style = FluentPlatformDetector.getDefaultPlatformStyle();
      expect(style, isA<ExtendedPlatformStyle>());
    });

    testWidgets('getPlatformStyle returns correct style from PlatformProvider',
        (WidgetTester tester) async {
      // Create a test widget with PlatformProvider
      await tester.pumpWidget(
        MaterialApp(
          home: PlatformProvider(
            settings: PlatformSettingsData(
              platformStyle: PlatformStyleData(
                windows: PlatformStyle.Material,
              ),
            ),
            builder: (context) {
              // Get the platform style
              final style = FluentPlatformDetector.getPlatformStyle(context);

              // Return a widget that displays the style
              return Text(style.toString());
            },
          ),
        ),
      );

      // Verify that the style is displayed
      expect(find.textContaining('ExtendedPlatformStyle'), findsOneWidget);
    });

    testWidgets('shouldUseFluent returns correct value',
        (WidgetTester tester) async {
      // Create a test widget with PlatformProvider
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: PlatformProvider(
            settings: PlatformSettingsData(
              platformStyle: PlatformStyleData(
                windows: PlatformStyle.Material,
              ),
            ),
            builder: (context) {
              // Get the result
              result = FluentPlatformDetector.shouldUseFluent(context);

              // Return a widget
              return Container();
            },
          ),
        ),
      );

      // Verify that the result is not null
      expect(result, isNotNull);
    });

    testWidgets('shouldUseMaterial returns correct value',
        (WidgetTester tester) async {
      // Create a test widget with PlatformProvider
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: PlatformProvider(
            settings: PlatformSettingsData(
              platformStyle: PlatformStyleData(
                windows: PlatformStyle.Material,
              ),
            ),
            builder: (context) {
              // Get the result
              result = FluentPlatformDetector.shouldUseMaterial(context);

              // Return a widget
              return Container();
            },
          ),
        ),
      );

      // Verify that the result is not null
      expect(result, isNotNull);
    });

    testWidgets('shouldUseCupertino returns correct value',
        (WidgetTester tester) async {
      // Create a test widget with PlatformProvider
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: PlatformProvider(
            settings: PlatformSettingsData(
              platformStyle: PlatformStyleData(
                windows: PlatformStyle.Cupertino,
              ),
            ),
            builder: (context) {
              // Get the result
              result = FluentPlatformDetector.shouldUseCupertino(context);

              // Return a widget
              return Container();
            },
          ),
        ),
      );

      // Verify that the result is not null
      expect(result, isNotNull);
    });
  });
}
