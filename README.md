<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# 📸 Media Attach Package

A beautiful and customizable Flutter package for media selection with multiple UI options - full-screen, dialog, and resizable bottom sheet.

## Features

- 🎨 **Multiple UI Options**
  - Full-screen media picker
  - Dialog-based picker
  - Resizable bottom sheet
- 🎯 **Smart Selection**
  - Single or multiple selection
  - Visual selection indicators
  - Selection limits
- 🌈 **Customizable Themes**
  - Light, dark, and custom themes
  - Fully customizable colors
  - Adaptive design
- 📱 **User-Friendly**
  - Drag-to-resize bottom sheet
  - Smooth animations
  - Intuitive gestures
- 🔄 **Media Support**
  - Image and video support
  - Thumbnail previews
  - Video duration indicators

## Getting started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  media_attach_package: ^1.0.0

### Android Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### iOS Permissions

Add these to your `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select media</string>
```

## Usage

### 1. Full-Screen Media Picker

```dart
import 'package:media_attach_package/media_attach_package.dart';

void openFullScreenPicker(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MediaPickerScreen(
        maxSelection: 10,
        allowMultiple: true,
        theme: MediaPickerTheme.lightTheme,
        title: 'Select Photos',
        onSelectionChanged: (selectedItems) {
          print('Selected: ${selectedItems.length} items');
        },
      ),
    ),
  ).then((selectedItems) {
    if (selectedItems != null) {
      // Handle selected items
      print('Final selection: ${selectedItems.length} items');
    }
  });
}
```

### 2. Dialog Media Picker

```dart
void showMediaPickerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => MediaPickerDialog(
      maxSelection: 5,
      allowMultiple: true,
      theme: MediaPickerTheme.darkTheme,
      onConfirmed: (selectedItems) {
        print('Confirmed selection: ${selectedItems.length} items');
      },
    ),
  );
}
```

### 3. Resizable Bottom Sheet

```dart
void showMediaPickerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MediaPickerBottomSheet(
      maxSelection: 10,
      allowMultiple: true,
      theme: MediaPickerTheme.customTheme,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      onConfirmed: (selectedItems) {
        print('Bottom sheet selection: ${selectedItems.length} items');
      },
    ),
  );
}
```

### Customization

#### Using Built-in Themes

```dart
// Light theme
MediaPickerTheme.lightTheme

// Dark theme  
MediaPickerTheme.darkTheme

// Custom theme
MediaPickerTheme.customTheme
```

#### Creating Custom Theme

```dart
const myCustomTheme = MediaPickerTheme(
  backgroundColor: Color(0xFFF8F9FA),
  appBarColor: Color(0xFF6200EE),
  primaryColor: Color(0xFF6200EE),
  accentColor: Color(0xFF03DAC6),
  textColor: Colors.black87,
  secondaryTextColor: Colors.grey,
  borderColor: Colors.grey.shade300,
  selectedColor: Color(0xFF6200EE),
  borderRadius: 12.0,
  gridSpacing: 2.0,
);
```

#### Advanced Customization

```dart
MediaPickerScreen(
  theme: MediaPickerTheme.lightTheme.copyWith(
    primaryColor: Colors.deepPurple,
    borderRadius: 16.0,
    gridSpacing: 4.0,
  ),
  initialSelection: previouslySelectedItems,
  maxSelection: 15,
  showVideos: false, // Hide videos
  allowMultiple: true,
);
```

## Additional information

### API Reference

#### MediaPickerScreen

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialSelection` | `List<MediaItem>` | `[]` | Pre-selected items |
| `maxSelection` | `int` | `10` | Maximum selectable items |
| `allowMultiple` | `bool` | `true` | Allow multiple selection |
| `showVideos` | `bool` | `true` | Show video files |
| `theme` | `MediaPickerTheme` | `MediaPickerTheme()` | Custom theme |
| `title` | `String` | `'Select Media'` | Screen title |
| `onSelectionChanged` | `Function(List<MediaItem>)` | `null` | Selection change callback |

#### MediaPickerBottomSheet

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialChildSize` | `double` | `0.7` | Initial sheet height (0.0-1.0) |
| `minChildSize` | `double` | `0.4` | Minimum sheet height (0.0-1.0) |
| `maxChildSize` | `double` | `0.9` | Maximum sheet height (0.0-1.0) |

#### MediaItem Model

```dart
MediaItem(
  id: '1',
  name: 'photo.jpg',
  path: '/storage/photo.jpg',
  dateAdded: 1633046400000,
  size: 2048576, // bytes
  width: 1920,
  height: 1080,
  albumId: 'camera',
  albumName: 'Camera',
  type: 'image', // or 'video'
  duration: 60000, // milliseconds for videos
  thumbnail: thumbnailBytes, // optional
);
```

### Examples

#### Basic Implementation

```dart
class MediaPickerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Picker Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => openFullScreenPicker(context),
              child: Text('Full Screen Picker'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showMediaPickerDialog(context),
              child: Text('Dialog Picker'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showMediaPickerBottomSheet(context),
              child: Text('Bottom Sheet Picker'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Advanced Usage with State Management

```dart
class AdvancedMediaPicker extends StatefulWidget {
  @override
  _AdvancedMediaPickerState createState() => _AdvancedMediaPickerState();
}

class _AdvancedMediaPickerState extends State<AdvancedMediaPicker> {
  List<MediaItem> _selectedMedia = [];

  void _handleMediaSelection(List<MediaItem> selectedItems) {
    setState(() {
      _selectedMedia = selectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selected: ${_selectedMedia.length}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMediaPickerBottomSheet(context),
        child: Icon(Icons.add_photo_alternate),
      ),
      body: _buildSelectedMediaGrid(),
    );
  }

  Widget _buildSelectedMediaGrid() {
    if (_selectedMedia.isEmpty) {
      return Center(child: Text('No media selected'));
    }
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _selectedMedia.length,
      itemBuilder: (context, index) {
        final item = _selectedMedia[index];
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(item.thumbnail!),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
```

### Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Bug Reports & Feature Requests

Found a bug or have a feature request? Please [open an issue](https://github.com/your-repo/media_attach_package/issues) on GitHub.

---

**Made with ❤️ for the Flutter community**

For more Flutter packages, check out our [other packages](https://pub.dev/publishers/your-publisher.dev/packages).
