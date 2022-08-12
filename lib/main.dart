import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Running',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
                onPressed: () {},
                child: const Text("Here is in Youtube ID"))
          ),
          OutlinedButton(
              onPressed: () {},
              child: const Text("Here is in Youtube ID"))
        ],
      ),
    );
  }
}