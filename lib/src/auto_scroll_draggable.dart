import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'drag_auto_scroll_controller.dart';
import 'drag_auto_scroll_scope.dart';

/// A drop-in replacement for [Draggable] that signals drag start/end to a
/// [DragAutoScrollController], enabling auto-scroll in any listening
/// [DragAutoScroller].
///
/// If no [controller] is provided, looks up the nearest
/// [DragAutoScrollScope] in the widget tree (created automatically by
/// [DragAutoScroller]).
///
/// All [Draggable] parameters are passed through unchanged.
///
/// ```dart
/// AutoScrollDraggable<int>(
///   data: index,
///   feedback: Material(child: Text('Item $index')),
///   child: ListTile(title: Text('Item $index')),
/// )
/// ```
class AutoScrollDraggable<T extends Object> extends StatelessWidget {
  /// Creates an auto-scroll-aware draggable.
  ///
  /// If [controller] is null, the nearest [DragAutoScrollScope] is used.
  /// If neither is available, the widget behaves like a standard [Draggable].
  const AutoScrollDraggable({
    super.key,
    this.controller,
    required this.child,
    required this.feedback,
    this.data,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = childDragAnchorStrategy,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.rootOverlay = false,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.allowedButtonsFilter,
  });

  /// Optional controller. If null, looks up [DragAutoScrollScope].
  final DragAutoScrollController? controller;

  /// {@macro flutter.widgets.Draggable.child}
  final Widget child;

  /// {@macro flutter.widgets.Draggable.feedback}
  final Widget feedback;

  /// {@macro flutter.widgets.Draggable.data}
  final T? data;

  /// {@macro flutter.widgets.Draggable.axis}
  final Axis? axis;

  /// {@macro flutter.widgets.Draggable.childWhenDragging}
  final Widget? childWhenDragging;

  /// {@macro flutter.widgets.Draggable.feedbackOffset}
  final Offset feedbackOffset;

  /// {@macro flutter.widgets.Draggable.dragAnchorStrategy}
  final DragAnchorStrategy dragAnchorStrategy;

  /// {@macro flutter.widgets.Draggable.affinity}
  final Axis? affinity;

  /// {@macro flutter.widgets.Draggable.maxSimultaneousDrags}
  final int? maxSimultaneousDrags;

  /// {@macro flutter.widgets.Draggable.onDragStarted}
  final VoidCallback? onDragStarted;

  /// {@macro flutter.widgets.Draggable.onDragUpdate}
  final DragUpdateCallback? onDragUpdate;

  /// {@macro flutter.widgets.Draggable.onDraggableCanceled}
  final DraggableCanceledCallback? onDraggableCanceled;

  /// {@macro flutter.widgets.Draggable.onDragEnd}
  final DragEndCallback? onDragEnd;

  /// {@macro flutter.widgets.Draggable.onDragCompleted}
  final VoidCallback? onDragCompleted;

  /// {@macro flutter.widgets.Draggable.ignoringFeedbackSemantics}
  final bool ignoringFeedbackSemantics;

  /// {@macro flutter.widgets.Draggable.ignoringFeedbackPointer}
  final bool ignoringFeedbackPointer;

  /// {@macro flutter.widgets.Draggable.rootOverlay}
  final bool rootOverlay;

  /// {@macro flutter.widgets.Draggable.hitTestBehavior}
  final HitTestBehavior hitTestBehavior;

  /// {@macro flutter.gestures.multidrag._allowedButtonsFilter}
  final AllowedButtonsFilter? allowedButtonsFilter;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? DragAutoScrollScope.maybeOf(context);

    return Draggable<T>(
      data: data,
      axis: axis,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      feedbackOffset: feedbackOffset,
      dragAnchorStrategy: dragAnchorStrategy,
      affinity: affinity,
      maxSimultaneousDrags: maxSimultaneousDrags,
      ignoringFeedbackSemantics: ignoringFeedbackSemantics,
      ignoringFeedbackPointer: ignoringFeedbackPointer,
      rootOverlay: rootOverlay,
      hitTestBehavior: hitTestBehavior,
      allowedButtonsFilter: allowedButtonsFilter,
      onDragStarted: () {
        effectiveController?.startDrag();
        onDragStarted?.call();
      },
      onDragUpdate: onDragUpdate,
      onDraggableCanceled: onDraggableCanceled,
      onDragEnd: (details) {
        effectiveController?.endDrag();
        onDragEnd?.call(details);
      },
      onDragCompleted: onDragCompleted,
      child: child,
    );
  }
}
