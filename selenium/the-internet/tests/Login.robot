*** Settings ***
Library        okw_env_docker.library.OkwEnvDockerLibrary    components_dir=${CURDIR}${/}..${/}components
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     Testumgebung Starten
Test Teardown  Testumgebung Beenden

*** Variables ***
${DOCKER_HOSTNAME}    %{OKW_DOCKER_HOSTNAME=localhost}

*** Test Cases ***
Erfolgreicher Login
    [Documentation]    Prueft den Login mit gueltigem Benutzer und Passwort.
    ...    Nach dem Login wird die Secure-Seite mit Willkommensmeldung angezeigt.

    SelectWindow       LoginPage
    SetValue           Benutzer       tomsmith
    SetValue           Passwort       SuperSecretPassword!

    ClickOn            Anmelden

    SelectWindow       SecurePage
    VerifyValueWCM     Willkommensmeldung    *You logged into a secure area*

Erfolgreicher Logout
    [Documentation]    Prueft Login und anschliessendes Logout.
    ...    Nach dem Logout erscheint die Login-Seite mit Abmeldemeldung.

    SelectWindow       LoginPage
    SetValue           Benutzer       tomsmith
    SetValue           Passwort       SuperSecretPassword!

    ClickOn            Anmelden

    SelectWindow       SecurePage
    ClickOn            Abmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *You logged out*

Fehlerhafter Benutzername
    [Documentation]    Prueft den Login mit falschem Benutzernamen.
    ...    Es wird eine Fehlermeldung auf der Login-Seite angezeigt.

    SelectWindow       LoginPage
    SetValue           Benutzer       wrongUser
    SetValue           Passwort       SuperSecretPassword!

    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *Your username is invalid*

Fehlerhaftes Passwort
    [Documentation]    Prueft den Login mit korrektem Benutzer aber falschem Passwort.
    ...    Es wird eine Fehlermeldung auf der Login-Seite angezeigt.

    SelectWindow       LoginPage
    SetValue           Benutzer       tomsmith
    SetValue           Passwort       WrongPassword

    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *Your password is invalid*

*** Keywords ***
Testumgebung Starten
    OnFailNOISE    ENV_Start          TheInternet
    OnFailNOISE    ENV_BuildAndRun
    OnFailNOISE    ENV_WaitForReady   TheInternet

    OnFailNOISE    StartApp           MyAppChrome

    OnFailNOISE    SelectWindow       Chrome
    OnFailNOISE    SetValue           URL    http://${DOCKER_HOSTNAME}:${TheInternet.port}/login

Testumgebung Beenden
    StopApp        MyAppChrome
    ENV_Stop
