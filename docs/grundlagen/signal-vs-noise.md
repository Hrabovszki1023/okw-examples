# Signal vs. NOISE

## Das Problem

Testcode enthält zwei Arten von Information:

- **Signal** — Die eigentliche Testlogik: Was wird getestet? Was ist das erwartete Ergebnis?
- **NOISE** — Technisches Rauschen: Wie findet man das Element? Welcher Treiber wird benutzt? Welche API wird aufgerufen?

Je mehr NOISE im Test steht, desto schwerer ist er zu lesen, zu warten und zu verstehen.

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

14 Zeilen. Die Testlogik (Benutzer eingeben, Kennwort eingeben, anmelden, prüfen)
ist in Selenium-Aufrufen, Locators und Waits vergraben.

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

## Das Prinzip

Jede Designentscheidung in OKW lässt sich auf eine Frage zurückführen:

> **Ist das Signal oder NOISE?**

- Locators im Test? → NOISE → Raus in YAML
- Selenium-Imports im Test? → NOISE → Raus in den Adapter
- Waits im Test? → NOISE → Raus ins Widget
- `$IGNORE` für irrelevante Schritte? → Entfernt NOISE aus dem Testablauf
- CamelCase-Keywords? → Maximales Signal pro Zeile

Wenn ein Testschritt nicht sofort verständlich ist, enthält er zu viel NOISE.
