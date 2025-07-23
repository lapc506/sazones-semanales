# Fluent UI Integration Spec

## Overview

This spec implements integration of fluent_ui with flutter_platform_widgets using dependency inversion patterns. The goal is to provide native Windows Fluent Design System widgets when the app runs on Windows platform while maintaining cross-platform compatibility.

## Project Structure

The implementation follows a layered architecture that extends the existing flutter_platform_widgets pattern:

### Core Infrastructure (`lib/core/`)

**Platform Layer (`lib/core/platform/`)**
- `fluent_platform_extensions.dart` - Extended PlatformStyle enum with Fluent option
- `fluent_platform_style_data.dart` - Updated PlatformStyleData supporting Fluent style
- `fluent_platform_detector.dart` - Windows platform detection logic

**Theme Layer (`lib/core/theme/`)**
- `fluent_theme_adapter.dart` - Converts Material themes to Fluent themes
- `fluent_color_extensions.dart` - Color conversion utilities for theme mapping

**Configuration Layer (`lib/core/config/`)**
- `fluent_configuration.dart` - Windows-specific configuration model
- `fluent_platform_settings_data.dart` - Extended PlatformSettingsData with Fluent config

**Widget Infrastructure (`lib/core/widgets/`)**
- `platform_widget_builder.dart` - Abstract interface for three-way platform support
- `multi_platform_widget.dart` - Base class for Material/Cupertino/Fluent widgets
- `fluent_widget_factory.dart` - Fluent widget creation utilities
- `fluent_widget_selector.dart` - Widget selection logic for platform detection
- `fluent_fallback_builder.dart` - Graceful fallback when fluent_ui unavailable
- `fluent_widget_mapping.dart` - Type mapping for fluent widgets

**Utilities (`lib/core/utils/`)**
- `fluent_dependency_checker.dart` - Runtime checks for fluent_ui availability
- `fluent_error_handler.dart` - Error handling and fallback utilities

### Presentation Layer (`lib/presentation/widgets/`)

**Core App Widgets**
- `fluent_platform_app.dart` - FluentPlatformApp with theme integration
- `fluent_platform_scaffold.dart` - Scaffold using fluent_ui ScaffoldPage

**UI Components**
- `fluent_platform_button.dart` - Button using fluent_ui Button components
- `fluent_platform_text_field.dart` - Text input using fluent_ui TextBox
- `fluent_platform_navigation_bar.dart` - Navigation using fluent_ui NavigationView
- `fluent_platform_app_bar.dart` - App bar using fluent_ui CommandBar

### Testing Structure (`test/`)

**Unit Tests**
- `test/core/` - Tests for core infrastructure (mirrors lib/core structure)
- `test/presentation/` - Tests for presentation widgets

**Integration Tests**
- `test/integration/fluent_navigation_integration_test.dart` - Navigation pattern tests
- `test/integration/fluent_platform_consistency_test.dart` - Cross-platform functionality
- `test/integration/fluent_state_management_test.dart` - Platform switch consistency
- `test/integration/fluent_app_lifecycle_test.dart` - App lifecycle and theme switching
- `test/integration/fluent_screen_integration_test.dart` - Screen integration verification

**Performance & Visual Tests**
- `test/performance/` - Performance benchmarks for widgets and themes
- `test/visual/` - Visual regression tests for fluent_ui appearance

### App Integration

**Main Configuration (`lib/main.dart`)**
- Updated to use FluentPlatformApp instead of PlatformApp
- Configured PlatformStyleData with Fluent style for Windows
- FluentConfiguration initialization with Windows-specific settings

**Screen Updates (`lib/presentation/screens/`)**
- Review and update existing screens to use new fluent platform widgets
- Replace direct Material/Cupertino usage with platform widgets

## Implementation Approach

### Dependency Inversion Pattern

The implementation uses dependency inversion to extend flutter_platform_widgets:

1. **Abstract Interface**: `PlatformWidgetBuilder` defines contracts for all three platforms
2. **Concrete Implementations**: Each widget implements Material, Cupertino, and Fluent variants
3. **Factory Pattern**: `MultiPlatformWidget` selects appropriate implementation based on platform
4. **Fallback Strategy**: Graceful degradation when fluent_ui is unavailable

### Platform Detection Strategy

```dart
// Platform style selection logic
switch (platformStyle) {
  case PlatformStyle.Fluent:
    return builder.buildFluent(context);
  case PlatformStyle.Cupertino:
    return builder.buildCupertino(context);
  case PlatformStyle.Material:
  default:
    return builder.buildMaterial(context);
}
```

### Theme Integration

- **Material to Fluent**: Automatic theme conversion using `FluentThemeAdapter`
- **System Integration**: Windows accent color support via `system_theme` package
- **Consistency**: Maintains visual coherence across platform switches

### Error Handling

- **Dependency Validation**: Runtime checks for fluent_ui package availability
- **Graceful Fallbacks**: Automatic fallback to Material widgets when needed
- **Developer Warnings**: Console warnings for configuration issues

## Dependencies

### Required Packages
```yaml
dependencies:
  fluent_ui: ^4.4.0
  system_theme: ^2.3.1  # For Windows system accent colors
  flutter_platform_widgets: ^7.0.1
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
  integration_test:
  mockito: ^5.4.2
```

## Usage Example

```dart
// Main app configuration
FluentPlatformApp(
  platformStyleData: PlatformStyleData(
    windows: PlatformStyle.Fluent,  // Use Fluent on Windows
    android: PlatformStyle.Material,
    ios: PlatformStyle.Cupertino,
  ),
  fluentConfiguration: FluentConfiguration(
    useSystemAccentColor: true,
    enableAcrylicEffects: true,
  ),
  // ... other app configuration
)

// Widget usage (same API across platforms)
FluentPlatformButton(
  onPressed: () => print('Pressed'),
  child: Text('Click me'),
)
```

## Benefits

1. **Platform Fidelity**: Native Windows Fluent Design experience
2. **Code Reuse**: Single codebase for all platforms
3. **Backward Compatibility**: Existing code continues to work
4. **Graceful Degradation**: Fallback to Material when fluent_ui unavailable
5. **Developer Experience**: Familiar flutter_platform_widgets API

## Migration Path

1. **Phase 1**: Add dependencies and core infrastructure
2. **Phase 2**: Implement core platform widgets (App, Scaffold, Button, TextField)
3. **Phase 3**: Add navigation and layout components
4. **Phase 4**: Update existing screens to use platform widgets
5. **Phase 5**: Comprehensive testing and optimization

This approach ensures minimal disruption to existing code while providing a robust foundation for Windows-native UI experiences.