# OKW4Robot Handbuch

OKW4Robot ist eine treiberunabhängige Keyword-Architektur für Robot Framework.
Ein Satz Keywords — `SetValue`, `ClickOn`, `VerifyValue` — funktioniert über
alle GUI-Technologien hinweg: Web, Java Swing, SAP GUI, Windows Desktop.
Eigenständige Bibliotheken erweitern das Muster auf REST, SSH und Kafka.

## Für wen ist dieses Handbuch?

Dieses Handbuch richtet sich an **Testautomatisierer, die Robot Framework
bereits kennen**. Grundlagen wie `*** Settings ***`, `*** Test Cases ***`
oder die Ausführung mit `robot` werden vorausgesetzt.

## Was lernt man hier?

| Kapitel | Inhalt |
|---|---|
| **Grundlagen** | Die OKW-Philosophie, Keywords, YAML-Locator, Tokens |
| **GUI-Bibliotheken** | Web Selenium, Java Swing, SAP GUI — Schritt für Schritt |
| **Umgebungs-Bibliotheken** | Docker und Proxmox: Testumgebungen automatisiert bereitstellen |
| **Spezial-Bibliotheken** | REST API, SSH, Kafka — Tests jenseits der GUI |
| **Zusammenspiel** | Wie alle Bibliotheken in einem End-to-End-Test zusammenwirken |

## Schnellstart

```bash
pip install robotframework-okw4robot robotframework-okw-web-selenium
```

```robot
*** Settings ***
Library    okw_web_selenium.library.OkwWebSeleniumLibrary    WITH NAME    OKW

*** Test Cases ***
Google Suche
    OKW.StartApp       MeinAppChrome
    OKW.SelectWindow   Suchseite
    OKW.SetValue       Suchfeld       Robot Framework
    OKW.ClickOn        Suchen
    OKW.StopApp
```

Das ist ein vollständiger OKW-Test. Keine Locators im Test, kein Page Object Model,
keine Selenium-Imports. Wie das funktioniert, erklärt das nächste Kapitel.

## Alle Beispiele sind lauffähig

Jedes Codebeispiel in diesem Handbuch stammt aus dem
[okw-examples](https://github.com/Hrabovszki1023/okw-examples) Repository.
Die Tests können direkt ausgeführt werden — klonen, installieren, starten.
