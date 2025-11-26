import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Size screenSize;

  const LoadingWidget({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: screenSize.width,
      height: screenSize.height,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );
  }
}
