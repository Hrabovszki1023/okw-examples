---
source_hash: 95d43bb3f533
---

# OKW4Robot Manual

OKW4Robot is a driver-agnostic keyword architecture for Robot Framework.
One set of keywords — `SetValue`, `ClickOn`, `VerifyValue` — works across
all GUI technologies: web, Java Swing, SAP GUI, Windows desktop.
Standalone libraries extend the pattern to REST, SSH and Kafka.

## Who Is This Manual For?

This manual is for **test automation engineers who already know Robot
Framework**. Basics such as `*** Settings ***`, `*** Test Cases ***` or
running tests with `robot` are assumed.

## What You Will Learn

| Chapter | Content |
|---|---|
| **Basics** | The OKW philosophy, keywords, YAML locators, tokens |
| **GUI Libraries** | Web Selenium, Java Swing, SAP GUI — step by step |
| **Environment Libraries** | Docker and Proxmox: provision test environments automatically |
| **Special Libraries** | REST API, SSH, Kafka — tests beyond the GUI |
| **Interplay** | How all libraries work together in an end-to-end test |

## Quick Start

```bash
pip install robotframework-okw4robot robotframework-okw-web-selenium
```

```robot
*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW

*** Test Cases ***
Google Suche
    OKW.StartApp       MeinAppChrome

    OKW.SelectWindow   Suchseite
    OKW.SetValue       Suchfeld       Robot Framework
    OKW.ClickOn        Suchen

    OKW.StopApp
```

That is a complete OKW test. No locators in the test, no Page Object
Model, no Selenium imports. The next chapter explains how it works.

!!! note "German business names"
    The widget, window and test names in the examples (`Suchfeld`,
    `Suchen`, `Benutzer`) are German, because they come unchanged from
    the runnable okw-examples repository. Use the business language of
    your own domain.

## All Examples Are Runnable

Every code example in this manual comes from the
[okw-examples](https://github.com/Hrabovszki1023/okw-examples) repository.
The tests can be run directly — clone, install, run.
