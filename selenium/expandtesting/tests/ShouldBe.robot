*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     ShouldBe Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/assertions/should-be

*** Test Cases ***
# === 'visible' — Sichtbarkeit pruefen ===

Sichtbarer Button Ist Sichtbar
    [Documentation]    btn1 ist sichtbar (kein hidden-Attribut).
    VerifyIsVisible    SichtbarerButton    YES

Versteckter Button Ist Nicht Sichtbar
    [Documentation]    btn2 hat das hidden-Attribut und ist nicht sichtbar.
    VerifyIsVisible    VersteckterButton    NO

Sichtbare Liste Ist Sichtbar
    [Documentation]    ul1 ist sichtbar (enthaelt sichtbare Eintraege).
    VerifyIsVisible    SichtbareListe    YES

# === 'checked' — Checkbox-Zustand pruefen ===

Checkbox Ist Angehakt
    [Documentation]    cb1 hat das checked-Attribut.
    VerifyValue    AktiveCheckbox    Checked

Checkbox Ist Nicht Angehakt
    [Documentation]    cb2 hat kein checked-Attribut.
    VerifyValue    InaktiveCheckbox    Unchecked

# === 'empty' — Leere Elemente pruefen ===

Leerer Bereich Ist Leer
    [Documentation]    div1 enthaelt keinen Text.
    VerifyValue    LeererBereich    ${EMPTY}

Gefuellter Bereich Hat Inhalt
    [Documentation]    div2 enthaelt den Text "Text for div2".
    VerifyValueWCM    GefuellterBereich    *Text for div2*

# === 'enabled' / 'disabled' — Aktivierungszustand pruefen ===

Aktiver Button Ist Aktiviert
    [Documentation]    btn3 ist enabled (kein disabled-Attribut).
    VerifyIsEnabled    AktiverButton    YES

Deaktivierter Button Ist Deaktiviert
    [Documentation]    btn4 hat das disabled-Attribut.
    VerifyIsEnabled    DeaktivierterButton    NO

# === 'a' — Zahlenwert pruefen ===

Zahlenfeld Hat Wert 8
    [Documentation]    Das Eingabefeld hat den Standardwert 8.
    VerifyValue    Zahlenwert    8

*** Keywords ***
ShouldBe Seite Oeffnen
    # Phase 1-3: App starten und zur ShouldBe-Seite navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   ShouldBePage
