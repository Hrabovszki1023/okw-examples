---
source_hash: 1d3ba7609021
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

**Counter-example — `TypeKey` appends:**

```robot
TypeKey        Benutzername    admin
VerifyValue    Benutzername    admin
TypeKey        Benutzername    admin
VerifyValue    Benutzername    adminadmin    # Result: "adminadmin"
```

`TypeKey` types the text in addition, without clearing the field first.
Every further call changes the state — `TypeKey` is **not** idempotent.

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
| `ClickOn` | "Save" button | **Depends** | Depending on the application: a second record, a "no changes" message, or the same action |
| `ClickOn` | "OK" / "Cancel" button in a dialog | **No** | The dialog closes — a second click no longer finds the object |
| `ClickOn` | Checkbox | **No** | Toggle: ON → OFF → ON → ... — `SetValue AGB Checked`, on the other hand, is idempotent; prefer it in navigation |
| `ClickOn` | Accordion panel | **No** | Toggle: open → closed → open → ... |

**Rule of thumb:** A keyword is not idempotent if it changes the
application state so that the same call afterwards behaves differently —
or no longer finds the GUI object at all ("object not found").

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

## Idempotency in the 5-Phase Model

The decisive rule applies not to individual keywords, but to the
**way into the test state**:

> Pay attention to idempotency when the **initial state** of an object
> **could be unknown** and you want to make sure that you **leave it
> in a defined state** afterwards.

An OKW test case has five phases:

| # | Phase | Content | Idempotent? |
|---|---|---|---|
| 1 | Initialise environment / reset | Reset the state, e.g. delete data from an earlier run | **Must** |
| 2 | Load test data | Create the required data | **Must** |
| 3 | Navigate to test state | Reach the right window/dialog | **Must** |
| 4 | Perform action | Enter values and trigger processing | May be non-idempotent |
| 5 | Verify acceptance criterion | Verify the result | Always — `Verify*` only reads |

Phases 1–3 bring the application from **any** initial state safely into
the test state — that is why they must be idempotent. This way the test
reaches the same state and verifies the same result on every run,
however often it runs.

!!! info "Failures outside phases 4 and 5 are usually NOISE"
    If a failure occurs **outside phase 4 or 5**, it is most likely
    **NOISE** — the actual test was never reached. That is why the steps
    of phases 1–3 are wrapped with
    [`OnFailNOISE`](../gui/web-selenium/index.md#onfailnoise): a failure
    there marks the test case as NOISE, not as an SUT defect. The
    5-phase model thus enables a quick first classification of test
    results.

**Example — idempotent test state:**

```robot
*** Test Cases ***
Login mit gültigem Benutzer
    # Phase 3: navigation (idempotent)
    OKW.StartApp        MeineApp
    OKW.SelectWindow    Login

    # Phase 4: perform action
    OKW.SetValue        Benutzer    admin       # idempotent
    OKW.SetValue        Kennwort    geheim      # idempotent
    OKW.ClickOn         Anmelden                # not idempotent: login page disappears

    # Phase 5: verify acceptance criterion (always idempotent)
    OKW.SelectWindow    Dashboard
    OKW.VerifyValue     Willkommen    Hallo admin

    OKW.StopApp
```

The inputs set a defined state — nothing depends on what was in the
field before or whether the test has run before. `ClickOn Anmelden`
(log in) is **not** idempotent on its own: after the click the login page
has disappeared, and a second click would no longer find the button.
That is fine — the click belongs to the action (phase 4), runs exactly
once per run, and
`SelectWindow Dashboard` confirms the new state. **In sum** the test case
is idempotent: it starts in the same state every time via `StartApp`.

## Signal vs. NOISE

Non-idempotent keywords are important — they trigger the actual test. A
`ClickOn Speichern` (save) or `DoubleClickOn Datensatz` (record) is the
**test action** itself. That is **Signal**.

But in the phases **initialise, test data and navigation**, non-idempotent
steps are a potential **NOISE generator**: if they depend on the initial
state, the test can fail on repetition — not because the test is wrong,
but because the way into the test state is fragile.

| Phase | Idempotent? | Why |
|---|---|---|
| 1–3: initialise, test data, navigation | **Must** be idempotent | Otherwise NOISE: test failures caused by a fragile way into the test state |
| 4: perform action | May be non-idempotent | That **is** the test — Signal |
| 5: verify acceptance criterion | Always idempotent | `Verify*` only reads, changes nothing |

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

> **Phases 1–3** (initialise, test data, navigation) → use idempotent keywords.
> **Phase 4** (perform action) → the right keyword for the action (may be non-idempotent).
> **Phase 5** (verify acceptance criterion) → `Verify*` (always idempotent).

!!! tip "Guideline for creating tests"
    1. **Reach the test state safely and simply** — choose the steps of
       phases 1–3 so that they work **whatever state existed before**.
    2. **In the test state** (phase 4), non-idempotent inputs are legitimate when
       they deliberately stimulate a function — e.g. keyboard control:

        ```robot
        TypeKey         Suchfeld          Rob     # Typing triggers the suggestion list
        VerifyExists    Vorschlagsliste   YES
        ```

        Every non-idempotent step is followed **immediately by a
        verification**: the system's reaction is checked against the
        expected result. That verification step is the actual Signal.

    3. Whether a non-idempotent step makes sense must be decided **case
       by case**. What matters first is knowing the differences.
