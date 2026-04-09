import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/studio_screen.dart';

void main() {
  runApp(const ProviderScope(child: RadFlowApp()));
}

class RadFlowApp extends StatelessWidget {
  const RadFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadFlow Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF11111B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF1E1E2E),
        ),
      ),
      home: const StudioScreen(),
    );
  }
}
