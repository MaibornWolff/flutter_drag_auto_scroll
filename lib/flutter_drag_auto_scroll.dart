/// Auto-scroll any scrollable widget when a Draggable enters its edge zones.
///
/// ## Quick Start
///
/// Wrap your scrollable with [DragAutoScroller] and replace [Draggable] with
/// [AutoScrollDraggable]:
///
/// ```dart
/// DragAutoScroller(
///   scrollController: _controller,
///   child: ListView.builder(
///     controller: _controller,
///     itemBuilder: (_, i) => AutoScrollDraggable<int>(
///       data: i,
///       feedback: Material(child: Text('$i')),
///       child: ListTile(title: Text('Item $i')),
///     ),
///   ),
/// )
/// ```
///
/// ## Cross-tree usage
///
/// When the drag source and scroll target are in different widget subtrees,
/// share a [DragAutoScrollController]:
///
/// ```dart
/// final controller = DragAutoScrollController();
///
/// // Scroll target
/// DragAutoScroller(controller: controller, scrollController: sc, child: ...)
///
/// // Drag source (different subtree)
/// AutoScrollDraggable(controller: controller, data: d, feedback: f, child: c)
/// ```
library;

export 'src/auto_scroll_draggable.dart';
export 'src/drag_auto_scroll_controller.dart';
export 'src/drag_auto_scroll_scope.dart';
export 'src/drag_auto_scroller.dart';
