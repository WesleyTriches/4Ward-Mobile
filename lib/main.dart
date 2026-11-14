import 'package:app01/telas/contador.dart';
import 'package:app01/telas/home.dart';
import 'package:app01/telas/login.dart';
import 'package:app01/telas/sobre.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/contador': (context) => ContadorPage(title: "Contador"),
        '/sobre': (context) => SobrePage(),
      },
    );
  }
}
