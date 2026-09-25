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

**Gegenbeispiel — `TypeKey` hängt an:**

```robot
TypeKey        Benutzername    admin
VerifyValue    Benutzername    admin
TypeKey        Benutzername    admin
VerifyValue    Benutzername    adminadmin    # Ergebnis: "adminadmin"
```

`TypeKey` tippt den Text zusätzlich ein, ohne das Feld vorher zu leeren.
Jeder weitere Aufruf verändert den Zustand — `TypeKey` ist **nicht**
idempotent.

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
| `ClickOn` | Button „Speichern" | **Bedingt** | Je nach Anwendung: zweiter Datensatz, Meldung „keine Änderungen“ oder dieselbe Aktion |
| `ClickOn` | Button „OK“ / „Abbrechen“ im Dialog | **Nein** | Der Dialog schließt sich — ein zweiter Klick findet das Objekt nicht mehr |
| `ClickOn` | Checkbox | **Nein** | Toggle: AN → AUS → AN → ... — idempotent ist dagegen `SetValue AGB Checked`; in der Navigation bevorzugen |
| `ClickOn` | Akkordeon-Panel | **Nein** | Toggle: Auf → Zu → Auf → ... |

**Merksatz:** Ein Keyword ist nicht idempotent, wenn es den Zustand
der Anwendung so ändert, dass derselbe Aufruf danach anders ausgeht —
oder das GUI-Objekt gar nicht mehr findet („Objekt nicht vorhanden“).

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

## Idempotenz im 5-Phasen-Modell

Die entscheidende Regel gilt nicht für einzelne Keywords, sondern
für den **Weg in den Testzustand**:

> Auf Idempotenz achtet man, wenn der **Ausgangszustand** eines
> Objekts **unbekannt** sein könnte und man sicherstellen will, dass
> man es anschließend **garantiert in einem bestimmten Zustand
> verlässt**.

Ein OKW-Testfall hat fünf Phasen:

| # | Phase | Inhalt | Idempotent? |
|---|---|---|---|
| 1 | Umgebung initialisieren / Reset | Zustand zurücksetzen, z. B. Daten eines früheren Laufs löschen | **Muss** |
| 2 | Testdaten einspielen | Benötigte Daten anlegen | **Muss** |
| 3 | Navigation in Testzustand | Zum richtigen Fenster/Dialog gelangen | **Muss** |
| 4 | Aktion ausführen | Werte eingeben und Verarbeitung auslösen | Darf nicht-idempotent sein |
| 5 | Akzeptanzkriterium prüfen | Ergebnis verifizieren | Immer — `Verify*` liest nur |

Die Phasen 1–3 bringen die Anwendung aus einem **beliebigen**
Ausgangszustand sicher in den Testzustand — deshalb müssen sie
idempotent sein. So erreicht der Test bei jedem Durchlauf denselben
Zustand und prüft dasselbe Ergebnis, egal wie oft er läuft.

!!! info "Fehler außerhalb von Phase 4 und 5 sind meist NOISE"
    Tritt ein Fehler **außerhalb von Phase 4 oder 5** auf, handelt es
    sich mit hoher Wahrscheinlichkeit um **NOISE** — der eigentliche
    Test wurde gar nicht erreicht. Deshalb werden die Schritte der
    Phasen 1–3 mit [`OnFailNOISE`](../gui/web-selenium/index.md#onfailnoise)
    abgesichert: Ein Fehler dort markiert den Testfall als NOISE, nicht
    als SUT-Fehler. Das 5-Phasen-Modell ermöglicht so eine schnelle
    Erstklassifikation von Testergebnissen.

**Beispiel — idempotenter Testzustand:**

```robot
*** Test Cases ***
Login mit gültigem Benutzer
    # Phase 3: Navigation (idempotent)
    OKW.StartApp        MeineApp
    OKW.SelectWindow    Login

    # Phase 4: Aktion ausführen
    OKW.SetValue        Benutzer    admin       # idempotent
    OKW.SetValue        Kennwort    geheim      # idempotent
    OKW.ClickOn         Anmelden                # nicht idempotent: Login-Seite verschwindet

    # Phase 5: Akzeptanzkriterium prüfen (immer idempotent)
    OKW.SelectWindow    Dashboard
    OKW.VerifyValue     Willkommen    Hallo admin

    OKW.StopApp
```

Die Eingaben setzen einen definierten Zustand — nichts hängt davon
ab, was vorher im Feld stand oder ob der Test schon einmal gelaufen
ist. `ClickOn Anmelden` ist für sich **nicht** idempotent: Nach dem
Klick ist die Login-Seite verschwunden, ein zweiter Klick fände den
Button nicht mehr. Das ist in Ordnung — der Klick gehört zur Aktion
(Phase 4), läuft pro Durchlauf genau einmal, und `SelectWindow Dashboard` bestätigt den neuen Zustand.
**In Summe** ist der Testfall idempotent: Er startet mit `StartApp`
jedes Mal im selben Zustand.

## Signal vs. NOISE

Nicht-idempotente Keywords sind wichtig — sie lösen den eigentlichen
Test aus. Ein `ClickOn Speichern` oder `DoubleClickOn Datensatz` ist
die **Testaktion** selbst. Das ist **Signal**.

Aber in den Phasen **Initialisieren, Testdaten und Navigation** sind
nicht-idempotente Schritte ein potenzieller **NOISE-Erzeuger**: Hängen
sie vom Ausgangszustand ab, kann der Test bei Wiederholung scheitern —
nicht weil der Test falsch ist, sondern weil der Weg in den
Testzustand fragil ist.

| Phase | Idempotent? | Warum |
|---|---|---|
| 1–3: Initialisieren, Testdaten, Navigation | **Muss** idempotent sein | Sonst NOISE: Testfehler durch fragilen Weg in den Testzustand |
| 4: Aktion ausführen | Darf nicht-idempotent sein | Das **ist** der Test — Signal |
| 5: Akzeptanzkriterium prüfen | Immer idempotent | `Verify*` liest nur, verändert nichts |

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

> **Phasen 1–3** (Initialisieren, Testdaten, Navigation) → idempotente Keywords verwenden.
> **Phase 4** (Aktion ausführen) → das richtige Keyword für die Aktion (darf nicht-idempotent sein).
> **Phase 5** (Akzeptanzkriterium prüfen) → `Verify*` (immer idempotent).

!!! tip "Faustregel für die Testerstellung"
    1. **Testzustand sicher und einfach erreichen** — die Schritte der
       Phasen 1–3 so wählen, dass sie funktionieren, **egal welcher
       Zustand vorher bestand**.
    2. **Im Testzustand** (Phase 4) sind nicht-idempotente Eingaben legitim, wenn
       sie gezielt eine Funktion stimulieren — z. B. Tastatursteuerung:

        ```robot
        TypeKey         Suchfeld          Rob     # Eintippen löst die Vorschlagsliste aus
        VerifyExists    Vorschlagsliste   YES
        ```

        Auf jeden nicht-idempotenten Schritt folgt **unmittelbar eine
        Prüfung**: Die Reaktion des Systems wird gegen das erwartete
        Ergebnis gehalten. Dieser Prüfschritt ist das eigentliche Signal.

    3. Ob ein nicht-idempotenter Schritt sinnvoll ist, muss **im
       Einzelfall** überlegt werden. Wichtig ist zunächst, die
       Unterschiede zu kennen.
