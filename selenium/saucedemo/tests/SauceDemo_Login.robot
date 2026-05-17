*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
Login Seite Oeffnen
    # Phase 1-3: App starten und zur Login-Seite navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

Anmelden Mit
    [Arguments]    ${benutzer}    ${passwort}
    # Phase 3: Navigation zum Testzustand
    OnFailNOISE    SelectWindow   SauceDemoLogin
    # Phase 4: Testaktion — Login ausfuehren
    SetValue       Benutzer    ${benutzer}
    SetValue       Passwort    ${passwort}
    ClickOn        Anmelden

Login Erfolgreich
    # Phase 3: Fensterwechsel ist Navigation
    OnFailNOISE    SelectWindow       SauceDemoProducts
    # Phase 5: Verifikation
    VerifyValue        Titel    Products

Login Fehlgeschlagen Mit Meldung
    [Arguments]    ${meldung}
    # Phase 3: Fensterwechsel ist Navigation
    OnFailNOISE    SelectWindow       SauceDemoLogin
    # Phase 5: Verifikation
    VerifyValue        Fehlermeldung    ${meldung}

*** Test Cases ***
# === Gueltige Logins ===

Login Standard User
    [Documentation]    Prueft Login mit dem Standard-Testbenutzer.
    Anmelden Mit    standard_user    secret_sauce
    Login Erfolgreich

Login Problem User
    [Documentation]    Prueft Login mit dem Problem-Testbenutzer.
    Anmelden Mit    problem_user    secret_sauce
    Login Erfolgreich

Login Performance Glitch User
    [Documentation]    Prueft Login mit dem Performance-Glitch-Testbenutzer.
    Anmelden Mit    performance_glitch_user    secret_sauce
    Login Erfolgreich

Login Error User
    [Documentation]    Prueft Login mit dem Error-Testbenutzer.
    Anmelden Mit    error_user    secret_sauce
    Login Erfolgreich

Login Visual User
    [Documentation]    Prueft Login mit dem Visual-Testbenutzer.
    Anmelden Mit    visual_user    secret_sauce
    Login Erfolgreich

# === Gesperrter Benutzer ===

Login Gesperrter Benutzer
    [Documentation]    Prueft Fehlermeldung bei gesperrtem Benutzer.
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Sorry, this user has been locked out.

# === Ungueltige Logins ===

Login Unbekannter Benutzer
    [Documentation]    Prueft Fehlermeldung bei unbekanntem Benutzernamen.
    Anmelden Mit    performance_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Username and password do not match any user in this service

Login Falsches Passwort
    [Documentation]    Prueft Fehlermeldung bei falschem Passwort.
    Anmelden Mit    standard_user    standard_user
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Username and password do not match any user in this service

Login Ohne Benutzer
    [Documentation]    Prueft Fehlermeldung wenn Benutzername leer ist.
    Anmelden Mit    ${EMPTY}    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Username is required

Login Ohne Passwort
    [Documentation]    Prueft Fehlermeldung wenn Passwort leer ist.
    Anmelden Mit    standard_user    ${EMPTY}
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Password is required

Login Ohne Benutzer Und Passwort
    [Documentation]    Prueft Fehlermeldung wenn beides leer ist.
    Anmelden Mit    ${EMPTY}    ${EMPTY}
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Username is required
