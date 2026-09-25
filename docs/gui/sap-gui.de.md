# SAP GUI

!!! info "In Bearbeitung"
    Dieses Kapitel wird noch geschrieben.

## Überblick

Die Bibliothek `robotframework-okw-sap-gui` ist der OKW-Treiber für
SAP GUI for Windows. Sie nutzt die SAP GUI Scripting COM API über
`pywin32` — kein zusätzlicher Server, keine JARs.

## Voraussetzungen

- Windows 10/11
- SAP GUI for Windows 7.70+
- SAP GUI Scripting aktiviert (`RZ11`: `sapgui/user_scripting` = `TRUE`)

## Installation

```bash
pip install robotframework-okw-sap-gui
```

## Verfügbare Widgets

| Widget-Klasse | SAP GUI Typ | Verwendung |
|---|---|---|
| `SapGui_TextField` | GuiTextField | Textfelder, Passwortfelder |
| `SapGui_Button` | GuiButton | Buttons |
| `SapGui_Label` | GuiLabel | Statische Texte |
| `SapGui_Checkbox` | GuiCheckBox | Checkboxen |
| `SapGui_ComboBox` | GuiComboBox | Dropdown-Auswahlen |
| `SapGui_Tab` | GuiTab | Tab-Reiter |
| `SapGui_StatusBar` | GuiStatusbar | Statusleiste (Text + Meldungstyp) |
| `SapGui_TCode` | virtuell | Transaktionscode-Eingabe |

## Locator-Strategien

| Strategie | YAML-Schlüssel | Beschreibung |
|---|---|---|
| Direct ID | `id` | SAP GUI Element-Pfad (`wnd[0]/usr/txtRSYST-BNAME`) |
| Horizontal Label | `hlabel` | Eingabefeld rechts neben einem Label |
| Vertical Label | `vlabel` | Eingabefeld unter einem Label |

## Lauffähige Beispiele

Siehe [sap-gui/](https://github.com/Hrabovszki1023/okw-examples/tree/master/sap-gui)
im okw-examples Repository.
