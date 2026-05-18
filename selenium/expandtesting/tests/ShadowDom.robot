*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     ShadowDom Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/shadowdom

*** Test Cases ***
Normaler Button Hat Text
    [Documentation]    Prueft den Text des normalen Buttons (ausserhalb Shadow DOM).
    VerifyValue    NormalerButton    Here's a basic button example.

Shadow Button Existiert
    [Documentation]    Prueft, dass der Button im Shadow DOM gefunden wird.
    VerifyExist    ShadowButton    YES

Shadow Button Hat Text
    [Documentation]    Prueft den Text des Buttons im Shadow DOM.
    VerifyValue    ShadowButton    This button is inside a Shadow DOM.

Normaler Und Shadow Button Unterscheiden Sich
    [Documentation]    Prueft, dass normaler und Shadow Button verschiedene Texte haben.
    ...    Beide haben id=my-btn, aber OKW findet den richtigen ueber shadow_host.
    VerifyValue    NormalerButton    Here's a basic button example.
    VerifyValue    ShadowButton      This button is inside a Shadow DOM.

*** Keywords ***
ShadowDom Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   ShadowDomPage
