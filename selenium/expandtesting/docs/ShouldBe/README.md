# ShouldBe — State Verification Keywords

**Page:** https://practice.expandtesting.com/assertions/should-be

**Test file:** `tests/ShouldBe.robot`

## What This Example Demonstrates

- **VerifyIsVisible** — check if an element is visible or hidden.
- **VerifyIsEnabled** — check if an element is enabled or disabled.
- **VerifyValue** with **Checked/Unchecked** — checkbox state verification.
- **VerifyValue** with **empty string** — verify an element has no content.
- **VerifyValueWCM** — wildcard matching for text content.
- All OKW state verification keywords in a single, compact example.

## Page Specifics

The page is designed as a test playground for assertion keywords. It
provides pre-configured elements in known states — no user interaction
needed. The page organizes elements into cards by assertion category:

| Card | Elements | State |
|---|---|---|
| **'visible'** | btn1, btn2 | btn1 visible, btn2 has `hidden` attribute |
| **'visible'** (lists) | ul1, ul2 | ul1 has visible items, ul2 all items hidden |
| **'checked'** | cb1, cb2 | cb1 has `checked` attribute, cb2 unchecked |
| **'empty'** | div1, div2 | div1 is empty, div2 contains text |
| **'enabled'/'disabled'** | btn3, btn4 | btn3 enabled, btn4 has `disabled` attribute |
| **'a'** (value) | a_number | Input with default value 8 |

The page uses the same terminology as OKW: "checked", "empty", "visible",
"enabled", "disabled" — making the mapping between page concepts and
OKW keywords nearly 1:1.

## Implementation

### Direct State Verification

No actions needed — the page has static elements in known states.
Each test case is a single verification step (phase 5 only):

```robot
Sichtbarer Button Ist Sichtbar
    VerifyIsVisible    SichtbarerButton    YES

Versteckter Button Ist Nicht Sichtbar
    VerifyIsVisible    VersteckterButton    NO
```

### OKW YES/NO Model

All state verification keywords use the OKW YES/NO model:
- `YES`, `TRUE`, `1` — element must have the property.
- `NO`, `FALSE`, `0` — element must not have the property.

### Checkbox Values

OKW uses `Checked` / `Unchecked` as checkbox values:

```robot
VerifyValue    AktiveCheckbox    Checked
VerifyValue    InaktiveCheckbox    Unchecked
```

### Empty Verification

An empty `<div>` returns an empty string for `get_text()`:

```robot
VerifyValue    LeererBereich    ${EMPTY}
```

## Test Cases

| Test | Keyword | Expected |
|---|---|---|
| Sichtbarer Button Ist Sichtbar | `VerifyIsVisible` | YES |
| Versteckter Button Ist Nicht Sichtbar | `VerifyIsVisible` | NO |
| Sichtbare Liste Ist Sichtbar | `VerifyIsVisible` | YES |
| Checkbox Ist Angehakt | `VerifyValue` | Checked |
| Checkbox Ist Nicht Angehakt | `VerifyValue` | Unchecked |
| Leerer Bereich Ist Leer | `VerifyValue` | (empty) |
| Gefuellter Bereich Hat Inhalt | `VerifyValueWCM` | \*Text for div2\* |
| Aktiver Button Ist Aktiviert | `VerifyIsEnabled` | YES |
| Deaktivierter Button Ist Deaktiviert | `VerifyIsEnabled` | NO |
| Zahlenfeld Hat Wert 8 | `VerifyValue` | 8 |
