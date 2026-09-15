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

### Schreib-Keywords (GUI-Zustand ändern)

| Keyword | Parameter | Zweck |
|---|---|---|
| `SetValue` | Widget, Wert | Wert setzen (Text eingeben, Checkbox setzen) |
| `ClickOn` | Widget | Widget anklicken |
| `DoubleClickOn` | Widget | Widget doppelklicken |
| `Select` | Widget, Wert | Eintrag auswählen (ComboBox, Menü) |
| `SelectMenu` | Widget, Wert | Menüeintrag auswählen |
| `TypeKey` | Widget, Wert | Text eintippen (ohne vorheriges Löschen) |
| `Delete` | Widget | Feldinhalt löschen |

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
