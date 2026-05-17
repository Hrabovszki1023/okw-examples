# Hovers — Mouse Hover with MoveOver

**Page:** https://practice.expandtesting.com/hovers

**Test file:** `tests/Hovers.robot`

## What This Example Demonstrates

- **MoveOver** keyword for mouse hover actions.
- **SetContext** for repeating GUI structures (user cards).
- Verifying **hidden elements** that only appear on hover.
- **VerifyExist** to check element visibility.

## Page Specifics

The page shows three user cards, each with an avatar image. The user
information (name and profile link) is **hidden by default** and only
becomes visible when the mouse hovers over the avatar. This is
implemented via CSS `:hover` on the card's `.figure` element.

Key characteristics:
- Three identical card structures — only the user name differs.
- User info is in a `<div class="figcaption">` that is hidden until hover.
- The profile link (`View profile`) only becomes clickable after hover.

## Implementation

### SetContext for Repeating Structures

Instead of defining separate widgets for each user card, the YAML uses
`__context__` with a `{UserName}` placeholder:

```yaml
UserCard:
  __context__:
    locator: { xpath: '//div[@class="figure"][.//h5[contains(text(),"{UserName}")]]' }
  Avatar:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/img[@alt="User Avatar"]' }
  Benutzername:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/h5' }
  ProfilLink:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/a[text()="View profile"]' }
```

In the test, `SetContext` selects the card by user name:

```robot
SetContext      UserCard    user1
MoveOver        Avatar
VerifyValueWCM  Benutzername    *user1*
```

Child locators use **relative XPath** (`.//...`) — they are automatically
scoped to the context element.

### MoveOver Keyword

`MoveOver` uses Selenium's `ActionChains.move_to_element()` to simulate
a real mouse hover. This triggers the CSS `:hover` state and makes the
hidden elements visible.

### OnFailNOISE

The `SetContext` call in phase 3 (navigation to test state) is wrapped
with `OnFailNOISE` — if context setup fails, the test is marked NOISE
instead of FAIL.

## Test Cases

| Test | Verifies |
|---|---|
| MoveOver zeigt User1 Info | Hover on user1 reveals user name |
| MoveOver zeigt User2 Info | Hover on user2 reveals user name |
| MoveOver zeigt User3 Info | Hover on user3 reveals user name |
| MoveOver ProfilLink wird sichtbar | Hover reveals the "View profile" link |
