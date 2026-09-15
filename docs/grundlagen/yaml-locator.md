# YAML-Locator

## Locators gehören nicht in den Test

In OKW werden alle GUI-Elemente in YAML-Dateien definiert. Der Test
referenziert Widgets nur über ihren **fachlichen Namen** — der technische
Locator bleibt in der YAML-Datei.

## Aufbau einer YAML-Datei

Eine YAML-Datei hat drei Ebenen: **App → Fenster → Widget**.

```yaml
MeineApp:                              # App-Name (für StartApp)
  __self__:                            # Adapter-Konfiguration
    class: okw_web_selenium.adapters.selenium_web.SeleniumWebAdapter
    browser: chrome

  Login:                               # Fenster-Name (für SelectWindow)
    Benutzername:                      # Widget-Name (für SetValue, ClickOn, ...)
      class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
      locator: { id: "user-name" }

    Kennwort:
      class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
      locator: { id: "password" }

    Anmelden:
      class: okw_web_selenium.widgets.webse_button.WebSe_Button
      locator: { id: "login-button" }
```

## Die drei Schlüssel

Jedes Widget hat zwei Pflichtschlüssel:

| Schlüssel | Zweck | Beispiel |
|---|---|---|
| `class` | Widget-Klasse (bestimmt das Verhalten) | `webse_textfield.WebSe_TextField` |
| `locator` | Wo das Element zu finden ist | `{ id: "user-name" }` |

Der optionale Schlüssel `label_for` verbindet ein Label mit einem Eingabefeld.

## Locator-Strategien

Jede Technologie hat eigene Locator-Strategien:

### Web Selenium

| Strategie | Beispiel |
|---|---|
| `id` | `{ id: "user-name" }` |
| `xpath` | `{ xpath: "//input[@name='q']" }` |
| `css` | `{ css: "input.search-field" }` |
| `name` | `{ name: "username" }` |

### SAP GUI

| Strategie | Beispiel |
|---|---|
| `id` | `{ id: "wnd[0]/usr/txtRSYST-BNAME" }` |
| `hlabel` | `{ hlabel: "Benutzer" }` |
| `vlabel` | `{ vlabel: "Mandant" }` |

### Java RemoteSwing

| Strategie | Beispiel |
|---|---|
| `name` | `{ name: "txtUsername" }` |

## Fachliche Namen wählen

Die Widget-Namen in YAML sind **fachliche Begriffe**, keine technischen IDs:

```yaml
# Gut: Fachliche Namen
Benutzername:
  locator: { id: "user-name" }
Kennwort:
  locator: { id: "password" }

# Schlecht: Technische IDs als Namen
user-name:
  locator: { id: "user-name" }
password:
  locator: { id: "password" }
```

Der Test soll sich wie eine Bedienungsanleitung lesen:

```robot
SetValue    Benutzername    admin       # Verständlich
SetValue    user-name       admin       # Technisch — NOISE
```

## Modularer Aufbau mit !include

Große Anwendungen werden in mehrere YAML-Dateien aufgeteilt:

```yaml
# Allpages.yaml — sammelt alle Seiten
LoginPage: !include LoginPage.yaml
Dashboard: !include Dashboard.yaml
Einstellungen: !include Einstellungen.yaml

# MeinAppChrome.yaml — App-Definition
MeinAppChrome:
  __self__:
    class: okw_web_selenium.adapters.selenium_web.SeleniumWebAdapter
    browser: chrome
  Chrome: !include Chrome.yaml
  _pages: !include-merge Allpages.yaml
```

**Regeln:**

- `!include` — bettet den Inhalt einer Datei unter einem Schlüssel ein
- `!include-merge` — fügt die Schlüssel der Datei **flach** ein (kein extra Nesting)
- Neue Seiten nur in `Allpages.yaml` eintragen — alle App-Definitionen bekommen sie automatisch

So lässt sich dieselbe Seitenstruktur für Chrome und Firefox nutzen —
nur `__self__.browser` und die Browser-Widgets unterscheiden sich.
