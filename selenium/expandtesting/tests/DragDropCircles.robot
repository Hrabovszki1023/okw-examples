*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     DragDropCircles Seite Oeffnen
Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/drag-and-drop-circles

*** Test Cases ***
# === DragTo: Kreise in Zielbereich ziehen ===

Roten Kreis In Zielbereich Ziehen
    [Documentation]    Zieht den roten Kreis per DragTo in den Zielbereich.
    DragTo    RoterKreis    Zielbereich
    VerifyExist    RoterKreis    NO

Gruenen Kreis In Zielbereich Ziehen
    [Documentation]    Zieht den gruenen Kreis per DragTo in den Zielbereich.
    DragTo    GruenerKreis    Zielbereich
    VerifyExist    GruenerKreis    NO

Blauen Kreis In Zielbereich Ziehen
    [Documentation]    Zieht den blauen Kreis per DragTo in den Zielbereich.
    DragTo    BlauerKreis    Zielbereich
    VerifyExist    BlauerKreis    NO

# === DragStart + Drop ===

Roten Kreis Mit DragStart Und Drop Ziehen
    [Documentation]    Mehrstufig: DragStart + Drop fuer den roten Kreis.
    DragStart    RoterKreis
    Drop         Zielbereich
    VerifyExist  RoterKreis    NO

Alle Kreise In Zielbereich Ziehen
    [Documentation]    Alle drei Kreise nacheinander in den Zielbereich ziehen.
    DragTo    RoterKreis      Zielbereich
    DragTo    GruenerKreis    Zielbereich
    DragTo    BlauerKreis     Zielbereich
    VerifyExist    RoterKreis      NO
    VerifyExist    GruenerKreis    NO
    VerifyExist    BlauerKreis     NO

*** Keywords ***
DragDropCircles Seite Oeffnen
    # Phase 1-3: App starten und zur DragDropCircles-Seite navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   DragDropCirclesPage
