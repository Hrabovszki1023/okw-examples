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

Seine Stärke zeigt `$IGNORE` als **Standardwert eines Parameters** in
einem High-Level Keyword. Das Keyword `Anmelden` bedient alle vier
Felder der Anmeldemaske — `Mandant` und `Sprache` sind optional und
stehen standardmäßig auf `${IGNORE}`:

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
    Anmelden    TESTUSER    geheim123                                # Mandant, Sprache: übersprungen

Anmeldung mit Mandant und Sprache
    Anmelden    TESTUSER    geheim123    Mandant=100    Sprache=DE
```

Wird ein optionaler Parameter nicht übergeben, bekommt `SetValue` den
Wert `$IGNORE` — der Schritt wird übersprungen. Wird er übergeben, wird
das Feld ganz normal befüllt.

!!! note "Reihenfolge der Parameter"
    In Robot Framework müssen Parameter mit Standardwert **nach** den
    Pflichtparametern stehen. Deshalb stehen `Mandant` und `Sprache` am
    Ende der Parameterliste — die Reihenfolge der `SetValue`-Zeilen im
    Keyword folgt trotzdem der Maske.

**Warum?** Ohne `$IGNORE` bräuchte das Keyword IF-Anweisungen für jedes
optionale Feld — oder man bräuchte mehrere Varianten des Keywords. Mit
`$IGNORE` bleibt **ein** Keyword linear und deckt alle Fälle ab — kein
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

Alle `Verify*`-Keywords unterstützen drei Modi zur Wertprüfung. Der Modus
wird über die **Endung des Keywords** gewählt: ohne Endung = EXACT,
`…WCM` = Wildcard, `…REGX` = regulärer Ausdruck.

### EXACT — Exakter Vergleich (Standard)

```robot
OKW.VerifyValue    Benutzername    admin
```

Der Wert muss exakt `admin` sein.

### WCM — Wildcard

```robot
OKW.VerifyValueWCM    Meldung    Anmeldung erfolgreich*
OKW.VerifyValueWCM    Datum      ??.??.2026
```

| Zeichen | Bedeutung |
|---|---|
| `*` | Beliebig viele beliebige Zeichen |
| `?` | Genau ein beliebiges Zeichen |

### REGX — Regulärer Ausdruck

```robot
OKW.VerifyValueREGX    Telefon    \\+49\\s\\d{3,4}\\s\\d+
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
