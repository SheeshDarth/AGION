import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/screens/main_shell.dart';

class AgionApp extends StatelessWidget {
  const AgionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agion',
      debugShowCheckedModeBanner: false,
      theme: AgionTheme.dark,
      home: const MainShell(),
    );
  }
}
