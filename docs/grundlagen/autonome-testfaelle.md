---
source_hash: ac320e6f9402
---

# Autonomous Test Cases

## What Autonomous Means

A test case is **autonomous** if its result depends only on the SUT and
not on which other test cases ran before it. It meets four conditions:

| # | Condition | Check question |
|---|---|---|
| 1 | **Runs on its own** | Does the test run when you start only this test? |
| 2 | **Independent of order** | Does it deliver the same result wherever it runs in the suite? |
| 3 | **Establishes its own initial state** | Does it fetch data, login and window itself instead of taking them over from a predecessor? |
| 4 | **Leaves nothing others need** | Can another test fail because this test is missing, red or did not clean up? |

The opposite is **chaining**: a test case builds on the result or the
state of another one.

## Why This Is Decisive for the Signal

The page [Strong Signal](strong-signal.md) describes how a test case
must be written so that its result can be unambiguously attributed to
one business aspect. Autonomy is the precondition for this: however
cleanly a chained test case is written, its result still depends on
other test cases.

This becomes particularly clear when something goes wrong. An
autonomous test case that fails during preparation states precisely:
**exactly this** aspect was not tested in this run. A decision can be
based on this, such as releasing anyway because the risk is small (see
["Not Tested" Is Information, Too](strong-signal.md#not-tested-is-information-too)).

In a chain, this information is lost:

| | Autonomous | Chained |
|---|---|---|
| Test 3 of 10 fails | Test 3 is red, 4 to 10 run normally | Test 3 is red, 4 to 10 are **red as well** or do not run at all |
| Which aspects are untested? | Exactly one, named in the test case name | Unclear, has to be reconstructed from the chain |
| What does a follow-up failure look like? | There is none | Like a failure in the follow-up test's **own** feature |
| Result | One F or one N | One N turns into many **apparent Fs** |

## What Else Chaining Costs

Besides the lost signal, a chain causes running costs that only become
apparent in day-to-day work:

| Cost | What happens | Example |
|---|---|---|
| **Forced completeness** | Anyone who needs a test from the middle of the chain has to run all its predecessors as well, even if they have nothing to do with the current question. | To recheck only `Note Loeschen` after a fix, `Login Erfolgreich` and `Note Erstellen Und Pruefen` have to run too. |
| **Administrative effort** | Predecessors and successors have to be maintained: in the order of the file, in naming conventions or as dependencies in the test management tool. These relationships are checked nowhere and silently go stale. | A new test is inserted "somewhere in between" and shifts what its successors find. |
| **Maintenance effort** | A change in one place requires adjustments in many test cases. If a link of the chain is changed, renamed or removed, everything after it breaks. | If `Note Erstellen Und Pruefen` is dropped because the feature is tested differently, `Note Lesen`, `Note Aktualisieren` and `Note Loeschen` turn red immediately. |

With autonomous test cases, all three disappear: every test can be
started on its own, there are no relationships to maintain, and a change
to the preparation affects exactly one high-level keyword such as
`Erzeuge Testnotiz`, not the order of the test cases.

## Forms of Chaining

Chaining is not always obvious. Four forms occur in practice:

| Form | Example | How to recognise it |
|---|---|---|
| **Data chaining** | Test A creates a record and memorises its ID, test B reads it | A test uses a value it did not create itself |
| **State chaining** | Test A logs in, test B continues in the same session | A test starts without `StartApp` or without logging in |
| **Order chaining** | Tests are called `01_Create`, `02_Change`, `03_Delete` | Numbers in the test case name |
| **Hidden chaining** | Test A does not clean up, test B trips over the leftovers | Tests are green on their own, red when run together |

The hidden form is the most dangerous because nobody intended it. In
this repository, `StopApp` used to be the last line of the SauceDemo
test cases. When a test failed, the browser stayed open, and the
following sorting tests turned red although they were green on their
own (see [Strong Signal](strong-signal.md#3-no-unnecessary-steps)).

## Example From This Repository

The REST integration test against the Notes API of expandtesting.com is
built as a chain. One test creates a note and memorises its ID, the
following tests continue working with this ID:

```robot
*** Test Cases ***
Note Erstellen Und Pruefen
    [Setup]    Login Ausfuehren
    RESTSelectEndpoint     /notes
    ...
    RESTSendRequest        POST
    RESTVerifyStatus       200
    RESTMemorizeValue      data.id      NOTE_ID

Note Lesen
    [Setup]    Login Ausfuehren
    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        GET
    RESTVerifyStatus       200
    RESTVerifyValue        data.title       OKW Testnotiz
```

`Note Lesen` does not create `NOTE_ID` itself but takes it over from
`Note Erstellen Und Pruefen`. What this means is shown by an experiment
with three ways of running it:

| Execution | Result of `Note Lesen` |
|---|---|
| Normal order | green |
| Random order (`--randomize tests`) | red: `Memorized key not found: NOTE_ID` |
| Only this test (`--test "Note Lesen"`) | red: `Memorized key not found: NOTE_ID` |

Reading notes works in all three cases. The test is red nevertheless,
and the message says nothing about the SUT. This is an **N** that looks
like a reading failure in the test report.

### Autonomous Version

Each test case creates its note itself and removes it again:

```robot
*** Test Cases ***
Note Lesen
    [Setup]       Erzeuge Testnotiz    OKW Testnotiz
    [Teardown]    Loesche Testnotiz

    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        GET

    RESTVerifyStatus       200
    RESTVerifyValue        data.title       OKW Testnotiz

*** Keywords ***
Erzeuge Testnotiz
    [Arguments]    ${titel}
    Login Ausfuehren
    RESTSelectEndpoint     /notes
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSetValue           title        ${titel}
    RESTSetValue           description  Vorbereitung
    RESTSetValue           category     Work
    RESTSendRequest        POST
    RESTVerifyStatus       200
    RESTMemorizeValue      data.id      NOTE_ID

Loesche Testnotiz
    RESTSelectEndpoint     /notes/$MEM{NOTE_ID}
    RESTSetHeader          x-auth-token    $MEM{TOKEN}
    RESTSendRequest        DELETE
```

If creating the note fails now, Robot Framework reports `Setup failed`
and does not even run the test body. The result is then unambiguous:
"reading not tested in this run", not "reading broken".

!!! note "State in the repository"
    The autonomous version is a proposal. The REST integration test in
    the repository is currently still in the chained form.

## Using Setup and Teardown Correctly

Robot Framework offers preparation and clean-up on two levels. Rule of
thumb: what a test **changes** belongs on test level. What all tests
only **read** may go on suite level.

| Level | Suitable for | Examples from this repository |
|---|---|---|
| `Suite Setup` / `Suite Teardown` | Environment and data that no test changes | Start the Kafka broker, create the test user for the Notes API |
| `Test Setup` / `Test Teardown` | State the test changes or needs for itself | Start the browser and open the login page, close the browser |
| `[Setup]` / `[Teardown]` in the test case | Preparation only this test needs | Create a note that only this test reads |

Two rules prevent hidden chaining:

- **Always clean up in the teardown.** The teardown also runs after a
  failure, the last line of the test case does not.
- **Keep preparation idempotent.** The test must reach its initial
  state from **any** previous state, even if an earlier run was aborted
  (see [Idempotency](idempotenz.md)).

## "But That Takes Longer"

The most common objection: if every test logs in by itself and creates
its own data, the suite runs longer. That is true, but:

- **Autonomous tests can be parallelised.** Chained ones cannot. With a
  tool such as `pabot`, the suite usually becomes **faster** than the
  chain.
- **Preparation does not have to go through the GUI.** Creating test
  data via API or shortcutting the login is a matter of
  [controllability](testbarkeit.md), not of autonomy.
- **Analysis time is more expensive than run time.** One more minute of
  run time costs compute time. An hour spent tracing ten red follow-up
  tests back to one cause costs a person.
- **Individual tests can be repeated.** `robot --rerunfailed` restarts
  only the red tests. This only works if they run on their own.

## Checking Autonomy

Robot Framework has everything needed to uncover chaining:

```bash
robot --randomize tests tests/
```

```bash
robot --test "Note Lesen" tests/
```

```bash
robot --rerunfailed output.xml tests/
```

If a suite behaves differently in random order than in normal order, or
a test fails when started on its own, it is chained. A run with
`--randomize tests` in CI uncovers new chaining before it becomes
entrenched.

## Checklist

!!! tip "Autonomy checklist"
    - The test uses no values created by another test.
    - The test starts the application and logs in by itself (in the setup).
    - No test case name contains an order number.
    - Clean-up is in the teardown, not the last line of the test case.
    - The suite setup only contains what no test changes.
    - The suite is green with `--randomize tests`.
    - Every test is green on its own with `--test "<name>"`.
