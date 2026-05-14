*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
Login Seite Oeffnen
    StartApp       MyAppChrome
    SelectWindow   Chrome
    SetValue       URL    ${URL}

Anmelden Mit
    [Arguments]    ${benutzer}    ${passwort}
    SelectWindow   SauceDemoLogin
    SetValue       Benutzer    ${benutzer}
    SetValue       Passwort    ${passwort}
    ClickOn        Anmelden

Login Erfolgreich
    SelectWindow       SauceDemoProducts
    VerifyValue        Titel    Products

Login Fehlgeschlagen Mit Meldung
    [Arguments]    ${meldung}
    SelectWindow       SauceDemoLogin
    VerifyValue        Fehlermeldung    ${meldung}

Gueltiger Login
    [Arguments]    ${benutzer}    ${passwort}
    Login Seite Oeffnen
    Anmelden Mit       ${benutzer}    ${passwort}
    Login Erfolgreich
    StopApp            MyAppChrome

Ungueltiger Login
    [Arguments]    ${benutzer}    ${passwort}    ${meldung}
    Login Seite Oeffnen
    Anmelden Mit                       ${benutzer}    ${passwort}
    Login Fehlgeschlagen Mit Meldung    ${meldung}
    StopApp                            MyAppChrome

*** Test Cases ***
Login Mit Gueltigem Benutzer
    [Documentation]    Prueft Login mit allen gueltigen Benutzern.
    [Template]    Gueltiger Login
    standard_user              secret_sauce
    problem_user               secret_sauce
    performance_glitch_user    secret_sauce
    error_user                 secret_sauce
    visual_user                secret_sauce

Login Mit Ungueltigem Benutzer
    [Documentation]    Prueft Fehlermeldungen bei ungueltigem Login.
    [Template]    Ungueltiger Login
    performance_user    secret_sauce    Epic sadface: Username and password do not match any user in this service
    standard_user       standard_user   Epic sadface: Username and password do not match any user in this service
    ${EMPTY}            secret_sauce    Epic sadface: Username is required
    standard_user       ${EMPTY}        Epic sadface: Password is required
    ${EMPTY}            ${EMPTY}        Epic sadface: Username is required

Login Mit Gesperrtem Benutzer
    [Documentation]    Prueft Fehlermeldung bei gesperrtem Benutzer.
    Login Seite Oeffnen
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Sorry, this user has been locked out.
    StopApp         MyAppChrome
