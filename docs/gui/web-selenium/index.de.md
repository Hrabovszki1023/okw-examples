# Web Selenium

Die Bibliothek `robotframework-okw-web-selenium` ist der OKW-Treiber für
Webanwendungen. Sie verwendet Selenium WebDriver über die SeleniumLibrary
für Robot Framework.

## Installation

```bash
pip install robotframework-okw-web-selenium
```

Installiert automatisch `robotframework-okw4robot` (Core) und
`robotframework-seleniumlibrary` als Abhängigkeiten.

## Erster Test: SauceDemo Login

Dieses Beispiel zeigt den vollständigen Aufbau eines OKW-Web-Tests —
vom YAML bis zum lauffähigen Testfall.

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

Beachte: Die YAML-Keys sind **Fachbegriffe** (`Benutzer`, `Passwort`,
`Anmelden`), nicht technische IDs (`txtUser`, `btnLogin`). Die
technischen Locatoren stehen nur im `locator`-Feld.

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
    VerifyValue    Titel    Products

Login Fehlgeschlagen Mit Meldung
    [Arguments]    ${meldung}
    OnFailNOISE    SelectWindow       SauceDemoLogin
    VerifyValue    Fehlermeldung    ${meldung}

*** Test Cases ***
Login Standard User
    Anmelden Mit    standard_user    secret_sauce
    Login Erfolgreich

Login Gesperrter Benutzer
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung
    ...    Epic sadface: Sorry, this user has been locked out.

Login Ohne Passwort
    Anmelden Mit    standard_user    ${EMPTY}
    Login Fehlgeschlagen Mit Meldung
    ...    Epic sadface: Password is required
```

### Schritt 5: Ausführen

```bash
robot tests/SauceDemo_Login.robot
```

`StartApp MyAppChrome` öffnet Chrome automatisch. `StopApp` schließt ihn.

---

## OnFailNOISE

Setup-Schritte wie `StartApp`, `SelectWindow` und URL-Eingabe sind
**NOISE** — sie sind nicht der eigentliche Test. Schlägt einer fehl,
soll der Testfall als NOISE markiert werden, nicht als echter Fehler.

`OnFailNOISE` bewirkt genau das: Schlägt das Keyword fehl, wird der
Test mit dem Tag `NOISE` markiert. Im Test-Setup ist jede Zeile mit
`OnFailNOISE` gewrapped:

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
  Chrome.yaml              # Browser-Fenster (URL-Leiste, ...)
  Firefox.yaml             # Browser-Fenster (URL-Leiste, ...)
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

## Widget-Klassen

Jede Widget-Klasse kapselt eine HTML-Elementfamilie:

| Widget-Klasse | HTML-Elemente | Typische Keywords |
|---|---|---|
| `WebSe_TextField` | `<input>`, `<textarea>` | SetValue, VerifyValue, TypeKey, Delete |
| `WebSe_Button` | `<button>`, `<input type=button>` | ClickOn, VerifyCaption |
| `WebSe_CheckBox` | `<input type=checkbox>` | ClickOn, SetValue, VerifyValue |
| `WebSe_ComboBox` | `<select>`, Custom-Dropdowns | Select, VerifyValue |
| `WebSe_ListBox` | `<select multiple>`, `<ul>` | Select, VerifyValue |
| `WebSe_RadioList` | `<input type=radio>` | Select, VerifyValue |
| `WebSe_Label` | `<span>`, `<div>`, `<p>`, `<label>` | VerifyValue, VerifyCaption |
| `WebSe_Link` | `<a>` | ClickOn, VerifyCaption |
| `WebSe_Table` | `<table>` | VerifyTableCellValue, LogTableCellValue |

Die Widget-Klasse wird im YAML-Feld `class` festgelegt. Im Testcode
taucht sie nie auf — der Test spricht nur Business-Sprache.

---

## Locator-Strategien

Das `locator`-Feld im YAML unterstützt alle Selenium-Strategien:

| Strategie | Beispiel | Wann verwenden |
|---|---|---|
| `css` | `{ css: '[data-test="username"]' }` | Standard für die meisten Elemente |
| `xpath` | `{ xpath: '//div[@class="price"]' }` | Textsuche, komplexe Hierarchien, SetContext |
| `id` | `{ id: user-name }` | Wenn das Element eine stabile ID hat |
| `name` | `{ name: password }` | HTML name-Attribut |

**Empfehlung:** CSS für einfache Elemente, XPath wenn Text-Matching oder
SetContext benötigt wird.

---

## SetContext: Wiederholende Strukturen

Web-Anwendungen enthalten häufig wiederholende Elemente — Produktkarten,
Tabellenzeilen, Listeneinträge. `SetContext` grenzt nachfolgende
Operationen auf eine Instanz ein.

### YAML mit `__context__`

```yaml
# locators/SauceDemoProducts.yaml
ProduktKarte:
  __context__:
    locator: { xpath: '//div[@data-test="inventory-item"]
      [.//div[@data-test="inventory-item-name"
      and text()="{ProduktName}"]]' }
  Produktname:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-name"]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button' }
```

### Test

```robot
*** Keywords ***
Produktpreis Pruefen
    [Arguments]    ${produkt}    ${erwarteter_preis}
    SetContext         ProduktKarte    ${produkt}
    VerifyValue        Produktpreis    ${erwarteter_preis}

*** Test Cases ***
SetContext Produktpreise Pruefen
    SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    SelectWindow   SauceDemoProducts

    Produktpreis Pruefen    Sauce Labs Backpack      $29.99
    Produktpreis Pruefen    Sauce Labs Bike Light    $9.99
    Produktpreis Pruefen    Sauce Labs Bolt T-Shirt  $15.99
```

**So funktioniert es:**

1. `SetContext ProduktKarte Sauce Labs Backpack` ersetzt `{ProduktName}`
   im `__context__`-Locator → findet die richtige Produktkarte.
2. `VerifyValue Produktpreis` nutzt den relativen Locator `.//div[...]` —
   er wird innerhalb der gefundenen Karte ausgewertet.
3. Der nächste `SetContext` wechselt zur nächsten Karte.

!!! warning "Nur XPath"
    SetContext erfordert XPath — sowohl für den `__context__`-Locator als
    auch für die Kind-Locatoren. CSS-Selektoren können keinen Textinhalt
    matchen und unterstützen keine relative Pfadkomposition.

---

## iFrame-Unterstützung

Wenn ein Widget innerhalb eines `<iframe>` liegt, wird das `iframe`-Attribut
im YAML ergänzt. Der Adapter wechselt automatisch in den Frame — kein
manuelles `switch_to.frame()` im Test.

### YAML

```yaml
# locators/IFramePage.yaml
Seitentitel:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { xpath: '//h1' }

EmailEingabe:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  iframe: { id: email-subscribe }
  locator: { id: email }

AbonnierenButton:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  iframe: { id: email-subscribe }
  locator: { id: btn-subscribe }

Erfolgsmeldung:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  iframe: { id: email-subscribe }
  locator: { id: success-message }

EditorBody:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  iframe: { id: mce_0_ifr }
  locator: { id: tinymce }
```

### Test

```robot
Email Abonnieren Erfolgreich
    SetValue       EmailEingabe        test@example.com
    ClickOn        AbonnierenButton
    VerifyValue    Erfolgsmeldung      You are now subscribed!

Zwischen Zwei IFrames Wechseln
    VerifyValue       AbonnierenButton    Subscribe
    VerifyValueWCM    EditorBody          *content goes here*
    VerifyValueWCM    IFrameUeberschrift  *inbox*
```

Der Testcode kennt keine iFrames. Das `iframe`-Attribut im YAML reicht —
der Adapter schaltet automatisch hin und zurück.

**Regeln:**

- `iframe` akzeptiert dieselben Locator-Strategien wie `locator`
  (css, xpath, id, ...).
- Verschachtelte iFrames (Frame im Frame) werden nicht unterstützt.
- Wenn zwei Widgets denselben iFrame nutzen, wird nur einmal gewechselt.

---

## Hover (MoveOver)

Manche Elemente werden erst sichtbar, wenn die Maus darüber fährt.
`MoveOver` bewegt den Mauszeiger auf ein Widget.

```robot
MoveOver       Profilbild
VerifyValue    ProfilInfo    View profile
```

---

## Match Modes: Exakt, Wildcard, Regex

Alle `Verify*`-Keywords unterstützen drei Matching-Modi:

```robot
# Exakte Übereinstimmung (Standard)
VerifyValue        Titel    Products

# Wildcard: * = beliebige Zeichen, ? = ein Zeichen
VerifyValueWCM     Seitentitel    *IFrame*

# Regulärer Ausdruck
VerifyValueREGX    Preis    \$\d+\.\d{2}
```

---

## Web-spezifische Keywords

Diese Keywords gibt es nur in der Selenium-Bibliothek:

| Keyword | Beschreibung |
|---|---|
| `ExecuteJS` | JavaScript im Browser-Kontext ausführen |
| `RemoveAds` | Werbe-Iframes/Overlays entfernen (per JS + MutationObserver) |

### RemoveAds

Entfernt Werbeelemente von der aktuellen Seite. Ein `MutationObserver`
wird installiert, der auch nachgeladene Ads entfernt.

```robot
# Standard (Google Ads):
OnFailIgnoreNOISE    RemoveAds

# Projektspezifische Selektoren:
OnFailIgnoreNOISE    RemoveAds    div.custom-banner    iframe[src*="ad-network"]
```

Am besten im Test-Setup mit `OnFailIgnoreNOISE` — wenn keine Ads da sind,
passiert nichts.

---

## Lauffähige Beispiele

Alle Beispiele aus diesem Kapitel stammen aus dem okw-examples Repository:

| Beispiel | Was es zeigt |
|---|---|
| [SauceDemo Login](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/saucedemo) | Login, Fehlerbehandlung, OnFailNOISE |
| [SauceDemo SetContext](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/saucedemo) | Wiederholende Produktkarten |
| [ExpandTesting IFrame](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/expandtesting) | iFrame-Wechsel, Email-Subscribe |
| [ExpandTesting DynamicTable](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/expandtesting) | Dynamische Tabellen |
| [ExpandTesting Hovers](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/expandtesting) | MoveOver, Hover-Aktionen |
| [The Internet](https://github.com/Hrabovszki1023/okw-examples/tree/main/selenium/the-internet) | Login, Checkboxen, Dropdown, Tabellen |

```bash
git clone https://github.com/Hrabovszki1023/okw-examples.git
cd okw-examples/selenium/saucedemo
pip install robotframework-okw-web-selenium
robot tests/
```
