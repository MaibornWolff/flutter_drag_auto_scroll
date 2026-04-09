# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter package that auto-scrolls any scrollable widget when a `Draggable` enters its edge zones. Supports same-tree (InheritedWidget) and cross-tree (shared controller) usage.

## Commands

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/flutter_drag_auto_scroll_test.dart

# Analyze
flutter analyze

# Format
dart format .

# Run example app
cd example && flutter run
```

## Architecture

Four public classes, all exported from `lib/flutter_drag_auto_scroll.dart`:

- **`DragAutoScrollController`** (`ChangeNotifier`) — signals drag active/inactive state. Shared between drag sources and scroll targets.
- **`DragAutoScrollScope`** (`InheritedWidget`) — provides a controller to descendants. Created automatically by `DragAutoScroller` when no explicit controller is given.
- **`DragAutoScroller`** (`StatefulWidget`) — wraps a scrollable child. Uses a `Ticker` to drive per-frame `jumpTo` scrolling when the pointer enters configurable edge zones. Listens to the controller for drag state.
- **`AutoScrollDraggable<T>`** — drop-in `Draggable` replacement that calls `startDrag`/`endDrag` on the controller. Resolves its controller via explicit parameter or `DragAutoScrollScope.maybeOf`.

**Data flow:** `AutoScrollDraggable` signals drag start/end → `DragAutoScrollController` notifies → `DragAutoScroller` activates edge-zone detection via `Listener`/`MouseRegion` → ticker-driven scrolling.

## Lint Rules

Uses `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`).
