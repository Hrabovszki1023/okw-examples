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
    OnFailNOISE    SetContext      UserCard    user1
    MoveOver        Avatar
    VerifyValueWCM  Benutzername    *user1*

MoveOver zeigt User2 Info
    [Documentation]    Prueft MoveOver fuer den zweiten Benutzer (user2).
    OnFailNOISE    SetContext      UserCard    user2
    MoveOver        Avatar
    VerifyValueWCM  Benutzername    *user2*

MoveOver zeigt User3 Info
    [Documentation]    Prueft MoveOver fuer den dritten Benutzer (user3).
    OnFailNOISE    SetContext      UserCard    user3
    MoveOver        Avatar
    VerifyValueWCM  Benutzername    *user3*

MoveOver ProfilLink wird sichtbar
    [Documentation]    Prueft, dass nach MoveOver der Link 'View profile'
    ...    sichtbar und klickbar wird.
    OnFailNOISE    SetContext      UserCard    user1
    MoveOver        Avatar
    VerifyExists     ProfilLink    YES

*** Keywords ***
Hovers Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   HoversPage
