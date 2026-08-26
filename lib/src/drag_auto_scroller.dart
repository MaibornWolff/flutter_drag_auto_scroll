import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'drag_auto_scroll_controller.dart';
import 'drag_auto_scroll_scope.dart';

/// Wraps a scrollable child and auto-scrolls when an [AutoScrollDraggable]
/// drag pointer enters the top or bottom edge zones.
///
/// Only scrolls when the associated [DragAutoScrollController] signals an
/// active drag. Regular pointer interactions (press, scroll, hover) are
/// ignored.
///
/// **Same widget tree** — no explicit controller needed:
/// ```dart
/// DragAutoScroller(
///   scrollController: _myController,
///   child: ListView.builder(
///     controller: _myController,
///     itemBuilder: (_, i) => AutoScrollDraggable<int>(
///       data: i,
///       feedback: Material(child: Text('$i')),
///       child: ListTile(title: Text('Item $i')),
///     ),
///   ),
/// )
/// ```
///
/// **Cross widget tree** — provide a shared controller:
/// ```dart
/// final dragController = DragAutoScrollController();
///
/// // Scroll target
/// DragAutoScroller(
///   controller: dragController,
///   scrollController: sc,
///   child: myScrollableList,
/// )
///
/// // Drag source (different subtree)
/// AutoScrollDraggable(
///   controller: dragController,
///   data: myData,
///   feedback: myFeedback,
///   child: myDraggableItem,
/// )
/// ```
class DragAutoScroller extends StatefulWidget {
  /// Creates a drag auto-scroller.
  ///
  /// [scrollController] must be attached to the scrollable child widget.
  ///
  /// If [controller] is null, an internal one is created and provided to
  /// descendants via [DragAutoScrollScope].
  const DragAutoScroller({
    super.key,
    required this.scrollController,
    this.controller,
    this.edgeThreshold = 80.0,
    this.maxScrollSpeed = 20.0,
    this.showEdgeZones = false,
    this.edgeZoneColor,
    required this.child,
  });

  /// The scroll controller of the scrollable child.
  final ScrollController scrollController;

  /// Optional drag controller. If null, an internal one is created and
  /// provided to descendants via [DragAutoScrollScope].
  final DragAutoScrollController? controller;

  /// Distance in logical pixels from the top/bottom edge where auto-scroll
  /// activates. Defaults to 80.
  final double edgeThreshold;

  /// Maximum scroll speed in logical pixels per frame at the very edge.
  /// Speed scales linearly from 0 at the threshold boundary to this value
  /// at the widget edge. Defaults to 20.
  final double maxScrollSpeed;

  /// When true, renders gradient overlays on the edge zones while a drag
  /// is active. Uses [edgeZoneColor] or `Theme.of(context).colorScheme.primary`.
  final bool showEdgeZones;

  /// Color for the edge zone overlays. Defaults to the theme's primary color.
  /// Only used when [showEdgeZones] is true.
  final Color? edgeZoneColor;

  /// The scrollable child widget.
  final Widget child;

  @override
  State<DragAutoScroller> createState() => _DragAutoScrollerState();
}

class _DragAutoScrollerState extends State<DragAutoScroller>
    with TickerProviderStateMixin {
  DragAutoScrollController? _internalController;
  Ticker? _ticker;
  double _scrollSpeed = 0;
  bool _pointerInside = false;
  bool _globalRouteRegistered = false;

  /// Set on pointer-up/exit; cleared on next [startDrag]. Prevents stale
  /// hover events from reactivating scrolling between drag end and the
  /// controller's [endDrag] call.
  bool _dismissed = false;

  DragAutoScrollController get _controller =>
      widget.controller ?? (_internalController ??= DragAutoScrollController());

  bool get _canScrollUp {
    final sc = widget.scrollController;
    return sc.hasClients && sc.position.pixels > sc.position.minScrollExtent;
  }

  bool get _canScrollDown {
    final sc = widget.scrollController;
    return sc.hasClients && sc.position.pixels < sc.position.maxScrollExtent;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDragStateChanged);
  }

  @override
  void didUpdateWidget(DragAutoScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _internalController;
    final newController = _controller;
    if (oldController != newController) {
      oldController?.removeListener(_onDragStateChanged);
      newController.addListener(_onDragStateChanged);
      if (!newController.isDragging) {
        _stopScrolling();
      }
    }
  }

  void _addGlobalRoute() {
    if (!_globalRouteRegistered) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_globalPointerRoute);
      _globalRouteRegistered = true;
    }
  }

  void _removeGlobalRoute() {
    if (_globalRouteRegistered) {
      GestureBinding.instance.pointerRouter
          .removeGlobalRoute(_globalPointerRoute);
      _globalRouteRegistered = false;
    }
  }

  void _onDragStateChanged() {
    if (_controller.isDragging) {
      _dismissed = false;
      _addGlobalRoute();
    } else {
      _removeGlobalRoute();
      _stopScrolling();
      _pointerInside = false;
      _dismissed = true;
    }
    if (widget.showEdgeZones) {
      setState(() {});
    }
  }

  void _globalPointerRoute(PointerEvent event) {
    if (event is PointerMoveEvent || event is PointerHoverEvent) {
      _handlePointerEvent(event.position);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _dismissed = true;
      _onPointerLeft();
    }
  }

  void _handlePointerEvent(Offset globalPosition) {
    if (!_controller.isDragging || _dismissed) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPosition);
    final size = box.size;
    final inside = local.dx >= 0 &&
        local.dx <= size.width &&
        local.dy >= 0 &&
        local.dy <= size.height;

    if (!inside) {
      if (_pointerInside) _onPointerLeft();
      return;
    }

    if (!_pointerInside) {
      _pointerInside = true;
    }
    if (widget.showEdgeZones) setState(() {});

    if (local.dy < widget.edgeThreshold) {
      final proximity = 1.0 - (local.dy / widget.edgeThreshold);
      _scrollSpeed = -widget.maxScrollSpeed * proximity.clamp(0.0, 1.0);
      _startScrolling();
    } else if (local.dy > size.height - widget.edgeThreshold) {
      final proximity = 1.0 - ((size.height - local.dy) / widget.edgeThreshold);
      _scrollSpeed = widget.maxScrollSpeed * proximity.clamp(0.0, 1.0);
      _startScrolling();
    } else {
      _stopScrolling();
    }
  }

  void _startScrolling() {
    if (_ticker != null && _ticker!.isActive) return;
    _ticker = createTicker(_onTick)..start();
  }

  void _stopScrolling() {
    _scrollSpeed = 0;
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _onPointerLeft() {
    _stopScrolling();
    if (_pointerInside) {
      _pointerInside = false;
      if (widget.showEdgeZones) setState(() {});
    }
  }

  void _onTick(Duration elapsed) {
    if (_scrollSpeed == 0) return;

    final controller = widget.scrollController;
    if (!controller.hasClients) return;

    final position = controller.position;
    final newOffset = (position.pixels + _scrollSpeed).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    controller.jumpTo(newOffset);
  }

  @override
  void dispose() {
    _removeGlobalRoute();
    _controller.removeListener(_onDragStateChanged);
    _stopScrolling();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    Widget result;
    if (widget.showEdgeZones) {
      final showOverlays = _controller.isDragging && _pointerInside;
      final canScrollUp = showOverlays && _canScrollUp;
      final canScrollDown = showOverlays && _canScrollDown;
      final color =
          widget.edgeZoneColor ?? Theme.of(context).colorScheme.primary;
      result = Stack(
        children: [
          child,
          if (canScrollUp)
            _EdgeZoneOverlay(
              edge: _Edge.top,
              height: widget.edgeThreshold,
              color: color,
            ),
          if (canScrollDown)
            _EdgeZoneOverlay(
              edge: _Edge.bottom,
              height: widget.edgeThreshold,
              color: color,
            ),
        ],
      );
    } else {
      result = child;
    }

    if (widget.controller == null) {
      return DragAutoScrollScope(controller: _controller, child: result);
    }
    return result;
  }
}

enum _Edge { top, bottom }

class _EdgeZoneOverlay extends StatelessWidget {
  const _EdgeZoneOverlay({
    required this.edge,
    required this.height,
    required this.color,
  });

  final _Edge edge;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTop = edge == _Edge.top;
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
