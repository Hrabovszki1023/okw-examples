---
source_hash: a9e5dec72185
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

!!! warning "SetContext only works with XPath"
    **Both** locators must be XPath:

    1. the **frame** around the repeating element (`__context__.locator`)
    2. all **elements inside the frame** (the child widgets) — as a
       relative XPath (`.//...`)

    Caution: a CSS locator for the frame currently does **not** raise an
    error — the context is ignored and the child widget is searched on
    the whole page. The test may then access the wrong instance. Why
    only XPath works is explained in [How It Works](#how-it-works).

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

## How It Works

### SetContext Is Like Dynamic SQL

Think of `SetContext` as **dynamic SQL**: the query is not written out
in the YAML, it is built **only at runtime** — from a template with a
placeholder, the value from the test, and the part for the element you
are looking for.

| Dynamic SQL | SetContext |
|---|---|
| Template with placeholder: `… WHERE name = '{name}'` | `__context__` locator with `{ProduktName}` |
| Which row? — insert the parameter at runtime | `SetContext ProduktKarte Sauce Labs Backpack` |
| Which column? — `SELECT price` | Child widget `Produktpreis` with a relative XPath |
| The database executes the finished query | The browser evaluates the finished XPath |

### Step by Step

**1. Template** — the frame from the YAML, with placeholder:

```
//div[@data-test="inventory-item"][.//div[text()="{ProduktName}"]]
```

**2. Insert the parameter** — `SetContext ProduktKarte Sauce Labs Backpack`
replaces `{ProduktName}`:

```
//div[@data-test="inventory-item"][.//div[text()="Sauce Labs Backpack"]]
```

**3. Chain** — on `VerifyValue Produktpreis` the relative XPath of the
child widget is appended:

```
(//div[@data-test="inventory-item"][.//div[text()="Sauce Labs Backpack"]])/.//div[@data-test="inventory-item-price"]
```

Only this composed expression is evaluated in the browser. It finds
**only** the price inside the Backpack card. The next `SetContext`
builds the query again with a different value.

### Why Only XPath?

XPath is the only locator strategy that can do **both** things
SetContext needs:

1. **Chaining** — two XPath expressions can be joined as text into
   **one** valid expression: frame + relative child path. `id` and
   `name` cannot be chained at all.
2. **Selection by text content** — the frame has to find the instance by
   its visible content: "the card that says *Sauce Labs Backpack*". CSS
   can chain descendants (`.card .price`), but it **cannot filter by
   text**.

## Rules

- `__context__` is a reserved key at widget-group level
- Placeholders use `{Name}` syntax and are replaced via `str.format()`
- Multiple placeholders are possible: `SetContext Tabelle Zeile=A Spalte=3`
- `SelectWindow` resets the context (new window = no context)
- Widgets **outside** the context group are not affected
- **XPath only:** the frame (`__context__.locator`) **and** all child
  locators must be XPath — see [Why Only XPath?](#why-only-xpath)
- Child locators use relative paths (`.//...`)

## When to Use SetContext?

| Situation | Solution |
|---|---|
| Single elements (login fields, buttons) | Normal widget in YAML |
| Repeating structures (cards, rows, lists) | `SetContext` |
| Tables with fixed columns | Table widget (if available) or `SetContext` |

For practice examples see
[Web Selenium → Repeating Structures](../gui/web-selenium/setcontext.md).
