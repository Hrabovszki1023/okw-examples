---
source_hash: acc0253bbc48
---

# Why Not Page Object Model?

!!! warning "POM does not conform to ISO/IEC/IEEE 29119-5"
    The standard for keyword-driven testing separates the **Domain
    Layer**, the **Decomposer** and the **Test Interface Layer**. POM
    mixes these elements in one page class: business methods, locators,
    interaction logic and page transitions. POM therefore cannot
    structurally represent the required layer separation — OKW can.
    → Details: [ISO 29119-5: POM Is Not Conformant](#iso-29119-5-pom-is-not-conformant)

## What POM Solves

The Page Object Model (POM) is the industry standard for Selenium tests.
The idea: locators do not belong in the test, but in separate classes —
one per page.

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

That is better than locators directly in the test. But it has limits.

!!! note "Selenium's own example violates POM"
    The Selenium documentation shows, as a negative example, a login
    test **without** POM — with locators directly in the test code. It
    reveals another problem: the check
    `assertThat(h1.getText(), is("Hello userName"))` does not belong to
    the login page, but to the **following page** after the login.
    Logically correct would be: after clicking "Sign in", the login page
    verifies that it has **disappeared**. That the welcome page appears
    and shows "Hello userName" is a check of the **following page** — it
    belongs in the test case or in a welcome page object, but definitely
    not in the POM of the login page. At this point it is simply
    illogical and mixes two different page responsibilities.

Selenium itself describes POM as offering a "clean separation between
test code and page-specific code". That is not quite true: the page
class contains **both** locators and interaction logic (`find_element`,
`send_keys`, `click`). The mixing is not resolved — it is merely moved
from the test into the page class.

DRY is also only **partially** achieved: locators appear once per page
class, but the interaction logic (find element, wait, clear, type) is
written again in every method and every page class. The only
inheritance in practice: a `BasePage` defines the driver call centrally,
and all page POMs inherit from it. Inheritance goes no further — there
is no widget level that encapsulates interaction patterns for text
fields, checkboxes or dropdowns across technologies.

## Selenium's "Correct" Solution — Compared with OKW

The [Selenium documentation](https://www.selenium.dev/documentation/test_practices/encouraged/page_object_models/)
shows two page classes and a test as the correct POM solution:

```java
// SignInPage.java — page object for the sign-in page
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
// HomePage.java — page object for the following page
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
// TestLogin.java — the actual test
public class TestLogin {
    @Test
    public void testLogin() {
        SignInPage signInPage = new SignInPage(driver);
        HomePage homePage = signInPage.loginValidUser("userName", "password");
        assertThat(homePage.getMessageText(), is("Hello userName"));
    }
}
```

Three files, about 50 lines of Java code. `loginValidUser()` contains
the interaction logic (`findElement`, `sendKeys`, `click`), the page
transition (`return new HomePage`) and the locators — all in one method.

### The Same Task with OKW

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

**What stands out?**

| | POM (Java) | OKW |
|---|---|---|
| Files | 3 Java classes | 2 YAML + 1 .robot |
| Lines of code | ~50 | ~30 (20 of them YAML configuration) |
| Locators | Embedded in the Java class | Isolated in YAML |
| Interaction logic | Written by hand in every method | In the widget class (once) |
| Page transition | `return new HomePage(driver)` | `SelectWindow HomePage` |
| Pre-condition | `if (!getTitle().equals(...)) throw` | `__self__` — automatic |
| Programming language required? | Yes (Java) | No (YAML + .robot) |
| Tied to a technology? | Yes (Selenium) | No (widget class exchangeable) |
| Test activities visible? | No — `loginValidUser()` hides the details | Yes — every user action is its own line |

The POM test case contains `signInPage.loginValidUser("userName",
"password")` — one method call. What happens in detail (which fields are
filled, in which order, what is clicked) stays hidden in the page class.
For failure analysis or a review, you have to jump into the page class
to understand the flow.

In the OKW test the user activities are transparent in the test case:
`SetValue Benutzername`, `SetValue Kennwort`, `ClickOn Anmelden`. Every
action is its own line — failure analysis and review are possible
without code navigation.

In POM, locators, interaction logic, page transitions and pre-conditions
sit in **the same class**. In OKW every responsibility has its own
place: locators in YAML, interaction in the widget, flow in the test,
pre-condition in `__self__`.

## Four Problems with POM

→ Why OKW solves these problems differently: [Why This Separation?](yaml-locator.md#why-this-separation)

### 1. Page Level Instead of Component Level

POM works at **page level**: every page gets its own class with its own
methods. `LoginPage.enter_username()`, `SearchPage.enter_query()`,
`ProfilePage.enter_name()` — three different methods that all do the
same thing: enter text into a text field.

OKW works at **component level**: a `TextField` widget knows how to
enter text. That applies to **every** text field in the whole system —
login, search, profile, whatever the page.

```
POM:    LoginPage.enter_username("admin")      # Method for this page only
        SearchPage.enter_query("OKW")          # Different method, same action
        ProfilePage.enter_name("Max")          # Yet another method

OKW:    SetValue    Benutzername    admin       # One keyword for all
        SetValue    Suchbegriff     OKW         # text fields everywhere
        SetValue    Name            Max
```

That is **DRY at component level**: a text field is implemented once,
not again on every page.

### 2. POM Requires Programmers

POM classes are Python code: classes, methods, inheritance,
constructors. A tester without programming experience cannot maintain
them.

OKW locators are YAML — configuration, not code:

```yaml
Login:
  Benutzername:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { id: "user-name" }
```

A tester can create, change and extend locators without writing a single
line of Python.

### 3. Every Interaction Is Implemented Separately

In POM every method has to implement the **entire interaction logic**
itself: wait until the element exists, check that it is in the visible
area, check that it is enabled, clear the field before input, enter the
value. The same applies to reading a value — wait, check, read.

This has to be written for **every object** and **every interaction**.
`LoginPage.enter_username()`, `LoginPage.enter_password()`,
`SearchPage.enter_query()` — the same wait-find-clear-type logic
everywhere.

In practice, every project then starts building its own mini framework:
helper methods for waits, base page classes with generic methods,
wrappers around `find_element`. This technical code mixes with the test
case description — and the test becomes unreadable.

OKW solves this with **widget classes**: `WebSe_TextField` implements the
entire interaction (wait, check, clear, type, read) **once**. Every text
field in the whole system uses the same implementation.

### 4. POM Does Not Scale Across Technology Boundaries

POM originally comes from the Selenium world and solves a real DRY
problem there: locators and interactions are centralised in page classes
instead of being scattered across test code. The pattern is now also
used with Playwright, Cypress, Appium and other tools. But every POM
implementation is tied to **one** technology. If the project also has to
test SAP GUI, Java Swing or a REST API, you need a separate page object
pattern for each technology — with its own structure, its own methods,
its own conventions.

The deeper reason: POM thinks in **method calls**
(`LoginPage.enter_username("admin")`), not in keywords. A method is tied
to its class, its technology and its page. A **low-level keyword** such
as `SetValue Benutzername admin` is technology-neutral — it describes
*what the user does*, not *how the technology implements it*. From
low-level keywords you build **high-level keywords** that summarise
business flows:

```robot
Login Admin
    SetValue    Benutzer    admin
    SetValue    Passwort    geheim
    ClickOn     Anmelden
```

`Login Admin` is a high-level keyword (ISO 29119-5, §3.7) — composed of
low-level keywords. A POM method `LoginPage.login("admin", "geheim")`
looks similar, but is tied to the class `LoginPage` and its technology.
The high-level keyword is free of that.

OKW uses **the same keywords** for all technologies:

```robot
# Web
OKW.SetValue       Benutzername    admin

# SAP GUI
OKW.SetValue       Benutzer        admin

# Java Swing
OKW.SetValue       txtUsername     admin
```

The test reads the same, whatever technology is behind it. Only the YAML
file and the widget class change.

## Widget Inheritance Instead of Page Classes

OKW widgets follow an inheritance hierarchy:

```
OkwWidget                          # Contract: okw_set_value, okw_get_value, ...
  └── WebSe_Base                   # Web-specific: find Selenium element
        └── WebSe_TextField        # Standard text field
              └── MeinDatumsfeld   # Project derivation: calendar popup
```

If a project has a special widget — e.g. a date field with a calendar
popup — you derive from the standard widget class and override only the
one method that works differently:

```python
class MeinDatumsfeld(WebSe_TextField):

    def okw_set_value(self, value):
        """Oeffnet den Kalender und waehlt das Datum."""
        self._pre_write()
        self.adapter.click(self.locator)           # Open calendar
        self.adapter.click({"xpath": f"//td[text()='{value}']"})  # Pick date
```

Nothing changes in the test:

```robot
SetValue    Geburtsdatum    15.09.2026
```

The tester does not notice that there is a special widget behind
`Geburtsdatum` (date of birth). That is Signal vs. NOISE in its purest
form.

## ISO 29119-5: POM Is Not Conformant

**ISO/IEC/IEEE 29119-5:2024** defines keyword-driven testing as an
approach with separate abstraction layers:

| ISO layer | Purpose | OKW implementation | POM |
|---|---|---|---|
| **Domain Layer** (§5.2.2) | Business language, understandable for domain experts | `.robot` test cases + high-level user keywords | Does not exist as a separate layer |
| **Decomposer** (§3.3) | Breaks high-level keywords down into low-level keywords | OKW core: keyword dispatch + YAML loader + widget resolution | Does not exist |
| **Test Interface Layer** (§5.2.3) | Technical interaction with the test object | Widget classes + adapters (Selenium, FlaUI, RemoteSwing, ...) | Page class (mixed with domain logic) |

**The core problem:** POM mixes exactly what the standard wants to
separate.

A page class such as `LoginPage` contains **at the same time**:

- **Business methods** (`loginValidUser()`) → belong in the Domain Layer
- **Locators** (`By.ID, "user-name"`) → belong in the Test Interface Layer
- **Interaction logic** (`findElement`, `sendKeys`, `click`) → belongs in the Test Interface Layer
- **Page transitions** (`return new HomePage(driver)`) → belong in the Decomposer

The ISO standard requires separation — POM delivers a monolith.

**OKW maps the ISO architecture:**

```
Domain Layer          Decomposer              Test Interface Layer
─────────────         ──────────              ────────────────────
.robot test     →     okw4robot         →     Widget + adapter
                      YAML loader
SetValue              Benutzername:           WebSe_TextField
  Benutzername   →      locator: {id: user}     .okw_set_value("admin")
  admin                                         → element.send_keys()
```

Every ISO layer has a clear counterpart in OKW:

- **Domain Layer** = `.robot` files (business language, no code)
- **Decomposer** = OKW core + YAML (business name → technical locator + widget)
- **Test Interface Layer** = widget classes + adapters (technical interaction)

A technology change (e.g. Selenium → FlaUI) affects only the Test
Interface Layer — Domain Layer and Decomposer stay unchanged. With POM,
a technology change affects **everything**: new page classes, new
locators, new interaction logic, new tests.

!!! info "For regulated environments"
    In industries with conformance requirements (automotive, medical
    devices, finance), OKW's ISO conformance is a direct argument: the
    test approach follows an international standard — POM does not.

## Summary

| Criterion | POM | OKW |
|---|---|---|
| Abstraction level | Page | Component (widget) |
| Locator format | Python code | YAML configuration |
| Reuse | Per page | Per widget type (DRY) |
| Interaction logic | Every method implements wait-find-act itself | Widget implements it once, everyone uses it |
| Technologies | One POM implementation per technology | All via the same contract |
| Special cases | New method in the page class | Widget derivation, override one method |
| Maintained by | Developers | Testers (YAML) + developers (widgets) |
| Review effort for AI generation (human in the loop) | High — framework code with control structures, repeated many times | Low — business keyword sequence only |
| ISO 29119-5 conformant? | No — no layer separation, no keywords in the sense of the standard | Yes — Domain Layer, Decomposer, Test Interface Layer |

## AI and Test Automation: POM vs. OKW

When an AI (Claude, ChatGPT, Copilot, ...) generates tests, reviews them
or learns from existing code, POM and OKW differ fundamentally.

### Generation

| Aspect | POM | OKW |
|---|---|---|
| What must be generated? | Java class with locators, methods, constructor, driver reference | YAML (configuration) + .robot (keywords) |
| Building blocks available? | No — every page class is written from scratch | Yes — low-level keywords (`SetValue`, `ClickOn`, `VerifyValue`) are ready-made building blocks |
| Error space | Large — compile errors, wrong inheritance, missing imports, wrong driver API | Small — wrong widget name or locator, immediately visible |
| Consistency | Varies per project (naming conventions, base classes, helper methods) | Always the same — same keywords, same YAML schema |

An AI generating OKW tests assembles **existing building blocks**. An AI
generating POM code has to **write** the entire interaction logic
**itself** — again for every page.

### Review

| Aspect | POM | OKW |
|---|---|---|
| Test case review | Method call (`loginValidUser()`) — details hidden | Every user action visible (`SetValue`, `ClickOn`) |
| Page class review | Java code with driver logic, locators, page transitions mixed | YAML is a pure data review, no code |
| Review by business testers | Difficult — Java knowledge required | Possible — .robot and YAML are readable without programming skills |

In a POM review, the AI (and the human) must distinguish between
locators, interaction logic and page transitions within the same class.
In an OKW review, these are separate files with one responsibility each.

### Human in the Loop: The Human Is the Bottleneck

When an AI generates automation scripts and a human reviews the result
("human in the loop"), the **human is the slowest component**. The AI
generates in seconds — the review takes minutes to hours. The process
can therefore be accelerated mainly in one way: **as little as possible
must be reviewed.**

How much a human has to review depends on how much **new code** is
created. With POM, the AI produces code. With OKW, it assembles
**already reviewed building blocks**.

#### A Real-World Example: The SauceDemo Shop

Every interaction with a GUI object has to be reviewed **once** — e.g.
whether the selection in a ComboBox synchronises correctly: is the
element ready? Is the value really set after the selection?

How often this has to be reviewed is shown by a public POM project for
the demo shop [saucedemo.com](https://www.saucedemo.com):
[`InventoryPage.java`](https://github.com/Nagraggini/sauce-demo/blob/main/src/main/java/pages/InventoryPage.java) (Java + Selenium).

**POM — what the reviewer has to check there:**

| GUI object | Implementation in the page class | Review effort |
|---|---|---|
| Sort ComboBox | 4 almost identical methods (`changeOrderingAtoZ`, `…ZtoA`, `…LowtoHigh`, `…HightoLow`) — each repeats wait, build select object, set value | 4× the same synchronisation — for **one** ComboBox |
| Product card | The XPath "card with product name X" is rebuilt in 4 methods by string concatenation | 4× the same locator — with an inconsistency: 3× `normalize-space()`, 1× `text()` |

The inconsistency in the product card is typical: the code looks
*almost* the same everywhere. That is exactly why the difference slips
through the review.

**OKW — the same GUI objects in
[okw-examples](https://github.com/Hrabovszki1023/okw-examples/blob/master/selenium/saucedemo):**

```yaml
# locators/SauceDemoProducts.yaml (excerpt)
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
# tests/SauceDemo_Sortierung.robot + SauceDemo_SetContext.robot (excerpt)
SelectWindow   SauceDemoProducts
Select         Sortierung           Price (low to high)
VerifyValue    ErsterProduktname    Sauce Labs Onesie

SetContext     ProduktKarte         Sauce Labs Backpack
VerifyValue    Produktpreis         $29.99
ClickOn        InDenWarenkorb
```

| GUI object | POM | OKW |
|---|---|---|
| Sort ComboBox | 4 methods, review synchronisation 4× | 1 YAML entry — synchronisation reviewed **once** in `WebSe_ComboBox` |
| Product card | 4× locator by string concatenation, inconsistent | 1× `__context__` — all child widgets use it |
| Test case | Method calls, details in the page class | Every line is a business statement |

In the OKW test case the reviewer only checks: is this the right flow?

#### Where Reviews Happen in OKW

| Level | DRY at … | What must be reviewed | How often |
|---|---|---|---|
| **Widget** | GUI object level | Interaction + synchronisation (e.g. `Select` in a ComboBox) | **Once** per widget type |
| **Test case** | Test case level — low-level and logically comprehensible high-level keywords, ideally without control structures | Only the business sequence | Per test case, a few lines |
| **YAML** | Locator level | Business name → technical locator | Per GUI object, pure data |

With OKW the human reviews the technology **once** — after that only
**what** is tested, no longer **how** the technology implements it.

#### Quality Grows with the Project

Every test case that uses a widget tests the widget as well. Defects are
found early, fixed **once**, and then fixed everywhere. Widgets,
low-level keywords and the high-level keywords built from them show
**fewer and fewer defects** over the course of the project.

With POM this is not the case: the same structures are built again and
again — and every new copy can contain new defects.

| Aspect | POM | OKW |
|---|---|---|
| Reviewing ComboBox synchronisation | *n* times — at every place in the code (SauceDemo: 4× for one ComboBox) | Once — in the widget |
| Review volume per new test case | New framework code incl. control structures | A few keyword lines + YAML entries if needed |
| Review effort as the test base grows | Grows with every page and every test case | Grows only with new widget types |
| Defect rate over the project | Stays high — structures are rebuilt again and again | Falls — proven building blocks are reused |

### Learning and Prompt Size

| Aspect | POM | OKW |
|---|---|---|
| What must the AI learn? | Project-specific class hierarchy, conventions, base page methods | Keyword list + YAML schema (compact, uniform) |
| Prompt size | Large — the whole class hierarchy is needed as context | Small — keyword table + one YAML example are enough |
| Transferability | Learned for one project, not transferable | Learned for OKW, applies to all projects and technologies |

An AI that has learned OKW once can generate tests for **every** OKW
technology — web, SAP GUI, Java Swing. An AI that has learned a Selenium
POM project has to **learn again** for every new project and every new
technology.

### Readability

```
POM test:
    SignInPage signInPage = new SignInPage(driver);
    HomePage homePage = signInPage.loginValidUser("userName", "password");
    assertThat(homePage.getMessageText(), is("Hello userName"));

OKW test:
    SelectWindow       SignIn
    SetValue           Benutzername           userName
    SetValue           Kennwort               password
    ClickOn            Anmelden

    SelectWindow       HomePage
    VerifyValue        Willkommensnachricht   Hello userName
```

For humans **and** AI alike: the OKW test is understandable line by line
— every line is a user action. In the POM test the logic hides behind
method calls that only become understandable after navigating into the
page class.
