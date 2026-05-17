# SauceDemo Login — Form-Based Authentication

**Page:** https://www.saucedemo.com

**Test file:** `tests/SauceDemo_Login.robot`

## What This Example Demonstrates

- **SetValue** and **ClickOn** for basic form interaction.
- **Positive and negative login tests** with shared helper keywords.
- **Error message verification** for different failure scenarios.
- **OnFailNOISE** for preparation phases (app start, navigation).
- Reusable keyword pattern: `Anmelden Mit` (login), `Login Erfolgreich`
  (success check), `Login Fehlgeschlagen Mit Meldung` (failure check).

## Page Specifics

SauceDemo is a demo e-commerce site by Sauce Labs with pre-defined
test users. The login page has:

- Username and password text fields.
- A login button.
- An error message container that appears on failed login attempts.
- Multiple test users with different behaviors (standard, locked out,
  problem, performance glitch, error, visual).

## Implementation

### Keyword Abstraction

The test uses three helper keywords that map to the test phases:

```robot
Anmelden Mit    ${benutzer}    ${passwort}     # Phase 4: Action
Login Erfolgreich                               # Phase 5: Success verification
Login Fehlgeschlagen Mit Meldung    ${meldung}  # Phase 5: Failure verification
```

This allows writing each test case as a single line:

```robot
Login Standard User
    Anmelden Mit    standard_user    secret_sauce
    Login Erfolgreich
```

### Window Switching

After login, the test switches to a different OKW window:
- **Success:** `SelectWindow SauceDemoProducts` — the product listing page.
- **Failure:** `SelectWindow SauceDemoLogin` — stays on the login page.

The `SelectWindow` calls in verification keywords are wrapped with
`OnFailNOISE` because they are navigation to the verification state
(phase 3), not the verification itself.

## Test Cases

| Category | Test | Verifies |
|---|---|---|
| Valid | Login Standard User | Standard user can log in |
| Valid | Login Problem User | Problem user can log in |
| Valid | Login Performance Glitch User | Slow user can log in |
| Valid | Login Error User | Error user can log in |
| Valid | Login Visual User | Visual user can log in |
| Locked | Login Gesperrter Benutzer | Locked user gets error message |
| Invalid | Login Unbekannter Benutzer | Unknown user gets error message |
| Invalid | Login Falsches Passwort | Wrong password gets error message |
| Empty | Login Ohne Benutzer | Empty username gets error message |
| Empty | Login Ohne Passwort | Empty password gets error message |
| Empty | Login Ohne Benutzer Und Passwort | Both empty gets error message |
