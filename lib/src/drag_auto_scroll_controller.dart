import 'package:flutter/foundation.dart';

/// Signals whether a drag is currently active.
///
/// Used by [DragAutoScroller] to activate auto-scrolling only during
/// [AutoScrollDraggable] drags. Can be shared across widget trees to connect
/// drag sources in one subtree with scroll targets in another.
///
/// ```dart
/// final controller = DragAutoScrollController();
///
/// // In one subtree — the scroll target
/// DragAutoScroller(controller: controller, ...)
///
/// // In another subtree — the drag source
/// AutoScrollDraggable(controller: controller, ...)
/// ```
///
/// Call [dispose] when the controller is no longer needed.
class DragAutoScrollController extends ChangeNotifier {
  bool _isDragging = false;

  /// Whether a drag is currently active.
  bool get isDragging => _isDragging;

  /// Signal that a drag has started.
  ///
  /// Called automatically by [AutoScrollDraggable]. Can also be called
  /// manually when using a standard [Draggable] with custom integration.
  void startDrag() {
    if (_isDragging) return;
    _isDragging = true;
    notifyListeners();
  }

  /// Signal that a drag has ended.
  ///
  /// Called automatically by [AutoScrollDraggable]. Can also be called
  /// manually when using a standard [Draggable] with custom integration.
  void endDrag() {
    if (!_isDragging) return;
    _isDragging = false;
    notifyListeners();
  }
}
