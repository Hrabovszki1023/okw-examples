# Selenium Automation That Reads Like a Spec — Part 6: Hover Effects

**Series: Selenium Test Automation with OKW4Robot**

---

Some UI elements only appear when you hover over them. Tooltip text, user profile overlays, dropdown menus, action buttons on card components — they're invisible until the mouse enters.

Selenium handles this with ActionChains:

```python
ActionChains(driver).move_to_element(avatar).perform()
```

But in a test suite, you also need to set up the right context first. If there are three user cards and each reveals different info on hover, you need to target the right card, hover, then verify the right content.

## The Test

```robot
MoveOver zeigt User1 Info
    SetContext      UserCard    user1
    MoveOver        Avatar
    VerifyValueWCM  Benutzername    *user1*

MoveOver zeigt User2 Info
    SetContext      UserCard    user2
    MoveOver        Avatar
    VerifyValueWCM  Benutzername    *user2*

MoveOver ProfilLink wird sichtbar
    SetContext      UserCard    user1
    MoveOver        Avatar
    VerifyExist     ProfilLink    YES
```

`SetContext` selects the card. `MoveOver` triggers the hover. `VerifyValueWCM` checks the revealed content. `VerifyExist` confirms the hidden link appeared.

Same keywords, different context. Three user cards tested with zero code duplication.

## The YAML

```yaml
UserCard:
  __context__:
    locator:
      xpath: >-
        //div[@class="figure"]
        [.//h5[text()="name: {UserName}"]]
  Avatar:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/img' }
  Benutzername:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/h5' }
  ProfilLink:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/a[contains(text(),"View profile")]' }
```

The `__context__` pattern (from Part 2) scopes all child widgets to a specific user card. `MoveOver` moves the mouse to the `Avatar` image within that card's context — triggering the CSS `:hover` state and revealing the hidden elements.

## When to Use MoveOver

| Scenario | Example |
|---|---|
| Tooltip verification | `MoveOver Feld` → `VerifyTooltip Feld Hilfetext` |
| Hidden overlay content | `MoveOver Avatar` → `VerifyValue Name admin` |
| Dropdown menu trigger | `MoveOver Datei` → `ClickOn Neu` |
| Existence check | `MoveOver Card` → `VerifyExist DeleteButton YES` |

`MoveOver` uses Selenium's ActionChains internally — the same mechanism — but wrapped in OKW's sync and retry logic. The element is waited for, scrolled into view, and then hovered.

## Try It Yourself

The example runs against [practice.expandtesting.com/hovers](https://practice.expandtesting.com/hovers).

Code: [github.com/Hrabovszki1023/okw-examples](https://github.com/Hrabovszki1023/okw-examples)
Framework: [github.com/Hrabovszki1023/robotframework-okw4robot](https://github.com/Hrabovszki1023/robotframework-okw4robot)

---

*This concludes the first season of the series. All six examples — login tests, repeating structures, Shadow DOM & iFrames, drag & drop, dynamic tables, and hover effects — are available on GitHub.*

#Selenium #TestAutomation #RobotFramework #QualityAssurance #SoftwareTesting
