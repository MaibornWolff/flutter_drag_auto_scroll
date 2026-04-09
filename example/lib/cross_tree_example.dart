import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

class CrossTreeExample extends StatefulWidget {
  const CrossTreeExample({super.key});

  @override
  State<CrossTreeExample> createState() => _CrossTreeExampleState();
}

class _CrossTreeExampleState extends State<CrossTreeExample> {
  final _controller = DragAutoScrollController();
  final _scrollController = ScrollController();
  final _droppedChips = <int, int>{};

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Drag a chip from the right onto the list to auto-scroll. '
                  'The two sides share a DragAutoScrollController.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: DragAutoScroller(
                  controller: _controller,
                  scrollController: _scrollController,
                  showEdgeZones: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 40,
                    itemBuilder: (context, index) {
                      final chipIndex = _droppedChips[index];
                      return DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          setState(() => _droppedChips[index] = details.data);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered = candidateData.isNotEmpty;
                          return Container(
                            color: isHovered
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: ListTile(
                              leading: chipIndex != null
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : const Icon(Icons.circle_outlined),
                              title: Text('Drop Target $index'),
                              subtitle: chipIndex != null
                                  ? Text('Received Chip $chipIndex')
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
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(width: 100,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 20,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          decoration: TextDecoration.none,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  child: Chip(label: Text('$index')),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
