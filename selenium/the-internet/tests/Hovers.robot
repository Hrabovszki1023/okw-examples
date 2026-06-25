*** Settings ***
Library        okw_env_docker.library.OkwEnvDockerLibrary    components_dir=${CURDIR}${/}..${/}components
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Testumgebung Starten
Test Teardown  Testumgebung Beenden

*** Variables ***
${DOCKER_HOSTNAME}    %{OKW_DOCKER_HOSTNAME=localhost}

*** Test Cases ***
Hover Ueber Avatar 1
    [Documentation]    Bewegt die Maus ueber Avatar 1 und prueft die Benutzerinfo.

    SelectWindow       HoversPage

    MoveOver           Avatar1

    VerifyValue        Benutzerinfo1    name: user1

Hover Ueber Avatar 2
    [Documentation]    Bewegt die Maus ueber Avatar 2 und prueft die Benutzerinfo.

    SelectWindow       HoversPage

    MoveOver           Avatar2

    VerifyValue        Benutzerinfo2    name: user2

Hover Ueber Avatar 3
    [Documentation]    Bewegt die Maus ueber Avatar 3 und prueft die Benutzerinfo.

    SelectWindow       HoversPage

    MoveOver           Avatar3

    VerifyValue        Benutzerinfo3    name: user3

*** Keywords ***
Testumgebung Starten
    OnFailNOISE    ENV_Start          TheInternet
    OnFailNOISE    ENV_BuildAndRun
    OnFailNOISE    ENV_WaitForReady   TheInternet

    OnFailNOISE    StartApp           MyAppChrome

    OnFailNOISE    SelectWindow       Chrome
    OnFailNOISE    SetValue           URL    http://${DOCKER_HOSTNAME}:${TheInternet.port}/hovers

Testumgebung Beenden
    StopApp        MyAppChrome
    ENV_Stop
