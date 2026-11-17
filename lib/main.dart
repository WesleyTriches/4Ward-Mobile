import 'package:flutter/material.dart';

void main() {
  runApp(const FourWardApp());
}

class FourWardApp extends StatelessWidget {
  const FourWardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '4Ward',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('4Ward'))),
    );
  }
}
