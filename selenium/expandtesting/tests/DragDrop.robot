*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     DragDrop Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/drag-and-drop

*** Test Cases ***
# === DragStart + Drop (mehrstufig) ===

Spalte A Nach B Ziehen
    [Documentation]    Zieht Spalte A auf Spalte B mit DragStart + Drop.
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B
    DragStart      SpalteA
    Drop           SpalteB
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A

Spalte B Nach A Ziehen
    [Documentation]    Zieht Spalte B auf Spalte A mit DragStart + Drop.
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B
    DragStart      SpalteB
    Drop           SpalteA
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A

Doppelter Tausch Bringt Ausgangszustand
    [Documentation]    Zweimal tauschen = urspruengliche Reihenfolge.
    DragStart      SpalteA
    Drop           SpalteB
    DragStart      SpalteA
    Drop           SpalteB
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B

# === DragTo (Shortcut) ===

DragTo Spalte A Nach B
    [Documentation]    Shortcut: DragTo zieht Spalte A direkt auf Spalte B.
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B
    DragTo         SpalteA    SpalteB
    VerifyValue    SpalteA    B
    VerifyValue    SpalteB    A

DragTo Doppelter Tausch
    [Documentation]    Zweimal DragTo = urspruengliche Reihenfolge.
    DragTo         SpalteA    SpalteB
    DragTo         SpalteA    SpalteB
    VerifyValue    SpalteA    A
    VerifyValue    SpalteB    B

*** Keywords ***
DragDrop Seite Oeffnen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   DragDropPage
