*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Register Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/register

*** Test Cases ***
Erfolgreiche Registrierung
    [Documentation]    Prueft die Registrierung mit gueltigem Benutzer und Passwort.
    ...    Nach der Registrierung wird auf die Login-Seite weitergeleitet
    ...    mit der Erfolgsmeldung "Successfully registered, you can log in now."
    ${ts}=             Evaluate    int(__import__('time').time())
    SelectWindow       RegisterPage
    SetValue           Benutzer              TestUser${ts}
    SetValue           Passwort              Test1234!
    SetValue           PasswortBestaetigen   Test1234!
    ClickOn            Registrieren

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *Successfully registered, you can log in now.*

Fehlender Benutzername
    [Documentation]    Prueft die Registrierung ohne Benutzername.
    ...    Es wird die Fehlermeldung "All fields are required." angezeigt.
    SelectWindow       RegisterPage
    SetValue           Passwort              Test1234!
    SetValue           PasswortBestaetigen   Test1234!
    ClickOn            Registrieren

    SelectWindow       RegisterPage
    VerifyValue        Fehlermeldung    All fields are required.

Fehlendes Passwort
    [Documentation]    Prueft die Registrierung ohne Passwort.
    ...    Es wird die Fehlermeldung "All fields are required." angezeigt.
    SelectWindow       RegisterPage
    SetValue           Benutzer              TestUser
    SetValue           PasswortBestaetigen   Test1234!
    ClickOn            Registrieren

    SelectWindow       RegisterPage
    VerifyValue        Fehlermeldung    All fields are required.

Passwoerter Stimmen Nicht Ueberein
    [Documentation]    Prueft die Registrierung mit unterschiedlichen Passwoertern.
    ...    Es wird die Fehlermeldung "Passwords do not match." angezeigt.
    SelectWindow       RegisterPage
    SetValue           Benutzer              TestUser
    SetValue           Passwort              Test1234!
    SetValue           PasswortBestaetigen   AnderesPW!
    ClickOn            Registrieren

    SelectWindow       RegisterPage
    VerifyValue        Fehlermeldung    Passwords do not match.

*** Keywords ***
Register Seite Oeffnen
    OnFailNOISE          StartApp       MyAppChrome

    OnFailNOISE          SelectWindow   Chrome
    OnFailNOISE          SetValue       URL    ${URL}
    OnFailIgnoreNOISE    RemoveAds
    Sleep    1
    OnFailNOISE          VerifyWindowExists    RegisterPage    YES

