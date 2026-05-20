*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/login

*** Test Cases ***
Erfolgreicher Login
    [Documentation]    Prueft den Login mit gueltigem Benutzer und Passwort.
    ...    Nach dem Login wird die Secure-Seite angezeigt mit Willkommensmeldung.
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       SecurePage
    VerifyValueWCM     Willkommensmeldung    *You logged into a secure area*
    VerifyValueWCM     Benutzername          *practice*
    VerifyExists       Abmelden              YES

Fehlerhafter Benutzername
    [Documentation]    Prueft den Login mit falschem Benutzernamen.
    ...    Es wird eine Fehlermeldung auf der Login-Seite angezeigt.
    SelectWindow       LoginPage
    SetValue           Benutzer       wrongUser
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValue        Fehlermeldung    Invalid username.

Fehlerhaftes Passwort
    [Documentation]    Prueft den Login mit korrektem Benutzer aber falschem Passwort.
    ...    Es wird eine Fehlermeldung auf der Login-Seite angezeigt.
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       WrongPassword
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValue     Fehlermeldung    Invalid password.

*** Keywords ***
Login Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    VerifyWindowExists    LoginPage    YES
