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
