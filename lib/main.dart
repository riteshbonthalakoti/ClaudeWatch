import 'package:flutter/material.dart';

void main() {
  runApp(const ClaudeWatchApp());
}

class ClaudeWatchApp extends StatelessWidget {
  const ClaudeWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClaudeWatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('ClaudeWatch'))),
    );
  }
}
