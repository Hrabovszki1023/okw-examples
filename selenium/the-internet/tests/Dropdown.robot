*** Settings ***
Library        okw_env_docker.library.OkwEnvDockerLibrary    components_dir=${CURDIR}${/}..${/}components
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Testumgebung Starten
Test Teardown  Testumgebung Beenden

*** Variables ***
${DOCKER_HOSTNAME}    %{OKW_DOCKER_HOSTNAME=localhost}

*** Test Cases ***
Option 1 Auswaehlen
    [Documentation]    Waehlt Option 1 aus der Dropdown-Liste und prueft den Wert.

    SelectWindow       DropdownPage

    SetValue           Auswahlliste    Option 1

    VerifyValue        Auswahlliste    Option 1

Option 2 Auswaehlen
    [Documentation]    Waehlt Option 2 aus der Dropdown-Liste und prueft den Wert.

    SelectWindow       DropdownPage

    SetValue           Auswahlliste    Option 2

    VerifyValue        Auswahlliste    Option 2

Option Wechseln
    [Documentation]    Waehlt erst Option 1, dann Option 2 und prueft jeweils den Wert.

    SelectWindow       DropdownPage

    SetValue           Auswahlliste    Option 1
    VerifyValue        Auswahlliste    Option 1

    SetValue           Auswahlliste    Option 2
    VerifyValue        Auswahlliste    Option 2

Ausgangszustand Pruefen
    [Documentation]    Prueft den Ausgangszustand der Dropdown-Liste.
    ...    Standardmaessig ist keine Option ausgewaehlt (Platzhalter).

    SelectWindow       DropdownPage

    VerifyValue        Auswahlliste    Please select an option

*** Keywords ***
Testumgebung Starten
    OnFailNOISE    ENV_Start          TheInternet
    OnFailNOISE    ENV_BuildAndRun
    OnFailNOISE    ENV_WaitForReady   TheInternet

    OnFailNOISE    StartApp           MyAppChrome

    OnFailNOISE    SelectWindow       Chrome
    OnFailNOISE    SetValue           URL    http://${DOCKER_HOSTNAME}:${TheInternet.port}/dropdown

Testumgebung Beenden
    StopApp        MyAppChrome
    ENV_Stop
