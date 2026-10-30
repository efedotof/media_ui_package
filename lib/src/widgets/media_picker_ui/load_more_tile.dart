import 'package:flutter/material.dart';

class LoadMoreTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const LoadMoreTile({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.expand_more),
          label: const Text('Загрузить ещё'),
        ),
      ),
    );
  }
}
