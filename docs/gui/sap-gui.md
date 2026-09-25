---
source_hash: f1f48cc5f20f
---

# SAP GUI

!!! info "Work in progress"
    This chapter is still being written.

## Overview

The library `robotframework-okw-sap-gui` is the OKW driver for SAP GUI
for Windows. It uses the SAP GUI Scripting COM API via `pywin32` — no
additional server, no JARs.

## Prerequisites

- Windows 10/11
- SAP GUI for Windows 7.70+
- SAP GUI Scripting enabled (`RZ11`: `sapgui/user_scripting` = `TRUE`)

## Installation

```bash
pip install robotframework-okw-sap-gui
```

## Available Widgets

| Widget class | SAP GUI type | Usage |
|---|---|---|
| `SapGui_TextField` | GuiTextField | Text fields, password fields |
| `SapGui_Button` | GuiButton | Buttons |
| `SapGui_Label` | GuiLabel | Static texts |
| `SapGui_Checkbox` | GuiCheckBox | Checkboxes |
| `SapGui_ComboBox` | GuiComboBox | Dropdown selections |
| `SapGui_Tab` | GuiTab | Tabs |
| `SapGui_StatusBar` | GuiStatusbar | Status bar (text + message type) |
| `SapGui_TCode` | virtual | Transaction code input |

## Locator Strategies

| Strategy | YAML key | Description |
|---|---|---|
| Direct ID | `id` | SAP GUI element path (`wnd[0]/usr/txtRSYST-BNAME`) |
| Horizontal label | `hlabel` | Input field to the right of a label |
| Vertical label | `vlabel` | Input field below a label |

## Runnable Examples

See [sap-gui/](https://github.com/Hrabovszki1023/okw-examples/tree/master/sap-gui)
in the okw-examples repository.
