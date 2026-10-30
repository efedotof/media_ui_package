import 'dart:typed_data';

import 'package:flutter/material.dart';

class PreviewLeading extends StatelessWidget {
  const PreviewLeading({super.key, required this.bytes});
  final Uint8List bytes;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        bytes,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
