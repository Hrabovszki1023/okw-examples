---
source_hash: c048ff3748da
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

```robot
*** Test Cases ***
Anmeldung ohne Mandant und Sprache
    OKW.SetValue       Mandant     ${IGNORE}       # Skipped
    OKW.SetValue       Benutzer    TESTUSER
    OKW.SetValue       Kennwort    geheim123
    OKW.SetValue       Sprache     ${IGNORE}       # Skipped
    OKW.ClickOn        Anmelden
```

**Why?** Without `$IGNORE` you would need IF statements or separate test
cases. With `$IGNORE` the test flow stays linear — no control-flow NOISE.

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

All `Verify*` keywords support three modes for value verification:

### EXACT — Exact Comparison (Default)

```robot
OKW.VerifyValue    Benutzername    admin
```

The value must be exactly `admin`.

### WCM — Wildcard

```robot
OKW.VerifyValue    Meldung    Anmeldung erfolgreich*
OKW.VerifyValue    Datum      ??.??.2026
```

| Character | Meaning |
|---|---|
| `*` | Any number of any characters |
| `?` | Exactly one character |

### REGX — Regular Expression

```robot
OKW.VerifyValue    Telefon    REGX:\\+49\\s\\d{3,4}\\s\\d+
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
