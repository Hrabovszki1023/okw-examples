*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary

*** Variables ***
${URL}    https://practice.expandtesting.com/dynamic-table

*** Test Cases ***
Dynamische Tabelle Chrome CPU Pruefen
    [Documentation]    Prueft den CPU-Wert von Chrome in einer dynamischen Tabelle.
    ...    Zeilen und Spalten wechseln bei jedem Laden.
    ...    OKW findet den Wert ueber Header-Namen und Zeilenname.
    StartApp       MyAppChrome
    SelectWindow   Chrome
    SetValue       URL    ${URL}
    SelectWindow   DynamicTablePage
    MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
    VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
    StopApp        MyAppChrome
