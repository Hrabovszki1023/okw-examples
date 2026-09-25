---
source_hash: c2a04b6e9736
---

# SetContext — Repeating Structures

## The Problem

Many applications have repeating GUI structures: product cards in a web
shop, rows in a table, items in a list. Each instance has the same
elements (name, price, button), but with different values.

Without `SetContext` you would have to define every instance separately
in YAML — that does not scale.

## The Solution: SetContext

`SetContext` scopes subsequent widget operations to one specific instance
of a repeating structure.

### YAML Definition

```yaml
ProduktKarte:
  __context__:
    locator:
      xpath: '//div[@data-test="inventory-item"][.//div[text()="{ProduktName}"]]'
  Produktname:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-name"]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button[contains(@data-test,"add-to-cart")]' }
```

**Key elements:**

- `__context__` — reserved key holding the locator of the repeating structure
- `{ProduktName}` — placeholder that is replaced by `SetContext`
- `.//...` — relative XPaths that refer to the context

### Test

```robot
*** Test Cases ***
Produkt in den Warenkorb legen
    OKW.SelectWindow   Products
    OKW.SetContext     ProduktKarte    Sauce Labs Backpack
    OKW.VerifyValue    Produktpreis    $29.99
    OKW.ClickOn        InDenWarenkorb

    OKW.SetContext     ProduktKarte    Sauce Labs Bike Light
    OKW.VerifyValue    Produktpreis    $9.99
    OKW.ClickOn        InDenWarenkorb
```

### What Happens Internally?

1. `SetContext ProduktKarte Sauce Labs Backpack` sets `{ProduktName}` = `Sauce Labs Backpack`
2. On `VerifyValue Produktpreis`:
    - `{ProduktName}` is replaced in the `__context__` locator
    - The resolved context XPath is prepended to the relative child locator
3. The result: only the price element inside the right product card is read

## Rules

- `__context__` is a reserved key at widget-group level
- Placeholders use `{Name}` syntax and are replaced via `str.format()`
- Multiple placeholders are possible: `SetContext Tabelle Zeile=A Spalte=3`
- `SelectWindow` resets the context (new window = no context)
- Widgets **outside** the context group are not affected
- Context locators must use **XPath** (no CSS — no text selection, no
  relative path composition possible)
- Child locators use relative paths (`.//...`)

## When to Use SetContext?

| Situation | Solution |
|---|---|
| Single elements (login fields, buttons) | Normal widget in YAML |
| Repeating structures (cards, rows, lists) | `SetContext` |
| Tables with fixed columns | Table widget (if available) or `SetContext` |

For practice examples see
[Web Selenium → Repeating Structures](../gui/web-selenium/setcontext.md).
