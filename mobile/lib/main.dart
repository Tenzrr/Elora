import 'package:flutter/material.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';

void main() => runApp(const EloraApp());

class EloraApp extends StatelessWidget {
  const EloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elora',
      debugShowCheckedModeBanner: false,
      theme: EloraTheme.light(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Elora')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Development scaffold. Features are not implemented.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
