---
source_hash: 644dea5bb606
---

# Testability: Observability and Controllability

## The Problem: Waiting Is Guesswork

An automated test is faster than any human. After a click on "Log in",
the next step is already waiting while the application is still
loading, rendering or talking to the server. So the test has to know:
**When is the application ready?**

The obvious answer is a `Sleep`:

```robot
ClickOn        Anmelden
Sleep          3s
VerifyExists   Produktliste    YES
```

But a fixed sleep is **never right**:

- **Too short:** The application is a little slower on that day and
  the test turns red. The cause is not in the SUT but in the test.
  That is an **N** in the sense of [Signal vs. NOISE](signal-vs-noise.md).
- **Too long:** The test keeps waiting even when the application has
  long been ready. The wasted time grows with every occurrence, every
  test case and every run.
- **Not maintainable:** If `3s` later becomes `5s`, every occurrence
  has to be changed.

### What a Sleep Costs

The time wasted per run is
**wait time × occurrences per test × number of tests**:

| Scenario | Wait time | Occurrences per test | Tests | Waste per run |
|---|---|---|---|---|
| One sleep after login | 10 s | 1 | 5,000 | 50,000 s ≈ **13 h 53 min** |
| Three small sleeps | 2 s | 3 | 5,000 | 30,000 s ≈ **8 h 20 min** |
| Many mini sleeps | 1 s | 10 | 5,000 | 50,000 s ≈ **13 h 53 min** |

With a nightly run on 20 working days, multiply by twenty.
Parallelisation only shortens the wall-clock time. The compute time,
and therefore the cost, stays the same.

!!! note "A sleep is a symptom"
    A sleep in a test shows that information is missing: the test
    cannot **see** whether the application is ready. So the problem is
    not the wait time but the **testability** of the SUT.

## Two Properties of the SUT

Testability has two sides:

| Property | Question | Examples |
|---|---|---|
| **Observability** | Can the test reliably **recognise** the state of the SUT? | Element visible and enabled, loading indicator gone, `aria-busy="false"`, unique test IDs |
| **Controllability** | Can the test deliberately **put** the SUT into a state? | Create test data via API, switch off animations, fix the clock, set feature flags |

Both are properties of the **application**, not of the test tool. If
they are missing, the test code has to compensate: with sleeps, with
brittle locators, with long click paths through the GUI to create test
data. Each of these places is a **potential NOISE source**.

| Missing ... | Symptom in the test | Consequence |
|---|---|---|
| Observability of the loading state | `Sleep` | Too short: N. Too long: wasted time |
| Observability of the elements | XPath over layout structures | Every layout change produces an N |
| Controllability of test data | Creating data via the GUI | Long preparation, every step can produce an N |
| Controllability of time | Test depends on date or time of day | Test is only green on certain days |

## How OKW Synchronises

OKW moves waiting out of the test case into the library. The test case
only describes **what** happens. When a widget is ready is decided by
the widget itself.

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

No sleep, no `Wait Until ...`. Still the test waits at exactly the
right places, and only as long as necessary.

### Before Every Action: Is the Widget Ready?

Before Web Selenium performs an action such as `SetValue`, `ClickOn`
or `Select`, the widget checks in turn:

1. **exists:** The element is present in the DOM.
2. **scroll_into_view:** The element is scrolled into the visible area.
3. **visible:** The element is visible.
4. **enabled:** The element is enabled, not `disabled`.
5. **editable:** The input field is writable, not `readonly`
   (text fields only).
6. **until_not_visible:** Project-wide loading indicators have
   disappeared (see below).

Each check is repeated every 0.1 s until it is met or the timeout
(default: 10 s) expires. If the widget is ready after 0.3 s, the test
continues after 0.3 s.

!!! info "Driver-dependent"
    This action synchronisation is currently implemented in the Web
    Selenium library. Verification with a timeout (next section), on the
    other hand, applies to **all** drivers because it lives in the
    OKW4Robot core.

### On Every Verification: Has the Expected Value Been Reached?

All `Verify*` keywords do not check once but **repeatedly**: they read
the actual value, compare it with the expected value and try again
until it matches or the timeout expires.

```robot
ClickOn        Speichern
VerifyValue    Statusmeldung    Gespeichert    # waits up to 10 s for the text
```

This makes the verification itself the synchronisation. A preceding
wait is unnecessary. This works because `Verify*` keywords only read
and are therefore [idempotent](idempotenz.md): they may be repeated any
number of times.

| Variable | Default | Applies to |
|---|---|---|
| `${OKW_TIMEOUT_VERIFY_VALUE}` | 10 s | `VerifyValue` and variants |
| `${OKW_TIMEOUT_VERIFY_EXISTS}` | 2 s | `VerifyExists`, `VerifyWindowExists` |
| `${OKW_TIMEOUT_VERIFY_VISIBLE}` | 2 s | `VerifyIsVisible` |
| `${OKW_TIMEOUT_VERIFY_ENABLED}` | 2 s | `VerifyIsEnabled` |
| `${OKW_POLL_VERIFY}` | 0.1 s | Polling interval of all `Verify*` |

### Timeout Instead of Wait Time

The decisive difference from a sleep:

| | Sleep | OKW timeout |
|---|---|---|
| Meaning | Fixed wait time | **Upper limit** |
| Application fast | Still waits the full time | Continues immediately |
| Application slow | Turns red (N) | Waits up to the limit |
| Increasing the value costs | Time in **every** run | Time only when the application really is slow |

Choosing a generous timeout is therefore almost free. Choosing a
generous sleep is expensive.

## Using Observability: Loading Indicators

Many applications show a spinner or a semi-transparent overlay while
loading. As long as it is visible, the elements underneath exist but
cannot be operated. This is exactly where the urge to add a sleep
usually comes from.

If the application makes its loading indicator **observable**, OKW
uses it directly. One variable is enough project-wide:

```robot
*** Variables ***
${OKW_BUSY_SELECTORS_WRITE}    css:.spinner, css:.busy-overlay
```

Before every action, OKW then additionally waits until these elements
have disappeared.

If only a single widget needs special handling, this is configured on
the widget in YAML. The test stays unchanged:

```yaml
Speichern:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '[data-testid="btn-save"]' }
  wait:
    write:
      timeout: 20
      until_not_visible:
        - css:.page-overlay
```

The rule behind it is the same as for [YAML locators](yaml-locator.md):
technical knowledge lives in **one** place, not in every test case.

## Setting Timeouts Correctly

| Level | Mechanism | When |
|---|---|---|
| **Global** | Default values | Fits most of the time |
| **Project** | `*** Variables ***` in a resource file | The application is generally slower |
| **Widget** | `wait:` block in YAML | A single widget is a special case |
| **Test case** | `SetOKWParameter    TimeOutVerifyValue    20s` | One test exceptionally needs more time |
| **Execution** | `robot --variable OKW_TIMEOUT_VERIFY_VALUE:30s` | Slow CI environment, debugging |

Rule of thumb: configure as high up as possible. A timeout in the test
case is allowed but should remain the exception.

## Controllability: What Development Can Contribute

Observability helps the test **wait**. Controllability helps it avoid
waiting in the first place. The following features live in the
application. The test team cannot build them itself but should request
them from development early:

| Feature | Purpose | Effect on the test |
|---|---|---|
| **Test mode** | The application knows it is being tested | Switches on the following features together |
| **Animations off** | No transition effects | Less wait time, no half-visible elements |
| **Test data via API** | Create the initial state directly | Short, stable preparation instead of a GUI click path |
| **Fixed clock** | Set date and time | Date-dependent tests behave the same every day |
| **Feature flags** | Switch features on or off deliberately | Tests run independently of the rollout state |
| **Stable test IDs** | `data-testid` on operable elements | Locators survive layout changes |

Test data via API can be created with the
[OKW REST library](../spezial/rest-api.md) in the same test case. This
keeps preparation (phases 1 and 2 in the
[5-phase model](idempotenz.md#idempotency-in-the-5-phase-model)) short
and idempotent.

!!! warning "Never enable test mode in production"
    A test mode that shortcuts logins or changes the clock must not be
    activatable in production. It belongs behind an environment
    configuration that only exists on test systems.

## Example From This Repository

The register test for expandtesting.com contains a sleep after removing
the ads:

```robot
Register Seite Oeffnen
    OnFailNOISE          StartApp       MyAppChrome

    OnFailNOISE          SelectWindow   Chrome
    OnFailNOISE          SetValue       URL    ${URL}
    OnFailIgnoreNOISE    RemoveAds
    Sleep    1
    OnFailNOISE          VerifyWindowExists    RegisterPage    YES
```

At first glance it looks superfluous: `VerifyWindowExists` checks
repeatedly anyway, and the login test next to it has the same flow
without a sleep. A measurement shows something else:

| Variant | Runs | Result |
|---|---|---|
| With `Sleep 1` | 6 × 4 tests | 24 green |
| Without `Sleep` | 7 × 4 tests | 26 green, 2 red |

Both red tests failed at the first `SetValue` with
`element not interactable`, although OKW had checked beforehand that
the field exists, is visible and is enabled. So the field was
**apparently ready** for OKW but could not be operated yet. Both
failures are an **N**: the registration itself worked correctly.

This is exactly what this chapter is about: the sleep bridges a
**missing signal**. Something on the page (such as a lazily loaded
element or a layout shift after the ads are removed) briefly makes the
field inoperable without this being observable from outside. The right
fix is to find the cause and register it as a busy selector. As long as
it is unknown, the sleep remains a deliberately accepted, **known**
NOISE source in exactly one place, not in every test case.

## Rules of Thumb

- **No `Sleep` in a test case.** If you need one, you have found a
  missing signal.
- **Fix the missing signal, do not bridge it:** first use a `Verify*`
  step as synchronisation, then register a loading indicator as a busy
  selector, and finally ask development for a signal.
- **Timeouts are upper limits.** Choose them generously, configure them
  centrally.
- **Testability is a requirement on the SUT.** Observability and
  controllability belong in development as early as possible, not only
  in test automation.
