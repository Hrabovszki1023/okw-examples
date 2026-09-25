---
source_hash: fe69e60170c9
---

# Idempotency

## What Does Idempotent Mean?

A keyword is **idempotent** if repeated calls with the same parameters
always produce the same result — regardless of the prior state of the
target object and without unwanted side effects.

> Run it once or run it ten times — the result is the same.

## Why Does It Matter?

Tests must be **stable** and **repeatable**. If a keyword does something
different on every call, the test becomes unreliable. Idempotent
keywords are:

- **Repeatable** — a failed test can be restarted without cleanup.
- **Order-tolerant** — individual steps can be moved without changing
  the result.
- **Robust against retry** — timeout-based polling (e.g. in
  `VerifyValue`) only works if the verification step is idempotent.

## Idempotent Keywords in OKW

### SetValue — Set a State, Do Not Append

`SetValue` sets the value of a widget to the given value, no matter what
was in the field before:

```robot
SetValue    Benutzername    admin
SetValue    Benutzername    admin    # Result: still "admin"
```

The field is **not** written twice — the state after the call is always
the same.

### SelectMenu — Set a State Idempotently

Without a value, `SelectMenu` is a **toggle** (not idempotent):

```robot
SelectMenu    Statusleiste              # Toggle: ON → OFF → ON → ...
```

With a value, `SelectMenu` becomes **idempotent** — it sets the desired
state, whatever the current one is:

```robot
SelectMenu    Statusleiste    Checked     # Result: always ON
SelectMenu    Statusleiste    Checked     # Result: still ON
SelectMenu    Statusleiste    Unchecked   # Result: always OFF
```

### Delete — Delete Content

`Delete` clears the content of a widget. Whatever was in it before, it
is empty afterwards:

```robot
Delete    Benutzername              # Field is empty
Delete    Benutzername              # Field is still empty
```

### Select — Set a Selection

`Select` selects an item. Selecting the same item again changes nothing:

```robot
Select    Land    Deutschland
Select    Land    Deutschland    # Result: still "Deutschland"
```

### Verify Keywords — Pure Verification

All `Verify*` keywords are idempotent by definition — they only read and
change nothing:

```robot
VerifyValue    Status    Aktiv     # Verifies, changes nothing
VerifyValue    Status    Aktiv     # Same result
```

## Idempotency Depends on the GUI Object

Whether a keyword is idempotent is determined not only by the keyword —
but also by the **GUI object** it acts on.

The same keyword `ClickOn` can be idempotent or not, depending on the
target object:

| Keyword | GUI object | Idempotent? | Why |
|---|---|---|---|
| `ClickOn` | Menu item | **Yes** | Always opens the same function |
| `ClickOn` | "Save" button | **Yes** | Always triggers the same action |
| `ClickOn` | Checkbox | **No** | Toggle: ON → OFF → ON → ... |
| `ClickOn` | Accordion panel | **No** | Toggle: open → closed → open → ... |

!!! warning "Think carefully in the test case"
    When creating a test, check **every step**: is this keyword
    idempotent on **this** GUI object? If not — is there an idempotent
    alternative?

    | Not idempotent | Idempotent alternative |
    |---|---|
    | `ClickOn AGB` (checkbox) | `SetValue AGB YES` |
    | `SelectMenu Statusleiste` (toggle) | `SelectMenu Statusleiste Checked` |

## Non-Idempotent Keywords

Some keywords are fundamentally **not** idempotent, regardless of the
GUI object:

| Keyword | Why not idempotent |
|---|---|
| `TypeKey` | Appends text instead of replacing it |
| `DoubleClickOn` | A double-click opens e.g. an editor — repeating it may close it |

## The Test State Must Be Idempotent

The decisive rule applies not to individual keywords, but to the
**entire navigation to the test state**:

> All steps from start to verification must be **idempotent in sum**.

A test case typically has three phases:

```
1. Navigation    →  Reach the right window/dialog
2. Action        →  Trigger the test (input, click, ...)
3. Verification  →  Verify the result
```

Phases 1 + 2 + 3 together must be idempotent — the test must reach the
same state and verify the same result on every run, however often it
runs.

**Example — idempotent test state:**

```robot
*** Test Cases ***
Login mit gültigem Benutzer
    OKW.StartApp        MeineApp
    OKW.SelectWindow    Login

    # Navigation + action (idempotent in sum)
    OKW.SetValue        Benutzer    admin       # idempotent
    OKW.SetValue        Kennwort    geheim      # idempotent
    OKW.ClickOn         Anmelden                # idempotent (button)

    # Verification (always idempotent)
    OKW.SelectWindow    Dashboard
    OKW.VerifyValue     Willkommen    Hallo admin

    OKW.StopApp
```

Every single step sets a defined state — nothing depends on what was in
the field before or whether the test has run before.

## Signal vs. NOISE

Non-idempotent keywords are important — they trigger the actual test. A
`ClickOn Speichern` (save) or `DoubleClickOn Datensatz` (record) is the
**test action** itself. That is **Signal**.

But in the **navigation to the test state**, non-idempotent steps are a
potential **NOISE generator**: if the navigation depends on state, the
test can fail on repetition — not because the test is wrong, but because
the navigation is fragile.

| Phase | Idempotent? | Why |
|---|---|---|
| Navigation | **Must** be idempotent | Otherwise NOISE: test failures caused by fragile navigation |
| Test action | May be non-idempotent | That **is** the test — Signal |
| Verification | Always idempotent | `Verify*` only reads, changes nothing |

**Example — NOISE caused by non-idempotent navigation:**

```robot
# NOISE: ClickOn on a checkbox is not idempotent
# On the second test run AGB is OFF instead of ON
ClickOn         AGB                     # Toggle: ON → OFF → ON → ...
ClickOn         Speichern               # Test action
VerifyValue     Status    Gespeichert   # Fails — but not because of Save!
```

```robot
# Signal: SetValue is idempotent
# However often the test runs — AGB is always ON
SetValue        AGB       YES           # Always ON
ClickOn         Speichern               # Test action
VerifyValue     Status    Gespeichert   # Stable
```

The rule:

> **Navigation** → use idempotent keywords (Signal).
> **Test action** → the right keyword for the action (may be non-idempotent).
> **Verification** → `Verify*` (always idempotent).
