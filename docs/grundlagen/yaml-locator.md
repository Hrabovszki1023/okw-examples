# YAML-Locator

## Locators gehören nicht in den Test

In OKW werden alle GUI-Elemente in YAML-Dateien definiert. Der Test
referenziert Widgets nur über ihren **fachlichen Namen** — der technische
Locator bleibt in der YAML-Datei.

### Warum diese Trennung?

1. **Lesbarkeit** — Testfälle enthalten nur fachliche Bezeichner
   (`Benutzer`, `Anmelden`, `Fehlermeldung`). Technische Locatoren
   wie `#wnd[0]/usr/txtRSYST-BNAME` sind NOISE und stören den Lesefluss.

2. **DRY** — Ändert sich ein Locator (z.B. weil sich die ID im HTML ändert),
   wird er an **genau einer Stelle** angepasst — in der YAML-Datei.
   Alle Tests, die das Widget nutzen, funktionieren sofort weiter.

3. **Trennung von Objekterkennung und Ablauflogik** — Die YAML-Datei
   beschreibt *was* auf dem Bildschirm existiert (Objekterkennung).
   Der Test beschreibt *was der Benutzer tut* (Ablauflogik). Im
   Page Object Model (POM) sind beide Aspekte in einer Klasse vermischt —
   bei einem Technologiewechsel (z.B. Web → SAP GUI) muss das POM
   komplett neu geschrieben werden. In OKW bleibt die Ablauflogik
   (Keywords, Testsequenzen) unverändert — nur die YAML-Locatoren
   und die Widget-Klassen werden ausgetauscht.

4. **DRY auf Interaktionsebene** — Die Widget-Klasse kapselt die
   technische Interaktion mit einem GUI-Element. Wie ein Textfeld
   befüllt, gelöscht oder ausgelesen wird, ist **einmal** in
   `WebSe_TextField` implementiert — nicht n-mal an jeder Stelle,
   an der ein Textfeld vorkommt. Im POM wird dieselbe Selenium-Logik
   (Element finden, löschen, Text eingeben) in jeder Page-Klasse
   erneut geschrieben.
   → Siehe auch: [Seiten-Ebene statt Komponenten-Ebene](warum-kein-pom.md#1-seiten-ebene-statt-komponenten-ebene)

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
