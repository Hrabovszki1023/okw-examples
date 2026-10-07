# Autonome Testfälle

## Was autonom bedeutet

Ein Testfall ist **autonom**, wenn sein Ergebnis nur vom SUT abhängt und
nicht davon, welche anderen Testfälle vorher gelaufen sind. Er erfüllt
vier Bedingungen:

| # | Bedingung | Prüffrage |
|---|---|---|
| 1 | **Allein lauffähig** | Läuft der Test, wenn man nur ihn startet? |
| 2 | **Reihenfolgeunabhängig** | Liefert er dasselbe Ergebnis, egal an welcher Stelle der Suite er läuft? |
| 3 | **Stellt seinen Ausgangszustand selbst her** | Holt er sich Daten, Anmeldung und Fenster selbst, statt sie von einem Vorgänger zu übernehmen? |
| 4 | **Hinterlässt nichts, was andere brauchen** | Kann ein anderer Test scheitern, weil dieser Test fehlt, rot ist oder etwas nicht aufgeräumt hat? |

Das Gegenteil ist die **Verkettung**: Ein Testfall baut auf dem Ergebnis
oder dem Zustand eines anderen auf.

## Warum das für das Signal entscheidend ist

Die Seite [Strong Signal](strong-signal.md) beschreibt, wie ein Testfall
geschrieben sein muss, damit sein Ergebnis eindeutig einem fachlichen
Aspekt zugeordnet werden kann. Autonomie ist die Voraussetzung dafür:
Ein verketteter Testfall kann noch so sauber geschrieben sein, sein
Ergebnis hängt trotzdem von fremden Testfällen ab.

Besonders deutlich wird das, wenn etwas schiefgeht. Ein autonomer
Testfall, der an der Vorbereitung scheitert, sagt präzise: **Genau
dieser** Aspekt wurde in diesem Lauf nicht getestet. Darauf lässt sich
eine Entscheidung stützen, etwa trotzdem auszuliefern, weil das Risiko
klein ist (siehe
[Auch „nicht getestet“ ist eine Information](strong-signal.md#auch-nicht-getestet-ist-eine-information)).

In einer Kette geht diese Information verloren:

| | Autonom | Verkettet |
|---|---|---|
| Test 3 von 10 scheitert | Test 3 ist rot, 4 bis 10 laufen normal | Test 3 ist rot, 4 bis 10 sind **ebenfalls rot** oder laufen gar nicht |
| Welche Aspekte sind ungeprüft? | Genau einer, er steht im Testfall-Namen | Unklar, muss aus der Kette rekonstruiert werden |
| Wie sieht ein Folgefehler aus? | Gibt es nicht | Wie ein Fehler in der **eigenen** Funktion des Folgetests |
| Ergebnis | Ein F oder ein N | Aus einem N werden viele **scheinbare F** |

## Was Verkettung außerdem kostet

Neben dem verlorenen Signal verursacht eine Kette laufende Kosten, die
erst im Alltag auffallen:

| Kosten | Was passiert | Beispiel |
|---|---|---|
| **Erzwungene Vollständigkeit** | Wer einen Test aus der Mitte der Kette braucht, muss alle Vorgänger mitlaufen lassen, auch wenn sie mit der aktuellen Frage nichts zu tun haben. | Um nur `Note Loeschen` nach einer Korrektur erneut zu prüfen, müssen `Login Erfolgreich` und `Note Erstellen Und Pruefen` mitlaufen. |
| **Verwaltungsaufwand** | Vorgänger und Nachfolger müssen gepflegt werden: in der Reihenfolge der Datei, in Namenskonventionen oder als Abhängigkeiten im Testmanagement-Werkzeug. Diese Beziehungen sind nirgends geprüft und veralten still. | Ein neuer Test wird „irgendwo dazwischen“ eingefügt und verschiebt, was seine Nachfolger vorfinden. |
| **Wartungsaufwand** | Eine Änderung an einer Stelle zieht Anpassungen in vielen Testfällen nach sich. Wird ein Glied der Kette geändert, umbenannt oder entfernt, brechen alle, die danach kommen. | Fällt `Note Erstellen Und Pruefen` weg, weil die Funktion anders getestet wird, sind `Note Lesen`, `Note Aktualisieren` und `Note Loeschen` sofort rot. |

Bei autonomen Testfällen entfallen alle drei: Jeder Test lässt sich
einzeln starten, es gibt keine Beziehungen zu pflegen, und eine
Änderung an der Vorbereitung betrifft genau ein High-Level Keyword wie
`Erzeuge Testnotiz`, nicht die Reihenfolge der Testfälle.

## Formen der Verkettung

Verkettung ist nicht immer offensichtlich. Vier Formen kommen in der
Praxis vor:

| Form | Beispiel | Wie man sie erkennt |
|---|---|---|
| **Daten-Verkettung** | Test A legt einen Datensatz an und merkt sich die ID, Test B liest ihn | Ein Test verwendet einen Wert, den er nicht selbst erzeugt hat |
| **Zustands-Verkettung** | Test A meldet sich an, Test B arbeitet in derselben Sitzung weiter | Ein Test beginnt ohne `StartApp` oder ohne Anmeldung |
| **Reihenfolge-Verkettung** | Tests heißen `01_Anlegen`, `02_Ändern`, `03_Löschen` | Nummern im Testfall-Namen |
| **Versteckte Verkettung** | Test A räumt nicht auf, Test B stolpert über die Reste | Tests laufen allein grün, im Verbund rot |

Die versteckte Form ist die gefährlichste, weil niemand sie
beabsichtigt hat. In diesem Repository standen `StopApp` früher als
letzte Zeile in den SauceDemo-Testfällen. Scheiterte ein Test, blieb
der Browser offen, und die folgenden Sortier-Tests wurden rot, obwohl
sie allein grün liefen (siehe [Strong Signal](strong-signal.md#3-keine-unnotigen-schritte)).

## Beispiel aus diesem Repository

Der REST-Integrationstest gegen die Notes-API von expandtesting.com ist
als Kette aufgebaut. Ein Test legt eine Notiz an und merkt sich ihre ID,
die folgenden Tests arbeiten mit dieser ID weiter:

```robot
*** Test Cases ***
Note Erstellen Und Pruefen
    [Setup]    Login Ausfuehren
    RESTSelectEndpoint     /notes
    ...
    RESTSendRequest        POST
    RESTVerifyStatus       200
    RESTMemorizeValue      data.id      NOTE_ID

Note Lesen
    [Setup]    Login Ausfuehren
    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        GET
    RESTVerifyStatus       200
    RESTVerifyValue        data.title       OKW Testnotiz
```

`Note Lesen` erzeugt `NOTE_ID` nicht selbst, sondern übernimmt sie von
`Note Erstellen Und Pruefen`. Was das bedeutet, zeigt ein Versuch mit
drei Ausführungsarten:

| Ausführung | Ergebnis von `Note Lesen` |
|---|---|
| Normale Reihenfolge | grün |
| Zufällige Reihenfolge (`--randomize tests`) | rot: `Memorized key not found: NOTE_ID` |
| Nur dieser Test (`--test "Note Lesen"`) | rot: `Memorized key not found: NOTE_ID` |

Das Lesen von Notizen funktioniert in allen drei Fällen. Rot ist der
Test trotzdem, und die Meldung sagt nichts über das SUT aus. Das ist
ein **N**, das im Testreport aussieht wie ein Fehler beim Lesen.

### Autonome Fassung

Jeder Testfall legt seine Notiz selbst an und räumt sie wieder weg:

```robot
*** Test Cases ***
Note Lesen
    [Setup]       Erzeuge Testnotiz    OKW Testnotiz
    [Teardown]    Loesche Testnotiz

    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        GET

    RESTVerifyStatus       200
    RESTVerifyValue        data.title       OKW Testnotiz

*** Keywords ***
Erzeuge Testnotiz
    [Arguments]    ${titel}
    Login Ausfuehren
    RESTSelectEndpoint     /notes
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSetValue           title        ${titel}
    RESTSetValue           description  Vorbereitung
    RESTSetValue           category     Work
    RESTSendRequest        POST
    RESTVerifyStatus       200
    RESTMemorizeValue      data.id      NOTE_ID

Loesche Testnotiz
    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        DELETE
```

Scheitert jetzt das Anlegen der Notiz, meldet Robot Framework
`Setup failed` und führt den Testrumpf gar nicht erst aus. Das Ergebnis
lautet dann eindeutig: „Lesen in diesem Lauf nicht geprüft“, nicht
„Lesen kaputt“.

!!! note "Stand im Repository"
    Die autonome Fassung ist ein Vorschlag. Im Repository steht der
    REST-Integrationstest derzeit noch in der verketteten Form.

## Setup und Teardown richtig einsetzen

Robot Framework bietet Vorbereitung und Aufräumen auf zwei Ebenen. Die
Faustregel: Was ein Test **verändert**, gehört auf Testebene. Was alle
Tests nur **lesen**, darf auf Suite-Ebene.

| Ebene | Geeignet für | Beispiele aus diesem Repository |
|---|---|---|
| `Suite Setup` / `Suite Teardown` | Umgebung und Daten, die kein Test verändert | Kafka-Broker starten, Testbenutzer für die Notes-API anlegen |
| `Test Setup` / `Test Teardown` | Zustand, den der Test verändert oder für sich braucht | Browser starten und Login-Seite öffnen, Browser schließen |
| `[Setup]` / `[Teardown]` im Testfall | Vorbereitung, die nur dieser Test braucht | Eine Notiz anlegen, die nur dieser Test liest |

Zwei Regeln verhindern die versteckte Verkettung:

- **Aufräumen immer im Teardown.** Der Teardown läuft auch nach einem
  Fehler, die letzte Zeile im Testfall nicht.
- **Vorbereitung idempotent halten.** Der Test muss seinen
  Ausgangszustand aus **jedem** Vorzustand erreichen, auch wenn ein
  früherer Lauf abgebrochen ist (siehe [Idempotenz](idempotenz.md)).

## „Aber das dauert doch länger“

Der häufigste Einwand: Wenn sich jeder Test selbst anmeldet und seine
Daten selbst anlegt, läuft die Suite länger. Das stimmt, aber:

- **Autonome Tests lassen sich parallelisieren.** Verkettete nicht. Mit
  einem Werkzeug wie `pabot` wird die Suite dadurch meist **schneller**
  als die Kette.
- **Vorbereitung muss nicht über die GUI laufen.** Testdaten per API
  anzulegen oder die Anmeldung abzukürzen ist eine Frage der
  [Steuerbarkeit](testbarkeit.md), nicht der Autonomie.
- **Analysezeit ist teurer als Laufzeit.** Eine Minute mehr Laufzeit
  kostet Rechenzeit. Eine Stunde, um zehn rote Folgetests auf eine
  Ursache zurückzuführen, kostet einen Menschen.
- **Einzelne Tests lassen sich wiederholen.** `robot --rerunfailed`
  startet nur die roten Tests neu. Das funktioniert nur, wenn sie
  allein lauffähig sind.

## Autonomie prüfen

Robot Framework bringt alles mit, um Verkettung aufzudecken:

```bash
robot --randomize tests tests/
```

```bash
robot --test "Note Lesen" tests/
```

```bash
robot --rerunfailed output.xml tests/
```

Läuft eine Suite in zufälliger Reihenfolge anders als in der normalen,
oder scheitert ein Test, wenn man ihn allein startet, ist er verkettet.
Ein Lauf mit `--randomize tests` in der CI deckt neue Verkettungen auf,
bevor sie sich festsetzen.

## Checkliste

!!! tip "Autonomie-Checkliste"
    - Der Test verwendet keine Werte, die ein anderer Test erzeugt hat.
    - Der Test startet die Anwendung und meldet sich selbst an (im Setup).
    - Kein Testfall-Name enthält eine Reihenfolgenummer.
    - Aufräumen steht im Teardown, nicht als letzte Zeile im Testfall.
    - Suite-Setup enthält nur, was kein Test verändert.
    - Die Suite ist mit `--randomize tests` grün.
    - Jeder Test ist mit `--test "<Name>"` allein grün.
