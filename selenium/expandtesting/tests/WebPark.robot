*** Settings ***
Library        okw_web_selenium.library.OkwWebSeleniumLibrary
Test Setup     WebPark Seite Oeffnen
# Test Teardown  StopApp    MyAppChrome

*** Variables ***
${URL}    https://practice.expandtesting.com/webpark

*** Test Cases ***
# === Valet Parking ===

Valet Parking Unter 5 Stunden
    [Documentation]    Valet Parking: 12 Euro fuer 5 Stunden oder weniger.
    Parkkosten Berechnen    Valet Parking    2026-06-01    10:00    2026-06-01    14:00
    VerifyValueWCM    Ergebnis    12.00*

Valet Parking Genau 5 Stunden
    [Documentation]    Valet Parking: Genau 5 Stunden = 12 Euro.
    Parkkosten Berechnen    Valet Parking    2026-06-01    08:00    2026-06-01    13:00
    VerifyValueWCM    Ergebnis    12.00*

Valet Parking Ueber 5 Stunden
    [Documentation]    Valet Parking: Ueber 5 Stunden = 18 Euro pro Tag.
    Parkkosten Berechnen    Valet Parking    2026-06-01    08:00    2026-06-01    14:00
    VerifyValueWCM    Ergebnis    18.00*

Valet Parking Mehrere Tage
    [Documentation]    Valet Parking: 3 Tage = 3 x 18 = 54 Euro.
    Parkkosten Berechnen    Valet Parking    2026-06-01    10:00    2026-06-04    10:00
    VerifyValueWCM    Ergebnis    54.00*

# === Short-Term Parking ===

Short-Term Parking Eine Stunde
    [Documentation]    Short-Term: Erste Stunde = 2 Euro.
    Parkkosten Berechnen    Short-Term Parking    2026-06-01    10:00    2026-06-01    11:00
    VerifyValueWCM    Ergebnis    2.00*

Short-Term Parking 90 Minuten
    [Documentation]    Short-Term: 1h + 30min = 2 + 1 = 3 Euro.
    Parkkosten Berechnen    Short-Term Parking    2026-06-01    10:00    2026-06-01    11:30
    VerifyValueWCM    Ergebnis    3.00*

Short-Term Parking 2 Stunden
    [Documentation]    Short-Term: 1h + 2x30min = 2 + 2 = 4 Euro.
    Parkkosten Berechnen    Short-Term Parking    2026-06-01    10:00    2026-06-01    12:00
    VerifyValueWCM    Ergebnis    4.00*

Short-Term Parking Tagesmaximum
    [Documentation]    Short-Term: Ganzer Tag = Maximum 24 Euro.
    Parkkosten Berechnen    Short-Term Parking    2026-06-01    08:00    2026-06-02    08:00
    VerifyValueWCM    Ergebnis    24.00*

# === Long-Term Garage Parking ===

Long-Term Garage 3 Stunden
    [Documentation]    Long-Term Garage: 3h x 2 Euro = 6 Euro.
    Parkkosten Berechnen    Long-Term Garage Parking    2026-06-01    10:00    2026-06-01    13:00
    VerifyValueWCM    Ergebnis    6.00*

Long-Term Garage Tagesmaximum
    [Documentation]    Long-Term Garage: Maximum 12 Euro pro Tag.
    Parkkosten Berechnen    Long-Term Garage Parking    2026-06-01    08:00    2026-06-02    08:00
    VerifyValueWCM    Ergebnis    12.00*

Long-Term Garage Eine Woche
    [Documentation]    Long-Term Garage: 7 Tage = 72 Euro (7. Tag frei).
    Parkkosten Berechnen    Long-Term Garage Parking    2026-06-01    08:00    2026-06-08    08:00
    VerifyValueWCM    Ergebnis    72.00*

# === Long-Term Surface Parking ===

Long-Term Surface 4 Stunden
    [Documentation]    Long-Term Surface: 4h x 2 Euro = 8 Euro.
    Parkkosten Berechnen    Long-Term Surface Parking    2026-06-01    10:00    2026-06-01    14:00
    VerifyValueWCM    Ergebnis    8.00*

Long-Term Surface Tagesmaximum
    [Documentation]    Long-Term Surface: Maximum 10 Euro pro Tag.
    Parkkosten Berechnen    Long-Term Surface Parking    2026-06-01    08:00    2026-06-02    08:00
    VerifyValueWCM    Ergebnis    10.00*

Long-Term Surface Eine Woche
    [Documentation]    Long-Term Surface: 7 Tage = 60 Euro (7. Tag frei).
    Parkkosten Berechnen    Long-Term Surface Parking    2026-06-01    08:00    2026-06-08    08:00
    VerifyValueWCM    Ergebnis    60.00*

# === Economy Lot Parking ===

Economy Parking 2 Stunden
    [Documentation]    Economy: 2h x 2 Euro = 4 Euro.
    Parkkosten Berechnen    Economy Parking    2026-06-01    10:00    2026-06-01    12:00
    VerifyValueWCM    Ergebnis    4.00*

Economy Parking Tagesmaximum
    [Documentation]    Economy: Maximum 9 Euro pro Tag.
    Parkkosten Berechnen    Economy Parking    2026-06-01    08:00    2026-06-02    08:00
    VerifyValueWCM    Ergebnis    9.00*

Economy Parking Eine Woche
    [Documentation]    Economy: 7 Tage = 54 Euro (7. Tag frei).
    Parkkosten Berechnen    Economy Parking    2026-06-01    08:00    2026-06-08    08:00
    VerifyValueWCM    Ergebnis    54.00*

*** Keywords ***
WebPark Seite Oeffnen
    # Phase 1-3: App starten und zur WebPark-Seite navigieren
    OnFailNOISE    StartApp       MyAppChrome
    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}
    OnFailNOISE    SelectWindow   WebParkPage

Parkkosten Berechnen
    [Arguments]    ${parkplatz}    ${ein_datum}    ${ein_zeit}    ${aus_datum}    ${aus_zeit}
    # Phase 2: Testdaten eingeben
    #   Select fuer die ComboBox, SetValue fuer die Flatpickr-Felder.
    #   Die Flatpickr-Felder verwenden projektspezifische Widgets
    #   (WebPark_DateField / WebPark_TimeField), die okw_set_value()
    #   ueberschreiben: Click → Ctrl+A → Delete → TypeKey → Escape.
    Select         Parkplatz        ${parkplatz}
    
    SetValue       EingangDatum     ${ein_datum}
    VerifyValue    EingangDatum     ${ein_datum}
    
    SetValue       EingangZeit      ${ein_zeit}
    VerifyValue    EingangZeit      ${ein_zeit}
    
    SetValue       AusgangDatum     ${aus_datum}
    VerifyValue    AusgangDatum     ${aus_datum}
    
    SetValue       AusgangZeit      ${aus_zeit}
    VerifyValue    AusgangZeit      ${aus_zeit}
    
    # Phase 4: Testaktion
    ClickOn        KostenBerechnen
