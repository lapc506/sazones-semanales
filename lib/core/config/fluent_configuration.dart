/// Enumeration of navigation styles available in Fluent UI
enum FluentNavigationStyle {
  /// Automatically selects the best navigation style based on window size
  automatic,

  /// Top navigation style (similar to tabs)
  top,

  /// Left side navigation pane
  left,

  /// Compact left side navigation with icons only when collapsed
  compact,

  /// Open navigation pane that can be toggled
  open
}

/// Configuration class for Fluent UI specific settings
class FluentConfiguration {
  /// Whether to use the system accent color from Windows
  final bool useSystemAccentColor;

  /// Whether to enable acrylic (transparency) effects in the UI
  final bool enableAcrylicEffects;

  /// The navigation style to use for Fluent UI navigation components
  final FluentNavigationStyle navigationStyle;

  /// Whether to use Fluent UI's reveal focus effect
  final bool useRevealFocus;

  /// Whether to use Fluent UI's reveal hover effect
  final bool useRevealHover;

  /// Creates a new FluentConfiguration instance
  const FluentConfiguration({
    this.useSystemAccentColor = true,
    this.enableAcrylicEffects = true,
    this.navigationStyle = FluentNavigationStyle.automatic,
    this.useRevealFocus = true,
    this.useRevealHover = true,
  });

  /// Creates a copy of this configuration with the given fields replaced
  FluentConfiguration copyWith({
    bool? useSystemAccentColor,
    bool? enableAcrylicEffects,
    FluentNavigationStyle? navigationStyle,
    bool? useRevealFocus,
    bool? useRevealHover,
  }) {
    return FluentConfiguration(
      useSystemAccentColor: useSystemAccentColor ?? this.useSystemAccentColor,
      enableAcrylicEffects: enableAcrylicEffects ?? this.enableAcrylicEffects,
      navigationStyle: navigationStyle ?? this.navigationStyle,
      useRevealFocus: useRevealFocus ?? this.useRevealFocus,
      useRevealHover: useRevealHover ?? this.useRevealHover,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FluentConfiguration &&
        other.useSystemAccentColor == useSystemAccentColor &&
        other.enableAcrylicEffects == enableAcrylicEffects &&
        other.navigationStyle == navigationStyle &&
        other.useRevealFocus == useRevealFocus &&
        other.useRevealHover == useRevealHover;
  }

  @override
  int get hashCode {
    return useSystemAccentColor.hashCode ^
        enableAcrylicEffects.hashCode ^
        navigationStyle.hashCode ^
        useRevealFocus.hashCode ^
        useRevealHover.hashCode;
  }

  @override
  String toString() {
    return 'FluentConfiguration('
        'useSystemAccentColor: $useSystemAccentColor, '
        'enableAcrylicEffects: $enableAcrylicEffects, '
        'navigationStyle: $navigationStyle, '
        'useRevealFocus: $useRevealFocus, '
        'useRevealHover: $useRevealHover)';
  }
}
