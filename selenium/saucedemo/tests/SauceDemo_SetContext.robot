*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://www.saucedemo.com

*** Keywords ***
SauceDemo Oeffnen Und Anmelden
    # Phase 1-3: Komplette Vorbereitung (App starten, navigieren, anmelden)
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   SauceDemoLogin
    OnFailNOISE    SetValue       Benutzer    standard_user
    OnFailNOISE    SetValue       Passwort    secret_sauce
    OnFailNOISE    ClickOn        Anmelden

Produktpreis Pruefen
    [Arguments]    ${produkt}    ${erwarteter_preis}
    # Phase 4: Testaktion — Context setzen und Preis pruefen
    SetContext         ProduktKarte    ${produkt}
    # Phase 5: Verifikation
    VerifyValue        Produktpreis    ${erwarteter_preis}

Produkt In Warenkorb Legen
    [Arguments]    ${produkt}
    # Phase 4: Testaktion — Context setzen und Warenkorb-Button klicken
    SetContext         ProduktKarte    ${produkt}
    ClickOn            InDenWarenkorb

*** Test Cases ***
SetContext Produktpreise Pruefen
    [Documentation]    Prueft Preise verschiedener Produkte ueber SetContext.
    ...    Jede Produktkarte wird dynamisch ueber den Namen selektiert,
    ...    ohne separate YAML-Eintraege pro Produkt.
    # Phase 1-3: Vorbereitung
    SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    SelectWindow   SauceDemoProducts
    OnFailNOISE    VerifyValue    Titel    Products
    # Phase 4-5: Test und Verifikation
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
    # Phase 1-3: Vorbereitung
    SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    SelectWindow   SauceDemoProducts
    # Phase 4: Testaktion
    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    StopApp        MyAppChrome
