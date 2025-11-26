import 'dart:typed_data';
import 'package:flutter/material.dart';

class LoadedMediaContent extends StatefulWidget {
  final Uint8List? mediaLoaded;
  final List<Uint8List>? mediasLoaded;
  final PageController controller;
  final List<String>? videoPaths;

  const LoadedMediaContent({
    super.key,
    this.mediaLoaded,
    this.mediasLoaded,
    required this.controller,
    this.videoPaths,
  });

  @override
  State<LoadedMediaContent> createState() => _LoadedMediaContentState();
}

class _LoadedMediaContentState extends State<LoadedMediaContent> {
  @override
  Widget build(BuildContext context) {
    if (widget.mediaLoaded != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            alignment: Alignment.center,
            panEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: Center(
              child: Image.memory(
                widget.mediaLoaded!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      );
    }

    if (widget.mediasLoaded != null && widget.mediasLoaded!.isNotEmpty) {
      if (widget.mediasLoaded!.length == 1) {
        return Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              alignment: Alignment.center,
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Center(
                child: Image.memory(
                  widget.mediaLoaded!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      }
      return PageView.builder(
        controller: PageController(initialPage: 0, viewportFraction: 1.0),
        itemCount: widget.mediasLoaded!.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.black,
            child: InteractiveViewer(
              alignment: Alignment.center,
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.memory(
                widget.mediasLoaded![index],
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          );
        },
      );
    }

    return Container(color: Colors.black);
  }
}
