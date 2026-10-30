import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_ui_package/media_ui_package.dart';

const int _maxPreviewBytes = 8 * 1024 * 1024;
const int _inlineImageMaxBytes = 512 * 1024;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaUiPackageInitialize().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media UI Package Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final List<SelectedMediaItem> _selected = [];

  void _addSelected(MediaPickerResult? result) {
    if (result == null || result.isEmpty) {
      _snack('Ничего не выбрано');
      return;
    }
    var added = 0;
    setState(() {
      for (final item in result.items) {
        final exists = _selected.any((e) => e.uri == item.uri);
        if (!exists) {
          _selected.add(item);
          added++;
        }
      }
    });
    _snack(added == 0 ? 'Эти файлы уже в списке' : 'Добавлено: $added');
  }

  void _removeSelected(SelectedMediaItem item) {
    setState(() => _selected.removeWhere((e) => e.uri == item.uri));
  }

  void _clearSelected() {
    setState(() => _selected.clear());
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDialog({
    bool multiSelect = true,
    List<MediaPickerSection>? sections,
  }) async {
    final result = await MediaPickerDialog.show(
      context,
      title: multiSelect ? 'Выбрать файлы' : 'Выбрать файл',
      multiSelect: multiSelect,
      sections:
          sections ??
          const [
            MediaPickerSection.media,
            MediaPickerSection.audio,
            MediaPickerSection.downloads,
            MediaPickerSection.documents,
            MediaPickerSection.others,
          ],
    );
    _addSelected(result);
  }

  Future<void> _openDialogThemed() async {
    const config = MediaPickerConfig(
      selectedColor: Colors.pink,
      borderColor: Colors.pinkAccent,
      borderRadius: 16,
      gridSpacing: 6,
    );
    final result = await MediaPickerDialog.show(
      context,
      title: 'Кастомная тема',
      config: config,
    );
    _addSelected(result);
  }

  Future<void> _openSheet() async {
    final result = await MediaPickerBottomSheet.show(
      context,
      title: 'Загрузить файл',
      confirmLabel: 'Прикрепить',
    );
    _addSelected(result);
  }

  Future<void> _openEmbedded() async {
    final result = await Navigator.of(context).push<MediaPickerResult>(
      MaterialPageRoute(builder: (_) => const _EmbeddedPickerPage()),
    );
    _addSelected(result);
  }

  void _openResultPage() {
    if (_selected.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          result: MediaPickerResult.fromItems(List.of(_selected)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media UI Package'),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Очистить выбранное',
              onPressed: _clearSelected,
            ),
        ],
      ),
      body: ValueListenableBuilder<MediaPermissionState>(
        valueListenable: MediaUiPackageInitialize().permissions,
        builder: (context, perms, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PermissionCard(perms: perms),
              const SizedBox(height: 16),
              _SelectedSection(
                items: _selected,
                onRemove: _removeSelected,
                onClear: _selected.isEmpty ? null : _clearSelected,
                onOpen: (item) => _previewItem(context, item),
                onOpenAll: _selected.isEmpty ? null : _openResultPage,
              ),
              const SizedBox(height: 16),
              _ActionTile(
                icon: Icons.photo_library,
                title: 'Диалог — мультивыбор',
                subtitle: 'Все секции, тема по умолчанию',
                onTap: _openDialog,
              ),
              _ActionTile(
                icon: Icons.image,
                title: 'Диалог — одиночный выбор',
                subtitle: 'Только медиатека, одиночный',
                onTap: () => _openDialog(
                  multiSelect: false,
                  sections: const [MediaPickerSection.media],
                ),
              ),
              _ActionTile(
                icon: Icons.palette,
                title: 'Диалог — кастомная тема',
                subtitle: 'Pink, radius 16, spacing 6',
                onTap: _openDialogThemed,
              ),
              _ActionTile(
                icon: Icons.expand_more,
                title: 'Bottom sheet',
                subtitle: 'Draggable, 85% экрана',
                onTap: _openSheet,
              ),
              _ActionTile(
                icon: Icons.fullscreen,
                title: 'Встроить в свой экран',
                subtitle: 'MediaPickerWidget напрямую',
                onTap: _openEmbedded,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectedSection extends StatelessWidget {
  final List<SelectedMediaItem> items;
  final void Function(SelectedMediaItem) onRemove;
  final VoidCallback? onClear;
  final void Function(SelectedMediaItem) onOpen;
  final VoidCallback? onOpenAll;

  const _SelectedSection({
    required this.items,
    required this.onRemove,
    required this.onOpen,
    this.onClear,
    this.onOpenAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = items.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Выбрано: ${items.length}',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (!isEmpty && onOpenAll != null)
                  TextButton(onPressed: onOpenAll, child: const Text('Все')),
                if (!isEmpty && onClear != null)
                  TextButton(onPressed: onClear, child: const Text('Очистить')),
              ],
            ),
            const SizedBox(height: 8),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Пока ничего не выбрано',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _SelectedTile(
                      item: item,
                      onTap: () => onOpen(item),
                      onRemove: () => onRemove(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedTile extends StatelessWidget {
  final SelectedMediaItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SelectedTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _ItemThumbnail(item: item),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      _formatBytes(item.size),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final MediaPermissionState perms;

  const _PermissionCard({required this.perms});

  @override
  Widget build(BuildContext context) {
    if (perms.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Проверка разрешений...'),
            ],
          ),
        ),
      );
    }

    if (perms.hasScopedPermission) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.verified, color: Colors.green),
          title: const Text('Разрешения выданы'),
          subtitle: Text(
            perms.hasAllFilesPermission
                ? 'MediaStore + полный доступ'
                : 'MediaStore (Download/Documents по SAF)',
          ),
        ),
      );
    }

    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.orange),
        title: const Text('Нужны разрешения на медиа'),
        subtitle: const Text('Выдайте доступ к фото, видео и аудио'),
        trailing: TextButton(
          onPressed: () => MediaUiPackageInitialize().requestScopedPermission(),
          child: const Text('Выдать'),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _EmbeddedPickerPage extends StatefulWidget {
  const _EmbeddedPickerPage();

  @override
  State<_EmbeddedPickerPage> createState() => _EmbeddedPickerPageState();
}

class _EmbeddedPickerPageState extends State<_EmbeddedPickerPage> {
  final _pickerKey = GlobalKey<MediaPickerWidgetState>();

  MediaPickerResult? _readSelection() {
    final r = _pickerKey.currentState?.currentResult;
    if (r == null || r.isEmpty) return null;
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<MediaPickerResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_readSelection());
      },
      child: Scaffold(
        body: SafeArea(
          child: MediaPickerWidget(
            key: _pickerKey,
            title: 'Встроенный пикер',
            confirmLabel: 'Выбрать',
            multiSelect: true,
            onConfirm: (result) => Navigator.of(context).pop(result),
            onCancel: () => Navigator.of(context).pop(_readSelection()),
          ),
        ),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  final MediaPickerResult result;

  const _ResultPage({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбрано: ${result.count}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Подробности',
            onPressed: () => _showDetails(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.data_usage, size: 18),
                const SizedBox(width: 8),
                Text('Общий размер: ${_formatBytes(result.totalSize)}'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: result.count,
              itemBuilder: (context, i) {
                final item = result.items[i];
                return _ResultItemTile(
                  item: item,
                  onTap: () => _previewItem(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: result.count,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final item = result.items[i];
            return ListTile(
              leading: Icon(_iconForType(item.type)),
              title: Text(item.name),
              subtitle: Text('${item.type} · ${_formatBytes(item.size)}'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.uri));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('URI скопирован')));
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResultItemTile extends StatelessWidget {
  final SelectedMediaItem item;
  final VoidCallback onTap;

  const _ResultItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ItemThumbnail(item: item),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final SelectedMediaItem item;

  const _ItemThumbnail({required this.item});

  bool get _isDeviceSource => item.source == MediaSource.device;

  @override
  Widget build(BuildContext context) {
    if (item.isImage && _isDeviceSource) return _mediaStoreThumb();
    if (item.isVideo && _isDeviceSource) return _mediaStoreThumb();
    if (item.isImage) return _fileBytesThumb();
    final color = item.isAudio ? Colors.purple : Colors.blueGrey;
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Icon(_iconForType(item.type), color: color),
    );
  }

  Widget _mediaStoreThumb() {
    return FutureBuilder<Uint8List?>(
      future: MediaThumbnailCache.load(item.id, item.type, 200, 200),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null) {
          return Image.memory(bytes, fit: BoxFit.cover);
        }
        return _placeholder(item.isVideo ? Icons.videocam : Icons.image);
      },
    );
  }

  Widget _fileBytesThumb() {
    if (item.size > _inlineImageMaxBytes) {
      return _placeholder(Icons.image);
    }
    final cached = FileBytesCache.cached(item.uri);
    if (cached != null) {
      return Image.memory(cached, fit: BoxFit.cover);
    }
    return FutureBuilder<Uint8List?>(
      future: FileBytesCache.load(item.uri),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null) {
          return Image.memory(bytes, fit: BoxFit.cover);
        }
        return _placeholder(Icons.image);
      },
    );
  }

  Widget _placeholder(IconData icon) => Container(
    color: Colors.grey.shade300,
    child: Icon(icon, color: Colors.grey.shade600),
  );
}

Future<void> _previewItem(BuildContext context, SelectedMediaItem item) async {
  if (item.size > _maxPreviewBytes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Файл слишком большой для превью: ${_formatBytes(item.size)}',
        ),
      ),
    );
    return;
  }

  if (!item.isImage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} · ${_formatBytes(item.size)}')),
    );
    return;
  }

  final cached = FileBytesCache.cached(item.uri);
  if (cached != null) {
    _showImageDialog(context, cached);
    return;
  }

  final bytes = await FileBytesCache.load(item.uri);
  if (!context.mounted) return;
  if (bytes == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Не удалось прочитать файл')));
    return;
  }
  _showImageDialog(context, bytes);
}

void _showImageDialog(BuildContext context, Uint8List bytes) {
  showDialog<void>(
    context: context,
    builder: (_) =>
        Dialog(child: InteractiveViewer(child: Image.memory(bytes))),
  );
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
}

IconData _iconForType(String type) {
  switch (type) {
    case 'image':
      return Icons.image;
    case 'video':
      return Icons.videocam;
    case 'audio':
      return Icons.music_note;
    default:
      return Icons.insert_drive_file;
  }
}
