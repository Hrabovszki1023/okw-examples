# Web Selenium

Die Bibliothek `robotframework-okw-web-selenium` ist der OKW-Treiber für
Webanwendungen. Sie verwendet Selenium WebDriver über die SeleniumLibrary
für Robot Framework.

Die meisten Selenium-Testsuiten haben dasselbe Problem: CSS-Selektoren,
XPaths und Treiber-Aufrufe stehen direkt im Testcode. Ändert sich die
Oberfläche, repariert man Locatoren in Dutzenden Dateien. Mit OKW
enthält der Test nur noch **Signal** — was getestet wird. Locatoren und
Treiber-Technik (**NOISE**) stehen in YAML und in Widget-Klassen.

!!! info "ISO/IEC/IEEE 29119-5"
    OKW setzt die Keyword-Architektur der ISO 29119-5 um:
    **Domain Layer** (`.robot`-Test) → **Decomposer** (OKW-Core + YAML)
    → **Test Interface Layer** (Widget + Selenium-Adapter).
    Das Page Object Model tut das nicht —
    siehe [Warum kein POM?](../../grundlagen/warum-kein-pom.md).

## Installation

```bash
pip install robotframework-okw-web-selenium
```

Installiert automatisch `robotframework-okw4robot` (Core) und
`robotframework-seleniumlibrary` als Abhängigkeiten.

## Erster Test: SauceDemo Login

Dieses Beispiel zeigt den vollständigen Aufbau eines OKW-Web-Tests —
vom YAML bis zum lauffähigen Testfall. Testobjekt ist der öffentliche
Demo-Shop [saucedemo.com](https://www.saucedemo.com).

![SauceDemo Login-Seite](images/01_saucedemo_login.png)

### Schritt 1: App-YAML anlegen

Die App-YAML definiert den Browser und sammelt alle Seiten:

```yaml
# locators/MyAppChrome.yaml
MyAppChrome:
  __self__:
    class: okw_web_selenium.adapters.selenium_web.SeleniumWebAdapter
    browser: chrome
  Chrome: !include Chrome.yaml
  _pages: !include-merge Allpages.yaml
```

`__self__` konfiguriert den Adapter. `!include-merge` bringt alle
Seiten-YAMLs als direkte Kinder in die App — nicht verschachtelt.

### Schritt 2: Seiten-YAML definieren

Jede Seite bekommt eine eigene YAML-Datei mit Business-Namen:

```yaml
# locators/SauceDemoLogin.yaml
__self__:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="login-container"]' }

Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="username"]' }

Passwort:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="password"]' }

Anmelden:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '[data-test="login-button"]' }

Fehlermeldung:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="error"]' }
```

Die YAML-Datei erfüllt zwei Aufgaben:

1. **Fachliche Namen.** Der Test sagt `Benutzer` — einen Fachbegriff,
   keine technische ID (`txtUser`, `btnLogin`). Die YAML bildet ihn auf
   den konkreten Locator ab.
2. **Widget-Verhalten.** `class` legt fest, *wie* ein Keyword auf dem
   GUI-Objekt ausgeführt wird. Ein `TextField` weiß, wie `SetValue`
   geht (löschen + eingeben), ein `Button`, wie `ClickOn` geht.

Ändert sich ein `data-test`-Attribut, wird es hier **einmal** korrigiert —
alle Testfälle laufen weiter.

### Schritt 3: Seiten in Allpages sammeln

```yaml
# locators/Allpages.yaml
SauceDemoLogin: !include SauceDemoLogin.yaml
SauceDemoProducts: !include SauceDemoProducts.yaml
```

Neue Seiten werden hier einmal eingetragen — alle App-YAMLs
(Chrome, Firefox, ...) bekommen sie automatisch.

### Schritt 4: Testdatei schreiben

```robot
*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
Login Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

Anmelden Mit
    [Arguments]    ${benutzer}    ${passwort}

    OnFailNOISE    SelectWindow   SauceDemoLogin
    SetValue       Benutzer    ${benutzer}
    SetValue       Passwort    ${passwort}
    ClickOn        Anmelden

Login Erfolgreich

    OnFailNOISE    SelectWindow       SauceDemoProducts
    VerifyValue        Titel    Products

Login Fehlgeschlagen Mit Meldung
    [Arguments]    ${meldung}

    OnFailNOISE    SelectWindow       SauceDemoLogin
    VerifyValue        Fehlermeldung    ${meldung}

*** Test Cases ***
Login Standard User
    Anmelden Mit    standard_user    secret_sauce
    Login Erfolgreich

Login Gesperrter Benutzer
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Sorry, this user has been locked out.

Login Ohne Passwort
    Anmelden Mit    standard_user    ${EMPTY}
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Password is required
```

Keine Selektoren, keine Treiber-Aufrufe. `SetValue`, `ClickOn` und
`VerifyValue` sind Low-Level Keywords — sie funktionieren für jede
GUI-Technologie. `Anmelden Mit` ist ein High-Level Keyword, das das
Testprojekt selbst aus ihnen zusammensetzt.

### Schritt 5: Ausführen

```bash
robot tests/SauceDemo_Login.robot
```

`StartApp MyAppChrome` öffnet Chrome automatisch. `StopApp` schließt ihn.

### 11 Testfälle, keine Redundanz

Die vollständige Suite
[`SauceDemo_Login.robot`](https://github.com/Hrabovszki1023/okw-examples/blob/master/selenium/saucedemo/tests/SauceDemo_Login.robot)
deckt den Login komplett ab:

| Testfälle | Was sie prüfen |
|---|---|
| 5 gültige Logins | standard, problem, performance_glitch, error, visual user |
| 1 gesperrter Benutzer | Fehlermeldung |
| 2 falsche Zugangsdaten | Unbekannter Benutzer, falsches Passwort |
| 3 leere Felder | Ohne Benutzer, ohne Passwort, beides leer |

Jeder Testfall hat zwei Zeilen. Die YAML ändert sich nie, die Keywords
ändern sich nie — nur die Testdaten variieren.

---

## OnFailNOISE

Setup-Schritte wie `StartApp`, `SelectWindow` und URL-Eingabe sind
**NOISE** — sie sind nicht der eigentliche Test. Schlägt einer fehl,
soll der Testfall als NOISE markiert werden, nicht als echter Fehler.

`OnFailNOISE` bewirkt genau das: Schlägt das Keyword fehl, wird der
Test mit dem Tag `NOISE` markiert.

```robot
Login Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
```

Die eigentlichen Testschritte (`SetValue Benutzer`, `ClickOn Anmelden`,
`VerifyValue`) stehen **ohne** `OnFailNOISE` — deren Fehler sind echte
Testergebnisse.

---

## Modulare YAML-Struktur

Für Web-Tests empfiehlt sich eine Trennung in App, Browser und Seiten:

```
locators/
  Chrome.yaml               # Browser-Fenster (URL-Leiste, ...)
  Firefox.yaml              # Browser-Fenster (URL-Leiste, ...)
  SauceDemoLogin.yaml       # Seite: Login
  SauceDemoProducts.yaml    # Seite: Produktübersicht
  Allpages.yaml             # Sammelt alle Seiten per !include
  MyAppChrome.yaml          # App = Adapter + Chrome + alle Seiten
  MyAppFirefox.yaml         # App = Adapter + Firefox + alle Seiten
```

**Vorteile:**

- Neue Seiten werden einmal in `Allpages.yaml` eingetragen — alle
  Browser-Varianten bekommen sie automatisch.
- Browser wechseln: `StartApp MyAppFirefox` statt `MyAppChrome`.
  Die Tests bleiben identisch.
- Jede Seiten-YAML ist eigenständig und übersichtlich.

---

## Weiter in diesem Kapitel

| Seite | Thema | Demo-Seite |
|---|---|---|
| [Wiederholende Strukturen](setcontext.md) | Produktkarten mit `SetContext` | saucedemo.com |
| [Shadow DOM und iFrames](shadow-dom-iframe.md) | Isolationsgrenzen ohne Testcode-Änderung | practice.expandtesting.com |
| [Drag & Drop](drag-and-drop.md) | HTML5 Drag & Drop, das Selenium nicht auslöst | practice.expandtesting.com |
| [Tabellen](tabellen.md) | Zellen über Header-Namen statt Positionen | practice.expandtesting.com |
| [Hover](hover.md) | Elemente, die erst bei Mausberührung erscheinen | practice.expandtesting.com |
| [Referenz](referenz.md) | Widget-Klassen, Locator-Strategien, Match Modes, Web-Keywords | – |
