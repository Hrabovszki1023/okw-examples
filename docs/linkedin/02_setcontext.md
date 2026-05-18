# Selenium Automation That Reads Like a Spec — Part 2: Repeating Structures

**Series: Selenium Test Automation with OKW4Robot**

---

Every e-commerce site has product cards. Every dashboard has data rows. Every inbox has message items. They all share the same problem: **N identical structures, each with different data.**

The Page Object approach? Write a method that takes an index. Or create a list of elements and loop through them. Or build a factory. It gets messy fast.

What if you could just say: "I'm talking about the Backpack card now"?

## The Test

```robot
SetContext Produktpreise Pruefen
    SelectWindow   SauceDemoProducts
    VerifyValue    Titel    Products

    SetContext         ProduktKarte    Sauce Labs Backpack
    VerifyValue        Produktpreis    $29.99

    SetContext         ProduktKarte    Sauce Labs Bike Light
    VerifyValue        Produktpreis    $9.99

    SetContext         ProduktKarte    Sauce Labs Fleece Jacket
    VerifyValue        Produktpreis    $49.99
```

Same keyword (`VerifyValue Produktpreis`), different product each time. No loops. No indices. No separate page objects per card.

## One YAML, All Cards

```yaml
ProduktKarte:
  __context__:
    locator:
      xpath: >-
        //div[@data-test="inventory-item"]
        [.//div[@data-test="inventory-item-name"
        and text()="{ProduktName}"]]
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

The `__context__` block defines a container with a **placeholder**. When you call `SetContext ProduktKarte Sauce Labs Backpack`, OKW replaces `{ProduktName}` with "Sauce Labs Backpack" — and every child widget is now scoped to that specific card.

## How It Works

```
SetContext    ProduktKarte    Sauce Labs Backpack
                  │                    │
                  ▼                    ▼
          context group        placeholder value
```

1. OKW finds `ProduktKarte.__context__.locator`
2. Replaces `{ProduktName}` → "Sauce Labs Backpack"
3. Stores the resolved XPath as the active context
4. When you access `Produktpreis`, OKW **prepends** the context XPath to the child's relative locator (`.//div[...]`)
5. Result: one absolute XPath that finds the price inside the Backpack card

Child locators use **relative paths** (`.//`) — they're scoped to their context element. No ambiguity. No index math.

## Actions Work Too

```robot
SetContext     ProduktKarte    Sauce Labs Backpack
ClickOn        InDenWarenkorb

SetContext     ProduktKarte    Sauce Labs Bike Light
ClickOn        InDenWarenkorb
```

Same button name, different card. Two products in the cart. Zero duplication.

## Why Not Just Use XPath With the Product Name?

You could write:

```robot
Click Element    xpath://div[contains(.,'Backpack')]//button[contains(@data-test,'add-to-cart')]
```

But then:
- Every test hardcodes the full XPath
- Widget type information is lost (no sync, no screenshots, no retry)
- When the DOM structure changes, you fix it in every test file
- You can't reuse the same locator pattern for a different page

With `SetContext`, the pattern is defined **once** in YAML. The test says **what it means** — not how to find it.

## Try It Yourself

The full example runs against [saucedemo.com](https://www.saucedemo.com).

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*Next in this series: Shadow DOM and iFrames — how OKW handles isolation boundaries without the tester even noticing.*

#Selenium #TestAutomation #RobotFramework #QualityAssurance #SoftwareTesting
