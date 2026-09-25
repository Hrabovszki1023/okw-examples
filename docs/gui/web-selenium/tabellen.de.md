# Tabellen

Die Tabelle auf der Demo-Seite mischt bei jedem Laden ihre Zeilen und
Spalten. Chrome steht heute in Zeile 3, morgen in Zeile 1. CPU ist mal
Spalte 4, mal Spalte 2.

Die meisten Selenium-Lösungen adressieren Zellen über Positionen:
`table/tr[3]/td[4]`. Das bricht, sobald sich die Reihenfolge ändert.
Also schreibt man Hilfsmethoden, die Header lesen, Zeilen nach Namen
suchen und Spalten abgleichen — viele Zeilen Code für einen Wert.

![Dynamische Tabelle](images/05_dynamic_table.png)

## Die OKW-Lösung

```robot
Dynamische Tabelle Chrome CPU Pruefen
    OnFailNOISE    StartApp       MyAppChrome

    OnFailNOISE    SelectWindow   Chrome
    OnFailNOISE    SetValue       URL    ${URL}

    OnFailNOISE    SelectWindow   DynamicTablePage
    MemorizeTableCellValueByHeaders    TaskManager    Chrome    CPU    CHROME_CPU
    VerifyValueWCM     ChromeCpuLabel    *${CHROME_CPU}*
    StopApp        MyAppChrome
```

Ein Keyword: Tabellenname, Zeilenschlüssel, Spaltenüberschrift,
Variablenname. OKW findet die Zelle, egal wo Chrome und CPU gerade
stehen.

`MemorizeTableCellValueByHeaders`:

1. findet das Tabellen-Widget `TaskManager`,
2. liest die Kopfzeile und bestimmt den Index der Spalte `CPU`,
3. sucht in der Schlüsselspalte (Standard: erste Spalte) die Zeile
   `Chrome` — der Zeilenschlüssel ist ein Wildcard-Muster,
4. liest den Wert am Schnittpunkt,
5. speichert ihn in `${CHROME_CPU}`.

Passt kein oder mehr als ein Zeilenschlüssel, schlägt das Keyword mit
einer klaren Meldung fehl.

## Die YAML

```yaml
# locators/DynamicTablePage.yaml (Auszug)
TaskManager:
  class: okw_web_selenium.widgets.webse_table.WebSe_Table
  locator: { css: 'table' }

ChromeCpuLabel:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '.bg-warning' }
```

Die Tabelle ist **ein** Widget. Keine Spaltendefinitionen, keine
Zeilenvorlagen. `WebSe_Table` liest die HTML-Struktur (`<thead>`, `<tr>`,
`<td>`) und baut die Zuordnung zur Laufzeit.

## Warum Header statt Position?

Dynamische Tabellen gibt es überall:

- Task-Manager (Prozesse sortieren sich nach CPU/Speicher)
- Dashboards (Spalten vom Benutzer konfigurierbar)
- Suchergebnisse (Sortierung ändert sich)
- Admin-Oberflächen (Daten ändern sich zwischen Tests)

Positionsbasierte Selektoren (`tr[3]/td[4]`) sind von Natur aus
zerbrechlich. Die Suche über Header ist **fachlich stabil**: Sie findet
„den CPU-Wert von Chrome“ — unabhängig vom Layout. Das ist Signal statt
NOISE.

## Tabellen-Keywords im Überblick

| Über Header (fachlich) | Über Position | Zweck |
|---|---|---|
| `VerifyTableCellValueByHeaders` | `VerifyTableCellValue` | Zellwert prüfen (auch `…REGX`) |
| `MemorizeTableCellValueByHeaders` | `MemorizeTableCellValue` | Zellwert in Variable speichern |
| `LogTableCellValueByHeaders` | `LogTableCellValue` | Zellwert ins Log schreiben |
| `SetTableCellValueByHeaders` | `SetTableCellValue` | Wert in Zelle eingeben |
| `ClickOnTableCellByHeaders` | `ClickOnTableCell` | Zelle anklicken |
| `DoubleClickOnTableCellByHeaders` | `DoubleClickOnTableCell` | Zelle doppelklicken |
| `VerifyTableRowContentByHeader` | `VerifyTableRowContent` | Ganze Zeile prüfen |
| `VerifyTableColumnContentByHeader` | `VerifyTableColumnContent` | Ganze Spalte prüfen |
| – | `VerifyTableRowCount`, `VerifyTableColumnCount` | Anzahl prüfen |
| – | `VerifyTableHasRow`, `VerifyTableContent` | Zeile vorhanden / Gesamtinhalt |

**Empfehlung:** Die `ByHeaders`-Varianten verwenden, wo immer möglich.
Positionen nur, wenn die Tabelle keine Überschriften hat.

Alle Tabellen-Keywords protokollieren Screenshots auf drei Ebenen:
**Zelle → Zeile → ganze Tabelle**. Im Robot-Log sieht man so vom Detail
bis zum Überblick, welche Zelle geprüft wurde.

## Lauffähiges Beispiel

[`selenium/expandtesting/tests/DynamicTable.robot`](https://github.com/Hrabovszki1023/okw-examples/blob/master/selenium/expandtesting/tests/DynamicTable.robot)
