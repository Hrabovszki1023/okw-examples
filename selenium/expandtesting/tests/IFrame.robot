*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     IFrame Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/iframe

*** Test Cases ***
Seitentitel Ausserhalb IFrame
    [Documentation]    Prueft den Seitentitel auf der Hauptseite (kein iFrame).
    VerifyValueWCM    Seitentitel    *IFrame*

Email IFrame Ueberschrift Lesen
    [Documentation]    Prueft die Ueberschrift im Email-Subscribe-IFrame.
    VerifyValueWCM    IFrameUeberschrift    *inbox*

Email IFrame Button Existiert
    [Documentation]    Prueft, dass der Subscribe-Button im IFrame existiert.
    VerifyExist    AbonnierenButton    YES

Email IFrame Button Text
    [Documentation]    Prueft den Text des Subscribe-Buttons im IFrame.
    VerifyValue    AbonnierenButton    Subscribe

TinyMCE IFrame Editor Lesen
    [Documentation]    Prueft den Standardtext im TinyMCE-Editor-IFrame.
    VerifyValueWCM    EditorBody    *content goes here*

Hauptseite Und IFrame Nacheinander
    [Documentation]    Prueft, dass OKW nahtlos zwischen Hauptseite und
    ...    IFrame hin- und herwechselt.
    VerifyValueWCM    Seitentitel         *IFrame*
    VerifyValueWCM    IFrameUeberschrift  *inbox*
    VerifyValueWCM    Seitentitel         *IFrame*
    VerifyValue        AbonnierenButton    Subscribe

*** Keywords ***
IFrame Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   IFramePage
