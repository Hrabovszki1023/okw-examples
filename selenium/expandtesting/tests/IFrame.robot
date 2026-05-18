*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     IFrame Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/iframe

*** Test Cases ***
# === Hauptseite ===

Seitentitel Ausserhalb IFrame
    [Documentation]    Prueft den Seitentitel auf der Hauptseite (kein iFrame).
    VerifyValueWCM    Seitentitel    *IFrame*

# === Email Subscribe IFrame ===

Email IFrame Ueberschrift Lesen
    [Documentation]    Prueft die Ueberschrift im Email-Subscribe-IFrame.
    VerifyValueWCM    IFrameUeberschrift    *inbox*

Email IFrame Button Text
    [Documentation]    Prueft den Text des Subscribe-Buttons im IFrame.
    VerifyValue    AbonnierenButton    Subscribe

Email Abonnieren Erfolgreich
    [Documentation]    Gibt eine Email ein und prueft die Erfolgsmeldung.
    SetValue       EmailEingabe        test@example.com
    ClickOn        AbonnierenButton
    VerifyValue    Erfolgsmeldung      You are now subscribed!

# === TinyMCE Editor IFrame ===

TinyMCE Standardtext Lesen
    [Documentation]    Prueft den Standardtext im TinyMCE-Editor-IFrame.
    VerifyValueWCM    EditorBody    *content goes here*

# === Uebergreifend: Wechsel zwischen IFrames ===

Hauptseite Und Email IFrame Nacheinander
    [Documentation]    Prueft nahtloses Wechseln zwischen Hauptseite und
    ...    Email-Subscribe-IFrame.
    VerifyValueWCM    Seitentitel         *IFrame*
    VerifyValueWCM    IFrameUeberschrift  *inbox*
    VerifyValueWCM    Seitentitel         *IFrame*
    VerifyValue       AbonnierenButton    Subscribe

Zwischen Zwei IFrames Wechseln
    [Documentation]    Prueft Wechsel zwischen Email-IFrame und TinyMCE-IFrame.
    VerifyValue       AbonnierenButton    Subscribe
    VerifyValueWCM    EditorBody          *content goes here*
    VerifyValueWCM    IFrameUeberschrift  *inbox*

*** Keywords ***
IFrame Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   IFramePage
