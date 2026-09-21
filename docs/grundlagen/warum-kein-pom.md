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

!!! note "Seleniums eigenes Beispiel verletzt POM"
    Die Selenium-Dokumentation zeigt als Negativbeispiel einen
    Login-Test **ohne** POM — mit Locatoren direkt im Testcode.
    Dabei fällt ein weiteres Problem auf: Die Prüfung
    `assertThat(h1.getText(), is("Hello userName"))` gehört nicht
    zur Login-Seite, sondern zur **Folgeseite** nach dem Login.
    Logisch korrekt wäre: Nach dem Klick auf „Anmelden" prüft die
    Login-Seite, ob sie **verschwunden** ist. Dass die Welcome-Seite
    erscheint und „Hello userName" zeigt, ist eine Prüfung der
    **Folgeseite** — die gehört in den Testfall oder in ein
    Welcome-Page-Object, aber definitiv nicht in das POM der
    Login-Seite. Das ist an der Stelle schlicht unlogisch und
    vermischt zwei verschiedene Seitenverantwortungen.

Selenium selbst beschreibt POM mit dem Vorteil einer „clean separation
between test code and page-specific code". Das stimmt so nicht: Die
Page-Klasse enthält **sowohl** Locatoren als auch Interaktionslogik
(`find_element`, `send_keys`, `click`). Die Vermischung wird nicht
aufgelöst — sie wird nur vom Test in die Page-Klasse verschoben.

Auch DRY wird nur **ansatzweise** umgesetzt: Locatoren stehen zwar
einmal pro Page-Klasse, aber die Interaktionslogik (Element finden,
warten, löschen, eingeben) wird in jeder Methode und in jeder
Page-Klasse erneut geschrieben. Die einzige Vererbung in der Praxis:
Eine `BasePage` definiert den Treiber-Aufruf zentral, alle
Seiten-POMs erben davon. Weiter geht die Vererbung nicht — es gibt
keine Widget-Ebene, die Interaktionsmuster für Textfelder, Checkboxen
oder Dropdowns technologieübergreifend kapselt.

## Seleniums „richtige" Lösung — und OKW im Vergleich

Die [Selenium-Dokumentation](https://www.selenium.dev/documentation/test_practices/encouraged/page_object_models/)
zeigt als korrekte POM-Lösung zwei Page-Klassen und einen Test:

```java
// SignInPage.java — Page Object für die Anmeldeseite
public class SignInPage {
    protected WebDriver driver;
    private By usernameBy = By.name("user_name");
    private By passwordBy = By.name("password");
    private By signinBy = By.name("sign_in");

    public SignInPage(WebDriver driver) {
        this.driver = driver;
        if (!driver.getTitle().equals("Sign In Page")) {
            throw new IllegalStateException("This is not Sign In Page,"
                + " current page is: " + driver.getCurrentUrl());
        }
    }

    public HomePage loginValidUser(String userName, String password) {
        driver.findElement(usernameBy).sendKeys(userName);
        driver.findElement(passwordBy).sendKeys(password);
        driver.findElement(signinBy).click();
        return new HomePage(driver);
    }
}
```

```java
// HomePage.java — Page Object für die Folgeseite
public class HomePage {
    protected WebDriver driver;
    private By messageBy = By.tagName("h1");

    public HomePage(WebDriver driver) {
        this.driver = driver;
        if (!driver.getTitle().equals("Home Page of logged in user")) {
            throw new IllegalStateException("This is not Home Page,"
                + " current page is: " + driver.getCurrentUrl());
        }
    }

    public String getMessageText() {
        return driver.findElement(messageBy).getText();
    }
}
```

```java
// TestLogin.java — Der eigentliche Test
public class TestLogin {
    @Test
    public void testLogin() {
        SignInPage signInPage = new SignInPage(driver);
        HomePage homePage = signInPage.loginValidUser("userName", "password");
        assertThat(homePage.getMessageText(), is("Hello userName"));
    }
}
```

Drei Dateien, ca. 50 Zeilen Java-Code. `loginValidUser()` enthält die
Interaktionslogik (`findElement`, `sendKeys`, `click`), den Seitenwechsel
(`return new HomePage`) und die Locatoren — alles in einer Methode.

### Dieselbe Aufgabe mit OKW

```yaml
# locators/SignIn.yaml
__self__:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: 'title=Sign In Page' }

Benutzername:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { name: user_name }

Kennwort:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { name: password }

Anmelden:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { name: sign_in }
```

```yaml
# locators/HomePage.yaml
__self__:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: 'title=Home Page of logged in user' }

Willkommensnachricht:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: h1 }
```

```robot
*** Keywords ***
Login Mit
    [Arguments]    ${benutzer}    ${passwort}

    OnFailNOISE    SelectWindow   SignIn
    SetValue       Benutzername   ${benutzer}
    SetValue       Kennwort       ${passwort}
    ClickOn        Anmelden

*** Test Cases ***
Login Gueltig
    Login Mit    userName    password

    SelectWindow       HomePage
    VerifyValue        Willkommensnachricht    Hello userName
```

**Was fällt auf?**

| | POM (Java) | OKW |
|---|---|---|
| Dateien | 3 Java-Klassen | 2 YAML + 1 .robot |
| Code-Zeilen | ~50 | ~30 (davon 20 YAML-Konfiguration) |
| Locatoren | In Java-Klasse eingebettet | In YAML isoliert |
| Interaktionslogik | In jeder Methode selbst geschrieben | In Widget-Klasse (einmal) |
| Seitenwechsel | `return new HomePage(driver)` | `SelectWindow HomePage` |
| Pre-Condition | `if (!getTitle().equals(...)) throw` | `__self__` — automatisch |
| Programmiersprache nötig? | Ja (Java) | Nein (YAML + .robot) |
| Technologiegebunden? | Ja (Selenium) | Nein (Widget-Klasse austauschbar) |
| Testaktivitäten sichtbar? | Nein — `loginValidUser()` verbirgt die Details | Ja — jede Benutzeraktion ist eine eigene Zeile |

Im POM-Testfall steht `signInPage.loginValidUser("userName", "password")`
— ein Methodenaufruf. Was im Detail passiert (welche Felder befüllt
werden, in welcher Reihenfolge, was geklickt wird), bleibt in der
Page-Klasse verborgen. Bei der Fehleranalyse oder einem Review muss
man in die Page-Klasse springen, um den Ablauf zu verstehen.

Im OKW-Test stehen die Benutzeraktivitäten transparent lesbar im
Testfall: `SetValue Benutzername`, `SetValue Kennwort`, `ClickOn Anmelden`.
Jede Aktion ist eine eigene Zeile — Fehleranalyse und Review sind
ohne Codenavigation möglich.

Im POM stecken Locatoren, Interaktionslogik, Seitenwechsel und
Pre-Conditions in **derselben Klasse**. In OKW ist jede Verantwortung
an einer eigenen Stelle: Locatoren in YAML, Interaktion im Widget,
Ablauf im Test, Pre-Condition in `__self__`.

## Vier Probleme mit POM

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

### 3. Jede Interaktion wird separat implementiert

In POM muss jede Methode die **gesamte Interaktionslogik** selbst
implementieren: Warten bis das Element existiert, prüfen ob es im
sichtbaren Bereich liegt, prüfen ob es aktiviert ist, Feld löschen
vor der Eingabe, Wert eingeben. Dasselbe gilt für das Lesen eines
Werts — warten, prüfen, auslesen.

Das muss für **jedes Objekt** und **jede Interaktion** geschrieben
werden. `LoginPage.enter_username()`, `LoginPage.enter_password()`,
`SearchPage.enter_query()` — überall dieselbe Wait-Find-Clear-Type-Logik.

In der Praxis fängt dann jedes Projekt an, ein eigenes Mini-Framework
zu bauen: Hilfsmethoden für Waits, Base-Page-Klassen mit generischen
Methoden, Wrapper um `find_element`. Dieser technische Code vermischt
sich mit der Testfallbeschreibung — und der Test wird unlesbar.

OKW löst das durch **Widget-Klassen**: `WebSe_TextField` implementiert
die gesamte Interaktion (warten, prüfen, löschen, eingeben, auslesen)
**einmal**. Jedes Textfeld im gesamten System nutzt dieselbe Implementierung.

### 4. POM skaliert nicht über Technologiegrenzen

POM stammt ursprünglich aus der Selenium-Welt und löst dort ein
reales DRY-Problem: Locatoren und Interaktionen werden in Page-Klassen
zentralisiert statt über den Testcode verstreut. Das Pattern wird
inzwischen auch bei Playwright, Cypress, Appium und anderen Tools
eingesetzt. Aber jede POM-Implementierung ist an **eine** Technologie
gebunden. Wenn das Projekt auch SAP GUI, Java Swing oder eine REST API
testen muss, braucht man für jede Technologie ein eigenes
Page-Object-Pattern — mit eigener Struktur, eigenen Methoden,
eigenen Konventionen.

Der tiefere Grund: POM denkt in **Methodenaufrufen**
(`LoginPage.enter_username("admin")`), nicht in abstrakten Keywords.
Eine Methode ist an ihre Klasse, ihre Technologie und ihre Seite
gebunden. Ein **elementares Keyword** wie `SetValue Benutzername admin` ist
technologieneutral — es beschreibt *was der Benutzer tut*, nicht
*wie die Technik es umsetzt*. Aus elementaren Keywords baut man
**abstrakte Keywords**, die fachliche Abläufe zusammenfassen:

```robot
Login Admin
    SetValue    Benutzer    admin
    SetValue    Passwort    geheim
    ClickOn     Anmelden
```

`Login Admin` ist ein abstraktes Keyword — zusammengesetzt aus
elementaren Keywords. Eine POM-Methode `LoginPage.login("admin", "geheim")`
sieht ähnlich aus, ist aber an die Klasse `LoginPage` und deren
Technologie gebunden. Das abstrakte Keyword ist frei davon.

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
| Interaktionslogik | Jede Methode implementiert Wait-Find-Act selbst | Widget implementiert einmal, alle nutzen es |
| Technologien | Je eine POM-Implementierung pro Technologie | Alle über denselben Kontrakt |
| Spezialfälle | Neue Methode in Page-Klasse | Widget-Ableitung, eine Methode überschreiben |
| Pflege durch | Entwickler | Tester (YAML) + Entwickler (Widgets) |

## KI und Testautomatisierung: POM vs. OKW

Wenn eine KI (Claude, ChatGPT, Copilot, ...) Tests generiert, reviewt
oder aus bestehendem Code lernt, unterscheiden sich POM und OKW
grundlegend.

### Generierung

| Aspekt | POM | OKW |
|---|---|---|
| Was muss generiert werden? | Java-Klasse mit Locatoren, Methoden, Konstruktor, Treiber-Referenz | YAML (Konfiguration) + .robot (Keywords) |
| Bausteine vorhanden? | Nein — jede Page-Klasse wird von Grund auf geschrieben | Ja — elementare Keywords (`SetValue`, `ClickOn`, `VerifyValue`) sind fertige Bausteine |
| Fehlerraum | Groß — Kompilierfehler, falsche Vererbung, fehlende Imports, falsche Treiber-API | Klein — falscher Widget-Name oder Locator, sofort erkennbar |
| Konsistenz | Variiert pro Projekt (Namenskonventionen, Base-Klassen, Hilfsmethoden) | Immer gleich — dieselben Keywords, dasselbe YAML-Schema |

Eine KI, die OKW-Tests generiert, setzt **vorhandene Bausteine**
zusammen. Eine KI, die POM-Code generiert, muss die gesamte
Interaktionslogik **selbst schreiben** — für jede Seite neu.

### Review

| Aspekt | POM | OKW |
|---|---|---|
| Testfall-Review | Methodenaufruf (`loginValidUser()`) — Details verborgen | Jede Benutzeraktion sichtbar (`SetValue`, `ClickOn`) |
| Page-Klassen-Review | Java-Code mit Treiber-Logik, Locatoren, Seitenwechsel vermischt | YAML ist reines Daten-Review, kein Code |
| Review durch Fachtester | Schwierig — Java-Kenntnisse nötig | Möglich — .robot und YAML sind lesbar ohne Programmierkenntnisse |

Im POM-Review muss die KI (und der Mensch) zwischen Locatoren,
Interaktionslogik und Seitenwechsel in derselben Klasse unterscheiden.
Im OKW-Review sind das getrennte Dateien mit jeweils einer
Verantwortung.

### Lernen und Prompt-Größe

| Aspekt | POM | OKW |
|---|---|---|
| Was muss die KI lernen? | Projekt-spezifische Klassenhierarchie, Konventionen, Base-Page-Methoden | Keyword-Liste + YAML-Schema (kompakt, einheitlich) |
| Prompt-Größe | Groß — gesamte Klassenhierarchie als Kontext nötig | Klein — Keyword-Tabelle + ein YAML-Beispiel reichen |
| Übertragbarkeit | Gelernt für ein Projekt, nicht übertragbar | Gelernt für OKW, gilt für alle Projekte und Technologien |

Eine KI, die einmal OKW gelernt hat, kann Tests für **jede**
OKW-Technologie generieren — Web, SAP GUI, Java Swing. Eine KI,
die ein Selenium-POM-Projekt gelernt hat, muss für jedes neue
Projekt und jede neue Technologie **erneut lernen**.

### Lesbarkeit

```
POM-Test:
    SignInPage signInPage = new SignInPage(driver);
    HomePage homePage = signInPage.loginValidUser("userName", "password");
    assertThat(homePage.getMessageText(), is("Hello userName"));

OKW-Test:
    SelectWindow       SignIn
    SetValue           Benutzername           userName
    SetValue           Kennwort               password
    ClickOn            Anmelden

    SelectWindow       HomePage
    VerifyValue        Willkommensnachricht   Hello userName
```

Für Mensch **und** KI gilt: Der OKW-Test ist Zeile für Zeile
verständlich — jede Zeile ist eine Benutzeraktion. Im POM-Test
steckt die Logik hinter Methodenaufrufen, die erst nach Navigation
in die Page-Klasse verständlich werden.
