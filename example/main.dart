import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

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
        body: const TabBarView(
          children: [_SameTreeExample(), _CrossTreeExample()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Example 1: Same widget tree — no explicit controller needed
// ---------------------------------------------------------------------------

class _SameTreeExample extends StatefulWidget {
  const _SameTreeExample();

  @override
  State<_SameTreeExample> createState() => _SameTreeExampleState();
}

class _SameTreeExampleState extends State<_SameTreeExample> {
  final _scrollController = ScrollController();
  String? _lastDropped;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'All items are AutoScrollDraggable. The controller is provided '
            'automatically via DragAutoScrollScope. Drag an item to the edges '
            'to auto-scroll, then drop it on the target below.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: DragAutoScroller(
            scrollController: _scrollController,
            showEdgeZones: true,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 50,
              itemBuilder: (context, index) {
                final color = colors[index % colors.length];
                return AutoScrollDraggable<int>(
                  data: index,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: color.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        'Item $index',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color.shade900,
                          decoration: TextDecoration.none,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _ItemTile(index: index, color: color),
                  ),
                  child: _ItemTile(index: index, color: color),
                );
              },
            ),
          ),
        ),
        _DropZone(
          label: _lastDropped != null
              ? 'Dropped: $_lastDropped'
              : 'Drop items here',
          onAccept: (i) => setState(() => _lastDropped = 'Item $i'),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.index, required this.color});

  final int index;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.shade100,
        child: Text(
          '$index',
          style: TextStyle(color: color.shade900, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('Draggable Item $index'),
      subtitle: const Text('Drag towards edge to auto-scroll'),
    );
  }
}

// ---------------------------------------------------------------------------
// Example 2: Cross widget tree — shared controller
// ---------------------------------------------------------------------------

class _CrossTreeExample extends StatefulWidget {
  const _CrossTreeExample();

  @override
  State<_CrossTreeExample> createState() => _CrossTreeExampleState();
}

class _CrossTreeExampleState extends State<_CrossTreeExample> {
  final _controller = DragAutoScrollController();
  final _scrollController = ScrollController();
  final _accepted = <int>[];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'The drag source (top row) and scroll target (list below) are in '
            'separate subtrees. They share a DragAutoScrollController. '
            'Drag a chip from the top row onto the list to auto-scroll.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // Drag source — separate subtree
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 20,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoScrollDraggable<int>(
                  controller: _controller,
                  data: index,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Chip $index',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          decoration: TextDecoration.none,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  child: Chip(label: Text('Chip $index')),
                ),
              );
            },
          ),
        ),
        const Divider(),
        // Scroll target — separate subtree
        Expanded(
          child: DragAutoScroller(
            controller: _controller,
            scrollController: _scrollController,
            showEdgeZones: true,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 40,
              itemBuilder: (context, index) {
                final isAccepted = _accepted.contains(index);
                return DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    setState(() => _accepted.add(index));
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovered = candidateData.isNotEmpty;
                    return Container(
                      color: isHovered
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: isAccepted
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.circle_outlined),
                        title: Text('Drop Target $index'),
                        subtitle: isAccepted
                            ? const Text('Item dropped here!')
                            : const Text('Drag a chip here'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared drop zone widget
// ---------------------------------------------------------------------------

class _DropZone extends StatelessWidget {
  const _DropZone({required this.label, required this.onAccept});

  final String label;
  final ValueChanged<int> onAccept;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: DragTarget<int>(
        onAcceptWithDetails: (details) => onAccept(details.data),
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          final theme = Theme.of(context);
          return Container(
            color: isHovered
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLow,
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isHovered
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
