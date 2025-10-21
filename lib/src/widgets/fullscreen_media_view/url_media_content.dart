import 'package:flutter/material.dart';

class UrlMediaContent extends StatelessWidget {
  final List<String> urls;
  final PageController controller;

  const UrlMediaContent({
    super.key,
    required this.urls,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 3.0,
          child: Image.network(
            urls.first,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error, color: Colors.white, size: 40),
            ),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: PageController(initialPage: 0, viewportFraction: 0.92),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final url = urls[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
