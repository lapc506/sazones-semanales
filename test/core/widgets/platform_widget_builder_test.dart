import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sazones_semanales/core/widgets/platform_widget_builder.dart';

void main() {
  group('PlatformWidgetBuilderMixin', () {
    test('provides default implementations for buildCupertino and buildFluent',
        () {
      // Create a test implementation of PlatformWidgetBuilder using the mixin
      final builder = TestWidgetBuilder();

      // Create a test BuildContext
      final context = TestBuildContext();

      // Test that buildCupertino falls back to buildMaterial
      final cupertinoWidget = builder.buildCupertino(context);
      expect(cupertinoWidget.runtimeType, equals(Text));
      expect((cupertinoWidget as Text).data, equals('Material'));

      // Test that buildFluent falls back to buildMaterial
      final fluentWidget = builder.buildFluent(context);
      expect(fluentWidget.runtimeType, equals(Text));
      expect((fluentWidget as Text).data, equals('Material'));
    });
  });

  group('FluentWidgetBuilderMixin', () {
    test(
        'provides default implementations for buildMaterial and buildCupertino',
        () {
      // Create a test implementation of PlatformWidgetBuilder using the mixin
      final builder = TestFluentWidgetBuilder();

      // Create a test BuildContext
      final context = TestBuildContext();

      // Test that buildMaterial falls back to buildFluent
      final materialWidget = builder.buildMaterial(context);
      expect(materialWidget.runtimeType, equals(Text));
      expect((materialWidget as Text).data, equals('Fluent'));

      // Test that buildCupertino falls back to buildFluent
      final cupertinoWidget = builder.buildCupertino(context);
      expect(cupertinoWidget.runtimeType, equals(Text));
      expect((cupertinoWidget as Text).data, equals('Fluent'));
    });
  });

  group('FluentWidgetConverter', () {
    test('converts colors between Flutter and Fluent UI', () {
      final flutterColor = Colors.blue;
      final fluentColor =
          FluentWidgetConverter.flutterToFluentColor(flutterColor);
      final convertedColor =
          FluentWidgetConverter.fluentToFlutterColor(fluentColor);

      expect(fluentColor, equals(flutterColor));
      expect(convertedColor, equals(flutterColor));
    });

    test('converts edge insets between Flutter and Fluent UI', () {
      final flutterInsets = EdgeInsets.all(8.0);
      final fluentInsets =
          FluentWidgetConverter.flutterToFluentEdgeInsets(flutterInsets);
      final convertedInsets =
          FluentWidgetConverter.fluentToFlutterEdgeInsets(fluentInsets);

      expect(fluentInsets, equals(flutterInsets));
      expect(convertedInsets, equals(flutterInsets));
    });

    test('converts text styles between Flutter and Fluent UI', () {
      final flutterStyle = TextStyle(fontSize: 16.0, color: Colors.black);
      final fluentStyle =
          FluentWidgetConverter.flutterToFluentTextStyle(flutterStyle);
      final convertedStyle =
          FluentWidgetConverter.fluentToFlutterTextStyle(fluentStyle);

      expect(fluentStyle, equals(flutterStyle));
      expect(convertedStyle, equals(flutterStyle));
    });

    test('converts border radius between Flutter and Fluent UI', () {
      final flutterRadius = BorderRadius.circular(8.0);
      final fluentRadius =
          FluentWidgetConverter.flutterToFluentBorderRadius(flutterRadius);
      final convertedRadius =
          FluentWidgetConverter.fluentToFlutterBorderRadius(fluentRadius);

      expect(fluentRadius, equals(flutterRadius));
      expect(convertedRadius, equals(flutterRadius));
    });
  });
}

/// A test implementation of PlatformWidgetBuilder using PlatformWidgetBuilderMixin.
class TestWidgetBuilder with PlatformWidgetBuilderMixin<Widget> {
  @override
  Widget buildMaterial(BuildContext context) {
    return Text('Material');
  }
}

/// A test implementation of PlatformWidgetBuilder using FluentWidgetBuilderMixin.
class TestFluentWidgetBuilder with FluentWidgetBuilderMixin<Widget> {
  @override
  Widget buildFluent(BuildContext context) {
    return Text('Fluent');
  }
}

/// A simple mock BuildContext for testing.
class TestBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
