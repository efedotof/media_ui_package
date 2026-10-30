import 'package:flutter/material.dart';

class MediaPickerConfig {
  final double gridSpacing;
  final double borderRadius;
  final Color selectedColor;
  final Color borderColor;

  const MediaPickerConfig({
    this.gridSpacing = 2.0,
    this.borderRadius = 8.0,
    this.selectedColor = Colors.blue,
    this.borderColor = Colors.grey,
  });

  MediaPickerConfig copyWith({
    double? gridSpacing,
    double? borderRadius,
    Color? selectedColor,
    Color? borderColor,
  }) {
    return MediaPickerConfig(
      gridSpacing: gridSpacing ?? this.gridSpacing,
      borderRadius: borderRadius ?? this.borderRadius,
      selectedColor: selectedColor ?? this.selectedColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  static MediaPickerConfig of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MediaPickerConfigScope>()
            ?.config ??
        const MediaPickerConfig();
  }
}

class MediaPickerConfigScope extends InheritedWidget {
  final MediaPickerConfig config;

  const MediaPickerConfigScope({
    super.key,
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(MediaPickerConfigScope oldWidget) {
    return config != oldWidget.config;
  }
}
