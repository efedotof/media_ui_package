# Media UI Package

A highly customizable Flutter package for selecting media and files. It provides a unified interface to access the device's MediaStore (images, videos, audio), as well as the Download and Documents directories on Android.

The package offers multiple UI presentations (full-screen, dialog, bottom sheet) with built-in lazy loading, caching, and permission handling.

## Features

- **Multiple UI Options:** Full-screen widget, modal dialog, or resizable bottom sheet.
- **Multiple Sources:** Access MediaStore (photos, videos), audio files, Downloads, and Documents.
- **Pagination & Lazy Loading:** Efficiently loads large directories in pages with automatic infinite scrolling.
- **Lazy Preview:** Generates and caches image previews without loading entire files into memory.
- **Permission Management:** Built-in handling for scoped media permissions, SAF (Storage Access Framework) folder selection, and `MANAGE_EXTERNAL_STORAGE`.
- **Customizable UI:** Adjust grid spacing, border radius, and selection colors via `MediaPickerConfig`.
- **Multi-selection:** Support for single or multiple file selections with a contextual AppBar.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  media_ui_package:
    git:
      url: https://github.com/your-repository/media_ui_package.git
```

## Initialization

The package must be initialized before use. It is recommended to do this in your `main.dart` file.

```dart
import 'package:flutter/material.dart';
import 'package:media_ui_package/src2/media_ui_package_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize permissions and DeviceMediaLibrary
  await MediaUiPackageInitialize().initialize();
  
  runApp(const MyApp());
}
```

## Android Configuration

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- For Android 12 and below -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- For Android 13 and above -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    
    <!-- Optional: For full access to Downloads/Documents on Android 11+ -->
    <uses-permission
        android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
        tools:ignore="ScopedStorage" />

    <application ...>
        ...
    </application>
</manifest>
```

## UI Variants

The package provides three ways to display the media picker depending on your application's design.

### 1. Media Picker Dialog

Shows the picker inside a centered modal dialog.

```dart
import 'package:media_ui_package/src2/widgets/media_picker_dialog.dart';
import 'package:media_ui_package/src2/models/media_picker_result.dart';

Future<void> openDialog(BuildContext context) async {
  final MediaPickerResult? result = await MediaPickerDialog.show(
    context,
    title: 'Attach Files',
    multiSelect: true,
    confirmLabel: 'Attach',
  );

  if (result != null && result.isNotEmpty) {
    print('Selected items: ${result.count}');
  }
}
```

### 2. Media Picker Bottom Sheet

Shows the picker as a resizable bottom sheet. You can configure the initial, minimum, and maximum height.

```dart
import 'package:media_ui_package/src2/widgets/media_bottom_sheet.dart';

Future<void> openBottomSheet(BuildContext context) async {
  final MediaPickerResult? result = await MediaPickerBottomSheet.show(
    context,
    title: 'Select Media',
    initialChildSize: 0.85,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    enableDrag: false, // Set to true to allow drag-to-dismiss
  );
  
  // Handle result...
}
```

### 3. Inline Full-Screen Widget

Embed the picker directly into your own screen or route.

```dart
import 'package:media_ui_package/src2/widgets/media_picker_widget.dart';

class MyCustomPickerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MediaPickerWidget(
          title: 'Custom Selection',
          multiSelect: true,
          onConfirm: (result) {
            Navigator.of(context).pop(result);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
```

## Theming and Customization

You can customize the appearance of the picker by passing a `MediaPickerConfig` instance to any of the UI methods (Dialog, Bottom Sheet, or Widget). 

### Available Configuration Properties

```dart
import 'package:media_ui_package/src2/themes/media_picker_theme.dart';

const customConfig = MediaPickerConfig(
  selectedColor: Colors.purple,     // Color of selection indicators and overlays
  borderColor: Colors.purpleAccent, // Border color of unselected indicators
  borderRadius: 12.0,               // Corner radius for media tiles
  gridSpacing: 4.0,                 // Spacing between items in the grid/list
);

await MediaPickerDialog.show(
  context,
  config: customConfig,
  // ...
);
```

### Using MediaPickerConfigScope (InheritedWidget)

If you want to apply a theme to a whole subtree without passing it to every dialog, you can wrap your widget with `MediaPickerConfigScope`:

```dart
MediaPickerConfigScope(
  config: const MediaPickerConfig(
    selectedColor: Colors.green,
    borderRadius: 16.0,
  ),
  child: YourAppOrWidget(),
)
```

## Available Sections

The picker organizes files into distinct sections that users can navigate via the bottom navigation menu:

- **Media (`MediaPickerSection.media`):** Images and videos from the device MediaStore.
- **Audio (`MediaPickerSection.audio`):** Audio files from the device.
- **Download (`MediaPickerSection.downloads`):** Files in the device's Download folder.
- **Documents (`MediaPickerSection.documents`):** Files in the device's Documents folder.
- **Others (`MediaPickerSection.others`):** A custom section (by default, shows generic files from Downloads).

You can limit the visible sections using the `sections` parameter:

```dart
MediaPickerDialog.show(
  context,
  sections: const [
    MediaPickerSection.media,
    MediaPickerSection.audio,
  ],
);
```

## Handling Permissions

The package automatically handles media permissions on startup via `MediaUiPackageInitialize`. 

For accessing Download and Documents folders on Android 10+, users must explicitly grant access.
- **Scoped Access (Android 11+):** The picker will automatically show a banner asking the user to select the folder via the Storage Access Framework (SAF).
- **Manage All Files:** If you need direct filesystem access, the UI will prompt the user to open system settings. The app will automatically refresh when returning to the foreground.

## Result Model

The `MediaPickerResult` contains a list of `SelectedMediaItem` objects.

```dart
class SelectedMediaItem {
  final String id;
  final String uri;
  final String name;
  final String type; // 'image', 'video', 'audio', 'file'
  final int size;
  final int? duration; // in milliseconds for video/audio
  final MediaSource source; // device, downloads, documents
}
```

Example of handling the result:

```dart
if (result != null && result.isNotEmpty) {
  // Total size of all selected files
  print('Total size: ${result.totalSize} bytes');
  
  // Iterate through selected items
  for (final item in result.items) {
    print('File: ${item.name}, URI: ${item.uri}, Type: ${item.type}');
  }
}
```

## License

This project is licensed under the MIT License.