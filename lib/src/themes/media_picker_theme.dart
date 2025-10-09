import 'package:flutter/material.dart';

class MediaPickerTheme {
  final Color backgroundColor;
  final Color appBarColor;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color borderColor;
  final Color selectedColor;
  final double borderRadius;
  final double gridSpacing;

  const MediaPickerTheme({
    this.backgroundColor = Colors.white,
    this.appBarColor = Colors.white,
    this.primaryColor = Colors.blue,
    this.accentColor = Colors.blueAccent,
    this.textColor = Colors.black,
    this.secondaryTextColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.selectedColor = Colors.blue,
    this.borderRadius = 8.0,
    this.gridSpacing = 2.0,
  });

  MediaPickerTheme copyWith({
    Color? backgroundColor,
    Color? appBarColor,
    Color? primaryColor,
    Color? accentColor,
    Color? textColor,
    Color? secondaryTextColor,
    Color? borderColor,
    Color? selectedColor,
    double? borderRadius,
    double? gridSpacing,
  }) {
    return MediaPickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      appBarColor: appBarColor ?? this.appBarColor,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      borderColor: borderColor ?? this.borderColor,
      selectedColor: selectedColor ?? this.selectedColor,
      borderRadius: borderRadius ?? this.borderRadius,
      gridSpacing: gridSpacing ?? this.gridSpacing,
    );
  }

  static MediaPickerTheme get lightTheme {
    return const MediaPickerTheme(
      backgroundColor: Colors.white,
      appBarColor: Colors.white,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      textColor: Colors.black,
      secondaryTextColor: Colors.grey,
    );
  }

  static MediaPickerTheme get darkTheme {
    return const MediaPickerTheme(
      backgroundColor: Colors.black,
      appBarColor: Colors.black,
      primaryColor: Colors.blueAccent,
      accentColor: Colors.lightBlueAccent,
      textColor: Colors.white,
      secondaryTextColor: Colors.grey,
    );
  }

  static MediaPickerTheme get customTheme {
    return const MediaPickerTheme(
      backgroundColor: Color(0xFFF5F5F5),
      appBarColor: Colors.deepPurple,
      primaryColor: Colors.deepPurple,
      accentColor: Colors.purpleAccent,
      textColor: Colors.black87,
      secondaryTextColor: Colors.grey,
    );
  }
}
