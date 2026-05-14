*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
SauceDemo Oeffnen Und Anmelden
    StartApp       MyAppChrome
    SelectWindow   Chrome
    SetValue       URL    ${URL}
    SelectWindow   SauceDemoLogin
    SetValue       Benutzer    standard_user
    SetValue       Passwort    secret_sauce
    ClickOn        Anmelden

Produktpreis Pruefen
    [Arguments]    ${produkt}    ${erwarteter_preis}
    SetContext         ProduktKarte    ${produkt}
    VerifyValue        Produktpreis    ${erwarteter_preis}

Produkt In Warenkorb Legen
    [Arguments]    ${produkt}
    SetContext         ProduktKarte    ${produkt}
    ClickOn            InDenWarenkorb

*** Test Cases ***
SetContext Produktpreise Pruefen
    [Documentation]    Prueft Preise verschiedener Produkte ueber SetContext.
    ...    Jede Produktkarte wird dynamisch ueber den Namen selektiert,
    ...    ohne separate YAML-Eintraege pro Produkt.
    SauceDemo Oeffnen Und Anmelden
    SelectWindow   SauceDemoProducts
    VerifyValue    Titel    Products
    Produktpreis Pruefen    Sauce Labs Backpack      $29.99
    Produktpreis Pruefen    Sauce Labs Bike Light    $9.99
    Produktpreis Pruefen    Sauce Labs Bolt T-Shirt  $15.99
    Produktpreis Pruefen    Sauce Labs Fleece Jacket  $49.99
    Produktpreis Pruefen    Sauce Labs Onesie        $7.99
    StopApp        MyAppChrome

SetContext Produkt In Warenkorb
    [Documentation]    Legt zwei Produkte ueber SetContext in den Warenkorb.
    ...    Der gleiche Button-Locator wird per Context auf verschiedene
    ...    Produktkarten angewendet.
    SauceDemo Oeffnen Und Anmelden
    SelectWindow   SauceDemoProducts
    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    StopApp        MyAppChrome
