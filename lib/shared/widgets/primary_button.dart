import 'package:claudewatch/core/widgets/base_widget.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends BaseWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
