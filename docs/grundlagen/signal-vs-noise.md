---
source_hash: f88489a7ac62
---

# Signal vs. NOISE

## The Problem

**Signal** is every reliable statement about the state of the **system
under test (SUT)** — a green test just as much as a test that finds a
real defect. **NOISE** is a red test whose cause does **not** lie in the
SUT, but in the script, the environment, the locator, the driver, the
synchronisation or the test data.

| Symbol | Meaning | Value |
|---|---|---|
| **P** (Pass) | Test confirms the expected behavior of the SUT | Signal |
| **F** (Fail) | Test reveals a real defect in the SUT | Signal |
| **N** (NOISE) | Test fails, the cause is not in the SUT | Effort without insight |

This gives two sums:

- **Total signal:** S = P + F
- **All red tests:** X = F + N

**The core problem:** whoever looks at a red test run only sees X — not F
and N separately. The separation has to be done by analysis. F is what
you are looking for. N costs the same analysis, but yields no insight
into the SUT.

The larger the test suite, the smaller the NOISE rate must be —
otherwise the analysis effort grows with every new test case. Stability
is not a fixed property, but a **growing requirement**. If it is not
met, test automation tips over: red test
runs become normal, tests are ignored or simply re-run — **alarm
fatigue**. What regression tests are for is lost: the reliable signal
"green = everything is fine".

### Where NOISE Comes From

The more potential NOISE sources the test code contains — embedded
locators, driver setup, wait logic, technical assertions — the more often
tests fail without finding an SUT defect. And the longer the analysis
takes to separate F from N. The following example shows where these
sources hide — and how OKW removes them from the test case.

!!! note "Signal or NOISE"
    Strictly speaking, NOISE only arises when a test turns **red** (X)
    and the cause does not lie in the SUT — then it is an **N**. A
    locator in the test code or a wait is not a failure in itself.

    When this manual says briefly "locators are NOISE" or "technical
    code is NOISE", it always means: **a potential NOISE source** — a
    place where an N can arise later. OKW's goal is to remove these
    sources from the test case before they turn into an N.

## Example: Login Test

### Without OKW (NOISE dominates)

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

14 lines. The test logic (enter user, enter password, log in, verify) is
buried in Selenium calls, locators and waits.

**What are the potential NOISE sources?**

1. **Technical and business commands mixed** — imports, driver setup
   (`webdriver.Chrome()`) and business actions (enter user) sit in the
   same code. The test case does not care which driver is used — this
   hurts readability and reviewability.

2. **Repeated interaction patterns** — `clear()` before every
   `send_keys()` is a technical detail of operating a text field. If the
   GUI behavior changes (e.g. `clear()` is no longer needed), every
   occurrence must be changed.

3. **Locators embedded in code** — `By.ID, "user-name"` sits directly in
   the test. If the same element is used in ten places, the locator
   appears ten times — one change affects all of them.

4. **Wait logic in the test** — `WebDriverWait` and
   `expected_conditions` are pure infrastructure. Whether and how long
   to wait is not a business concern of the test.

5. **Verification on a technical level** —
   `assert "inventory" in driver.current_url` checks a URL instead of a
   business state. What is meant is: "The product page is visible."

6. **Cleanup is the test's responsibility** — `driver.quit()` must be
   called manually. Forget it, and the browser stays open.

### With OKW (Signal dominates)

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

8 lines, every line is immediately understandable. No locators, no
waits, no Selenium imports. The test reads like an operating manual.

## Where Did the Rest Go?

| What | Without OKW | With OKW |
|---|---|---|
| Locators (`By.ID, "user-name"`) | In test code | In YAML files |
| Driver (`webdriver.Chrome()`) | In test code | In the adapter (YAML `__self__`) |
| Waits (`WebDriverWait`) | In test code | In the widget (automatic) |
| Element interaction (`.send_keys()`) | In test code | In the widget (`okw_set_value`) |

Everything is still there — but in the right place:

```
Test (.robot)     →  Signal only: WHAT is tested
YAML (.yaml)      →  Locators: WHERE the elements are
Widget (.py)      →  Interaction: HOW it is operated
Adapter (.py)     →  Technology: WHICH driver
```

## The Trinity: Test — YAML — Widget

OKW separates business and technology through three layers:

```
┌─────────────────────────┐
│  Test (.robot)           │  Business language — "SetValue Name admin"
│  Signal only             │  No locator, no driver, no wait
├─────────────────────────┤
│  YAML locator (.yaml)    │  Mapping — "Name → { name: txtName }"
│  Decoupling layer        │  Connects business term with technical ID
├─────────────────────────┤
│  Widget + adapter (.py)  │  Technology — "txtName → clear + send_keys"
│  NOISE only              │  Driver, waits, element interaction
└─────────────────────────┘
```

**Why does this matter?**

- The **test** speaks the language of the business tester:
  `SetValue Name admin`. No `txtName`, no `By.ID`, no `send_keys`.
- The **YAML file** is the decoupling layer. It translates the business
  term `Name` into the technical ID `txtName`. When the GUI changes
  (TextField → MultilineField), only the YAML file changes — the test
  stays the same.
- **Widget + adapter** encapsulate the technical implementation. Whether
  Selenium, Swing or SAP GUI is behind it is invisible to the test.

This separation makes OKW tests **technology-neutral**: the same test
(`SetValue Name admin`) works with web, Java Swing and SAP GUI — only the
YAML file and the adapter differ.

## The Principle

Every design decision in OKW can be traced back to one question:

> **Is this a potential NOISE source?**

As long as everything runs without errors, NOISE goes unnoticed. But as
soon as an error occurs, the decisive question is: **In how many places
do you have to intervene to eliminate the cause?**

OKW eliminates potential NOISE sources by moving each responsibility to
exactly one place:

- Locators in the test? → Potential NOISE source → Move to YAML (one place)
- Selenium imports in the test? → Potential NOISE source → Move to the adapter (one place)
- Waits in the test? → Potential NOISE source → Move to the widget (one place)
- `$IGNORE` for irrelevant steps? → Removes NOISE from the test flow
- CamelCase keywords? → Maximum Signal per line

If a test step is not immediately understandable, it contains too many
potential NOISE sources.
