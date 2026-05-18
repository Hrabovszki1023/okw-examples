# Selenium Automation That Reads Like a Spec — Part 4: Drag & Drop

**Series: Selenium Test Automation with OKW4Robot**

---

Try dragging an HTML5 `draggable="true"` element with Selenium's ActionChains:

```python
ActionChains(driver).drag_and_drop(source, target).perform()
```

Nothing happens. The elements don't move. No error — it just silently fails.

This is a well-known Selenium limitation. ActionChains fires mouse events, but HTML5 drag & drop requires `DragEvent` with a `DataTransfer` object. Selenium doesn't create those. The browser never triggers `dragstart`, `drop`, or `dragend`.

## The OKW Solution

Simple case — drag A to B:

```robot
Spalte A Nach B Ziehen
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B
    DragTo         SpalteA    SpalteB
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A
```

One keyword. Source and target. Done.

For complex sequences with intermediate targets:

```robot
DragStart      RoterKreis
DragOver       Zwischenziel
Drop           Zielbereich
```

`DragStart` and `DragOver` are **preparatory** — they only collect element references. `Drop` fires the entire event sequence **atomically** in a single JavaScript call.

## Under the Hood

OKW simulates the complete HTML5 drag event sequence via `execute_script`:

```
dragstart(source)
  → dragenter(intermediate) → dragover(intermediate) → dragleave(intermediate)
  → dragenter(target) → dragover(target) → drop(target)
→ dragend(source)
```

This fires real `DragEvent` objects with a real `DataTransfer` — exactly what the browser expects. Both tested patterns work:

- **Column swap** (innerHTML swap via JS event handlers)
- **Circle move** (DOM relocation via `appendChild`)

## The YAML

```yaml
SpalteA:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { id: column-a }

SpalteB:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { id: column-b }
```

Standard widgets. No special drag classes. OKW adds drag capability to every widget through the base class.

## Collect-Then-Execute

The three-step pattern (`DragStart` → `DragOver` → `Drop`) follows a collect-then-execute design:

| Keyword | What it does | Events fired |
|---|---|---|
| `DragStart` | Stores source element reference | None |
| `DragOver` | Appends to intermediate list (repeatable) | None |
| `Drop` | Fires entire sequence atomically via JS | All |

Why atomic? Because the browser expects `dragstart` through `dragend` as one coherent sequence. Firing events one-by-one across separate JavaScript calls can break the `DataTransfer` state.

`DragTo` is the shortcut for the common case — no intermediates, just source to target.

## Try It Yourself

Both examples run against [practice.expandtesting.com](https://practice.expandtesting.com):
- `/drag-and-drop` — column swap
- `/drag-and-drop-circles` — circle relocation

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*Next in this series: Dynamic tables — when rows and columns shuffle on every page load.*

#Selenium #TestAutomation #RobotFramework #DragAndDrop #HTML5 #QualityAssurance
