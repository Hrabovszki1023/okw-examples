# SauceDemo SetContext — Repeating GUI Structures

**Page:** https://www.saucedemo.com (Products page after login)

**Test file:** `tests/SauceDemo_SetContext.robot`

## What This Example Demonstrates

- **SetContext** for scoping widgets to repeating GUI structures.
- One YAML definition handles **all product cards** — no separate
  entry per product.
- **ClickOn** within a context (same button locator, different cards).
- **OnFailNOISE** for the complete preparation phase (login + navigation).

## Page Specifics

The SauceDemo products page displays 6 product cards in a grid. Each
card has the same structure:

- Product name
- Product description
- Product price
- "Add to cart" button

The challenge: all cards share the same HTML structure and CSS classes.
Without context, a locator like `.inventory_item_price` matches all 6
prices. The test needs to read the price of a **specific** product.

## Implementation

### SetContext with Placeholders

The YAML defines a `ProduktKarte` context group with a `{ProduktName}`
placeholder:

```yaml
ProduktKarte:
  __context__:
    locator: { xpath: '//div[@data-test="inventory-item"]
      [.//div[@data-test="inventory-item-name"
      and text()="{ProduktName}"]]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button[contains(@data-test,"add-to-cart")]' }
```

In the test, `SetContext` replaces the placeholder and scopes all
subsequent widget operations:

```robot
SetContext         ProduktKarte    Sauce Labs Backpack
VerifyValue        Produktpreis    $29.99
```

### How Context Resolution Works

1. `SetContext ProduktKarte Sauce Labs Backpack` stores
   `{ProduktName}` = `Sauce Labs Backpack`.
2. When accessing `Produktpreis`, the runtime:
   - Replaces `{ProduktName}` in the context XPath.
   - Prepends the resolved context XPath to the child's relative locator.
3. Child locators use relative paths (`.//...`) — scoped to the
   context element.

### Reusable Test Keywords

```robot
Produktpreis Pruefen
    [Arguments]    ${produkt}    ${erwarteter_preis}
    SetContext         ProduktKarte    ${produkt}
    VerifyValue        Produktpreis    ${erwarteter_preis}
```

This keeps test cases concise and readable:

```robot
Produktpreis Pruefen    Sauce Labs Backpack      $29.99
Produktpreis Pruefen    Sauce Labs Bike Light    $9.99
```

## Test Cases

| Test | Verifies |
|---|---|
| SetContext Produktpreise Pruefen | Prices of 5 products via SetContext |
| SetContext Produkt In Warenkorb | Adding 2 products to cart via SetContext |
