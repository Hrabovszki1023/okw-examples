# Warum kein Page Object Model?

!!! warning "POM ist nicht konform zu ISO/IEC/IEEE 29119-5"
    Die Norm für Keyword-Driven Testing trennt **Domain Layer**,
    **Decomposer** und **Test Interface Layer**. POM vermischt diese
    Elemente in einer Page-Klasse: fachliche Methoden, Locatoren,
    Interaktionslogik und Seitenwechsel. Damit kann POM die geforderte
    Schichtentrennung strukturell nicht abbilden — OKW schon.
    → Details: [ISO 29119-5: POM ist nicht normkonform](#iso-29119-5-pom-ist-nicht-normkonform)

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
(`LoginPage.enter_username("admin")`), nicht in Keywords.
Eine Methode ist an ihre Klasse, ihre Technologie und ihre Seite
gebunden. Ein **Low-Level Keyword** wie `SetValue Benutzername admin` ist
technologieneutral — es beschreibt *was der Benutzer tut*, nicht
*wie die Technik es umsetzt*. Aus Low-Level Keywords baut man
**High-Level Keywords**, die fachliche Abläufe zusammenfassen:

```robot
Login Admin
    SetValue    Benutzer    admin
    SetValue    Passwort    geheim
    ClickOn     Anmelden
```

`Login Admin` ist ein High-Level Keyword (ISO 29119-5, §3.7) —
zusammengesetzt aus Low-Level Keywords. Eine POM-Methode
`LoginPage.login("admin", "geheim")` sieht ähnlich aus, ist aber an
die Klasse `LoginPage` und deren Technologie gebunden. Das High-Level
Keyword ist frei davon.

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

## ISO 29119-5: POM ist nicht normkonform

Die **ISO/IEC/IEEE 29119-5:2024** definiert Keyword-Driven Testing als
Ansatz mit getrennten Abstraktionsschichten:

| ISO-Schicht | Zweck | OKW-Umsetzung | POM |
|---|---|---|---|
| **Domain Layer** (§5.2.2) | Fachliche Sprache, für Domänenexperten verständlich | `.robot`-Testfälle + High-Level User-Keywords | Existiert nicht als eigene Schicht |
| **Decomposer** (§3.3) | Bricht High-Level Keywords auf Low-Level Keywords herunter | OKW-Core: Keyword-Dispatch + YAML-Loader + Widget-Auflösung | Existiert nicht |
| **Test Interface Layer** (§5.2.3) | Technische Interaktion mit dem Testobjekt | Widget-Klassen + Adapter (Selenium, FlaUI, RemoteSwing, ...) | Page-Klasse (vermischt mit Domain-Logik) |

**Das Kernproblem:** POM vermischt genau das, was die Norm trennen will.

Eine Page-Klasse wie `LoginPage` enthält **gleichzeitig**:

- **Fachliche Methoden** (`loginValidUser()`) → gehört in den Domain Layer
- **Locatoren** (`By.ID, "user-name"`) → gehört in den Test Interface Layer
- **Interaktionslogik** (`findElement`, `sendKeys`, `click`) → gehört in den Test Interface Layer
- **Seitenwechsel** (`return new HomePage(driver)`) → gehört in den Decomposer

Die ISO fordert Trennung — POM liefert einen Monolithen.

**OKW bildet die ISO-Architektur ab:**

```
Domain Layer          Decomposer              Test Interface Layer
─────────────         ──────────              ────────────────────
.robot-Test     →     okw4robot         →     Widget + Adapter
                      YAML-Loader
SetValue              Benutzername:           WebSe_TextField
  Benutzername   →      locator: {id: user}     .okw_set_value("admin")
  admin                                         → element.send_keys()
```

Jede ISO-Schicht hat in OKW eine klare Entsprechung:

- **Domain Layer** = `.robot`-Dateien (fachliche Sprache, kein Code)
- **Decomposer** = OKW-Core + YAML (fachlicher Name → technischer Locator + Widget)
- **Test Interface Layer** = Widget-Klassen + Adapter (technische Interaktion)

Ein Technologiewechsel (z. B. Selenium → FlaUI) betrifft nur den Test
Interface Layer — Domain Layer und Decomposer bleiben unverändert.
Bei POM betrifft ein Technologiewechsel **alles**: neue Page-Klassen,
neue Locatoren, neue Interaktionslogik, neue Tests.

!!! info "Für regulierte Umgebungen"
    In Branchen mit Normkonformitäts-Anforderungen (Automotive, Medizintechnik,
    Finanzwesen) ist die ISO-Konformität von OKW ein direktes Argument:
    Der Testansatz folgt einer internationalen Norm — POM nicht.

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
| Prüfaufwand bei KI-Generierung (Human in the Loop) | Hoch — Framework-Code mit Kontrollstrukturen, vielfach wiederholt | Gering — nur fachliche Keyword-Abfolge |
| ISO 29119-5 konform? | Nein — keine Layer-Trennung, keine Keywords im Sinne der Norm | Ja — Domain Layer, Decomposer, Test Interface Layer |

## KI und Testautomatisierung: POM vs. OKW

Wenn eine KI (Claude, ChatGPT, Copilot, ...) Tests generiert, reviewt
oder aus bestehendem Code lernt, unterscheiden sich POM und OKW
grundlegend.

### Generierung

| Aspekt | POM | OKW |
|---|---|---|
| Was muss generiert werden? | Java-Klasse mit Locatoren, Methoden, Konstruktor, Treiber-Referenz | YAML (Konfiguration) + .robot (Keywords) |
| Bausteine vorhanden? | Nein — jede Page-Klasse wird von Grund auf geschrieben | Ja — Low-Level Keywords (`SetValue`, `ClickOn`, `VerifyValue`) sind fertige Bausteine |
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

### Human in the Loop: Der Mensch ist der Engpass

Erzeugt eine KI Automatisierungsskripte und prüft ein Mensch das
Ergebnis („Human in the Loop“), dann ist der **Mensch die langsamste
Komponente**. Die KI generiert in Sekunden — die Prüfung dauert Minuten
bis Stunden. Beschleunigen lässt sich der Prozess daher vor allem so:
**Es muss möglichst wenig geprüft werden.**

Wie viel ein Mensch prüfen muss, hängt davon ab, wie viel **neuer Code**
entsteht. Bei POM erzeugt die KI Code. Bei OKW setzt sie **geprüfte
Bausteine** zusammen.

#### Beispiel aus der Praxis: Der SauceDemo-Shop

Jede Interaktion mit einem GUI-Objekt muss **einmal** geprüft werden —
z. B. ob die Auswahl in einer ComboBox richtig synchronisiert: Ist das
Element bereit? Ist der Wert nach der Auswahl wirklich gesetzt?

Wie oft das geprüft werden muss, zeigt ein öffentliches POM-Projekt für
den Demo-Shop [saucedemo.com](https://www.saucedemo.com):
[`InventoryPage.java`](https://github.com/Nagraggini/sauce-demo/blob/main/src/main/java/pages/InventoryPage.java) (Java + Selenium).

**POM — was der Reviewer dort prüfen muss:**

| GUI-Objekt | Umsetzung in der Page-Klasse | Prüfaufwand |
|---|---|---|
| Sortier-ComboBox | 4 fast identische Methoden (`changeOrderingAtoZ`, `…ZtoA`, `…LowtoHigh`, `…HightoLow`) — jede wiederholt Warten, Auswahl-Objekt bauen, Wert setzen | 4× dieselbe Synchronisation — für **eine** ComboBox |
| Produktkarte | Der XPath „Karte mit Produktname X“ wird in 4 Methoden per String-Verkettung neu zusammengebaut | 4× derselbe Locator — mit Inkonsistenz: 3× `normalize-space()`, 1× `text()` |

Die Inkonsistenz bei der Produktkarte ist typisch: Der Code sieht an
jeder Stelle *fast* gleich aus. Genau deshalb rutscht der Unterschied
im Review durch.

**OKW — dieselben GUI-Objekte in
[okw-examples](https://github.com/Hrabovszki1023/okw-examples/blob/master/selenium/saucedemo):**

```yaml
# locators/SauceDemoProducts.yaml (Auszug)
Sortierung:
  class: okw_web_selenium.widgets.webse_combobox.WebSe_ComboBox
  locator: { css: 'select[data-test="product-sort-container"]' }

ErsterProduktname:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { xpath: '(//div[@data-test="inventory-item-name"])[1]' }

ProduktKarte:
  __context__:
    locator: { xpath: '//div[@data-test="inventory-item"][.//div[@data-test="inventory-item-name" and text()="{ProduktName}"]]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button' }
```

```robot
# tests/SauceDemo_Sortierung.robot + SauceDemo_SetContext.robot (Auszug)
SelectWindow   SauceDemoProducts
Select         Sortierung           Price (low to high)
VerifyValue    ErsterProduktname    Sauce Labs Onesie

SetContext     ProduktKarte         Sauce Labs Backpack
VerifyValue    Produktpreis         $29.99
ClickOn        InDenWarenkorb
```

| GUI-Objekt | POM | OKW |
|---|---|---|
| Sortier-ComboBox | 4 Methoden, 4× Synchronisation prüfen | 1 YAML-Eintrag — Synchronisation **einmal** in `WebSe_ComboBox` geprüft |
| Produktkarte | 4× Locator per String-Verkettung, inkonsistent | 1× `__context__` — alle Kind-Widgets nutzen ihn |
| Testfall | Methodenaufrufe, Details in der Page-Klasse | Jede Zeile eine fachliche Aussage |

Der Reviewer prüft im OKW-Testfall nur noch: Ist das der richtige Ablauf?

#### Wo bei OKW geprüft wird

| Ebene | DRY auf … | Was geprüft werden muss | Wie oft |
|---|---|---|---|
| **Widget** | GUI-Objekt-Ebene | Interaktion + Synchronisation (z. B. `Select` in ComboBox) | **Einmal** pro Widget-Typ |
| **Testfall** | Testfall-Ebene — Low-Level und logisch nachvollziehbare High-Level Keywords, möglichst ohne Kontrollstrukturen | Nur die fachliche Abfolge | Pro Testfall, wenige Zeilen |
| **YAML** | Locator-Ebene | Fachlicher Name → technischer Locator | Pro GUI-Objekt, reine Daten |

Der Mensch prüft bei OKW die Technik **einmal** — danach nur noch,
**was** getestet wird, nicht mehr, **wie** die Technik es umsetzt.

#### Qualität wächst mit dem Projekt

Jeder Testfall, der ein Widget nutzt, testet das Widget mit. Fehler
werden dadurch früh gefunden, **einmal** behoben und sind dann überall
behoben. Widgets, Low-Level Keywords und die daraus gebauten High-Level
Keywords weisen über den Projektverlauf **zunehmend weniger Fehler** auf.

Bei POM ist das nicht gegeben: Dieselben Strukturen werden immer wieder
neu gebaut — und jede neue Kopie kann neue Fehler enthalten.

| Aspekt | POM | OKW |
|---|---|---|
| Prüfung der ComboBox-Synchronisation | *n*-mal — an jeder Stelle im Code (SauceDemo: 4× für eine ComboBox) | Einmal — im Widget |
| Prüfvolumen pro neuem Testfall | Neuer Framework-Code inkl. Kontrollstrukturen | Wenige Keyword-Zeilen + ggf. YAML-Einträge |
| Prüfaufwand bei wachsender Testbasis | Steigt mit jeder Seite und jedem Testfall | Steigt nur mit neuen Widget-Typen |
| Fehlerrate über den Projektverlauf | Bleibt hoch — Strukturen werden immer neu gebaut | Sinkt — bewährte Bausteine werden wiederverwendet |

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
