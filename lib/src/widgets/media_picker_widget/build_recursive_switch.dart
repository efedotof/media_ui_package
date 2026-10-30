import 'package:flutter/material.dart';

class BuildRecursiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const BuildRecursiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SwitchListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        value: value,
        title: const Text('Сканировать подпапки'),
        subtitle: Text(
          value
              ? 'Медленнее, но находит файлы в подпапках'
              : 'Только корень папки (быстро)',
          style: const TextStyle(fontSize: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}