---
source_hash: a039ca72f8b8
---

# Tokens and Match Modes

## Global Tokens

OKW defines three tokens that work in **all** libraries. They are
defined as Robot Framework variables and used in keyword parameters.

```robot
*** Variables ***
${IGNORE}    $IGNORE
${EMPTY}     $EMPTY
${DELETE}    $DELETE
```

### $IGNORE — Skip a Step

`$IGNORE` turns a keyword into a no-op. The step is skipped (PASS)
without executing anything.

`$IGNORE` shows its strength as the **default value of a parameter** in
a high-level keyword. The keyword `Anmelden` (log in) operates all four
fields of the login form — `Mandant` (client) and `Sprache` (language)
are optional and default to `${IGNORE}`:

```robot
*** Variables ***
${IGNORE}    $IGNORE

*** Keywords ***
Anmelden
    [Arguments]    ${Benutzer}    ${Kennwort}    ${Mandant}=${IGNORE}    ${Sprache}=${IGNORE}
    OKW.SetValue       Mandant     ${Mandant}
    OKW.SetValue       Benutzer    ${Benutzer}
    OKW.SetValue       Kennwort    ${Kennwort}
    OKW.SetValue       Sprache     ${Sprache}
    OKW.ClickOn        Anmelden

*** Test Cases ***
Anmeldung ohne Mandant und Sprache
    Anmelden    TESTUSER    geheim123                                # Mandant, Sprache: skipped

Anmeldung mit Mandant und Sprache
    Anmelden    TESTUSER    geheim123    Mandant=100    Sprache=DE
```

If an optional parameter is not passed, `SetValue` receives `$IGNORE` —
the step is skipped. If it is passed, the field is filled as usual.

!!! note "Parameter order"
    In Robot Framework, parameters with a default value must come
    **after** the mandatory parameters. That is why `Mandant` and
    `Sprache` are at the end of the parameter list — the order of the
    `SetValue` lines inside the keyword still follows the form.

**Why?** Without `$IGNORE` the keyword would need IF statements for every
optional field — or several variants of the keyword. With `$IGNORE`
**one** keyword stays linear and covers all cases — no control-flow
NOISE.

### $EMPTY — Verify or Set an Empty Value

`$EMPTY` stands for an explicitly empty value:

```robot
# Verify that a field is empty
OKW.VerifyValue    Benutzername    ${EMPTY}

# Set an empty value (clear the field)
OKW.SetValue       Suchbegriff     ${EMPTY}
```

### $DELETE — Delete Field Content

`$DELETE` triggers an explicit delete action:

```robot
OKW.SetValue    Benutzername    ${DELETE}       # Actively clear the field
```

!!! note "Difference between $EMPTY and $DELETE"
    `$EMPTY` sets the value to empty. `$DELETE` performs an active
    delete operation (e.g. Ctrl+A, Delete). The result may be the same,
    but the action differs — relevant for fields with special delete
    logic.

## Match Modes

All `Verify*` keywords support three modes for value verification. The
mode is selected by the **keyword suffix**: no suffix = EXACT,
`…WCM` = wildcard, `…REGX` = regular expression.

!!! info "Why three modes — and why EXACT is the default"
    **EXACT — the normal case.** In the vast majority of cases you want
    an exact check: does the field contain exactly the user's name? The
    expected text appears in the test just as it appears on screen — no
    special characters, no escaping. That is the easiest to read and to
    write.

    If there were only wildcards, every text containing `*` or `?` would
    become a problem: you would first have to escape these characters to
    check them literally. This is exactly where business testers fail.
    EXACT, by contrast, compares **character by character what is
    there**.

    **WCM — when a pattern is enough.** If only the form should be
    checked, not the concrete value — e.g. a date (`??.??.????`) or the
    beginning of a text (`Anmeldung erfolgreich*`) — a wildcard pattern
    is sufficient.

    **REGX — for the hard cases.** If that is not enough either, there
    are regular expressions. They are powerful, but require specialist
    knowledge.

    **Rule of thumb:** As simple as possible, as exact as necessary —
    EXACT first, then WCM, REGX only when there is no other way. The
    verification must reliably identify whether the right target state
    has been reached — nothing more.

### EXACT — Exact Comparison (Default)

```robot
OKW.VerifyValue    Benutzername    admin
```

The value must be exactly `admin`.

### WCM — Wildcard

```robot
OKW.VerifyValueWCM    Meldung    Anmeldung erfolgreich*
OKW.VerifyValueWCM    Datum      ??.??.2026
```

| Character | Meaning |
|---|---|
| `*` | Any number of any characters |
| `?` | Exactly one character |

### REGX — Regular Expression

```robot
OKW.VerifyValueREGX    Telefon    \\+49\\s\\d{3,4}\\s\\d+
```

Uses `re.search` with the multiline flag.

## Value Expansion with $MEM{}

Stored values can be reused in parameters:

```robot
# Store a value
OKW.MemorizeValue    Bestellnummer    BestNr

# Use the stored value
OKW.VerifyValue      Referenz         $MEM{BestNr}
```

Missing keys cause an immediate error — no silent failure.

## YES/NO for Existence Checks

`VerifyExists` accepts several spellings:

| Input | Meaning |
|---|---|
| `YES`, `TRUE`, `1` | Element must exist |
| `NO`, `FALSE`, `0` | Element must not exist |

```robot
OKW.VerifyExists    Fehlermeldung    NO       # Must not be visible
OKW.VerifyExists    Willkommen       YES      # Must be visible
```
