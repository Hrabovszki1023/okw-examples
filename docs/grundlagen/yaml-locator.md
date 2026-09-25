---
source_hash: c97d9ae1c743
---

# YAML Locators

## Locators Do Not Belong in the Test

In OKW, all GUI elements are defined in YAML files. The test references
widgets only by their **business name** — the technical locator stays in
the YAML file.

### Why This Separation?

1. **Readability** — test cases contain only business identifiers
   (`Benutzer`, `Anmelden`, `Fehlermeldung`). Technical locators such as
   `#wnd[0]/usr/txtRSYST-BNAME` are NOISE and disrupt reading.

2. **DRY** — if a locator changes (e.g. because the ID in the HTML
   changes), it is adjusted in **exactly one place** — the YAML file.
   All tests using the widget keep working immediately.

3. **Separation of object recognition and flow logic** — the YAML file
   describes *what* exists on the screen (object recognition). The test
   describes *what the user does* (flow logic). In the Page Object Model
   (POM) both aspects are mixed in one class — on a technology change
   (e.g. web → SAP GUI) the POM must be rewritten completely. In OKW the
   flow logic (keywords, test sequences) stays unchanged — only the YAML
   locators and widget classes are exchanged.

4. **DRY at interaction level** — the widget class encapsulates the
   technical interaction with a GUI element. How a text field is filled,
   cleared or read is implemented **once** in `WebSe_TextField` — not n
   times at every place where a text field occurs. In POM the same
   Selenium logic (find element, clear, type text) is written again in
   every page class.
   → See also: [Page Level Instead of Component Level](warum-kein-pom.md#1-page-level-instead-of-component-level)

## Structure of a YAML File

A YAML file has three levels: **App → Window → Widget**.

```yaml
MeineApp:                              # App name (for StartApp)
  __self__:                            # Adapter configuration
    class: okw_web_selenium.adapters.selenium_web.SeleniumWebAdapter
    browser: chrome

  Login:                               # Window name (for SelectWindow)
    Benutzername:                      # Widget name (for SetValue, ClickOn, ...)
      class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
      locator: { id: "user-name" }

    Kennwort:
      class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
      locator: { id: "password" }

    Anmelden:
      class: okw_web_selenium.widgets.webse_button.WebSe_Button
      locator: { id: "login-button" }
```

## The Keys

Every widget has two mandatory keys:

| Key | Purpose | Example |
|---|---|---|
| `class` | Widget class (determines the behavior) | `webse_textfield.WebSe_TextField` |
| `locator` | Where to find the element | `{ id: "user-name" }` |

The optional key `label_for` connects a label with an input field.

## Locator Strategies

Each technology has its own locator strategies:

### Web Selenium

| Strategy | Example |
|---|---|
| `id` | `{ id: "user-name" }` |
| `xpath` | `{ xpath: "//input[@name='q']" }` |
| `css` | `{ css: "input.search-field" }` |
| `name` | `{ name: "username" }` |

### SAP GUI

| Strategy | Example |
|---|---|
| `id` | `{ id: "wnd[0]/usr/txtRSYST-BNAME" }` |
| `hlabel` | `{ hlabel: "Benutzer" }` |
| `vlabel` | `{ vlabel: "Mandant" }` |

### Java RemoteSwing

| Strategy | Example |
|---|---|
| `name` | `{ name: "txtUsername" }` |

## Choose Business Names

Widget names in YAML are **business terms**, not technical IDs:

```yaml
# Good: business names
Benutzername:
  locator: { id: "user-name" }
Kennwort:
  locator: { id: "password" }

# Bad: technical IDs as names
user-name:
  locator: { id: "user-name" }
password:
  locator: { id: "password" }
```

The test should read like an operating manual:

```robot
SetValue    Benutzername    admin       # Understandable
SetValue    user-name       admin       # Technical — NOISE
```

## Modular Structure with !include

Large applications are split into several YAML files:

```yaml
# Allpages.yaml — collects all pages
LoginPage: !include LoginPage.yaml
Dashboard: !include Dashboard.yaml
Einstellungen: !include Einstellungen.yaml

# MeinAppChrome.yaml — app definition
MeinAppChrome:
  __self__:
    class: okw_web_selenium.adapters.selenium_web.SeleniumWebAdapter
    browser: chrome
  Chrome: !include Chrome.yaml
  _pages: !include-merge Allpages.yaml
```

**Rules:**

- `!include` — embeds the content of a file under a key
- `!include-merge` — inserts the keys of the file **flat** (no extra nesting)
- Add new pages only in `Allpages.yaml` — all app definitions get them automatically

This lets you use the same page structure for Chrome and Firefox — only
`__self__.browser` and the browser widgets differ.
