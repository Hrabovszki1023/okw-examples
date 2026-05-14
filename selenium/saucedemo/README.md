# SauceDemo -- OKW Selenium Examples

Tests against [saucedemo.com](https://www.saucedemo.com), a public demo
e-commerce site by Sauce Labs.

## Run

```bash
pip install -r ../../requirements.txt
robot tests/
```

## Test Results

<details>
<summary>SauceDemo Login -- 3 tests, 3 passed (click to expand)</summary>

```
==============================================================================
SauceDemo Login
==============================================================================
Login Mit Gueltigem Benutzer :: Prueft Login mit allen gueltigen B... | PASS |
------------------------------------------------------------------------------
Login Mit Ungueltigem Benutzer :: Prueft Fehlermeldungen bei ungue... | PASS |
------------------------------------------------------------------------------
Login Mit Gesperrtem Benutzer :: Prueft Fehlermeldung bei gesperrt... | PASS |
------------------------------------------------------------------------------
SauceDemo Login                                                       | PASS |
3 tests, 3 passed, 0 failed
==============================================================================
```

</details>

<details>
<summary>SauceDemo SetContext -- 2 tests, 2 passed (click to expand)</summary>

```
==============================================================================
SauceDemo SetContext
==============================================================================
SetContext Produktpreise Pruefen :: Prueft Preise verschiedener Pr... | PASS |
------------------------------------------------------------------------------
SetContext Produkt In Warenkorb :: Legt zwei Produkte ueber SetCon... | PASS |
------------------------------------------------------------------------------
SauceDemo SetContext                                                  | PASS |
2 tests, 2 passed, 0 failed
==============================================================================
```

</details>

**Detailed Reports (interactive):**
- [Log -- full keyword trace with screenshots](results/log.html)
- [Report -- test summary](results/report.html)

## Test Suites

### SauceDemo_Login.robot

Login tests with valid, invalid, and locked-out users using Robot Framework
templates for data-driven testing.

**Test cases:**
- Login with 5 valid users (template-driven)
- Login with 5 invalid credential combinations (template-driven)
- Login with locked-out user

### SauceDemo_SetContext.robot

Demonstrates `SetContext` for repeating GUI structures. Product cards on the
inventory page are accessed by product name -- no per-product locators needed.

**Test cases:**
- Verify prices of multiple products via SetContext
- Add products to cart via SetContext

## YAML Locator Files

All GUI element definitions are in `locators/`. No hardcoded selectors appear
in the test code.

| File | Purpose |
|---|---|
| `MyAppChrome.yaml` | App definition: Chrome browser + all pages |
| `Chrome.yaml` | Browser window (URL bar, maximize) |
| `SauceDemoLogin.yaml` | Login page (username, password, login button, error message) |
| `SauceDemoProducts.yaml` | Products page with `SetContext` for product cards |
| `Allpages.yaml` | Page collector (add new pages here) |

## Comparison with Standard Approaches

### Login: OKW vs. Page Object Model (Python)

A common Selenium approach uses the Page Object Model with explicit methods
for each action. Compare:

**Standard POM** ([source](https://github.com/dhodi-fahad/saucedemo-selenium-tests)):

```python
class LoginPage:
    def __init__(self, driver):
        self.driver = driver

    def enter_username(self, username):
        self.driver.find_element(By.ID, "user-name").send_keys(username)
        sleep(1)

    def enter_password(self, password):
        self.driver.find_element(By.ID, "password").send_keys(password)
        sleep(1)

    def click_login_btn(self):
        self.driver.find_element(By.ID, "login-button").click()
        sleep(1)

    def login(self, username, password):
        self.enter_username(username)
        self.enter_password(password)
        self.click_login_btn()
        sleep(1)
```

**OKW:**

```robot
Anmelden Mit
    [Arguments]    ${benutzer}    ${passwort}
    SelectWindow   SauceDemoLogin
    SetValue       Benutzer    ${benutzer}
    SetValue       Passwort    ${passwort}
    ClickOn        Anmelden
```

| Aspect | Standard POM | OKW |
|---|---|---|
| Lines of code | 4 methods, ~15 lines Python | 5 lines Robot |
| Locators | Hardcoded in each method | YAML (separate file) |
| Sleeps | `sleep(1)` after every action | None (polling-based) |
| Additional files | LoginPage.py + test file | YAML + test file |

### Product Cards: OKW SetContext vs. Explicit Per-Product Keywords

A common Robot Framework approach creates explicit branches for each product.
Compare:

**Standard Robot Framework** ([source](https://github.com/mithaputrianty/SauceDemoRobotFramework/blob/master/steps/product_steps.robot)):

```robot
User click Add to cart button on one of product ${product_name}
    Run Keyword If    '${product_name}'=='Sauce Labs Backpack'
    ...    Click Element    ${add_product_button}[backpack]
    Run Keyword If    '${product_name}'=='Sauce Labs Bolt T-Shirt'
    ...    Click Element    ${add_product_button}[boltshirt]
    Run Keyword If    '${product_name}'=='Sauce Labs Fleece Jacket'
    ...    Click Element    ${add_product_button}[fleecejacket]
    Run Keyword If    '${product_name}'=='Sauce Labs Onesie'
    ...    Click Element    ${add_product_button}[onesie]
    Run Keyword If    '${product_name}'=='Sauce Labs Bike Light'
    ...    Click Element    ${add_product_button}[bikelight]
```

This pattern is repeated **8 times** in the original code (add, remove, verify,
cart-remove, ...) with `Sleep 2s` after every action.

**OKW with SetContext:**

```robot
Produkt In Warenkorb Legen
    [Arguments]    ${produkt}
    SetContext     ProduktKarte    ${produkt}
    ClickOn        InDenWarenkorb
```

| Aspect | Standard | OKW + SetContext |
|---|---|---|
| New product added to shop | Change ~40 lines across 8 keywords | 0 lines -- just use the new name |
| Locators | Hardcoded per product | 1x in YAML, parameterized |
| Sleeps | `Sleep 2s` x ~15 per test | None |
| Add-to-cart keyword | 7 lines (5 branches) | 3 lines |

## Related Projects (for Comparison)

- [dhodi-fahad/saucedemo-selenium-tests](https://github.com/dhodi-fahad/saucedemo-selenium-tests) -- Python/Selenium with Page Object Model
- [mithaputrianty/SauceDemoRobotFramework](https://github.com/mithaputrianty/SauceDemoRobotFramework) -- Robot Framework with SeleniumLibrary (explicit per-product keywords)
- [PaulVaroutsos/SauceDemo-Automation](https://github.com/PaulVaroutsos/SauceDemo-Automation) -- Python/Selenium/Pytest
- [hoangthach252/RobotFrameworkDemo](https://github.com/hoangthach252/RobotFrameworkDemo) -- Robot Framework with Playwright/Browser Library
- [reinaldorossetti/robot_atdd_playwright_saucedemo](https://github.com/reinaldorossetti/robot_atdd_playwright_saucedemo) -- Robot Framework with Playwright and Allure
