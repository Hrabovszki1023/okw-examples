# Warum kein Page Object Model?

## Was POM löst

Das Page Object Model (POM) ist der Industriestandard für Selenium-Tests.
Die Idee: Locators gehören nicht in den Test, sondern in eigene Klassen —
eine pro Seite.

```python
class LoginPage:
    def __init__(self, driver):
        self.driver = driver
        self.username = (By.ID, "user-name")
        self.password = (By.ID, "password")
        self.login_btn = (By.ID, "login-button")

    def enter_username(self, user):
        self.driver.find_element(*self.username).send_keys(user)

    def enter_password(self, pwd):
        self.driver.find_element(*self.password).send_keys(pwd)

    def click_login(self):
        self.driver.find_element(*self.login_btn).click()
```

Das ist besser als Locators direkt im Test. Aber es hat Grenzen.

## Drei Probleme mit POM

→ Warum OKW diese Probleme anders löst: [Warum diese Trennung?](yaml-locator.md#warum-diese-trennung)

### 1. Seiten-Ebene statt Komponenten-Ebene

POM arbeitet auf **Seiten-Ebene**: Jede Seite bekommt eine eigene Klasse mit
eigenen Methoden. `LoginPage.enter_username()`, `SearchPage.enter_query()`,
`ProfilePage.enter_name()` — drei verschiedene Methoden, die alle dasselbe tun:
Text in ein Textfeld eingeben.

OKW arbeitet auf **Komponenten-Ebene**: Ein `TextField`-Widget weiß, wie man
Text eingibt. Das gilt für **jedes** Textfeld im gesamten System — Login,
Suche, Profil, egal welche Seite.

```
POM:    LoginPage.enter_username("admin")      # Methode nur für diese Seite
        SearchPage.enter_query("OKW")          # Andere Methode, gleiche Aktion
        ProfilePage.enter_name("Max")          # Noch eine Methode

OKW:    SetValue    Benutzername    admin       # Ein Keyword für alle
        SetValue    Suchbegriff     OKW         # Textfelder überall
        SetValue    Name            Max
```

Das ist **DRY auf Komponentenebene**: Ein Textfeld wird einmal implementiert,
nicht auf jeder Seite neu.

### 2. POM braucht Programmierer

POM-Klassen sind Python-Code: Klassen, Methoden, Vererbung, Konstruktoren.
Das kann ein Tester ohne Programmiererfahrung nicht pflegen.

OKW-Locators sind YAML — Konfiguration, kein Code:

```yaml
Login:
  Benutzername:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { id: "user-name" }
```

Ein Tester kann Locators anlegen, ändern und erweitern, ohne eine Zeile
Python zu schreiben.

### 3. POM skaliert nicht über Technologiegrenzen

Ein Selenium-POM funktioniert nur mit Selenium. Wenn das Projekt auch
SAP GUI, Java Swing oder eine REST API testen muss, braucht man für jede
Technologie ein eigenes Page-Object-Pattern — mit eigener Struktur,
eigenen Methoden, eigenen Konventionen.

OKW verwendet **dieselben Keywords** für alle Technologien:

```robot
# Web
OKW.SetValue       Benutzername    admin

# SAP GUI
OKW.SetValue       Benutzer        admin

# Java Swing
OKW.SetValue       txtUsername     admin
```

Der Test liest sich gleich, egal welche Technologie dahinterliegt.
Nur die YAML-Datei und die Widget-Klasse ändern sich.

## Widget-Vererbung statt Seiten-Klassen

OKW-Widgets folgen einer Vererbungshierarchie:

```
OkwWidget                          # Kontrakt: okw_set_value, okw_get_value, ...
  └── WebSe_Base                   # Web-spezifisch: Selenium-Element finden
        └── WebSe_TextField        # Standard-Textfeld
              └── MeinDatumsfeld   # Projekt-Ableitung: Kalender-Popup
```

Wenn ein Projekt ein spezielles Widget hat — z.B. ein Datumsfeld mit
Kalender-Popup — leitet man von der Standard-Widget-Klasse ab und
überschreibt nur die eine Methode, die anders funktioniert:

```python
class MeinDatumsfeld(WebSe_TextField):

    def okw_set_value(self, value):
        """Oeffnet den Kalender und waehlt das Datum."""
        self._pre_write()
        self.adapter.click(self.locator)           # Kalender öffnen
        self.adapter.click({"xpath": f"//td[text()='{value}']"})  # Datum wählen
```

Im Test ändert sich nichts:

```robot
SetValue    Geburtsdatum    15.09.2026
```

Der Tester merkt nicht, dass hinter `Geburtsdatum` ein spezielles Widget
steht. Das ist Signal vs. NOISE in Reinform.

## Zusammenfassung

| Kriterium | POM | OKW |
|---|---|---|
| Abstraktionsebene | Seite | Komponente (Widget) |
| Locator-Format | Python-Code | YAML-Konfiguration |
| Wiederverwendung | Pro Seite | Pro Widget-Typ (DRY) |
| Technologien | Nur eine (z.B. Selenium) | Alle über denselben Kontrakt |
| Spezialfälle | Neue Methode in Page-Klasse | Widget-Ableitung, eine Methode überschreiben |
| Pflege durch | Entwickler | Tester (YAML) + Entwickler (Widgets) |
