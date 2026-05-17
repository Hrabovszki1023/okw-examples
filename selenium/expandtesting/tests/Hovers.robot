*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Hovers Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/hovers

*** Test Cases ***
MoveOver zeigt User1 Info
    [Documentation]    Prueft, dass MoveOver auf dem Avatar die versteckten
    ...    Benutzer-Informationen sichtbar macht (user1).
    # Phase 3: Navigation zum Testzustand (Context setzen)
    OnFailNOISE    SetContext      UserCard    user1
    # Phase 4: Testaktion — Maus ueber Avatar bewegen
    MoveOver        Avatar
    # Phase 5: Verifikation
    VerifyValueWCM  Benutzername    *user1*

MoveOver zeigt User2 Info
    [Documentation]    Prueft MoveOver fuer den zweiten Benutzer (user2).
    # Phase 3: Navigation zum Testzustand
    OnFailNOISE    SetContext      UserCard    user2
    # Phase 4: Testaktion
    MoveOver        Avatar
    # Phase 5: Verifikation
    VerifyValueWCM  Benutzername    *user2*

MoveOver zeigt User3 Info
    [Documentation]    Prueft MoveOver fuer den dritten Benutzer (user3).
    # Phase 3: Navigation zum Testzustand
    OnFailNOISE    SetContext      UserCard    user3
    # Phase 4: Testaktion
    MoveOver        Avatar
    # Phase 5: Verifikation
    VerifyValueWCM  Benutzername    *user3*

MoveOver ProfilLink wird sichtbar
    [Documentation]    Prueft, dass nach MoveOver der Link 'View profile'
    ...    sichtbar und klickbar wird.
    # Phase 3: Navigation zum Testzustand
    OnFailNOISE    SetContext      UserCard    user1
    # Phase 4: Testaktion
    MoveOver        Avatar
    # Phase 5: Verifikation
    VerifyExist     ProfilLink    YES

*** Keywords ***
Hovers Seite Oeffnen
    # Phase 1-3: App starten und zur Hovers-Seite navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   HoversPage
