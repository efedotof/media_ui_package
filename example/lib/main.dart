import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';

void main() {
  DeviceMediaLibrary.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media UI Package Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: Locale('ru'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(title: 'Media UI Package Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MediaItem> _selectedMediaItems = [];

  void _openMediaPickerScreen() async {
    final result = await Navigator.of(context).push<List<MediaItem>>(
      MaterialPageRoute(
        builder: (context) => MediaPickerScreen(
          allowMultiple: true,
          maxSelection: 5,
          showVideos: true,
          initialSelection: _selectedMediaItems,
          showSelectionIndicators: true,
          config: const MediaPickerConfig(),
          mediaLibrary: DeviceMediaLibrary(),
          onSelectionChanged: null,
          onConfirmed: null,
          onConfirmedWithBytes: null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openMediaPickerDialog() async {
    final result = await MediaPickerBottomSheet.open(
      context: context,
      allowMultiple: false,
      showVideos: false,
      initialSelection: _selectedMediaItems,
      maxSelection: 5,
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openMediaPickerBottomSheet() async {
    final result = await MediaPickerBottomSheet.open(
      context: context,
      allowMultiple: true,
      maxSelection: 3,
      showVideos: true,
      initialSelection: _selectedMediaItems,
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openMediaPickerUI() async {
    final result = await showDialog<List<MediaItem>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          height: 500,
          child: MediaPickerUI(
            initialSelection: _selectedMediaItems,
            maxSelection: 5,
            allowMultiple: true,
            showVideos: true,
            onFilesSelected: (files) {
              Navigator.of(context).pop(files);
            },
            showPickButton: true,
            enableDragDrop: true,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload, size: 64),
                    const SizedBox(height: 16),
                    const Text('Drag & Drop Area'),
                    const Text('or click the + button'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final pickerState = context
                            .findAncestorStateOfType<MediaPickerWidgetState>();
                        pickerState?.pickFiles();
                      },
                      child: const Text('Select Files Manually'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openPlatformMediaPicker() async {
    final result = await showDialog<List<MediaItem>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: PlatformMediaPickerUI(
          initialSelection: _selectedMediaItems,
          maxSelection: 5,
          allowMultiple: true,
          showVideos: true,
          onConfirmed: (files) {
            Navigator.of(context).pop(files);
          },
          enableDragDrop: true,
          child: Container(
            height: 400,
            width: 400,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 64),
                  SizedBox(height: 16),
                  Text('Platform Media Picker'),
                  Text('Supports drag & drop'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openFullscreenView() {
    if (_selectedMediaItems.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullscreenMediaView(
            mediaItems: _selectedMediaItems,
            initialIndex: 0,
            selectedItems: _selectedMediaItems,
            onItemSelected: (item, selected) {
              setState(() {
                if (selected) {
                  _selectedMediaItems.add(item);
                } else {
                  _selectedMediaItems.remove(item);
                }
              });
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullscreenMediaView(
            urlMedia: true,
            urlMedias: const [
              'https://picsum.photos/800/600',
              'https://picsum.photos/800/601',
              'https://picsum.photos/800/602',
            ],
          ),
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedMediaItems.clear();
    });
  }

  Widget _buildMediaPreview(MediaItem item, int index) {
    final isVideo = item.type.contains('video');
    final isNetwork = item.uri.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullscreenMediaView(
              mediaItems: _selectedMediaItems,
              initialIndex: index,
              selectedItems: _selectedMediaItems,
              onItemSelected: (item, selected) {
                setState(() {
                  if (selected) {
                    _selectedMediaItems.add(item);
                  } else {
                    _selectedMediaItems.remove(item);
                  }
                });
              },
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media preview
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: isVideo
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 32, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Video',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : isNetwork
                ? Image.network(
                    item.uri,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  )
                : kIsWeb
                ? FutureBuilder<Uint8List?>(
                    future: _loadImageBytes(item),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : Image.file(
                    File(item.uri),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  ),
          ),

          // Video indicator
          if (isVideo)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7 * 255),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(item.duration ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Selection index
          if (_selectedMediaItems.contains(item))
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${_selectedMediaItems.indexOf(item) + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMediaItems.remove(item);
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),

          // File info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7 * 255),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    _formatFileSize(item.size),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8 * 255),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _loadImageBytes(MediaItem item) async {
    try {
      return await DeviceMediaLibrary().getFileBytes(item.uri);
    } catch (e) {
      return null;
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          if (_selectedMediaItems.isNotEmpty)
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear_all),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _openMediaPickerScreen,
                    child: const Text('Open Media Picker Screen'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _openMediaPickerDialog,
                    child: const Text('Open Media Picker Dialog'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _openMediaPickerBottomSheet,
                    child: const Text('Open Media Picker Bottom Sheet'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _openMediaPickerUI,
                    child: const Text('Open Media Picker UI (Drag & Drop)'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _openPlatformMediaPicker,
                    child: const Text('Open Platform Media Picker'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _openFullscreenView,
                    child: const Text('Open Fullscreen View'),
                  ),
                ),
              ],
            ),
          ),

          // Selected media preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Selected Media: ${_selectedMediaItems.length}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (_selectedMediaItems.isNotEmpty)
                            OutlinedButton(
                              onPressed: _clearSelection,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text('Clear All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_selectedMediaItems.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline
                                      .withValues(alpha: 0.5 * 255),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No media selected',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use buttons above to select media files',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.7 * 255),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: _selectedMediaItems.length,
                            itemBuilder: (context, index) {
                              return _buildMediaPreview(
                                _selectedMediaItems[index],
                                index,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Feature cards list
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildFeatureCard(
                    context,
                    'Media Picker Screen',
                    'Full-screen media selection with multi-select, video support, and selection indicators',
                    Icons.photo_library,
                    _openMediaPickerScreen,
                  ),
                  _buildFeatureCard(
                    context,
                    'Media Picker Dialog',
                    'Dialog-based media selection. Uses MediaPickerUI with drag&drop on Windows/Web',
                    Icons.photo,
                    _openMediaPickerDialog,
                  ),
                  _buildFeatureCard(
                    context,
                    'Media Picker Bottom Sheet',
                    'Bottom Sheet for media selection. Uses MediaPickerUI on Windows/Web',
                    Icons.grid_view,
                    _openMediaPickerBottomSheet,
                  ),
                  _buildFeatureCard(
                    context,
                    'Media Picker UI',
                    'Direct use of MediaPickerUI with drag&drop support for Windows/Web',
                    Icons.cloud_upload,
                    _openMediaPickerUI,
                  ),
                  _buildFeatureCard(
                    context,
                    'Platform Media Picker',
                    'Cross-platform picker with direct access to DeviceMediaLibrary',
                    Icons.perm_media,
                    _openPlatformMediaPicker,
                  ),
                  _buildFeatureCard(
                    context,
                    'Fullscreen Media View',
                    'Fullscreen media viewer with zoom gestures, video player, and overlay',
                    Icons.fullscreen,
                    _openFullscreenView,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
