# Keywords

## Ein Satz Keywords für alle Technologien

OKW definiert einen festen Satz von Keywords, die in **allen** GUI-Bibliotheken
identisch funktionieren. Der Test spricht eine einheitliche Sprache —
die Technologie dahinter ist austauschbar.

## Übersicht

### Anwendungs-Steuerung

| Keyword | Parameter | Zweck |
|---|---|---|
| `StartApp` | AppName | Anwendung starten (definiert in YAML) |
| `StopApp` | | Anwendung beenden |
| `SelectWindow` | WindowName | Fenster/Dialog auswählen |
| `SetContext` | ContextName, Wert | Kontext für wiederholende Strukturen setzen |

### Eingabe-Keywords (GUI-Zustand ändern)

#### Ohne Wert (Aktion auf Widget)

| Keyword | Parameter | Zweck |
|---|---|---|
| `ClickOn` | Widget | Widget anklicken |
| `DoubleClickOn` | Widget | Widget doppelklicken |
| `MoveOver` | Widget | Maus über Widget bewegen (Hover) |
| `Delete` | Widget | Feldinhalt löschen |
| `SelectMenu` | Widget | Menüeintrag anklicken (Toggle) |

#### Mit Wert (Einzelwert-Eingabe)

| Keyword | Parameter | Zweck |
|---|---|---|
| `SetValue` | Widget, Wert | Wert setzen (Text eingeben, Checkbox setzen) |
| `TypeKey` | Widget, Wert | Text eintippen (ohne vorheriges Löschen) |
| `Select` | Widget, Wert | Einzelnen Eintrag auswählen (ComboBox, RadioButton) |
| `SelectMenu` | Widget, Wert | Menüeintrag auf Zustand setzen (Checked/Unchecked) |

#### Mehrfach-Auswahl (Listen)

| Keyword | Parameter | Zweck |
|---|---|---|
| `Select` | Widget, Wert₁ / Wert₂ / ... | Mehrere Einträge auswählen (ListBox) |

### Lese-Keywords (GUI-Zustand prüfen)

| Keyword | Parameter | Zweck |
|---|---|---|
| `VerifyValue` | Widget, Erwartet | Wert prüfen (mit Match Mode) |
| `VerifyCaption` | Widget, Erwartet | Sichtbaren Text/Beschriftung prüfen |
| `VerifyTooltip` | Widget, Erwartet | Tooltip-Text prüfen |
| `VerifyExists` | Widget, YES/NO | Existenz prüfen |
| `LogValue` | Widget | Aktuellen Wert ins Protokoll schreiben |
| `LogCaption` | Widget | Sichtbaren Text ins Protokoll schreiben |
| `MemorizeValue` | Widget, Schlüssel | Wert für späteren Zugriff speichern |

### Tabellen-Keywords

Tabellen haben eigene Keywords, die über Zeile/Spalte oder Spaltenüberschriften adressieren:

#### Eingabe

| Keyword | Parameter | Zweck |
|---|---|---|
| `ClickOnTableCell` | Tabelle, Zeile, Spalte | Zelle anklicken |
| `ClickOnTableCellByHeaders` | Tabelle, Zeile, Spaltenname | Zelle anklicken (per Spaltenüberschrift) |
| `DoubleClickOnTableCell` | Tabelle, Zeile, Spalte | Zelle doppelklicken |
| `DoubleClickOnTableCellByHeaders` | Tabelle, Zeile, Spaltenname | Zelle doppelklicken (per Spaltenüberschrift) |
| `SetTableCellValue` | Tabelle, Zeile, Spalte, Wert | Zellenwert setzen |
| `SetTableCellValueByHeaders` | Tabelle, Zeile, Spaltenname, Wert | Zellenwert setzen (per Spaltenüberschrift) |

#### Lesen und Prüfen

| Keyword | Parameter | Zweck |
|---|---|---|
| `VerifyTableCellValue` | Tabelle, Zeile, Spalte, Erwartet | Zellenwert prüfen |
| `VerifyTableCellValueByHeaders` | Tabelle, Zeile, Spaltenname, Erwartet | Zellenwert prüfen (per Spaltenüberschrift) |
| `VerifyTableRowContent` | Tabelle, Zeile, Erwartet₁ / ... | Zeileninhalt prüfen |
| `VerifyTableColumnContent` | Tabelle, Spalte, Erwartet₁ / ... | Spalteninhalt prüfen |
| `VerifyTableContent` | Tabelle, Erwartet (Matrix) | Gesamte Tabelle prüfen |
| `VerifyTableHasRow` | Tabelle, Erwartet₁ / ... | Prüfen ob Zeile existiert |
| `VerifyTableRowCount` | Tabelle, Erwartet | Zeilenanzahl prüfen |
| `VerifyTableColumnCount` | Tabelle, Erwartet | Spaltenanzahl prüfen |
| `LogTableCellValue` | Tabelle, Zeile, Spalte | Zellenwert ins Protokoll |
| `MemorizeTableCellValue` | Tabelle, Zeile, Spalte, Schlüssel | Zellenwert merken |

## Low-Level vs. High-Level Keywords (ISO/IEC/IEEE 29119-5)

OKW übernimmt die Keyword-Terminologie aus **ISO/IEC/IEEE 29119-5:2024**
(*Software Testing — Part 5: Keyword-driven testing*) statt eigener
Begriffe — damit ist die Einordnung normativ belegt, nicht nur
Konvention.

| ISO-Begriff (§) | Definition (sinngemäß) | Entspricht bei OKW |
|---|---|---|
| **low-level keyword** (§3.14) | Deckt nur eine oder wenige einfache Aktionen ab, ist **nicht** aus anderen Keywords zusammengesetzt | Die eingebauten OKW-Keywords selbst: `SetValue`, `ClickOn`, `VerifyValue`, ... (siehe Übersicht oben) |
| **high-level keyword** (§3.7) | Komplexe, aus anderen Keywords komponierbare Aktivität, gedacht für Domänenexperten | Ein **Robot-Framework-User-Keyword**, das mehrere OKW-Keywords zu einem Geschäftsvorfall kombiniert (z.B. `Anmelden` als Wrapper um `SetValue`+`SetValue`+`ClickOn`) |
| **composite keyword** (§3.2) | Strukturmerkmal: besteht aus ≥2 anderen Keywords (unabhängig von der Abstraktionsebene) | Jedes User-Keyword, das andere Keywords aufruft — kann selbst wieder low-level oder high-level sein |

**Wichtig:** *composite* ist ein reines Bauprinzip ("woraus besteht es"),
*high-level/low-level* beschreibt die Abstraktionsebene ("wer benutzt
es"). Ein composite keyword kann technisch bleiben (Zwischenschicht)
oder geschäftsseitig sein (Domänenschicht) — beides ist laut Norm
zulässig. Auch ein **Testfall** ist im Grunde ein composite keyword —
er besteht aus einer Folge von Keywords, die zusammen einen
Geschäftsvorfall abbilden.

**Konsequenz für OKW:** Die Bibliothek selbst liefert ausschließlich
**low-level keywords** — das ist bewusst so, siehe [Signal vs.
NOISE](signal-vs-noise.md).

> OKW liefert die Ziegelsteine (low-level keywords), nicht das
> fertige Gebäude. Welche Baugruppen (high-level/composite keywords)
> daraus entstehen, entscheidet jedes Projekt selbst — OKW kennt das
> Gebäude gar nicht. High-level/composite Keywords entstehen
projektspezifisch über Robot Framework `*** Keywords ***`-Definitionen,
die OKW-Keywords kombinieren:

!!! warning "Empfehlung: Testfälle direkt aus Low-Level Keywords"
    Testfälle, die direkt aus Low-Level Keywords bestehen, bilden
    **jede Benutzeraktion als eigene Zeile** ab. Das macht sie
    als Sequenz am leichtesten nachvollziehbar — sowohl für den
    Autor als auch für Reviewer und bei der Fehleranalyse.

    Verschachtelte High-Level Keywords (Keyword ruft Keyword ruft
    Keyword) werden ab der zweiten Ebene schwer nachvollziehbar:
    Man muss in jedes Keyword hineinspringen, um den tatsächlichen
    Ablauf zu verstehen. Das ist **NOISE** — nicht im Testcode
    selbst, sondern im Kopf des Lesers.

    High-Level Keywords sind trotzdem nützlich — z. B. als
    Setup/Teardown oder für wiederkehrende Navigationsblöcke.
    Aber der **Testkern** (Eingabe + Prüfung) sollte aus
    Low-Level Keywords bestehen, damit die Benutzeraktivitäten
    transparent bleiben.

```robot
*** Keywords ***
Anmelden
    [Arguments]    ${Benutzer}    ${Kennwort}
    OKW.SetValue       Benutzer     ${Benutzer}
    OKW.SetValue        Kennwort    ${Kennwort}
    OKW.ClickOn         Anmelden
```

`Anmelden` ist hier ein high-level/composite keyword im Sinne der
Norm — zusammengesetzt aus drei OKW-low-level-keywords, für
Domänenexperten lesbar, ohne dass OKW selbst dafür ein eigenes
Sprachkonstrukt bräuchte. Robot Framework liefert den
Komposition-Mechanismus bereits nativ.

## CamelCase-Konvention

Keywords werden immer als **CamelCase ohne Leerzeichen** geschrieben:

```robot
SetValue       Benutzer    admin       # Richtig
Set Value      Benutzer    admin       # Falsch — Leerzeichen
set_value      Benutzer    admin       # Falsch — Snake Case
```

**Warum?** In Robot Frameworks tabulatorgetrenntem Format können
Leerzeichen mit Parametertrennern verwechselt werden. CamelCase ist
eindeutig.

## Keyword-Aufruf mit Bibliotheks-Prefix

OKW-Keywords werden immer mit dem Bibliotheks-Prefix `OKW.` aufgerufen:

```robot
*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW

*** Test Cases ***
Mein Test
    OKW.SetValue       Benutzername    admin
    OKW.ClickOn        Anmelden
    OKW.VerifyValue    Willkommen      Hallo admin
```

Das `WITH NAME OKW` in der Library-Zeile definiert den Prefix.
So ist sofort klar, welche Keywords zu OKW gehören.

## Beispiel: Gleicher Test, drei Technologien

Der gleiche Test funktioniert mit verschiedenen Treibern — nur die
YAML-Datei und die Library-Zeile ändern sich:

=== "Web Selenium"

    ```robot
    Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW
    ```

=== "SAP GUI"

    ```robot
    Library    okw_sap_gui.library.OkwSapGuiLibrary    WITH NAME    OKW
    ```

=== "Java Swing"

    ```robot
    Library    okw_java_remoteswing.library.OkwJavaRemoteSwingLibrary    WITH NAME    OKW
    ```

Der Testkörper bleibt identisch:

```robot
*** Test Cases ***
Anmeldung
    OKW.StartApp       MeineApp
    OKW.SelectWindow   Login
    OKW.SetValue       Benutzer    admin
    OKW.SetValue       Kennwort    geheim
    OKW.ClickOn        Anmelden
    OKW.StopApp
```
