# Von der Testbeschreibung zum automatisierten Test -- in 5 Minuten

Wie nah kann ein automatisierter Test an einer manuellen Testbeschreibung sein?

Viele Testautomatisierungsprojekte scheitern nicht an der Technik,
sondern an der Kluft zwischen Fachsprache und Code.
Der Tester beschreibt *was* geprueft werden soll --
der Entwickler implementiert *wie*. Dazwischen geht Wissen verloren.

In diesem Beitrag zeige ich, wie OKW4Robot diese Kluft schliesst:
Die automatisierten Testfaelle lesen sich fast 1:1 wie die manuelle
Testbeschreibung -- und decken dabei sogar einen Bug auf.

---

## Die Testseite

Die Seite https://practice.expandtesting.com/login bietet eine
Login-Funktion mit drei dokumentierten Testfaellen:

- Erfolgreicher Login mit gueltigem Benutzer und Passwort
- Login mit falschem Benutzernamen
- Login mit falschem Passwort

Die Testfallbeschreibung steht direkt auf der Seite -- ideal fuer
einen Vergleich.

---

## Testfall 1: Erfolgreicher Login

| # | Manuelle Beschreibung (Original) | OKW4Robot Keyword |
|---|---|---|
| 1 | Launch the browser. | `StartApp MyAppChrome` |
| 2 | Navigate to the login page URL. | `SetValue URL https://...` |
| 3 | Verify that the login page is displayed. | `SelectWindow LoginPage` |
| 4 | Enter Username: `practice`. | `SetValue Benutzer practice` |
| 5 | Enter Password: `SuperSecretPassword!`. | `SetValue Passwort SuperSecretPassword!` |
| 6 | Click the Login button. | `ClickOn Anmelden` |
| 7 | Verify redirect to `/secure` page. | `SelectWindow SecurePage` |
| 8 | Confirm success message is visible. | `VerifyValueWCM Willkommensmeldung *You logged into a secure area*` |
| 9 | Verify that a Logout button is displayed. | `VerifyExists Abmelden YES` |

**Was auffaellt:** Jeder manuelle Schritt hat ein direktes Gegenstueck.
Kein Selenium-Code, kein XPath im Test, keine technischen Hilfskonstrukte.
Die Keywords `Benutzer`, `Passwort`, `Anmelden` sind fachliche Namen --
die technische Aufloesung (`css:#username`, `css:#password`,
`css:#submit-login`) steckt in einer separaten YAML-Datei.

---

## Testfall 2: Fehlerhafter Benutzername

| # | Manuelle Beschreibung (Original) | OKW4Robot Keyword |
|---|---|---|
| 1-3 | Browser starten, navigieren, Login-Seite pruefen. | *(Test Setup)* |
| 4 | Enter an incorrect Username (e.g., `wrongUser`). | `SetValue Benutzer wrongUser` |
| 5 | Enter Password: `SuperSecretPassword!`. | `SetValue Passwort SuperSecretPassword!` |
| 6 | Click the Login button. | `ClickOn Anmelden` |
| 7 | Verify error message "Invalid username." | `VerifyValue Fehlermeldung Invalid username.` |
| 8 | Ensure user remains on login page. | `SelectWindow LoginPage` |

---

## Testfall 3: Fehlerhaftes Passwort

| # | Manuelle Beschreibung (Original) | OKW4Robot Keyword |
|---|---|---|
| 1-3 | Browser starten, navigieren, Login-Seite pruefen. | *(Test Setup)* |
| 4 | Enter Username: `practice`. | `SetValue Benutzer practice` |
| 5 | Enter an incorrect Password (e.g., `WrongPassword`). | `SetValue Passwort WrongPassword` |
| 6 | Click the Login button. | `ClickOn Anmelden` |
| 7 | Verify error message "Invalid password." | `VerifyValue Fehlermeldung Invalid password.` |
| 8 | Ensure user remains on login page. | `SelectWindow LoginPage` |

---

## Der komplette automatisierte Test

```robot
*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/login

*** Test Cases ***
Erfolgreicher Login
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       SecurePage
    VerifyValueWCM     Willkommensmeldung    *You logged into a secure area*
    VerifyValueWCM     Benutzername          *practice*
    VerifyExists        Abmelden              YES

Fehlerhafter Benutzername
    SelectWindow       LoginPage
    SetValue           Benutzer       wrongUser
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValue        Fehlermeldung    Invalid username.

Fehlerhaftes Passwort
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       WrongPassword
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValue        Fehlermeldung    Invalid password.

*** Keywords ***
Login Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
```

---

## Und dann passiert das hier: Falsch ist richtig

Die Testfaelle 2 und 3 schlagen fehl. Aber nicht weil der Test falsch
ist -- sondern weil die Anwendung einen Bug hat:

- **Spezifikation:** Bei falschem Benutzernamen soll `Invalid username.`
  erscheinen.
- **Tatsaechliches Verhalten:** Die Seite zeigt stattdessen
  `Your password is invalid!` -- egal ob der Benutzername oder das
  Passwort falsch ist.

Der Test prueft gegen die Spezifikation, nicht gegen die Implementierung.
Wenn der Test fehlschlaegt, liegt der Fehler bei der Anwendung, nicht
beim Test.

Das ist die Essenz eines guten Tests: Er findet Fehler, statt sie zu
verstecken.

---

## Die Trennung: Fachlich vs. Technisch

Was den Test lesbar haelt, ist die strikte Trennung:

**Im Testfall** stehen nur fachliche Begriffe:

```
SetValue    Benutzer    practice
ClickOn     Anmelden
```

**In der YAML-Datei** steckt die technische Aufloesung:

```yaml
Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '#username' }

Anmelden:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '#submit-login' }
```

Aendert sich die Oberflaeche (z.B. `id="username"` wird zu
`data-test="user-input"`), aendert sich genau eine Zeile in der
YAML-Datei. Der Testfall bleibt unveraendert.

---

## Fazit

- Automatisierte Tests koennen so lesbar sein wie manuelle
  Testbeschreibungen.
- Die Trennung von Fachsprache und Technik macht Tests wartbar.
- Ein guter Test prueft die Spezifikation -- und findet echte Bugs.

Manchmal ist "Falsch" genau richtig.

---

*Dieser Beitrag ist Teil der Serie zur schluesselwortgetriebenen
Testautomatisierung mit OKW4Robot.*
