import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/services.dart';

/// A factory class for creating Fluent UI widgets.
///
/// This class provides utility methods for creating Fluent UI widgets with
/// consistent styling and behavior.
class FluentWidgetFactory {
  /// Creates a Fluent UI button with the given parameters.
  ///
  /// This method creates a [fluent.Button] with the specified parameters.
  static fluent.Button createButton({
    required VoidCallback? onPressed,
    required Widget child,
    fluent.ButtonStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return fluent.Button(
      onPressed: onPressed,
      style: style,
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );
  }

  /// Creates a Fluent UI filled button with the given parameters.
  ///
  /// This method creates a [fluent.FilledButton] with the specified parameters.
  static fluent.FilledButton createFilledButton({
    required VoidCallback? onPressed,
    required Widget child,
    fluent.ButtonStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return fluent.FilledButton(
      onPressed: onPressed,
      style: style,
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );
  }

  /// Creates a Fluent UI text button with the given parameters.
  ///
  /// This method creates a [fluent.Button] with a text style for text buttons.
  static fluent.Button createTextButton({
    required VoidCallback? onPressed,
    required Widget child,
    fluent.ButtonStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    // Use a regular Button with a style that makes it look like a text button
    return fluent.Button(
      onPressed: onPressed,
      style: style ??
          fluent.ButtonStyle(
            backgroundColor: fluent.WidgetStateProperty.resolveWith(
                (states) => Colors.transparent),
            elevation: fluent.WidgetStateProperty.all(0.0),
          ),
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );
  }

  /// Creates a Fluent UI icon button with the given parameters.
  ///
  /// This method creates a [fluent.IconButton] with the specified parameters.
  static fluent.IconButton createIconButton({
    required VoidCallback? onPressed,
    required Widget icon,
    fluent.ButtonStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return fluent.IconButton(
      onPressed: onPressed,
      style: style,
      autofocus: autofocus,
      focusNode: focusNode,
      icon: icon,
    );
  }

  /// Creates a Fluent UI text box with the given parameters.
  ///
  /// This method creates a [fluent.TextBox] with the specified parameters.
  static fluent.TextBox createTextBox({
    TextEditingController? controller,
    String? placeholder,
    bool enabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    GestureTapCallback? onTap,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool autofocus = false,
    FocusNode? focusNode,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool obscureText = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    List<TextInputFormatter>? inputFormatters,
    EdgeInsetsGeometry? padding,
    BoxDecoration? boxDecoration,
    Color? cursorColor,
    Widget? prefix,
    Widget? suffix,
  }) {
    // Convert BoxDecoration to WidgetStateProperty<BoxDecoration> if provided
    fluent.WidgetStateProperty<BoxDecoration>? decoration;
    if (boxDecoration != null) {
      decoration = fluent.WidgetStateProperty.resolveWith((_) => boxDecoration);
    }

    return fluent.TextBox(
      controller: controller,
      placeholder: placeholder,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofocus: autofocus,
      focusNode: focusNode,
      style: style,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      inputFormatters: inputFormatters,
      padding: padding ?? EdgeInsets.zero, // Provide a default value if null
      decoration: decoration,
      cursorColor: cursorColor,
      prefix: prefix,
      suffix: suffix,
    );
  }

  /// Creates a Fluent UI checkbox with the given parameters.
  ///
  /// This method creates a [fluent.Checkbox] with the specified parameters.
  static fluent.Checkbox createCheckbox({
    required bool? checked,
    required ValueChanged<bool?>? onChanged,
    fluent.CheckboxThemeData? style,
    String? semanticLabel,
    bool autofocus = false,
    FocusNode? focusNode,
    Widget? content,
  }) {
    return fluent.Checkbox(
      checked: checked,
      onChanged: onChanged,
      style: style,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      focusNode: focusNode,
      content: content,
    );
  }

  /// Creates a Fluent UI toggle switch with the given parameters.
  ///
  /// This method creates a [fluent.ToggleSwitch] with the specified parameters.
  static fluent.ToggleSwitch createToggleSwitch({
    required bool checked,
    required ValueChanged<bool>? onChanged,
    fluent.ToggleSwitchThemeData? style,
    String? semanticLabel,
    bool autofocus = false,
    FocusNode? focusNode,
    Widget? content,
  }) {
    return fluent.ToggleSwitch(
      checked: checked,
      onChanged: onChanged,
      style: style,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      focusNode: focusNode,
      content: content,
    );
  }

  /// Creates a Fluent UI radio button with the given parameters.
  ///
  /// This method creates a [fluent.RadioButton] with the specified parameters.
  static fluent.RadioButton createRadioButton<T>({
    required T? value,
    required T? groupValue,
    required ValueChanged<T?>? onChanged,
    fluent.RadioButtonThemeData? style,
    String? semanticLabel,
    bool autofocus = false,
    FocusNode? focusNode,
    Widget? content,
  }) {
    return fluent.RadioButton(
      checked: value == groupValue,
      onChanged: onChanged != null
          ? (value == groupValue ? null : (_) => onChanged(value))
          : null,
      style: style,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      focusNode: focusNode,
      content: content,
    );
  }

  /// Creates a Fluent UI slider with the given parameters.
  ///
  /// This method creates a [fluent.Slider] with the specified parameters.
  static fluent.Slider createSlider({
    required double value,
    required ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    fluent.SliderThemeData? style,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return fluent.Slider(
      value: value,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      style: style,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }

  /// Creates a Fluent UI progress ring with the given parameters.
  ///
  /// This method creates a [fluent.ProgressRing] with the specified parameters.
  static fluent.ProgressRing createProgressRing({
    double? value,
    double? strokeWidth,
    Color? activeColor,
    Color? backgroundColor,
  }) {
    return fluent.ProgressRing(
      value: value,
      strokeWidth: strokeWidth ?? 2.0, // Provide a default value if null
      activeColor: activeColor,
      backgroundColor: backgroundColor,
    );
  }

  /// Creates a Fluent UI progress bar with the given parameters.
  ///
  /// This method creates a [fluent.ProgressBar] with the specified parameters.
  static fluent.ProgressBar createProgressBar({
    double? value,
    Color? activeColor,
    Color? backgroundColor,
  }) {
    return fluent.ProgressBar(
      value: value,
      activeColor: activeColor,
      backgroundColor: backgroundColor,
    );
  }
}
