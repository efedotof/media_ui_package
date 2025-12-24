# 📸 Media Attach Package

A beautiful and customizable Flutter package for media selection with multiple UI options - full-screen, dialog, and resizable bottom sheet.

## Features

- 🎨 **Multiple UI Options**
  - Full-screen media picker
  - Dialog-based picker
  - Resizable bottom sheet with customizable border radius
- 🎯 **Smart Selection**
  - Single or multiple selection
  - Visual selection indicators
  - Selection limits
- 🌈 **Customizable Themes**
  - Light, dark, and custom themes
  - Fully customizable colors
  - Adaptive design
  - Customizable border radius for bottom sheet
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
```

### Android Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
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

### 3. Resizable Bottom Sheet with Customizable Border Radius

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
      borderRadius: 18.0, // Customize border radius (optional)
      onConfirmed: (selectedItems) {
        print('Bottom sheet selection: ${selectedItems.length} items');
      },
    ),
  );
}

// Without border radius (sharp corners)
void showMediaPickerBottomSheetNoRadius(BuildContext context) {
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
      // borderRadius is omitted - will have no rounded corners
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

## API Reference

### MediaPickerScreen

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialSelection` | `List<MediaItem>` | `[]` | Pre-selected items |
| `maxSelection` | `int` | `10` | Maximum selectable items |
| `allowMultiple` | `bool` | `true` | Allow multiple selection |
| `showVideos` | `bool` | `true` | Show video files |
| `theme` | `MediaPickerTheme` | `MediaPickerTheme()` | Custom theme |
| `title` | `String` | `'Select Media'` | Screen title |
| `onSelectionChanged` | `Function(List<MediaItem>)` | `null` | Selection change callback |
| `thumbnailBuilder` | `Uint8List? Function(MediaItem)?` | `null` | Custom thumbnail builder |
| `albumId` | `String?` | `null` | Specific album ID to show |
| `mediaType` | `MediaType` | `MediaType.all` | Type of media to display |
| `config` | `MediaPickerConfig?` | `null` | Advanced configuration |

### MediaPickerDialog

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialSelection` | `List<MediaItem>` | `[]` | Pre-selected items |
| `maxSelection` | `int` | `10` | Maximum selectable items |
| `allowMultiple` | `bool` | `true` | Allow multiple selection |
| `showVideos` | `bool` | `true` | Show video files |
| `onSelectionChanged` | `Function(List<MediaItem>)` | `null` | Selection change callback |
| `onConfirmed` | `Function(List<MediaItem>)` | `null` | Confirmation callback |
| `config` | `MediaPickerConfig?` | `null` | Advanced configuration |

### MediaPickerBottomSheet

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialSelection` | `List<MediaItem>` | `[]` | Pre-selected items |
| `maxSelection` | `int` | `10` | Maximum selectable items |
| `allowMultiple` | `bool` | `true` | Allow multiple selection |
| `showVideos` | `bool` | `true` | Show video files |
| `onSelectionChanged` | `Function(List<MediaItem>)` | `null` | Selection change callback |
| `onConfirmed` | `Function(List<MediaItem>)` | `null` | Confirmation callback |
| `initialChildSize` | `double` | `0.7` | Initial sheet height (0.0-1.0) |
| `minChildSize` | `double` | `0.4` | Minimum sheet height (0.0-1.0) |
| `maxChildSize` | `double` | `0.9` | Maximum sheet height (0.0-1.0) |
| `showSelectionIndicators` | `bool` | `true` | Show selection indicators |
| `config` | `MediaPickerConfig?` | `null` | Advanced configuration |
| **`borderRadius`** | **`double?`** | **`null`** | **Custom border radius. If `null`, no rounding is applied** |

### MediaItem Model

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

### FullscreenMediaView

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mediaItems` | `List<MediaItem>?` | `null` | List of media items |
| `initialIndex` | `int?` | `null` | Initial media index |
| `selectedItems` | `List<MediaItem>?` | `null` | Pre-selected items |
| `onItemSelected` | `Function(MediaItem, bool)?` | `null` | Item selection callback |
| `urlMedia` | `bool` | `false` | Use URL media mode |
| `urlMedial` | `String?` | `null` | Single URL for media |
| `urlMedias` | `List<String>?` | `null` | List of media URLs |
| `mediaLoaded` | `Uint8List?` | `null` | Single loaded media |
| `mediasLoaded` | `List<Uint8List>?` | `null` | List of loaded media |
| `showSelectionIndicator` | `bool` | `true` | Show selection indicators |

## Examples

### Basic Implementation

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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showMediaPickerBottomSheetNoRadius(context),
              child: Text('Bottom Sheet (No Radius)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Advanced Usage with State Management

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
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MediaPickerBottomSheet(
            maxSelection: 10,
            allowMultiple: true,
            borderRadius: 24.0, // Custom border radius
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            onConfirmed: _handleMediaSelection,
          ),
        ),
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

### Fullscreen Media Viewer

```dart
void viewMediaFullscreen(BuildContext context, MediaItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullscreenMediaView(
        mediaItems: [item],
        initialIndex: 0,
        showSelectionIndicator: false,
      ),
    ),
  );
}

// View loaded media
void viewLoadedMedia(BuildContext context, Uint8List imageBytes) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullscreenMediaView(
        mediaLoaded: imageBytes,
        showSelectionIndicator: false,
      ),
    ),
  );
}

// View URL media
void viewUrlMedia(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullscreenMediaView(
        urlMedia: true,
        urlMedial: imageUrl,
        showSelectionIndicator: false,
      ),
    ),
  );
}
```

## New Features

### Customizable Border Radius for Bottom Sheet

The latest version introduces a new `borderRadius` parameter for the `MediaPickerBottomSheet` widget:

```dart
// With rounded corners (18px radius)
MediaPickerBottomSheet(
  borderRadius: 18.0,
  // other parameters...
)

// With no rounded corners (sharp edges)
MediaPickerBottomSheet(
  // borderRadius omitted or set to null
  // other parameters...
)

// Custom radius
MediaPickerBottomSheet(
  borderRadius: 12.0, // 12px radius
  // other parameters...
)
```

**Note:** When `borderRadius` is `null` or not provided, the bottom sheet will have no rounded corners (`BorderRadius.zero`).

## Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Bug Reports & Feature Requests

Found a bug or have a feature request? Please [open an issue](https://github.com/efedotof/media_ui_package/issues) on GitHub.