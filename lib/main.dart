import 'package:flutter/material.dart';
import 'app/bootstrap.dart';

/// Application entry point.
///
/// Delegates startup work (Flutter bindings, system UI, dependency setup) to
/// [bootstrap] and launches the app.
void main() => bootstrap();

/// Simple example app used by the template.
///
/// This class exists mainly to keep the old template structure alive. Actual
/// app startup is performed by [bootstrap].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// A simple counter page used by the Flutter template.
///
/// This widget is stateful so it can update the counter when the button is
/// pressed.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// Title shown in the app bar.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
