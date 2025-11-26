import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

void main() {
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaPickerScreen(
          allowMultiple: true,
          maxSelection: 5,
          showVideos: true,
          initialSelection: _selectedMediaItems,
          onSelectionChanged: (selectedItems) {
            debugPrint('Selected items: ${selectedItems.length}');
          },
        ),
      ),
    );

    if (result != null && result is List<MediaItem>) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openMediaPickerDialog() async {
    final result = await showDialog<List<MediaItem>>(
      context: context,
      builder: (context) => MediaPickerDialog(
        allowMultiple: false,
        showVideos: false,
        initialSelection: _selectedMediaItems,
        onSelectionChanged: (selectedItems) {
          debugPrint('Dialog selection: ${selectedItems.length}');
        },
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMediaItems = result;
      });
    }
  }

  void _openMediaPickerBottomSheet() async {
    final result = await showModalBottomSheet<List<MediaItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        allowMultiple: true,
        maxSelection: 3,
        showVideos: true,
        initialSelection: _selectedMediaItems,
        onSelectionChanged: (selectedItems) {
          debugPrint('Bottom sheet selection: ${selectedItems.length}');
        },
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
                    onPressed: _openFullscreenView,
                    child: const Text('Open Fullscreen View'),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Media: ${_selectedMediaItems.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedMediaItems.isEmpty)
                      Text(
                        'No media selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedMediaItems.map((item) {
                          return Chip(
                            label: Text(
                              'Item ${_selectedMediaItems.indexOf(item) + 1}',
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                _selectedMediaItems.remove(item);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildFeatureCard(
                    context,
                    'Media Picker Screen',
                    'Полноэкранный выбор медиа с поддержкой множественного выбора, видео и индикацией выбора',
                    Icons.photo_library,
                    _openMediaPickerScreen,
                  ),
                  _buildFeatureCard(
                    context,
                    'Media Picker Dialog',
                    'Диалоговое окно выбора медиа с ограниченным количеством элементов',
                    Icons.photo,
                    _openMediaPickerDialog,
                  ),
                  _buildFeatureCard(
                    context,
                    'Media Picker Bottom Sheet',
                    'Bottom Sheet для выбора медиа с плавной анимацией и кастомными размерами',
                    Icons.grid_view,
                    _openMediaPickerBottomSheet,
                  ),
                  _buildFeatureCard(
                    context,
                    'Fullscreen Media View',
                    'Полноэкранный просмотр медиа с жестами масштабирования, видео плеером и оверлеем',
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}
