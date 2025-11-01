import 'package:flutter/material.dart';

class AnimatedSheetContent extends StatelessWidget {
  final Widget child;

  const AnimatedSheetContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
