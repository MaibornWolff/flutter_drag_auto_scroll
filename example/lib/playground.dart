import 'package:flutter/material.dart';

import 'cross_tree_example.dart';
import 'same_tree_example.dart';

/// The original tweakable examples with live sliders for edge threshold and
/// scroll speed.
class Playground extends StatelessWidget {
  const Playground({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Same Tree'),
              Tab(text: 'Cross Tree'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: const [SameTreeExample(), CrossTreeExample()],
            ),
          ),
        ],
      ),
    );
  }
}
