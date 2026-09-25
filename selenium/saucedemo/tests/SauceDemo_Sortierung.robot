*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   SauceDemoLogin
    OnFailNOISE    SetValue       Benutzer    standard_user
    OnFailNOISE    SetValue       Passwort    secret_sauce
    OnFailNOISE    ClickOn        Anmelden

*** Test Cases ***
Produkte Nach Preis Aufsteigend Sortieren
    [Documentation]    Sortiert die Produktliste ueber die ComboBox.
    ...    Die Synchronisation der Auswahl steckt einmal im Widget
    ...    WebSe_ComboBox — der Testfall enthaelt nur die fachliche Aussage.
    SauceDemo Oeffnen Und Anmelden

    SelectWindow   SauceDemoProducts
    Select         Sortierung           Price (low to high)
    VerifyValue    Sortierung           Price (low to high)
    VerifyValue    ErsterProduktname    Sauce Labs Onesie

    StopApp        MyAppChrome

Produkte Nach Name Absteigend Sortieren
    [Documentation]    Sortiert die Produktliste absteigend nach Name.
    SauceDemo Oeffnen Und Anmelden

    SelectWindow   SauceDemoProducts
    Select         Sortierung           Name (Z to A)
    VerifyValue    Sortierung           Name (Z to A)
    VerifyValue    ErsterProduktname    Test.allTheThings() T-Shirt (Red)

    StopApp        MyAppChrome
