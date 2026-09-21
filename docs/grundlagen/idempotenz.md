# Idempotenz

## Was bedeutet idempotent?

Ein Keyword ist **idempotent**, wenn es bei wiederholtem Aufruf mit
denselben Parametern immer dasselbe Ergebnis liefert — unabhängig
vom Zustand des Zielobjektes vorher und ohne unerwünschte
Seiteneffekte.

> Einmal ausführen oder zehnmal ausführen — das Ergebnis ist dasselbe.

## Warum ist das wichtig?

Tests müssen **stabil** und **wiederholbar** sein. Wenn ein Keyword
bei jedem Aufruf etwas anderes bewirkt, wird der Test unzuverlässig.
Idempotente Keywords sind:

- **Wiederholbar** — Ein fehlgeschlagener Test kann ohne Aufräumarbeit
  erneut gestartet werden.
- **Reihenfolge-tolerant** — Einzelne Schritte können verschoben werden,
  ohne das Ergebnis zu verändern.
- **Robust gegen Retry** — Timeout-basiertes Polling (z. B. bei
  `VerifyValue`) funktioniert nur, wenn der Prüfschritt idempotent ist.

## Idempotente Keywords in OKW

### SetValue — Zustand setzen, nicht anhängen

`SetValue` setzt den Wert eines Widgets auf den angegebenen Wert.
Egal was vorher im Feld stand:

```robot
SetValue    Benutzername    admin
SetValue    Benutzername    admin    # Ergebnis: immer noch "admin"
```

Das Feld wird **nicht** doppelt beschrieben — der Zustand nach dem
Aufruf ist immer derselbe.

### SelectMenu — Zustand idempotent setzen

Ohne Wert ist `SelectMenu` ein **Toggle** (nicht idempotent):

```robot
SelectMenu    Statusleiste              # Toggle: AN → AUS → AN → ...
```

Mit Wert wird `SelectMenu` **idempotent** — es setzt den gewünschten
Zustand, egal was der aktuelle ist:

```robot
SelectMenu    Statusleiste    Checked     # Ergebnis: immer AN
SelectMenu    Statusleiste    Checked     # Ergebnis: immer noch AN
SelectMenu    Statusleiste    Unchecked   # Ergebnis: immer AUS
```

### Delete — Inhalt löschen

`Delete` leert den Inhalt eines Widgets. Egal was vorher drin stand,
danach ist es leer:

```robot
Delete    Benutzername              # Feld ist leer
Delete    Benutzername              # Feld ist immer noch leer
```

### Select — Auswahl setzen

`Select` wählt einen Eintrag aus. Wird derselbe Eintrag nochmal
ausgewählt, ändert sich nichts:

```robot
Select    Land    Deutschland
Select    Land    Deutschland    # Ergebnis: immer noch "Deutschland"
```

### Verify-Keywords — reine Prüfung

Alle `Verify*`-Keywords sind per Definition idempotent — sie lesen
nur und verändern nichts:

```robot
VerifyValue    Status    Aktiv     # Prüft, verändert nichts
VerifyValue    Status    Aktiv     # Gleiches Ergebnis
```

## Idempotenz hängt vom GUI-Objekt ab

Ob ein Keyword idempotent ist, bestimmt nicht nur das Keyword —
sondern auch das **GUI-Objekt**, auf das es wirkt.

Das gleiche Keyword `ClickOn` kann je nach Zielobjekt idempotent
oder nicht idempotent sein:

| Keyword | GUI-Objekt | Idempotent? | Warum |
|---|---|---|---|
| `ClickOn` | Menüeintrag | **Ja** | Öffnet immer dieselbe Funktion |
| `ClickOn` | Button „Speichern" | **Ja** | Löst immer dieselbe Aktion aus |
| `ClickOn` | Checkbox | **Nein** | Toggle: AN → AUS → AN → ... |
| `ClickOn` | Akkordeon-Panel | **Nein** | Toggle: Auf → Zu → Auf → ... |

!!! warning "Im Testfall genau überlegen"
    Bei der Testerstellung muss man für **jeden Schritt** prüfen:
    Ist dieses Keyword auf **diesem** GUI-Objekt idempotent?
    Wenn nicht — gibt es eine idempotente Alternative?

    | Nicht idempotent | Idempotente Alternative |
    |---|---|
    | `ClickOn AGB` (Checkbox) | `SetValue AGB YES` |
    | `SelectMenu Statusleiste` (Toggle) | `SelectMenu Statusleiste Checked` |

## Nicht-idempotente Keywords

Einige Keywords sind grundsätzlich **nicht** idempotent, unabhängig
vom GUI-Objekt:

| Keyword | Warum nicht idempotent |
|---|---|
| `TypeKey` | Hängt Text an, statt zu ersetzen |
| `DoubleClickOn` | Doppelklick öffnet z. B. einen Editor — Wiederholung kann schließen |

## Der Testzustand muss idempotent sein

Die entscheidende Regel gilt nicht für einzelne Keywords, sondern
für die **gesamte Navigation zum Testzustand**:

> Alle Schritte vom Start bis zur Prüfung müssen **in Summe
> idempotent** sein.

Ein Testfall hat typisch drei Phasen:

```
1. Navigation    →  Zum richtigen Fenster/Dialog gelangen
2. Aktion        →  Den Test auslösen (Eingabe, Klick, ...)
3. Prüfung       →  Ergebnis verifizieren
```

Die Phasen 1 + 2 + 3 zusammen müssen idempotent sein — der Test
muss bei jedem Durchlauf denselben Zustand erreichen und dasselbe
Ergebnis prüfen, egal wie oft er läuft.

**Beispiel — idempotenter Testzustand:**

```robot
*** Test Cases ***
Login mit gültigem Benutzer
    OKW.StartApp        MeineApp
    OKW.SelectWindow    Login

    # Navigation + Aktion (idempotent in Summe)
    OKW.SetValue        Benutzer    admin       # idempotent
    OKW.SetValue        Kennwort    geheim      # idempotent
    OKW.ClickOn         Anmelden                # idempotent (Button)

    # Prüfung (immer idempotent)
    OKW.SelectWindow    Dashboard
    OKW.VerifyValue     Willkommen    Hallo admin

    OKW.StopApp
```

Jeder einzelne Schritt setzt einen definierten Zustand — nichts
hängt davon ab, was vorher im Feld stand oder ob der Test schon
einmal gelaufen ist.

## Signal vs. NOISE

Nicht-idempotente Keywords sind wichtig — sie lösen den eigentlichen
Test aus. Ein `ClickOn Speichern` oder `DoubleClickOn Datensatz` ist
die **Testaktion** selbst. Das ist **Signal**.

Aber in der **Navigation zum Testzustand** sind nicht-idempotente
Schritte ein potenzieller **NOISE-Erzeuger**: Wenn die Navigation
zustandsabhängig ist, kann der Test bei Wiederholung scheitern —
nicht weil der Test falsch ist, sondern weil die Navigation
fragil ist.

| Phase | Idempotent? | Warum |
|---|---|---|
| Navigation | **Muss** idempotent sein | Sonst NOISE: Testfehler durch fragile Navigation |
| Testaktion | Darf nicht-idempotent sein | Das **ist** der Test — Signal |
| Prüfung | Immer idempotent | `Verify*` liest nur, verändert nichts |

**Beispiel — NOISE durch nicht-idempotente Navigation:**

```robot
# NOISE: ClickOn auf Checkbox ist nicht idempotent
# Beim zweiten Testlauf steht AGB auf AUS statt AN
ClickOn         AGB                     # Toggle: AN → AUS → AN → ...
ClickOn         Speichern               # Testaktion
VerifyValue     Status    Gespeichert   # Schlägt fehl — aber nicht wegen Speichern!
```

```robot
# Signal: SetValue ist idempotent
# Egal wie oft der Test läuft — AGB ist immer AN
SetValue        AGB       YES           # Immer AN
ClickOn         Speichern               # Testaktion
VerifyValue     Status    Gespeichert   # Stabil
```

Die Regel:

> **Navigation** → idempotente Keywords verwenden (Signal).
> **Testaktion** → das richtige Keyword für die Aktion (darf nicht-idempotent sein).
> **Prüfung** → `Verify*` (immer idempotent).
