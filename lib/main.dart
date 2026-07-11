import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dalil Al-Mosafer',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dalil Al-Mosafer'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'App is working',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
