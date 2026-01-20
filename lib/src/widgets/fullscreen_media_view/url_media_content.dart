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
    if (urls.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white, size: 32),
              SizedBox(height: 8),
              Text(
                'Нет доступных изображений',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (urls.length == 1) {
      return Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: Image.network(
              urls.first,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Ошибка загрузки',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.network(
                urls[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image at index $index: $error');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Ошибка загрузки',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
