import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.screenSize});
  final Size screenSize;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: screenSize.width,
      height: screenSize.height,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}