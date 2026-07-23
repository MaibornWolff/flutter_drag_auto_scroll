# flutter_drag_auto_scroll example

Demo app for the [`flutter_drag_auto_scroll`](../) package, showcasing
auto-scrolling scrollables during drag & drop in three scenarios.

## Running

```bash
flutter run
```

The app works best on desktop or web, where lists are long enough to scroll
and drags can comfortably reach the edge zones.

## Demos

Use the navigation rail on the left to switch between demos. The theme toggle
at the bottom of the rail switches between light and dark mode.

### Playlist (same tree)

A music playlist whose songs can be reordered by dragging. The
`DragAutoScroller` wraps the list and creates its controller internally,
providing it to the `AutoScrollDraggable` rows via `DragAutoScrollScope` — no
explicit wiring needed. Drag a song toward the top or bottom edge of the list
to see the auto-scroll kick in.

### Sprint (cross tree)

A task board where team members are dragged from a sidebar onto tasks in the
backlog to assign them. The sidebar (drag source) and the task list (scroll
target) live in separate widget subtrees, so they share an explicit
`DragAutoScrollController`.

### Playground

Tweakable versions of both setups with live controls:

- **Edge threshold** — how close to the edge the pointer must be before
  scrolling starts
- **Max scroll speed** — the per-frame scroll speed at the very edge
- **Show edge zones** — toggles the debug overlay that visualizes the edge
  zones
