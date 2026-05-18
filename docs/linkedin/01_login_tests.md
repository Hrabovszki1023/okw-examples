# Selenium Automation That Reads Like a Spec — Part 1: Login Tests

**Series: Selenium Test Automation with OKW4Robot**

---

Most Selenium test suites I've seen share the same problem: they're full of CSS selectors, XPaths, and driver calls buried directly in the test code. When the UI changes, you're fixing locators across dozens of files.

What if your test could look like this instead?

## The Test

```robot
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

No selectors. No driver calls. No imports. Just what the test does — in plain language.

Behind those keywords are three simple building blocks:

```robot
Anmelden Mit
    [Arguments]    ${user}    ${password}
    SelectWindow   SauceDemoLogin
    SetValue       Benutzer    ${user}
    SetValue       Passwort    ${password}
    ClickOn        Anmelden

Login Erfolgreich
    SelectWindow       SauceDemoProducts
    VerifyValue        Titel    Products

Login Fehlgeschlagen Mit Meldung
    [Arguments]    ${meldung}
    SelectWindow       SauceDemoLogin
    VerifyValue        Fehlermeldung    ${meldung}
```

`SetValue`, `ClickOn`, `VerifyValue` — these are the **only keywords you need**. They work across any GUI technology: web, desktop, mobile. The same test could run on a Java Swing app tomorrow without changing a single line of test logic.

## Where Are the Locators?

In a YAML file. Completely separate from the test:

```yaml
# SauceDemoLogin.yaml
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

Four widgets. One file. When the `data-test` attribute changes, you fix it here — once — and all 11 test cases keep working.

## 11 Tests, Zero Redundancy

From this setup we get full login coverage:

| Test | What it verifies |
|---|---|
| 5 valid logins | standard, problem, performance_glitch, error, visual user |
| 1 locked user | correct error message |
| 2 wrong credentials | unknown user, wrong password |
| 3 empty fields | no user, no password, both empty |

Every test is two lines: call `Anmelden Mit`, then check the result. The YAML never changes. The keywords never change. Only the test data varies.

## What Makes This Different?

Traditional Selenium Page Object:

```python
class LoginPage:
    def __init__(self, driver):
        self.driver = driver
        self.username = driver.find_element(By.CSS, '[data-test="username"]')
        self.password = driver.find_element(By.CSS, '[data-test="password"]')
        self.login_btn = driver.find_element(By.CSS, '[data-test="login-button"]')

    def login(self, user, pwd):
        self.username.send_keys(user)
        self.password.send_keys(pwd)
        self.login_btn.click()
```

OKW approach:

```yaml
# YAML: what exists on the page
Benutzer:
  locator: { css: '[data-test="username"]' }
```
```robot
# Test: what to do with it
SetValue    Benutzer    standard_user
```

No page class. No constructor. No `driver.find_element`. The YAML declares **what exists**. The test declares **what to do**. OKW connects them.

## Try It Yourself

The full example runs against [saucedemo.com](https://www.saucedemo.com) — a free practice site.

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*Next in this series: How SetContext handles repeating GUI structures — like product cards — without defining each one separately.*

#Selenium #TestAutomation #RobotFramework #QualityAssurance #SoftwareTesting
