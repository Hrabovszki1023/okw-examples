*** Settings ***
Library        okw_env_docker.library.OkwEnvDockerLibrary    components_dir=${CURDIR}${/}..${/}components
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Testumgebung Starten
Test Teardown  Testumgebung Beenden

*** Variables ***
${DOCKER_HOSTNAME}    %{OKW_DOCKER_HOSTNAME=localhost}

*** Test Cases ***
Zellwert Pruefen
    [Documentation]    Prueft einzelne Zellwerte in der Tabelle.

    SelectWindow       TablesPage

    VerifyTableCellValue    Tabelle1    1    1    Smith
    VerifyTableCellValue    Tabelle1    1    2    John
    VerifyTableCellValue    Tabelle1    2    1    Bach
    VerifyTableCellValue    Tabelle1    3    4    $100.00

Zeileninhalt Pruefen
    [Documentation]    Prueft den kompletten Inhalt einer Tabellenzeile.

    SelectWindow       TablesPage

    VerifyTableRowContent    Tabelle1    1    Smith$TABJohn$TABjsmith@gmail.com$TAB$50.00$TABhttp://www.jsmith.com$TAB*

Spalteninhalt Pruefen
    [Documentation]    Prueft den Inhalt der Spalte Last Name.

    SelectWindow       TablesPage

    VerifyTableColumnContent    Tabelle1    1    Smith$TABBach$TABDoe$TABConway

Zeilenanzahl Pruefen
    [Documentation]    Prueft die Anzahl der Datenzeilen in der Tabelle.

    SelectWindow       TablesPage

    VerifyTableRowCount    Tabelle1    4

Spaltenanzahl Pruefen
    [Documentation]    Prueft die Anzahl der Spalten in der Tabelle.

    SelectWindow       TablesPage

    VerifyTableColumnCount    Tabelle1    6

Zellwert Per Header Pruefen
    [Documentation]    Prueft einen Zellwert ueber Spaltenname statt Index.

    SelectWindow       TablesPage

    VerifyTableCellValueByHeaders    Tabelle1    Smith    First Name    John
    VerifyTableCellValueByHeaders    Tabelle1    Bach     Email          fbach@yahoo.com

*** Keywords ***
Testumgebung Starten
    OnFailNOISE    ENV_Start          TheInternet
    OnFailNOISE    ENV_BuildAndRun
    OnFailNOISE    ENV_WaitForReady   TheInternet

    OnFailNOISE    StartApp           MyAppChrome

    OnFailNOISE    SelectWindow       Chrome
    OnFailNOISE    SetValue           URL    http://${DOCKER_HOSTNAME}:${TheInternet.port}/tables

Testumgebung Beenden
    StopApp        MyAppChrome
    ENV_Stop
