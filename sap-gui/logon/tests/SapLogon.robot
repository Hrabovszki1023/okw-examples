*** Settings ***
Documentation    SAP GUI Logon -- OKW Beispiel-Tests
...
...    Voraussetzungen:
...    - SAP GUI for Windows muss laufen
...    - SAP GUI Scripting aktiviert (RZ11: sapgui/user_scripting = TRUE)
...    - Eine SAP-Verbindung muss offen sein
Library    okw_sap_gui.library.OkwSapGuiLibrary    WITH NAME    OKW

Suite Setup       Starte SAP
Suite Teardown    Beende SAP

*** Variables ***
${IGNORE}    $IGNORE
${EMPTY}     $EMPTY
${DELETE}    $DELETE

*** Keywords ***
Starte SAP
    OKW.StartApp       SapLogon
    OKW.SelectWindow   Logon

Beende SAP
    OKW.StopApp

*** Test Cases ***
SAP Anmeldung mit gueltigem Benutzer
    [Documentation]    Prueft die SAP-Anmeldung mit gueltigem Benutzer.
    OKW.SetValue       Mandant     100
    OKW.SetValue       Benutzer    TESTUSER
    OKW.SetValue       Kennwort    geheim123
    OKW.SetValue       Sprache     DE
    OKW.ClickOn        Anmelden
    OKW.VerifyCaption  Statusleiste    S

SAP Anmeldung mit falschem Kennwort
    [Documentation]    Prueft die Fehlermeldung bei falschem Kennwort.
    OKW.SetValue       Benutzer    TESTUSER
    OKW.SetValue       Kennwort    FALSCH
    OKW.ClickOn        Anmelden
    OKW.VerifyCaption  Statusleiste    E
    OKW.VerifyValue    Statusleiste    Name oder Kennwort ist nicht korrekt*

SAP Anmeldung mit IGNORE Token
    [Documentation]    Mandant und Sprache werden uebersprungen.
    OKW.SetValue       Mandant     ${IGNORE}
    OKW.SetValue       Benutzer    TESTUSER
    OKW.SetValue       Kennwort    geheim123
    OKW.SetValue       Sprache     ${IGNORE}
    OKW.ClickOn        Anmelden
