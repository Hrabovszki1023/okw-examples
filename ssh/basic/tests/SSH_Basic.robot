*** Settings ***
Documentation     OKW Remote SSH — Basic integration examples.
...               Requires an SSH target server configured via:
...               ~/.okw/configs/testhost.yaml  (host, port, username)
...               ~/.okw/secrets.yaml           (password or key_file)
...
...               See: docs/ci-cd-pipeline.md (Phase 2: okw-ssh-target)

Library           robotframework_okw_remote_ssh.RemoteSshLibrary    backend=paramiko

*** Variables ***
${SESSION}    sshtest
${CONFIG}     testhost

*** Test Cases ***
Kommando Ausfuehren Und Ausgabe Pruefen
    [Documentation]    Fuehrt ein einfaches Kommando aus und prueft die Ausgabe.
    Open Remote Session    ${SESSION}    ${CONFIG}
    Execute Remote         ${SESSION}    echo "Hello from OKW"
    Verify Remote Response    ${SESSION}    Hello from OKW
    Verify Remote Exit Code    ${SESSION}    0
    Close Remote Session   ${SESSION}

Exit Code Bei Fehler Pruefen
    [Documentation]    Prueft den Exit Code eines fehlschlagenden Kommandos.
    Open Remote Session    ${SESSION}    ${CONFIG}
    Execute Remote And Continue    ${SESSION}    exit 7
    Verify Remote Exit Code    ${SESSION}    7
    Close Remote Session   ${SESSION}

Wildcard Und Regex Matching
    [Documentation]    Prueft WCM- und REGX-Matching auf Kommandoausgabe.
    Open Remote Session    ${SESSION}    ${CONFIG}
    Execute Remote         ${SESSION}    echo "Date: 23.10.1963"
    Verify Remote Response WCM     ${SESSION}    *??.??.????*
    Verify Remote Response REGX    ${SESSION}    Date:\\s+\\d{2}\\.\\d{2}\\.\\d{4}
    Close Remote Session   ${SESSION}

Datei Erstellen Und Loeschen
    [Documentation]    Erstellt eine Datei, prueft Existenz, loescht sie wieder.
    Open Remote Session    ${SESSION}    ${CONFIG}
    Execute Remote    ${SESSION}    echo "OKW test content" > /tmp/okw_example_test.txt
    Verify Remote File Exists    ${SESSION}    /tmp/okw_example_test.txt    YES
    Remove Remote File    ${SESSION}    /tmp/okw_example_test.txt
    Verify Remote File Exists    ${SESSION}    /tmp/okw_example_test.txt    NO
    Close Remote Session   ${SESSION}
