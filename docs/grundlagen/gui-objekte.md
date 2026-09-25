---
source_hash: b71618df46c9
---

# GUI Objects

OKW divides GUI objects into five categories — by the **dimension of
their data**. This classification determines which keywords apply to an
object, and it holds for all technologies (web, Swing, SAP GUI, ...).

## Overview

| Category | Examples | Data dimension |
|---|---|---|
| **Objects without data** | Button, Link, MenuItem | None — action only |
| **One-dimensional objects** | TextField, Checkbox, ComboBox | One value |
| **Multi-dimensional objects** | Table | Row × column |
| **Frame objects (context)** | SetContext groups | Encapsulate child widgets |
| **Window objects** | Pages, tab areas, dialogs | Group GUI objects |

---

## Objects Without Data

Objects without a data value of their own. You can click them, but not
write to them with `SetValue`. A button shows a **caption**, but no
changeable value — so there is no `VerifyValue`, but `VerifyCaption`.

**Typical representatives:**

- Button / push button
- Link / hyperlink
- MenuItem

**Applicable keywords:**

| Keyword | Purpose |
|---|---|
| `ClickOn` | Click |
| `DoubleClickOn` | Double-click |
| `MoveOver` | Move the mouse over it (hover) |
| `VerifyCaption` | Verify the caption |
| `VerifyTooltip` | Verify the tooltip |
| `VerifyExists` | Verify existence (YES/NO) |
| `LogCaption` | Log the caption |
| `SelectMenu` | Select a menu item (menus only) |

**Example:**

```robot
ClickOn         Anmelden
VerifyCaption   Anmelden    Anmelden
VerifyTooltip   Speichern   Dokument speichern (Strg+S)
```

```yaml
Anmelden:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '[data-test="login-button"]' }
```

---

## One-Dimensional Objects

Objects with **one value**. The value can be set, read and verified.

### TextField / MultilineField

Text fields for one line or several lines.

| Keyword | Purpose |
|---|---|
| `SetValue` | Enter text (replaces previous content) |
| `TypeKey` | Type text (without clearing first) |
| `Delete` | Delete field content |
| `VerifyValue` | Verify the value (EXACT, WCM, REGX) |
| `VerifyPlaceholder` | Verify the placeholder text |
| `MemorizeValue` | Store the value |
| `LogValue` | Log the value |

```robot
SetValue       Benutzer    admin
VerifyValue    Benutzer    admin
Delete         Benutzer
VerifyValue    Benutzer    ${EMPTY}
```

```yaml
Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="username"]' }
```

### Checkbox

Binary state: on or off.

| Keyword | Purpose |
|---|---|
| `SetValue` | Set the state (Checked/Unchecked or YES/NO) |
| `ClickOn` | Toggle the state |
| `VerifyValue` | Verify the state |

```robot
SetValue       AGB    Checked
VerifyValue    AGB    Checked
ClickOn        AGB
VerifyValue    AGB    Unchecked
```

```yaml
AGB:
  class: okw_web_selenium.widgets.webse_checkbox.WebSe_CheckBox
  locator: { id: accept-terms }
```

### ComboBox (Dropdown)

Select one value from a list.

| Keyword | Purpose |
|---|---|
| `Select` | Select an item |
| `SetValue` | Select an item (alias for Select) |
| `VerifyValue` | Verify the selected value |
| `VerifyListCount` | Verify the number of items |

```robot
Select         Land    Deutschland
VerifyValue    Land    Deutschland
```

```yaml
Land:
  class: okw_web_selenium.widgets.webse_combobox.WebSe_ComboBox
  locator: { id: country-select }
```

### RadioList (Radio Button Group)

Select exactly one value from a group.

| Keyword | Purpose |
|---|---|
| `Select` | Select an option |
| `VerifyValue` | Verify the selected option |
| `VerifyListCount` | Verify the number of options |

```robot
Select         Zahlungsart    Kreditkarte
VerifyValue    Zahlungsart    Kreditkarte
```

```yaml
Zahlungsart:
  class: okw_web_selenium.widgets.webse_radiolist.WebSe_RadioList
  locator: { css: '[name="payment-method"]' }
```

### ListBox (Multiple Selection)

List with single or multiple selection.

| Keyword | Purpose |
|---|---|
| `Select` | Select an item |
| `VerifyValue` | Verify the selected value |
| `VerifyListCount` | Verify the number of items |
| `VerifySelectedCount` | Verify the number of selected items |

```robot
Select                 Farben    Rot, Blau
VerifyValue            Farben    Rot, Blau
VerifySelectedCount    Farben    2
```

```yaml
Farben:
  class: okw_web_selenium.widgets.webse_listbox.WebSe_ListBox
  locator: { id: color-list }
```

### Label (Static Text)

Read-only objects — text that is displayed but not edited.

| Keyword | Purpose |
|---|---|
| `VerifyValue` | Verify the displayed text (EXACT, WCM, REGX) |
| `VerifyCaption` | Verify the caption |
| `MemorizeValue` | Store the text |
| `LogValue` | Log the text |

```robot
VerifyValue    Fehlermeldung    Epic sadface: Username is required
```

```yaml
Fehlermeldung:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="error"]' }
```

!!! note "A label is not a button"
    A label has no `SetValue` and no `ClickOn`. If a text is clickable,
    it is a link or a button — not a label.

---

## Multi-Dimensional Objects

### Table

Tables have two dimensions: **row × column**. The keywords address
single cells, whole rows, whole columns or the entire table.

**Index-based keywords** (row/column as number, 1-based):

| Keyword | Parameters | Purpose |
|---|---|---|
| `VerifyTableCellValue` | Name, row, column, expected | Verify a single cell |
| `VerifyTableRowContent` | Name, row, row pattern | Verify a whole row |
| `VerifyTableColumnContent` | Name, column, column pattern | Verify a whole column |
| `VerifyTableRowCount` | Name, expected | Verify the row count |
| `VerifyTableColumnCount` | Name, expected | Verify the column count |
| `VerifyTableHasRow` | Name, row pattern | Verify that a row exists |
| `VerifyTableContent` | Name, table pattern | Verify the entire table |

**Header-based keywords** (row by key value, column by header):

| Keyword | Purpose |
|---|---|
| `VerifyTableCellValueByHeaders` | Cell by row key + column header |
| `VerifyTableRowContentByHeader` | Row by header + key |
| `VerifyTableColumnContentByHeader` | Column by header |

```robot
# Index-based: row 2, column 3
VerifyTableCellValue    Ergebnistabelle    2    3    42.50

# Header-based: row with name "Smith", column "Alter" (age)
VerifyTableCellValueByHeaders    Ergebnistabelle    Smith    Alter    35
```

```yaml
Ergebnistabelle:
  class: okw_web_selenium.widgets.webse_table.WebSe_Table
  locator: { css: 'table.results' }
```

!!! info "Separators"
    Cells within a row are separated by `$TAB`, rows by `$LF`. These
    tokens are configurable.

---

## Frame Objects (Context)

Web applications often contain **repeating structures** — product
cards, table rows, list items — with the same internal structure.
Instead of defining each instance separately in YAML, `SetContext`
combines them.

A frame object is not a widget — it is a **container** that groups child
widgets and is identified via a placeholder.

```robot
SetContext      ProduktKarte    Sauce Labs Backpack
VerifyValue     Produktpreis    $29.99
ClickOn         InDenWarenkorb
```

```yaml
ProduktKarte:
  __context__:
    locator: { xpath: '//div[@class="product"]
      [.//h3[text()="{ProduktName}"]]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/span[@class="price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button[contains(@class,"add-to-cart")]' }
```

**Rules:**

- `__context__` is a reserved key — like `__self__`.
- Placeholders use `{Name}` syntax: `SetContext ProduktKarte Sauce Labs Backpack`
  replaces `{ProduktName}` in the locator.
- Child locators are relative (`.//...`) — scoped to the context element.
- `SelectWindow` clears the context automatically.

!!! warning "XPath only"
    SetContext requires XPath — both for the `__context__` locator and
    for the child locators. CSS selectors support neither text search
    nor relative path composition.

    Libraries without XPath (Java RemoteSwing, SAP GUI) do **not**
    support SetContext.

Full documentation: [SetContext](setcontext.md)

---

## Window Objects

A **window** in OKW is whatever you **define** as a window. It can be a
whole page, but also a part of it — e.g. a tab, a dialog or a panel.

```robot
SelectWindow    Login
SetValue        Benutzer    admin

SelectWindow    Einstellungen
ClickOn         Speichern
```

`SelectWindow` determines the area in which subsequent keywords act. It
is the **scope** for all widget operations.

### Pages as Windows

On the web, a page is typically a window:

```yaml
# locators/SauceDemoLogin.yaml
__self__:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="login-container"]' }

Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="username"]' }
```

### Tab Areas as Windows

A tab inside a page can be defined as a window of its own — the widgets
on the tab belong together logically:

```yaml
# Tab "Persönliche Daten" (personal data) as a window
PersoenlicheDaten:
  __self__:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { css: '#tab-personal' }
  Vorname:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#first-name' }
  Nachname:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#last-name' }

# Tab "Adresse" (address) as a window
Adresse:
  __self__:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { css: '#tab-address' }
  Strasse:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#street' }
  PLZ:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#zip' }
```

```robot
SelectWindow    PersoenlicheDaten
SetValue        Vorname    Max
SetValue        Nachname   Mustermann

SelectWindow    Adresse
SetValue        Strasse    Hauptstr. 1
SetValue        PLZ        12345
```

### `__self__` as Pre-Condition

The `__self__` element of a window serves as a **pre-condition**:
`SelectWindow` waits until this element exists before it continues.
Choose an element that uniquely identifies the window area — a container
`<div>`, a form, a tab panel.

!!! tip "Window = logical grouping"
    A window is not a technical concept (no browser window, no OS
    dialog). It is a **logical grouping** of GUI objects that are tested
    together. The tester decides what a window is.

---

## Keyword Matrix

The following matrix shows which keywords apply to which object
category:

### Actions

| Keyword | No data | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `ClickOn` | ✓ | ✓ | ✓ | | | | |
| `DoubleClickOn` | ✓ | | | | | | |
| `MoveOver` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `SetValue` | | ✓ | ✓ | ✓ | | | |
| `Select` | | | | ✓ | ✓ | ✓ | |
| `TypeKey` | | ✓ | | ✓ | | | |
| `Delete` | | ✓ | | | | | |
| `SelectMenu` | ✓ | | | | | | |

### Verifications

| Keyword | No data | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `VerifyValue` | | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `VerifyCaption` | ✓ | | | | | | |
| `VerifyTooltip` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `VerifyExists` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `VerifyPlaceholder` | | ✓ | | ✓ | | | |
| `VerifyListCount` | | | | ✓ | ✓ | ✓ | |
| `VerifyTableCellValue` | | | | | | | ✓ |
| `VerifyTableRowCount` | | | | | | | ✓ |

### Store / Log

| Keyword | No data | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `MemorizeValue` | | ✓ | ✓ | ✓ | | ✓ | |
| `MemorizeCaption` | ✓ | | | | | | |
| `LogValue` | | ✓ | ✓ | ✓ | | ✓ | |
| `LogCaption` | ✓ | | | | | | |
