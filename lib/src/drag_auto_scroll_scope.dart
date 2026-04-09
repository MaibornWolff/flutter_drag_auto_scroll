import 'package:flutter/widgets.dart';

import 'drag_auto_scroll_controller.dart';

/// Provides a [DragAutoScrollController] to descendant widgets.
///
/// Created automatically by [DragAutoScroller] when no explicit controller
/// is provided. Used by [AutoScrollDraggable] to look up the controller
/// in the same widget tree.
///
/// You typically don't need to use this directly — [DragAutoScroller] creates
/// it for you. It's public for advanced use cases where you want to provide
/// a controller to a subtree without wrapping a scrollable.
class DragAutoScrollScope extends InheritedWidget {
  /// Creates a scope that provides [controller] to descendants.
  const DragAutoScrollScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller provided to descendants.
  final DragAutoScrollController controller;

  /// Returns the nearest [DragAutoScrollController] above [context],
  /// or `null` if none is found.
  static DragAutoScrollController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DragAutoScrollScope>()
        ?.controller;
  }

  /// Returns the nearest [DragAutoScrollController] above [context].
  ///
  /// Throws if no [DragAutoScrollScope] is found.
  static DragAutoScrollController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(
      controller != null,
      'No DragAutoScrollScope found in context. '
      'Wrap your widget tree with DragAutoScroller or provide a '
      'DragAutoScrollController explicitly.',
    );
    return controller!;
  }

  @override
  bool updateShouldNotify(DragAutoScrollScope oldWidget) =>
      controller != oldWidget.controller;
}
