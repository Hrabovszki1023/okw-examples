# Tokens und Match Modes

## Globale Tokens

OKW definiert drei Tokens, die in **allen** Bibliotheken funktionieren.
Sie werden als Robot-Framework-Variablen definiert und in Keyword-Parametern verwendet.

```robot
*** Variables ***
${IGNORE}    $IGNORE
${EMPTY}     $EMPTY
${DELETE}    $DELETE
```

### $IGNORE — Schritt überspringen

`$IGNORE` macht ein Keyword zum No-Op. Der Schritt wird übersprungen (PASS),
ohne etwas auszuführen.

```robot
*** Test Cases ***
Anmeldung ohne Mandant und Sprache
    OKW.SetValue       Mandant     ${IGNORE}       # Wird übersprungen
    OKW.SetValue       Benutzer    TESTUSER
    OKW.SetValue       Kennwort    geheim123
    OKW.SetValue       Sprache     ${IGNORE}       # Wird übersprungen
    OKW.ClickOn        Anmelden
```

**Warum?** Ohne `$IGNORE` bräuchte man IF-Anweisungen oder separate
Testfälle. Mit `$IGNORE` bleibt der Testablauf linear — kein
Kontrollfluss-NOISE.

### $EMPTY — Leeren Wert prüfen oder setzen

`$EMPTY` steht für einen explizit leeren Wert:

```robot
# Prüfen, dass ein Feld leer ist
OKW.VerifyValue    Benutzername    ${EMPTY}

# Leeren Wert setzen (Feld leeren)
OKW.SetValue       Suchbegriff     ${EMPTY}
```

### $DELETE — Feldinhalt löschen

`$DELETE` löst eine explizite Löschaktion aus:

```robot
OKW.SetValue    Benutzername    ${DELETE}       # Feld aktiv leeren
```

!!! note "Unterschied $EMPTY vs. $DELETE"
    `$EMPTY` setzt den Wert auf leer. `$DELETE` führt eine aktive
    Löschoperation aus (z.B. Ctrl+A, Delete). Das Ergebnis kann
    gleich sein, aber die Aktion unterscheidet sich — relevant für
    Felder mit spezieller Lösch-Logik.

## Match Modes

Alle `Verify*`-Keywords unterstützen drei Modi zur Wertprüfung:

### EXACT — Exakter Vergleich (Standard)

```robot
OKW.VerifyValue    Benutzername    admin
```

Der Wert muss exakt `admin` sein.

### WCM — Wildcard

```robot
OKW.VerifyValue    Meldung    Anmeldung erfolgreich*
OKW.VerifyValue    Datum      ??.??.2026
```

| Zeichen | Bedeutung |
|---|---|
| `*` | Beliebig viele beliebige Zeichen |
| `?` | Genau ein beliebiges Zeichen |

### REGX — Regulärer Ausdruck

```robot
OKW.VerifyValue    Telefon    REGX:\\+49\\s\\d{3,4}\\s\\d+
```

Verwendet `re.search` mit Multiline-Flag.

## Wert-Expansion mit $MEM{}

Gespeicherte Werte können in Parametern wiederverwendet werden:

```robot
# Wert speichern
OKW.MemorizeValue    Bestellnummer    BestNr

# Gespeicherten Wert verwenden
OKW.VerifyValue      Referenz         $MEM{BestNr}
```

Fehlende Schlüssel erzeugen sofort einen Fehler — kein stilles Versagen.

## YES/NO für Existenzprüfung

`VerifyExists` akzeptiert verschiedene Schreibweisen:

| Eingabe | Bedeutung |
|---|---|
| `YES`, `TRUE`, `1` | Element muss existieren |
| `NO`, `FALSE`, `0` | Element darf nicht existieren |

```robot
OKW.VerifyExists    Fehlermeldung    NO       # Darf nicht sichtbar sein
OKW.VerifyExists    Willkommen       YES      # Muss sichtbar sein
```
