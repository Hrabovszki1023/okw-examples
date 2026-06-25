*** Settings ***
Library        okw_env_docker.library.OkwEnvDockerLibrary    components_dir=${CURDIR}${/}..${/}components
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Testumgebung Starten
Test Teardown  Testumgebung Beenden

*** Variables ***
${DOCKER_HOSTNAME}    %{OKW_DOCKER_HOSTNAME=localhost}

*** Test Cases ***
Checkbox Anwaehlen
    [Documentation]    Prueft SetValue YES auf eine nicht angehakte Checkbox.

    SelectWindow       CheckboxesPage
    VerifyValue        Checkbox1    Unchecked

    SetValue           Checkbox1    YES

    VerifyValue        Checkbox1    Checked

Checkbox Abwaehlen
    [Documentation]    Prueft SetValue NO auf eine angehakte Checkbox.

    SelectWindow       CheckboxesPage
    VerifyValue        Checkbox2    Checked

    SetValue           Checkbox2    NO

    VerifyValue        Checkbox2    Unchecked

Checkbox Zustand Pruefen
    [Documentation]    Prueft den Ausgangszustand beider Checkboxen.
    ...    Checkbox 1 ist standardmaessig nicht angehakt, Checkbox 2 ist angehakt.

    SelectWindow       CheckboxesPage

    VerifyValue        Checkbox1    Unchecked
    VerifyValue        Checkbox2    Checked

Checkbox Hin Und Her Schalten
    [Documentation]    Prueft das Umschalten einer Checkbox in beide Richtungen.

    SelectWindow       CheckboxesPage

    SetValue           Checkbox1    YES
    VerifyValue        Checkbox1    Checked

    SetValue           Checkbox1    NO
    VerifyValue        Checkbox1    Unchecked

*** Keywords ***
Testumgebung Starten
    OnFailNOISE    ENV_Start          TheInternet
    OnFailNOISE    ENV_BuildAndRun
    OnFailNOISE    ENV_WaitForReady   TheInternet

    OnFailNOISE    StartApp           MyAppChrome

    OnFailNOISE    SelectWindow       Chrome
    OnFailNOISE    SetValue           URL    http://${DOCKER_HOSTNAME}:${TheInternet.port}/checkboxes

Testumgebung Beenden
    StopApp        MyAppChrome
    ENV_Stop
