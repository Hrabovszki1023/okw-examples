# OKW Examples

Executable examples for [OKW4Robot](https://github.com/Hrabovszki1023/robotframework-okw4robot) --
a driver-agnostic keyword architecture for Robot Framework.

Each example uses **publicly available demo websites** and can be run
immediately after installation. No application code, no test
infrastructure -- just `pip install` and `robot`.

## Quick Start

```bash
pip install -r requirements.txt
```

### Run SauceDemo Login Tests

```bash
cd selenium/saucedemo
robot tests/SauceDemo_Login.robot
```

### Run SauceDemo SetContext Tests

```bash
cd selenium/saucedemo
robot tests/SauceDemo_SetContext.robot
```

### Run ExpandTesting Dynamic Table Test

```bash
cd selenium/expandtesting
robot tests/DynamicTable.robot
```

## Prerequisites

- Python 3.10+
- Chrome browser
- [ChromeDriver](https://chromedriver.chromium.org/) matching your Chrome version

## Examples

| Example | Website | What it demonstrates |
|---|---|---|
| [SauceDemo Login](selenium/saucedemo/) | [saucedemo.com](https://www.saucedemo.com) | Login with valid/invalid/locked users, template-driven tests |
| [SauceDemo SetContext](selenium/saucedemo/) | [saucedemo.com](https://www.saucedemo.com) | Repeating GUI structures (product cards) without per-item locators |
| [Dynamic Table](selenium/expandtesting/) | [expandtesting.com](https://practice.expandtesting.com/dynamic-table) | Table access by header names, dynamic content |

## Project Structure

```
okw-examples/
  requirements.txt
  selenium/
    saucedemo/
      locators/            # YAML GUI object definitions
      tests/               # Robot Framework test suites
      README.md            # Detailed description and comparison
    expandtesting/
      locators/
      tests/
      README.md
```

## How OKW Works

OKW separates **what** to test from **how** to find GUI elements:

- **Tests** use abstract keywords: `SetValue`, `ClickOn`, `VerifyValue`
- **Locators** are defined in YAML files -- no hardcoded selectors in test code
- **Drivers** (Selenium, FlaUI, RemoteSwing) are loaded automatically via YAML config

This means the same test keywords work across web, desktop, and Java Swing
applications. Only the YAML locator files differ.

## Links

- [OKW4Robot Core](https://github.com/Hrabovszki1023/robotframework-okw4robot)
- [OKW Web Selenium Driver](https://github.com/Hrabovszki1023/robotframework-okw-web-selenium)
