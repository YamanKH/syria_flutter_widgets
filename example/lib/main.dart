import 'package:flutter/material.dart';
import 'package:syria_flutter_widgets/syria_flutter_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AnimatedSyrianFlag(
                width: 260,
                height: 150,
                borderRadius: 18,
                elevation: 10,
                waveAmplitude: 0.02,
                waveFrequency: 1.2,
              ),
              SizedBox(height: 24),
              SyrianFlag(width: 240, height: 140, borderRadius: 18, elevation: 6),
              SizedBox(height: 24),
              SyrianFlagBadge(diameter: 140, elevation: 6),
            ],
          ),
        ),
      ),
    );
  }
}
