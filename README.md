# flutter_drag_auto_scroll

[![pub package](https://img.shields.io/pub/v/flutter_drag_auto_scroll.svg)](https://pub.dev/packages/flutter_drag_auto_scroll)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Auto-scroll any vertically scrollable widget when a `Draggable` enters its
top or bottom edge zones.

Works on all platforms. Zero dependencies beyond Flutter.

> **Note:** Only vertical scrolling is supported. Horizontal scrollables are
> not yet handled — contributions welcome.

## Features

- **Drop-in usage** -- replace `Draggable` with `AutoScrollDraggable` and wrap
  your scrollable with `DragAutoScroller`. That's it.
- **Same-tree mode** -- when drag source and scroll target share a widget tree,
  the controller is provided automatically via `InheritedWidget`.
- **Cross-tree mode** -- share a `DragAutoScrollController` between separate
  subtrees (e.g. a side panel and a main list).
- **Edge zone overlays** -- optional themed gradient indicators showing the
  scroll trigger zones during drag.
- **Proportional speed** -- scroll speed scales linearly from 0 at the threshold
  boundary to `maxScrollSpeed` at the widget edge.

## Getting started

```yaml
dependencies:
  flutter_drag_auto_scroll: ^0.1.0
```

## Usage

### Same widget tree (simplest)

![same-tree reorder](https://github.com/MaibornWolff/flutter_drag_auto_scroll/releases/download/v0.1.0/playlist_demo.gif)

No explicit controller needed. `DragAutoScroller` creates one internally and
provides it to descendants via `DragAutoScrollScope`.

```dart
DragAutoScroller(
  scrollController: _scrollController,
  showEdgeZones: true,
  child: ListView.builder(
    controller: _scrollController,
    itemBuilder: (context, i) => AutoScrollDraggable<int>(
      data: i,
      feedback: Material(child: Text('Item $i')),
      child: ListTile(title: Text('Item $i')),
    ),
  ),
)
```

### Cross widget tree

![cross-tree reorder](https://github.com/MaibornWolff/flutter_drag_auto_scroll/releases/download/v0.1.0/sprint_demo.gif)

When the drag source and scroll target live in different subtrees, create a
shared `DragAutoScrollController`:

```dart
final controller = DragAutoScrollController();

// Left panel -- the scroll target
DragAutoScroller(
  controller: controller,
  scrollController: _listScrollController,
  child: myListView,
)

// Right panel -- the drag source
AutoScrollDraggable<MyData>(
  controller: controller,
  data: myData,
  feedback: myFeedback,
  child: myDraggableItem,
)
```

### Configuration

| Parameter | Default | Description |
|---|---|---|
| `edgeThreshold` | `80.0` | Pixels from edge where scrolling activates |
| `maxScrollSpeed` | `20.0` | Max pixels per frame at the very edge |
| `showEdgeZones` | `false` | Show gradient overlays during drag |
| `edgeZoneColor` | theme primary | Color for edge zone overlays |

### Manual integration

If you can't use `AutoScrollDraggable`, call the controller directly:

```dart
Draggable<int>(
  data: 1,
  feedback: myFeedback,
  onDragStarted: () => controller.startDrag(),
  onDragEnd: (_) => controller.endDrag(),
  child: myChild,
)
```

## How it works

1. `AutoScrollDraggable` calls `controller.startDrag()` when a drag begins.
2. `DragAutoScroller` listens to the controller. While `isDragging` is true,
   it processes pointer/hover events to detect the cursor position.
3. When the pointer enters an edge zone, a `Ticker` drives frame-by-frame
   `jumpTo()` calls on the scroll controller, with speed proportional to
   proximity to the edge.
4. `AutoScrollDraggable` calls `controller.endDrag()` when the drag ends,
   which stops scrolling immediately.

Regular pointer interactions (press-and-hold, scrolling, mouse hover) are
ignored because the controller is only active during `AutoScrollDraggable` drags.

## Example

The [example app](example/) demonstrates both modes: a same-tree list where
items are reordered by dragging, and a cross-tree layout where items are
dragged from a side panel into a scrolling list. Run it with:

```bash
cd example && flutter run
```

## License

MIT -- see [LICENSE](LICENSE).
