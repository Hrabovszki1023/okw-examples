# DragDropCircles — Drag & Drop Keywords (Circle Move)

**Page:** https://practice.expandtesting.com/drag-and-drop-circles

**Test file:** `tests/DragDropCircles.robot`

## What This Example Demonstrates

- **DragTo** — drag individual elements into a drop zone.
- **DragStart** + **Drop** — same result with the multi-step API.
- **VerifyExists** — confirm that elements moved out of their
  original container (DOM relocation via `appendChild`).
- CSS-class-based locators (elements without IDs).

## Page Specifics

The page provides three colored circles that can be dragged into
a target area:

| Element | Selector | Color | Attribute |
|---|---|---|---|
| Red circle | `#source .red` | Red | `draggable="true"` |
| Green circle | `#source .green` | Green | `draggable="true"` |
| Blue circle | `#source .blue` | Blue | `draggable="true"` |
| Target area | `#target` | Silver | `dropzone="true"` |

Unlike the column-swap example, this page **moves** the dropped
element into the target container (`appendChild`). The circle
is physically relocated in the DOM — it no longer exists under
`#source` after the drop.

## Implementation

### DragTo — One-Step Drag

Each circle is dragged individually into the target area:

```robot
Roten Kreis In Zielbereich Ziehen
    DragTo         RoterKreis    Zielbereich
    VerifyExists    RoterKreis    NO
```

After the drop, `VerifyExists` with `NO` confirms the circle is no
longer in its original `#source` container (the CSS locator
`#source .red` no longer matches).

### CSS-Class Locators

The circles have no IDs — they are identified by combining the
container ID with the color class:

```yaml
RoterKreis:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '#source .red' }
```

### All Circles at Once

Multiple `DragTo` calls in sequence — each is independent:

```robot
Alle Kreise In Zielbereich Ziehen
    DragTo    RoterKreis      Zielbereich
    DragTo    GruenerKreis    Zielbereich
    DragTo    BlauerKreis     Zielbereich
```

## Test Cases

| Test | Keywords | Verification |
|---|---|---|
| Roten Kreis In Zielbereich Ziehen | `DragTo` | Red circle gone from source |
| Gruenen Kreis In Zielbereich Ziehen | `DragTo` | Green circle gone from source |
| Blauen Kreis In Zielbereich Ziehen | `DragTo` | Blue circle gone from source |
| Roten Kreis Mit DragStart Und Drop Ziehen | `DragStart` + `Drop` | Red circle gone from source |
| Alle Kreise In Zielbereich Ziehen | 3x `DragTo` | All circles gone from source |
