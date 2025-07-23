import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'fluent_configuration.dart';

/// Extended PlatformSettingsData that includes Fluent UI configuration
class FluentPlatformSettingsData extends PlatformSettingsData {
  /// Configuration specific to Fluent UI on Windows platform
  final FluentConfiguration? fluentConfiguration;

  /// Creates a new FluentPlatformSettingsData instance
  FluentPlatformSettingsData({
    // Original PlatformSettingsData parameters
    super.iosUsesMaterialWidgets,
    super.iosUseZeroPaddingForAppbarPlatformIcon,
    super.platformStyle,
    super.legacyIosUsesMaterialWidgets,
    super.wrapCupertinoAppBarMiddleWithMediaQuery,

    // New Fluent configuration parameter
    this.fluentConfiguration,
  });

  /// Creates a copy of this settings data with the given fields replaced
  FluentPlatformSettingsData copyWith({
    bool? iosUsesMaterialWidgets,
    bool? iosUseZeroPaddingForAppbarPlatformIcon,
    PlatformStyleData? platformStyle,
    bool? legacyIosUsesMaterialWidgets,
    bool? wrapCupertinoAppBarMiddleWithMediaQuery,
    FluentConfiguration? fluentConfiguration,
  }) {
    return FluentPlatformSettingsData(
      iosUsesMaterialWidgets:
          iosUsesMaterialWidgets ?? this.iosUsesMaterialWidgets,
      iosUseZeroPaddingForAppbarPlatformIcon:
          iosUseZeroPaddingForAppbarPlatformIcon ??
              this.iosUseZeroPaddingForAppbarPlatformIcon,
      platformStyle: platformStyle ?? this.platformStyle,
      legacyIosUsesMaterialWidgets:
          legacyIosUsesMaterialWidgets ?? this.legacyIosUsesMaterialWidgets,
      wrapCupertinoAppBarMiddleWithMediaQuery:
          wrapCupertinoAppBarMiddleWithMediaQuery ??
              this.wrapCupertinoAppBarMiddleWithMediaQuery,
      fluentConfiguration: fluentConfiguration ?? this.fluentConfiguration,
    );
  }

  /// Creates a new FluentPlatformSettingsData from an existing PlatformSettingsData
  factory FluentPlatformSettingsData.from(
    PlatformSettingsData settings, {
    FluentConfiguration? fluentConfiguration,
  }) {
    return FluentPlatformSettingsData(
      iosUsesMaterialWidgets: settings.iosUsesMaterialWidgets,
      iosUseZeroPaddingForAppbarPlatformIcon:
          settings.iosUseZeroPaddingForAppbarPlatformIcon,
      platformStyle: settings.platformStyle,
      legacyIosUsesMaterialWidgets: settings.legacyIosUsesMaterialWidgets,
      wrapCupertinoAppBarMiddleWithMediaQuery:
          settings.wrapCupertinoAppBarMiddleWithMediaQuery,
      fluentConfiguration: fluentConfiguration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FluentPlatformSettingsData) return false;

    // We can't use super != other because PlatformSettingsData doesn't override ==
    return other.iosUsesMaterialWidgets == iosUsesMaterialWidgets &&
        other.iosUseZeroPaddingForAppbarPlatformIcon ==
            iosUseZeroPaddingForAppbarPlatformIcon &&
        other.platformStyle == platformStyle &&
        other.legacyIosUsesMaterialWidgets == legacyIosUsesMaterialWidgets &&
        other.wrapCupertinoAppBarMiddleWithMediaQuery ==
            wrapCupertinoAppBarMiddleWithMediaQuery &&
        other.fluentConfiguration == fluentConfiguration;
  }

  @override
  int get hashCode =>
      iosUsesMaterialWidgets.hashCode ^
      iosUseZeroPaddingForAppbarPlatformIcon.hashCode ^
      platformStyle.hashCode ^
      legacyIosUsesMaterialWidgets.hashCode ^
      wrapCupertinoAppBarMiddleWithMediaQuery.hashCode ^
      (fluentConfiguration?.hashCode ?? 0);

  @override
  String toString() {
    return 'FluentPlatformSettingsData(${super.toString()}, '
        'fluentConfiguration: $fluentConfiguration)';
  }
}
