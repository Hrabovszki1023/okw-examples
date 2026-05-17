*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://practice.expandtesting.com/dynamic-table

*** Test Cases ***
Dynamische Tabelle Chrome CPU Pruefen
    [Documentation]    Prueft den CPU-Wert von Chrome in einer dynamischen Tabelle.
    ...    Zeilen und Spalten wechseln bei jedem Laden.
    ...    OKW findet den Wert ueber Header-Namen und Zeilenname.
    # Phase 1-3: Vorbereitung — App starten und zur Tabelle navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   DynamicTablePage
    # Phase 4: Testaktion — CPU-Wert aus Tabelle lesen
    MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
    # Phase 5: Verifikation — Wert mit Label abgleichen
    VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
    StopApp        MyAppChrome
