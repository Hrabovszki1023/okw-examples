# WebPark — Parking Cost Calculator

**Page:** https://practice.expandtesting.com/webpark

**Test file:** `tests/WebPark.robot`

## What This Example Demonstrates

- **Custom widget classes** that override `okw_set_value()` for a
  third-party JavaScript UI component (Flatpickr).
- The **widget override pattern**: project-specific widgets inherit from
  a standard OKW widget and change only the behavior that differs.
- Working with **ComboBox** (`Select`) and **date/time input fields**.
- **17 test cases** covering all 5 parking lot types with boundary values.

## Page Specifics

The page uses [Flatpickr](https://flatpickr.js.org/), a JavaScript
date/time picker library. Flatpickr takes over the native `<input>`
elements and adds a calendar/time overlay. This causes two problems:

1. **Focus shift:** Clicking a Flatpickr field opens the overlay and
   moves focus away from the input element.
2. **Click before keys:** SeleniumLibrary's `Press Keys` always clicks
   the element before sending keys (via `ActionChains.click`). This
   deselects any marked text.

Standard `SetValue` (clear + input\_text) does not work with Flatpickr
fields.

## Implementation

### Project-Specific Widgets

Two widget classes in `widgets/` override `okw_set_value()`:

| Widget | File | Purpose |
|---|---|---|
| `WebPark_DateField` | `widgets/webpark_datefield.py` | Date input (YYYY-MM-DD) |
| `WebPark_TimeField` | `widgets/webpark_timefield.py` | Time input (HH:MM) |

Both inherit from `WebSe_TextField` and use the same key sequence:

```
1. Focus    — Set focus via JavaScript (no click, avoids Flatpickr overlay stealing focus)
2. CTRL+a   — Select all text (with locator — SeleniumLibrary clicks first, setting focus)
3. Value    — Type new value WITHOUT locator (None) — no click, selection is preserved
4. ESCAPE   — Close the picker overlay WITHOUT locator (None)
```

The critical insight: after `CTRL+a` selects all text, subsequent
`press_keys` calls must use `None` as locator. Otherwise SeleniumLibrary
clicks the element again and deselects the text.

### YAML Locators

```yaml
# Standard OKW widgets
Parkplatz:
  class: okw_web_selenium.widgets.webse_combobox.WebSe_ComboBox
  locator: { id: parkingLot }

# Project-specific Flatpickr widgets
EingangDatum:
  class: widgets.webpark_datefield.WebPark_DateField
  locator: { id: entryDate }
```

The `class:` key references `widgets.webpark_datefield` — a project-local
Python package. The OKW YAML loader automatically adds the project
directory to `sys.path`, so no `--pythonpath` is needed.

### Automatic sys.path

When the YAML loader finds a locator file (e.g., `locators/WebParkPage.yaml`),
it adds the parent directory (`expandtesting/`) to `sys.path`. This allows
`import widgets.webpark_datefield` to resolve automatically.

## Test Cases

All 5 parking lot types are covered with boundary and multi-day scenarios:

| Parking Lot | Tests | Rates |
|---|---|---|
| Valet Parking | 4 | $12 (up to 5h), $18/day |
| Short-Term Parking | 4 | $2 first hour, +$1/30min, max $24/day |
| Long-Term Garage | 3 | $2/hour, max $12/day, 7th day free |
| Long-Term Surface | 3 | $2/hour, max $10/day, 7th day free |
| Economy Parking | 3 | $2/hour, max $9/day, 7th day free |

## Reuse Pattern

This example shows how to integrate **any** JavaScript UI component
library (Select2, React-Datepicker, Material UI, etc.) into OKW:

1. Create a widget class inheriting from the closest standard widget.
2. Override only the method that needs different behavior (`okw_set_value`).
3. Place the widget in a `widgets/` package next to `locators/`.
4. Reference the class in YAML via the `class:` key.
