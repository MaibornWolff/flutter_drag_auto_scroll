import 'package:flutter/material.dart';
import 'package:flutter_drag_auto_scroll/flutter_drag_auto_scroll.dart';

import 'scroller_controls.dart';

class SameTreeExample extends StatefulWidget {
  const SameTreeExample({super.key});

  @override
  State<SameTreeExample> createState() => _SameTreeExampleState();
}

class _SameTreeExampleState extends State<SameTreeExample> {
  final _scrollController = ScrollController();
  final _settings = ScrollerSettings();
  final _items = List.generate(50, (i) => i);

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onReorder(int draggedIndex, int insertBeforeIndex) {
    setState(() {
      if (insertBeforeIndex > draggedIndex) insertBeforeIndex--;
      if (draggedIndex == insertBeforeIndex) return;
      final item = _items.removeAt(draggedIndex);
      _items.insert(insertBeforeIndex, item);
    });
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
                  'Reorderable list using AutoScrollDraggable. The controller is '
                  'provided automatically via DragAutoScrollScope (InheritedWidget). '
                  'Drag an item to the edges to auto-scroll, then drop it between '
                  'items to reorder.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ScrollerControls(settings: _settings, onChanged: () => setState(() {})),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: DragAutoScroller(
            scrollController: _scrollController,
            edgeThreshold: _settings.edgeThreshold,
            maxScrollSpeed: _settings.maxScrollSpeed,
            showEdgeZones: _settings.showEdgeZones,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final color = _colors[item % _colors.length];
                return _ReorderableItem(index: index, item: item, color: color, onReorder: _onReorder);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReorderableItem extends StatefulWidget {
  const _ReorderableItem({required this.index, required this.item, required this.color, required this.onReorder});

  final int index;
  final int item;
  final MaterialColor color;
  final void Function(int draggedIndex, int insertBeforeIndex) onReorder;

  @override
  State<_ReorderableItem> createState() => _ReorderableItemState();
}

class _ReorderableItemState extends State<_ReorderableItem> {
  bool _dropAbove = false;
  bool _dropBelow = false;

  void _onMove(DragTargetDetails<int> details, RenderBox box) {
    final local = box.globalToLocal(details.offset);
    final half = box.size.height / 2;
    setState(() {
      _dropAbove = local.dy < half;
      _dropBelow = local.dy >= half;
    });
  }

  void _onLeave(int? _) {
    setState(() {
      _dropAbove = false;
      _dropBelow = false;
    });
  }

  void _onAccept(DragTargetDetails<int> details) {
    final insertAt = _dropBelow ? widget.index + 1 : widget.index;
    setState(() {
      _dropAbove = false;
      _dropBelow = false;
    });
    widget.onReorder(details.data, insertAt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<int>(
      onAcceptWithDetails: _onAccept,
      onMove: (details) {
        final box = context.findRenderObject()! as RenderBox;
        _onMove(details, box);
      },
      onLeave: _onLeave,
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DropIndicator(visible: _dropAbove, color: theme.colorScheme.primary),
            AutoScrollDraggable<int>(
              data: widget.index,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: widget.color.shade100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Item ${widget.item}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.color.shade900,
                      decoration: TextDecoration.none,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _ItemTile(item: widget.item, color: widget.color),
              ),
              child: _ItemTile(item: widget.item, color: widget.color),
            ),
            _DropIndicator(visible: _dropBelow, color: theme.colorScheme.primary),
          ],
        );
      },
    );
  }
}

class _DropIndicator extends StatelessWidget {
  const _DropIndicator({required this.visible, required this.color});

  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 16), color: color);
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.color});

  final int item;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.shade100,
        child: Text(
          '$item',
          style: TextStyle(color: color.shade900, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('Draggable Item $item'),
      subtitle: const Text('Drag towards edge to auto-scroll'),
    );
  }
}
