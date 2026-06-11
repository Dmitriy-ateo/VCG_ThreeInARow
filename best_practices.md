# Flutter & Game Development Best Practices - Hexa Match

This document establishes the official rendering, state, and memory optimization guidelines for the project. All developers and AI assistants must follow these practices when modifying or extending this codebase.

---

## 1. Rendering & Canvas Optimizations

### Use `RepaintBoundary` to Isolate Animations
- **The Problem**: When a widget under a Canvas/CustomPainter animates (like a pulsing ball), it triggers a repaint of the entire canvas subtree.
- **The Solution**: Wrap independent animated items and static backgrounds in separate `RepaintBoundary` widgets. This forces Flutter to cache the static parts as separate raster layers, preventing unnecessary repaints.
- **Application**: The static grid cells must be isolated from the animating neon balls.

### Optimize Custom Painters (`shouldRepaint`)
- Never return `true` blindly in `shouldRepaint`.
- Validate specific properties that affect drawing (e.g. `oldDelegate.color != color`).
- Keep heavy calculations (like math layouts or path parsing) out of the `paint()` loop. Precompute and cache them.

### Minimize Path Re-creations
- Inside `CustomPainter.paint`, avoid instantiating new `Path` objects on every frame if the shape is constant. Cache the path or compute it only when the size changes.

---

## 2. Widget Rebuilds & State Decoupling

### Keep Rebuild Scopes Tight
- Use `ListenableBuilder` or `ValueListenableBuilder` at the lowest possible level in the widget tree.
- Avoid wrapping the entire `Scaffold` in a builder if only the score counter or a single cell changes. Rebuilding the entire screen causes layout passes for all static UI cards and buttons.

### Maximize Use of `const`
- Always use `const` constructors for static widgets (containers, cards, texts, icons). This tells Flutter the widget tree structure hasn't changed, bypassing the build phase entirely for those nodes during updates.

---

## 3. Grid Math & Layout Caching

### Precalculate Coordinate Conversions
- Do not perform expensive trigonometry or coordinate translations inside the rendering loop.
- Precalculate the center pixel offsets of all hex coordinates once when the `BoardShape` changes, rather than recalculating bounds and scale on every rebuild of `HexBoardWidget`.

---

## 4. Memory & Resource Hygiene

### Controller and Listener Disposal
- Always override `dispose()` on stateful widgets to terminate `AnimationController`s, `ScrollController`s, and custom text inputs.
- Unsubscribe custom listeners from `ChangeNotifier` objects if added manually to avoid reference leakage.

### Avoid Heavy Object Allocations in `build`
- Avoid creating new `Paint` objects, gradients, or math models inside `build()` or `paint()`. Declare them as static/final constants or reuse them.
