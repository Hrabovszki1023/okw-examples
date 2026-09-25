---
source_hash: 948ea966d0ca
---

# Keywords

## One Set of Keywords for All Technologies

OKW defines a fixed set of keywords that work identically in **all** GUI
libraries. The test speaks one uniform language — the technology behind
it is exchangeable.

## Overview

### Application Control

| Keyword | Parameters | Purpose |
|---|---|---|
| `StartApp` | AppName | Start the application (defined in YAML) |
| `StopApp` | | Stop the application |
| `SelectWindow` | WindowName | Select a window/dialog |
| `SetContext` | ContextName, value | Set the context for repeating structures |

### Input Keywords (Change GUI State)

#### Without Value (Action on Widget)

| Keyword | Parameters | Purpose |
|---|---|---|
| `ClickOn` | Widget | Click the widget |
| `DoubleClickOn` | Widget | Double-click the widget |
| `MoveOver` | Widget | Move the mouse over the widget (hover) |
| `Delete` | Widget | Delete field content |
| `SelectMenu` | Widget | Click a menu item (toggle) |

#### With Value (Single-Value Input)

| Keyword | Parameters | Purpose |
|---|---|---|
| `SetValue` | Widget, value | Set a value (enter text, set checkbox) |
| `TypeKey` | Widget, value | Type text (without clearing first) |
| `Select` | Widget, value | Select a single item (ComboBox, RadioButton) |
| `SelectMenu` | Widget, value | Set a menu item to a state (Checked/Unchecked) |

#### Multiple Selection (Lists)

| Keyword | Parameters | Purpose |
|---|---|---|
| `Select` | Widget, value₁ / value₂ / ... | Select several items (ListBox) |

### Read Keywords (Verify GUI State)

| Keyword | Parameters | Purpose |
|---|---|---|
| `VerifyValue` | Widget, expected | Verify value (with match mode) |
| `VerifyCaption` | Widget, expected | Verify visible text/caption |
| `VerifyTooltip` | Widget, expected | Verify tooltip text |
| `VerifyExists` | Widget, YES/NO | Verify existence |
| `LogValue` | Widget | Write the current value to the log |
| `LogCaption` | Widget | Write the visible text to the log |
| `MemorizeValue` | Widget, key | Store a value for later use |

### Table Keywords

Tables have their own keywords that address cells by row/column or by
column headers:

#### Input

| Keyword | Parameters | Purpose |
|---|---|---|
| `ClickOnTableCell` | Table, row, column | Click a cell |
| `ClickOnTableCellByHeaders` | Table, row, column name | Click a cell (by column header) |
| `DoubleClickOnTableCell` | Table, row, column | Double-click a cell |
| `DoubleClickOnTableCellByHeaders` | Table, row, column name | Double-click a cell (by column header) |
| `SetTableCellValue` | Table, row, column, value | Set a cell value |
| `SetTableCellValueByHeaders` | Table, row, column name, value | Set a cell value (by column header) |

#### Read and Verify

| Keyword | Parameters | Purpose |
|---|---|---|
| `VerifyTableCellValue` | Table, row, column, expected | Verify a cell value |
| `VerifyTableCellValueByHeaders` | Table, row, column name, expected | Verify a cell value (by column header) |
| `VerifyTableRowContent` | Table, row, expected₁ / ... | Verify row content |
| `VerifyTableColumnContent` | Table, column, expected₁ / ... | Verify column content |
| `VerifyTableContent` | Table, expected (matrix) | Verify the whole table |
| `VerifyTableHasRow` | Table, expected₁ / ... | Verify that a row exists |
| `VerifyTableRowCount` | Table, expected | Verify the row count |
| `VerifyTableColumnCount` | Table, expected | Verify the column count |
| `LogTableCellValue` | Table, row, column | Write a cell value to the log |
| `MemorizeTableCellValue` | Table, row, column, key | Store a cell value |

## Low-Level vs. High-Level Keywords (ISO/IEC/IEEE 29119-5)

OKW adopts the keyword terminology of **ISO/IEC/IEEE 29119-5:2024**
(*Software Testing — Part 5: Keyword-driven testing*) instead of
inventing its own terms — so the classification is backed by the
standard, not just by convention.

| ISO term (§) | Definition (paraphrased) | Corresponds in OKW to |
|---|---|---|
| **low-level keyword** (§3.14) | Covers only one or a few simple actions, is **not** composed from other keywords | The built-in OKW keywords themselves: `SetValue`, `ClickOn`, `VerifyValue`, ... (see overview above) |
| **high-level keyword** (§3.7) | Complex activity composable from other keywords, intended for domain experts | A **Robot Framework user keyword** that combines several OKW keywords into a business transaction (e.g. `Anmelden` (log in) as a wrapper around `SetValue`+`SetValue`+`ClickOn`) |
| **composite keyword** (§3.2) | Structural property: consists of ≥2 other keywords (regardless of abstraction level) | Every user keyword that calls other keywords — can itself be low-level or high-level |

**Important:** *composite* is purely a construction principle ("what is
it made of"), *high-level/low-level* describes the abstraction level
("who uses it"). A composite keyword can remain technical (intermediate
layer) or be business-oriented (domain layer) — both are permitted by
the standard. A **test case** is essentially a composite keyword too —
it consists of a sequence of keywords that together represent a business
transaction.

**Consequence for OKW:** the library itself provides **only low-level
keywords** — deliberately so, see [Signal vs. NOISE](signal-vs-noise.md).

> OKW delivers the bricks (low-level keywords), not the finished
> building. Which assemblies (high-level/composite keywords) are built
> from them is decided by each project — OKW does not even know the
> building. High-level/composite keywords are created per project via
> Robot Framework `*** Keywords ***` definitions that combine OKW
> keywords:

!!! warning "Recommendation: test cases built directly from low-level keywords"
    Test cases built directly from low-level keywords show **every user
    action as its own line**. That makes them easiest to follow as a
    sequence — for the author as well as for reviewers and during
    failure analysis.

    Nested high-level keywords (keyword calls keyword calls keyword)
    become hard to follow from the second level on: you have to jump
    into every keyword to understand the actual flow. That is
    **NOISE** — not in the test code itself, but in the reader's head.

    High-level keywords are still useful — e.g. as setup/teardown or for
    recurring navigation blocks. But the **test core** (input +
    verification) should consist of low-level keywords, so the user
    activities stay transparent.

```robot
*** Keywords ***
Anmelden
    [Arguments]    ${Benutzer}    ${Kennwort}
    OKW.SetValue       Benutzer     ${Benutzer}
    OKW.SetValue        Kennwort    ${Kennwort}
    OKW.ClickOn         Anmelden
```

Here `Anmelden` is a high-level/composite keyword in the sense of the
standard — composed of three OKW low-level keywords, readable for domain
experts, without OKW needing a language construct of its own. Robot
Framework already provides the composition mechanism natively.

## CamelCase Convention

Keywords are always written as **CamelCase without spaces**:

```robot
SetValue       Benutzer    admin       # Correct
Set Value      Benutzer    admin       # Wrong — space
set_value      Benutzer    admin       # Wrong — snake case
```

**Why?** In Robot Framework's tab-separated format, spaces can be
confused with parameter separators. CamelCase is unambiguous.

## Keyword Calls with Library Prefix

OKW keywords are always called with the library prefix `OKW.`:

```robot
*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW

*** Test Cases ***
Mein Test
    OKW.SetValue       Benutzername    admin
    OKW.ClickOn        Anmelden
    OKW.VerifyValue    Willkommen      Hallo admin
```

`WITH NAME OKW` in the library line defines the prefix. It is
immediately clear which keywords belong to OKW.

## Example: Same Test, Three Technologies

The same test works with different drivers — only the YAML file and the
library line change:

=== "Web Selenium"

    ```robot
    Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW
    ```

=== "SAP GUI"

    ```robot
    Library    okw_sap_gui.library.OkwSapGuiLibrary    WITH NAME    OKW
    ```

=== "Java Swing"

    ```robot
    Library    okw_java_remoteswing.library.OkwJavaRemoteSwingLibrary    WITH NAME    OKW
    ```

The test body stays identical:

```robot
*** Test Cases ***
Anmeldung
    OKW.StartApp       MeineApp
    OKW.SelectWindow   Login
    OKW.SetValue       Benutzer    admin
    OKW.SetValue       Kennwort    geheim
    OKW.ClickOn        Anmelden
    OKW.StopApp
```
