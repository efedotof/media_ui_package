import 'package:flutter/material.dart';
import '../elastic_item.dart';

class LoadingPlaceholder extends StatelessWidget {
  const LoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ElasticItem(index: 0, totalLoadingItems: 1);
  }
}
