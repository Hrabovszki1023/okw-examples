# SAP GUI Logon -- OKW SAP GUI Examples

Tests against the SAP Logon screen using the OKW4Robot SAP GUI driver.

> **Requires a running SAP system.** These tests cannot run in CI
> without a SAP GUI for Windows installation and an active SAP connection.

## Prerequisites

- Windows 10/11
- SAP GUI for Windows 7.70+
- SAP GUI Scripting enabled (`RZ11`: `sapgui/user_scripting` = `TRUE`)
- An open SAP connection

## Install

```bash
pip install robotframework-okw-sap-gui
```

## Run

```bash
robot tests/SapLogon.robot
```

## What the Tests Show

| Test | Keywords Used |
|---|---|
| SAP Anmeldung mit gueltigem Benutzer | SetValue, ClickOn, VerifyCaption (StatusBar type) |
| SAP Anmeldung mit falschem Kennwort | VerifyCaption (E=Error), VerifyValue (text) |
| SAP Anmeldung mit IGNORE Token | $IGNORE token to skip steps |

## Signal vs. NOISE

```robot
# NOISE -- SAP GUI Scripting direkt:
session.FindById("wnd[0]/usr/txtRSYST-BNAME").Text = "TESTUSER"
session.FindById("wnd[0]/usr/pwdRSYST-BCODE").Text = "geheim123"
session.FindById("wnd[0]/tbar[0]/btn[0]").Press()

# SIGNAL -- OKW:
SetValue    Benutzer    TESTUSER
SetValue    Kennwort    geheim123
ClickOn     Anmelden
```
