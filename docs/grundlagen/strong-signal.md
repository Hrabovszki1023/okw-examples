---
source_hash: ec2917c47ed7
---

# Strong Signal

## From Signal to Strong Signal

[Signal vs. NOISE](signal-vs-noise.md) distinguishes three test results:
**P** (pass), **F** (real SUT failure) and **N** (NOISE, cause outside
the SUT). That does not yet say **how good** a signal is.

A red test that takes half an hour of analysis to find out what is
actually broken does deliver an F, but a **weak** one. A **Strong
Signal** is a test result that shows immediately, without further
analysis:

- **what** was tested,
- **which business aspect** is affected,
- **why** the test is red.

A Strong Signal test case also **never delivers a misleading result**.
If it fails because of NOISE, the meaning is unambiguous: there is **no
valid statement** about this business aspect in this run. It fakes
neither a green nor a red that has nothing to do with its test intent.

## Scope: Test Design and Test Implementation

A signal can be weak for two different reasons:

| Weak because of ... | Question | Example | Topic of this page? |
|---|---|---|---|
| **Test design** | Is the test case suitable for finding a failure? | The n-th test case checks a value in the **middle** of an equivalence class instead of at its **boundaries**. It adds no new insight. | No |
| **Test implementation** | Can the result be unambiguously attributed to one business aspect? | The test case is chained with others or checks several aspects at once. | **Yes** |

Whether the test derivation method is suitable for finding failures
(for example boundary value analysis instead of arbitrary values from
the middle of an equivalence class) is **not** discussed here. This page
assumes a sensibly derived test case and describes how it must be
**written** so that its signal **can** be strong: so that it is not
weakened by chaining with other test cases or by mixed test intents.

A well-derived test case can lose its signal through poor
implementation. A poorly derived test case gains no insight through good
implementation. Both are needed.

## The Eight Properties

| # | Property | In short |
|---|---|---|
| 1 | One test intent | One test, one intent |
| 2 | Immediate stop | The first failure ends the test |
| 3 | No unnecessary steps | Only what serves the test intent |
| 4 | Clear verifications | Expected and actual value are in the failure message |
| 5 | Flat structure | No control structures in the test case |
| 6 | One business acceptance criterion | One cause, one red |
| 7 | Deterministic inputs | Same input, same result |
| 8 | Business names | The test reads like instructions |

### 1. One Test Intent per Test Case

A test case checks **exactly one** business aspect. The login tests for
expandtesting.com show this:

```robot
*** Test Cases ***
Fehlerhafter Benutzername
    SelectWindow       LoginPage
    SetValue           Benutzer       wrongUser
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *invalid*

Fehlerhaftes Passwort
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       WrongPassword
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *invalid*
```

Both cases would have fitted into one test. Kept separate, a red result
tells you immediately **which** of the two cases no longer works.

### 2. The First Failure Ends the Test

Continuing after a failure produces follow-up failures and logs in which
the actual failure gets lost. Robot Framework stops a test case at the
first failure by itself. Do not defeat this protection:

| Avoid in the test case | Why |
|---|---|
| `Run Keyword And Continue On Failure` | The test continues after the failure, follow-up failures hide the cause |
| `Run Keyword And Ignore Error` | A failure silently disappears, the test can turn green although something is broken |
| `TRY` / `EXCEPT` | Hidden recovery logic, the result is no longer unambiguous |

The only deliberate exception in OKW is `OnFailIgnoreNOISE` for steps
that are irrelevant to the business, such as `RemoveAds`.

### 3. No Unnecessary Steps

Every additional step is another place where the test can fail without
the test intent being affected. A test for "wrong password" does not
need to navigate to the start page, log out or check the layout
afterwards.

Clean-up belongs in the `Test Teardown`, not in the test case:

```robot
*** Settings ***
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome
```

This is more than a matter of style. In the SauceDemo tests, `StopApp`
used to be the last line of the test case. When a test failed, this
line was never reached, the browser stayed open, and the **following**
tests failed as well: the sorting tests were green on their own and red
when run together. A failure in one test thus produced two Ns in
others. The teardown, by contrast, always runs, even after a failure.

### 4. Clear Verifications

When a test is red, it must be visible without code analysis which
value was expected and which one actually came. OKW's `Verify*`
keywords deliver exactly that:

```
[VerifyValue] 'Fehlermeldung'
Match failed (mode=MatchMode.EXACT).
Expected: 'Epic sadface: Password is required'
Actual:   'Epic sadface: Username is required'
```

Business name, expected and actual value are right below each other. A
technical check such as `assert "inventory" in driver.current_url`, on
the other hand, only says on failure that a text did not occur in a URL.

### 5. Flat Structure

The test case contains **no** `IF`, `FOR`, `WHILE` or `TRY`. All steps
are listed linearly. This makes every failure location unambiguous and
every run takes the same path.

High-level keywords composed by the test project itself are allowed.
However, they must not contain hidden logic or hidden preconditions
themselves:

```robot
*** Test Cases ***
Login Gesperrter Benutzer
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Sorry, this user has been locked out.
```

### 6. One Business Acceptance Criterion

Every test case ends with **one** business acceptance criterion: the
state that must be reached after the action. This can comprise several
`Verify*` steps as long as they describe the **same** state:

```robot
Erfolgreicher Login
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       SecurePage
    VerifyValueWCM     Willkommensmeldung    *You logged into a secure area*
    VerifyValueWCM     Benutzername          *practice*
    VerifyExists       Abmelden              YES
```

Together, the three verifications describe **one** state: "The user is
logged in." If the same test then also added products to the cart and
checked the total, it would have a **second** test intent. That belongs
in a test of its own.

!!! warning "No acceptance criterion, no signal"
    A test without a final `Verify*` only turns red when something fails
    technically. Whether the application did the right thing from a
    business point of view is never found out. The cart test in this
    repository used to put two products into the cart and end there.
    Only the check `VerifyValue    WarenkorbAnzahl    2` turns it into a
    statement about the SUT.

### 7. Deterministic Inputs

The same inputs must lead to the same results: no random values, no
dependency on date or time of day, no leftover data from earlier runs.

Sometimes a test still needs a unique value. The register test creates
a new user in every run:

```robot
${ts}=             Evaluate    int(__import__('time').time())
SetValue           Benutzer              TestUser${ts}
```

This is acceptable because the **expected value** does not depend on
it: the success message is always the same. Strictly speaking, though,
the timestamp reveals missing [controllability](testbarkeit.md): if the
test could delete the user beforehand, it would not need a unique name.

### 8. Business Names

The steps read in the language of the business domain. In OKW, three
things take care of this:

| Level | Weak | Strong |
|---|---|---|
| Widget name in YAML | `ClickOn    btnLogin45` | `ClickOn    Anmelden` |
| Test case name | `Test 17` | `Login Gesperrter Benutzer` |
| High-level keyword | `Schritt 3` | `Login Fehlgeschlagen Mit Meldung` |

How business names are separated from technical IDs is shown in the
chapter [YAML Locators](yaml-locator.md).

## Example: Weak Signal vs. Strong Signal

### Weak Signal

```robot
*** Test Cases ***
Shop Funktioniert
    SauceDemo Oeffnen Und Anmelden
    SelectWindow    SauceDemoProducts

    Select          Sortierung           Price (low to high)
    Run Keyword And Continue On Failure
    ...    VerifyValue    ErsterProduktname    Sauce Labs Onesie

    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    VerifyValue     WarenkorbAnzahl    2

    StopApp         MyAppChrome
```

This test checks sorting and the cart at once, simply continues after a
sorting failure and cleans up in the test case instead of the teardown.
If it turns red, it is unclear **which** aspect is broken. If the
sorting is wrong but the cart is fine, the whole test still turns red,
and every reader has to open the log.

### Strong Signal

```robot
*** Settings ***
Test Teardown    StopApp    MyAppChrome

*** Test Cases ***
Produkte Nach Preis Aufsteigend Sortieren
    SauceDemo Oeffnen Und Anmelden
    SelectWindow   SauceDemoProducts
    Select         Sortierung           Price (low to high)
    VerifyValue    Sortierung           Price (low to high)
    VerifyValue    ErsterProduktname    Sauce Labs Onesie

SetContext Produkt In Warenkorb
    SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    SelectWindow   SauceDemoProducts
    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    VerifyValue        WarenkorbAnzahl    2
```

Two tests, two test intents. If one turns red, the cause is already in
the name of the test case. That each test logs in by itself is
intended: none depends on the result of another.

!!! note "Origin of the examples"
    The weak signal variant is a deliberately constructed
    counterexample. The strong signal tests are in
    `selenium/saucedemo/tests/SauceDemo_Sortierung.robot` and
    `SauceDemo_SetContext.robot` exactly as shown.

## An N Stays an Honest N

A Strong Signal test can also fail because of NOISE. The difference: it
says so. Steps that only belong to the preparation are guarded with
[`OnFailNOISE`](../gui/web-selenium/index.md#onfailnoise):

```robot
*** Keywords ***
Login Seite Oeffnen
    OnFailNOISE          StartApp       MyAppChrome
    OnFailNOISE          SelectWindow   Chrome
    OnFailNOISE          SetValue       URL    ${URL}
```

If one of these steps fails, the test gets the tag `NOISE` and the
failure message the prefix `[N]`. The result is then not "login broken"
but "login not tested in this run". Which steps these are is described
by the [5-phase model](idempotenz.md#idempotency-in-the-5-phase-model):
failures in phases 1 to 3 are almost always an N.

### "Not Tested" Is Information, Too

This is where it becomes clear why **one aspect per test case** and
**no chaining** belong together. Even if such a test case already fails
during preparation, it delivers a precise statement: **exactly this**
requirement, state or use case was not tested in this run.

With this information, you can decide:

- **Release anyway**, because the risk for this aspect is small.
- **Release anyway**, because experience shows this feature is stable
  and nothing was changed in the affected area.
- **Retest**, specifically only this one test case, or manually.

With chained test cases, this decision is not possible. If the third
test case in a chain of ten fails, test cases four to ten are red as
well or did not run at all. Which requirements are therefore untested
first has to be laboriously reconstructed, and a red follow-up test case
looks like a failure in its own feature. One N thus turns into many
apparent Fs.

!!! info "More on this"
    Which forms of chaining exist, how to recognise them and how test
    cases become independent of each other is described on the page
    [Autonomous Test Cases](autonome-testfaelle.md).

## Checklist

!!! tip "Strong Signal checklist"
    **Focus**

    - The test checks exactly one business aspect.
    - The test case name states this test intent.
    - Every step directly serves the test intent.

    **Initial state**

    - The test does not depend on any other test.
    - Preparation steps are guarded with `OnFailNOISE`.
    - Inputs are deterministic.

    **Flow**

    - No `IF`, `FOR`, `TRY` in the test case.
    - No `Run Keyword And Continue On Failure`, no `Run Keyword And Ignore Error`.
    - No `Sleep`, no wait keywords (see [Testability](testbarkeit.md)).
    - Clean-up is in the teardown.

    **Verification**

    - The test ends with one business acceptance criterion.
    - The failure message shows expected and actual value.

    **The decisive question**

    - When the test turns red: can you see **immediately** what, where and why?

## Relation to the Other Basics

Strong Signal is the goal, the other basics are the means:

| Basic | Contribution to a Strong Signal |
|---|---|
| [YAML Locators](yaml-locator.md) | Business names in the test, technology in one place |
| [Idempotency](idempotenz.md) | Every run reaches the same initial state |
| [Testability](testbarkeit.md) | The test can recognise and establish the state without guessing |
| [Tokens and Match Modes](tokens-und-match-modes.md) | Verifications express exactly the business expectation |

> **One test, one intent, one unambiguous result.**
