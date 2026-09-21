# Signal vs. NOISE

## Das Problem

Wenn ein Testfall fehlschlägt, gibt es zwei mögliche Ursachen:

- **Signal** — Der Test hat einen echten Fehler im **System Under Test
  (SUT)** gefunden. Das ist das Ziel der Testautomatisierung.
- **NOISE** — Der Fehler liegt **nicht** im SUT, sondern im Skript,
  in der Umgebung, im Locator, im Treiber, im Timeout. Es ist ein
  Fehler, der analysiert werden muss, aber keinen SUT-Fehler aufdeckt.

Solange alle Tests grün sind, fällt NOISE nicht auf. Aber sobald ein
Testfall fehlschlägt, beginnt die Analyse: Ist das ein echter
SUT-Fehler (Signal) oder ein technisches Problem (NOISE)?

Je mehr potenzielle NOISE-Quellen im Testcode stecken — eingebettete
Locatoren, Treiber-Setup, Wait-Logik, technische Assertions — desto
öfter schlagen Tests fehl, ohne einen SUT-Fehler zu finden. Und desto
länger dauert die Analyse, um echte Fehler von technischem Rauschen
zu unterscheiden.

## Beispiel: Login-Test

### Ohne OKW (NOISE dominiert)

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Chrome()
driver.get("https://www.saucedemo.com")

wait = WebDriverWait(driver, 10)
username = wait.until(EC.presence_of_element_located((By.ID, "user-name")))
username.clear()
username.send_keys("standard_user")

password = driver.find_element(By.ID, "password")
password.clear()
password.send_keys("secret_sauce")

driver.find_element(By.ID, "login-button").click()

assert "inventory" in driver.current_url
driver.quit()
```

14 Zeilen. Die Testlogik (Benutzer eingeben, Kennwort eingeben, anmelden,
prüfen) ist in Selenium-Aufrufen, Locators und Waits vergraben.

**Was sind potenzielle NOISE-Quellen?**

1. **Technische und fachliche Befehle vermischt** — Imports, Treiber-Setup
   (`webdriver.Chrome()`) und fachliche Aktionen (Benutzer eingeben) stehen
   im selben Code. Den Testfall interessiert nicht, welcher Treiber
   verwendet wird — das beeinträchtigt Lesbarkeit und Reviewfähigkeit.

2. **Wiederholte Interaktionsmuster** — `clear()` vor jedem `send_keys()`
   ist ein technisches Detail der Textfeld-Bedienung. Bei einer Änderung
   des GUI-Verhaltens (z.B. kein `clear()` mehr nötig) müssen alle
   Stellen angepasst werden.

3. **Locatoren im Code eingebettet** — `By.ID, "user-name"` steht direkt
   im Test. Wird dasselbe Element an zehn Stellen verwendet, steht der
   Locator zehnmal im Code — eine Änderung betrifft alle Stellen.

4. **Wait-Logik im Test** — `WebDriverWait` und `expected_conditions`
   sind reine Infrastruktur. Ob und wie lange gewartet wird, ist kein
   fachliches Anliegen des Tests.

5. **Prüfung auf technischer Ebene** — `assert "inventory" in driver.current_url`
   prüft eine URL statt eines fachlichen Zustands. Was fachlich gemeint
   ist: „Die Produktseite ist sichtbar."

6. **Aufräumen ist Testverantwortung** — `driver.quit()` muss manuell
   aufgerufen werden. Vergisst man es, bleibt der Browser offen.

### Mit OKW (Signal dominiert)

```robot
*** Test Cases ***
Login mit gueltigem Benutzer
    OKW.StartApp       MeinAppChrome

    OKW.SelectWindow   Login
    OKW.SetValue       Benutzername    standard_user
    OKW.SetValue       Kennwort        secret_sauce
    OKW.ClickOn        Anmelden

    OKW.SelectWindow   Products
    OKW.VerifyExists   Produktliste    YES

    OKW.StopApp
```

8 Zeilen, jede Zeile ist sofort verständlich. Keine Locators, keine Waits,
keine Selenium-Imports. Der Test liest sich wie eine Bedienungsanleitung.

## Wo ist der Rest geblieben?

| Was | Ohne OKW | Mit OKW |
|---|---|---|
| Locators (`By.ID, "user-name"`) | Im Testcode | In YAML-Dateien |
| Treiber (`webdriver.Chrome()`) | Im Testcode | Im Adapter (YAML `__self__`) |
| Waits (`WebDriverWait`) | Im Testcode | Im Widget (automatisch) |
| Element-Interaktion (`.send_keys()`) | Im Testcode | Im Widget (`okw_set_value`) |

Alles ist noch da — aber an der richtigen Stelle:

```
Test (.robot)     →  Nur Signal: WAS wird getestet
YAML (.yaml)      →  Locators: WO sind die Elemente
Widget (.py)      →  Interaktion: WIE wird bedient
Adapter (.py)     →  Technologie: WELCHER Treiber
```

## Die Trinität: Test — YAML — Widget

OKW trennt Fachlichkeit und Technik durch drei Schichten:

```
┌─────────────────────────┐
│  Test (.robot)           │  Fachsprache — "SetValue Name admin"
│  Nur Signal              │  Kein Locator, kein Treiber, kein Wait
├─────────────────────────┤
│  YAML Locator (.yaml)    │  Mapping — "Name → { name: txtName }"
│  Entkopplungsschicht     │  Verbindet Fachbegriff mit technischer ID
├─────────────────────────┤
│  Widget + Adapter (.py)  │  Technik — "txtName → clear + send_keys"
│  Nur NOISE               │  Treiber, Waits, Element-Interaktion
└─────────────────────────┘
```

**Warum ist das wichtig?**

- Der **Test** spricht die Sprache des Fachtesters: `SetValue Name admin`.
  Kein `txtName`, kein `By.ID`, kein `send_keys`.
- Die **YAML-Datei** ist die Entkopplungsschicht. Sie übersetzt den
  Fachbegriff `Name` in die technische ID `txtName`. Wenn sich die GUI
  ändert (TextField → MultilineField), ändert sich nur die YAML-Datei —
  der Test bleibt unverändert.
- **Widget + Adapter** kapseln die technische Umsetzung. Ob Selenium,
  Swing oder SAP GUI dahinter steckt, ist für den Test unsichtbar.

Diese Trennung macht OKW-Tests **technologieneutral**: Derselbe Test
(`SetValue Name admin`) funktioniert mit Web, Java Swing und SAP GUI —
nur die YAML-Datei und der Adapter sind unterschiedlich.

## Das Prinzip

Jede Designentscheidung in OKW lässt sich auf eine Frage zurückführen:

> **Ist das eine potenzielle NOISE-Quelle?**

Solange alles fehlerfrei läuft, fällt NOISE nicht auf. Aber sobald ein
Fehler auftritt, stellt sich die entscheidende Frage: **An wie vielen
Stellen muss eingegriffen werden, um die Ursache abzustellen?**

OKW eliminiert potenzielle NOISE-Quellen, indem es jede Verantwortung
an genau eine Stelle verschiebt:

- Locators im Test? → Potenzielle NOISE-Quelle → Raus in YAML (eine Stelle)
- Selenium-Imports im Test? → Potenzielle NOISE-Quelle → Raus in den Adapter (eine Stelle)
- Waits im Test? → Potenzielle NOISE-Quelle → Raus ins Widget (eine Stelle)
- `$IGNORE` für irrelevante Schritte? → Entfernt NOISE aus dem Testablauf
- CamelCase-Keywords? → Maximales Signal pro Zeile

Wenn ein Testschritt nicht sofort verständlich ist, enthält er zu viel
potenzielle NOISE-Quellen.
