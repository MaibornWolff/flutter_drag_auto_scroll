import 'package:flutter/material.dart';

import 'same_tree_example.dart';
import 'cross_tree_example.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_drag_auto_scroll',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ExampleTabs(),
    );
  }
}

class ExampleTabs extends StatelessWidget {
  const ExampleTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_drag_auto_scroll'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Same Tree'),
              Tab(text: 'Cross Tree'),
            ],
          ),
        ),
        body: TabBarView(
          children: [const SameTreeExample(), const CrossTreeExample()],
        ),
      ),
    );
  }
}
