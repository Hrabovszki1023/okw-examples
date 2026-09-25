---
source_hash: ee37a03431b6
---

# Reference

## Widget Classes

Each widget class encapsulates one family of HTML elements. The
interaction including synchronisation is implemented **once** in the
class and applies to every GUI object of that type.

| Widget class | HTML elements | Typical keywords |
|---|---|---|
| `WebSe_TextField` | `<input>` | SetValue, VerifyValue, TypeKey, Delete |
| `WebSe_MultilineField` | `<textarea>` | SetValue, VerifyValue, TypeKey, Delete |
| `WebSe_Button` | `<button>`, `<input type=button>` | ClickOn, VerifyCaption |
| `WebSe_CheckBox` | `<input type=checkbox>` | ClickOn, SetValue, VerifyValue |
| `WebSe_ComboBox` | `<select>`, custom dropdowns | Select, VerifyValue |
| `WebSe_ListBox` | `<select multiple>`, `<ul>` | Select, VerifyValue |
| `WebSe_RadioList` | `<input type=radio>` | Select, VerifyValue |
| `WebSe_Label` | `<span>`, `<div>`, `<p>`, `<label>` | VerifyValue, VerifyCaption |
| `WebSe_Link` | `<a>` | ClickOn, VerifyCaption |
| `WebSe_Table` | `<table>` | see [Tables](tabellen.md) |

The widget class is set in the YAML field `class`. It never appears in
test code — the test speaks business language only.

All widgets additionally support `MoveOver` ([Hover](hover.md)) and drag
& drop ([Drag & Drop](drag-and-drop.md)) via the base class `WebSe_Base`.

## Locator Strategies

The `locator` field in YAML supports all Selenium strategies:

| Strategy | Example | When to use |
|---|---|---|
| `css` | `{ css: '[data-test="username"]' }` | Default for most elements |
| `xpath` | `{ xpath: '//div[@class="price"]' }` | Text matching, complex hierarchies, SetContext |
| `id` | `{ id: user-name }` | When the element has a stable ID |
| `name` | `{ name: password }` | HTML `name` attribute |

**Recommendation:** CSS for simple elements, XPath when text matching or
SetContext is needed.

Additional YAML keys for isolation boundaries:

| Key | Purpose | Page |
|---|---|---|
| `shadow_host` | Element lives inside a Shadow DOM (CSS only) | [Shadow DOM and iFrames](shadow-dom-iframe.md) |
| `iframe` | Element lives inside an iFrame | [Shadow DOM and iFrames](shadow-dom-iframe.md) |
| `__context__` | Repeating structure with placeholder (XPath only) | [Repeating Structures](setcontext.md) |

## Match Modes: Exact, Wildcard, Regex

All `Verify*` keywords support three match modes:

```robot
# Exact match (default)
VerifyValue        Titel    Products

# Wildcard: * = any characters, ? = one character
VerifyValueWCM     Seitentitel    *IFrame*

# Regular expression
VerifyValueREGX    Preis    \$\d+\.\d{2}
```

Details: [Tokens and Match Modes](../../grundlagen/tokens-und-match-modes.md).

## Web-Specific Keywords

These keywords exist only in the Selenium library:

| Keyword | Description |
|---|---|
| `ExecuteJS` | Execute JavaScript in the browser context |
| `RemoveAds` | Remove ad iframes/overlays (via JS + MutationObserver) |

### RemoveAds

Removes ad elements from the current page. A `MutationObserver` is
installed that also removes ads loaded later.

```robot
# Default (Google Ads):
OnFailIgnoreNOISE    RemoveAds

# Project-specific selectors:
OnFailIgnoreNOISE    RemoveAds    div.custom-banner    iframe[src*="ad-network"]
```

Best used in the test setup with `OnFailIgnoreNOISE` — if there are no
ads, nothing happens.

## Runnable Examples

All examples in this chapter come from the okw-examples repository:

| Example | What it shows |
|---|---|
| [SauceDemo](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/saucedemo) | Login, OnFailNOISE, SetContext, ComboBox sorting |
| [ExpandTesting](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/expandtesting) | Shadow DOM, iFrames, drag & drop, dynamic tables, hover |
| [The Internet](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/the-internet) | Login, checkboxes, dropdown, tables, hover |

```bash
git clone https://github.com/Hrabovszki1023/okw-examples.git
cd okw-examples/selenium/saucedemo
pip install robotframework-okw-web-selenium
robot tests/
```
