import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

import 'scroller_controls.dart';

class CrossTreeExample extends StatefulWidget {
  const CrossTreeExample({super.key});

  @override
  State<CrossTreeExample> createState() => _CrossTreeExampleState();
}

class _CrossTreeExampleState extends State<CrossTreeExample> {
  final _controller = DragAutoScrollController();
  final _scrollController = ScrollController();
  final _settings = ScrollerSettings();
  final _droppedChips = <int, int>{};

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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  'The drag source (chips on the right) and scroll target (list on '
                  'the left) are in separate widget subtrees. They share a '
                  'DragAutoScrollController. Drag a chip onto the list to '
                  'auto-scroll and drop it on a target.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ScrollerControls(
                  settings: _settings,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DragAutoScroller(
                  controller: _controller,
                  scrollController: _scrollController,
                  edgeThreshold: _settings.edgeThreshold,
                  maxScrollSpeed: _settings.maxScrollSpeed,
                  showEdgeZones: _settings.showEdgeZones,
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
              const VerticalDivider(width: 1),
              SizedBox(
                width: 100,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
          ),
        ),
      ],
    );
  }
}
