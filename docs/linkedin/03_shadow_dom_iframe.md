# Selenium Automation That Reads Like a Spec — Part 3: Shadow DOM & iFrames

**Series: Selenium Test Automation with OKW4Robot**

---

Two words that make Selenium testers groan: **Shadow DOM** and **iFrames**.

Shadow DOM elements are invisible to standard selectors. iFrames require `switch_to.frame()` / `switch_to.default_content()` calls scattered across your code. Both break the clean Page Object pattern. Both create maintenance nightmares.

But here's the thing: **the tester shouldn't care.**

A button is a button. Whether it sits in the main DOM, inside a Shadow Root, or behind an iFrame — the user clicks it the same way. So should the test.

## The Test (Shadow DOM)

```robot
Normaler Button Hat Text
    VerifyValue    NormalerButton    Here's a basic button example.

Shadow Button Hat Text
    VerifyValue    ShadowButton    This button is inside a Shadow DOM.
```

Two buttons. Same keyword. The test doesn't know — or care — that one lives inside a Shadow Root.

## The YAML (Shadow DOM)

```yaml
NormalerButton:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { id: my-btn }

ShadowButton:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  shadow_host: { css: '#shadow-host' }
  locator: { css: '#my-btn' }
```

One extra line: `shadow_host`. That's it. OKW navigates through the Shadow Root automatically using Selenium 4's `shadow_root` API.

**Technical note:** Only CSS selectors work inside Shadow DOM. This isn't an OKW limitation — it's a browser limitation. `document.evaluate()` (XPath) refuses Shadow Roots as context nodes. OKW validates this and gives you a clear error if you accidentally use XPath.

## The Test (iFrames)

```robot
Email Abonnieren Erfolgreich
    SetValue       EmailEingabe        test@example.com
    ClickOn        AbonnierenButton
    VerifyValue    Erfolgsmeldung      You are now subscribed!

Zwischen Zwei IFrames Wechseln
    VerifyValue       AbonnierenButton    Subscribe
    VerifyValueWCM    EditorBody          *content goes here*
    VerifyValueWCM    IFrameUeberschrift  *inbox*
```

Three different iFrames accessed in sequence. No `switch_to.frame()`. No `switch_to.default_content()`. OKW tracks the active frame and switches automatically.

## The YAML (iFrames)

```yaml
# Main page (no iframe)
Seitentitel:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { xpath: '//h1' }

# Email subscribe iframe
EmailEingabe:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  iframe: { id: email-subscribe }
  locator: { id: email }

# TinyMCE editor iframe
EditorBody:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  iframe: { id: mce_0_ifr }
  locator: { id: tinymce }
```

Again, one extra line: `iframe`. OKW handles the rest:

1. Element on main page? → ensure `default_content()`
2. Element in iframe A? → switch to iframe A, stay there
3. Next element in iframe B? → switch to B automatically
4. Back to main page? → switch to `default_content()`

Unlike Shadow DOM, iFrames support **both CSS and XPath** — no restrictions.

## The Pattern

Both features follow the same design principle:

| Feature | YAML key | Test code change | Selector support |
|---|---|---|---|
| Shadow DOM | `shadow_host: { css: '...' }` | None | CSS only |
| iFrame | `iframe: { id: '...' }` | None | CSS + XPath |

The boundary information lives in YAML. The test stays clean. The adapter handles switching transparently.

This is what driver-agnostic means: **technical details belong in the locator definition, not in the test logic.**

## Try It Yourself

Both examples run against [practice.expandtesting.com](https://practice.expandtesting.com).

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*Next in this series: Drag & Drop — how to simulate HTML5 drag events that Selenium's ActionChains simply can't trigger.*

#Selenium #TestAutomation #RobotFramework #ShadowDOM #QualityAssurance #SoftwareTesting
