# DragDrop — Drag & Drop Keywords (Column Swap)

**Page:** https://practice.expandtesting.com/drag-and-drop

**Test file:** `tests/DragDrop.robot`

## What This Example Demonstrates

- **DragStart** + **Drop** — multi-step drag & drop sequence.
- **DragTo** — shortcut for direct source-to-target drag.
- **VerifyValue** — confirm that column content swapped correctly.
- HTML5 `draggable="true"` elements with JS-based event simulation.
- The collect-then-execute pattern: `DragStart`/`DragOver` only
  collect elements, `Drop` executes the entire sequence atomically.

## Page Specifics

The page provides two draggable columns that swap their content
on drop:

| Element | ID | Content | Attribute |
|---|---|---|---|
| Column A | `column-a` | Header "A" | `draggable="true"` |
| Column B | `column-b` | Header "B" | `draggable="true"` |

The page uses pure HTML5 Drag & Drop API (no external libraries).
On drop, the `innerHTML` of source and target is swapped via
JavaScript event handlers (`dragstart`, `dragover`, `drop`, `dragend`).

## Implementation

### DragTo — Simple Case

Most drag & drop scenarios are a direct source-to-target move.
`DragTo` handles this in one keyword:

```robot
DragTo Spalte A Nach B
    DragTo         SpalteA    SpalteB
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A
```

### DragStart + Drop — Multi-Step

For scenarios with intermediate targets (e.g., expanding tree nodes),
use the multi-step sequence:

```robot
Spalte A Nach B Ziehen
    DragStart      SpalteA
    Drop           SpalteB
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A
```

### Collect → Execute Pattern

`DragStart` and `DragOver` are preparatory — they only collect
element references. No drag events are fired until `Drop` executes
the entire sequence atomically:

1. `DragStart` → stores source element in adapter
2. `DragOver` → appends intermediate to list (repeatable)
3. `Drop` → fires `dragstart` → `[dragover]*` → `drop` → `dragend`

### HTML5 Drag Event Simulation

Selenium ActionChains do not trigger HTML5 drag events. OKW uses
JavaScript-based event simulation with synthetic `DragEvent` and
`DataTransfer` objects. This works universally for all HTML5
`draggable` elements.

## Test Cases

| Test | Keywords | Verification |
|---|---|---|
| Spalte A Nach B Ziehen | `DragStart` + `Drop` | A↔B swapped |
| Spalte B Nach A Ziehen | `DragStart` + `Drop` | B↔A swapped |
| Doppelter Tausch Bringt Ausgangszustand | 2x `DragStart` + `Drop` | Back to A, B |
| DragTo Spalte A Nach B | `DragTo` | A↔B swapped |
| DragTo Doppelter Tausch | 2x `DragTo` | Back to A, B |
