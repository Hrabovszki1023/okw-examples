# GUI-Objekte

OKW unterteilt GUI-Objekte in fünf Kategorien — nach der **Dimension
ihrer Daten**. Diese Einteilung bestimmt, welche Keywords auf ein
Objekt anwendbar sind, und gilt für alle Technologien (Web, Swing,
SAP GUI, ...).

## Übersicht

| Kategorie | Beispiele | Daten-Dimension |
|---|---|---|
| **Objekte ohne Daten** | Button, Link, MenuItem | Keine — nur Aktion |
| **Eindimensionale Objekte** | TextField, Checkbox, ComboBox | Ein Wert |
| **Mehrdimensionale Objekte** | Table | Zeile × Spalte |
| **Rahmenobjekte (Context)** | SetContext-Gruppen | Kapseln Kind-Widgets |
| **Fensterobjekte** | Seiten, Tab-Bereiche, Dialoge | Gruppieren GUI-Objekte |

---

## Objekte ohne Daten

Objekte ohne eigenen Datenwert. Man kann sie anklicken, aber nicht
mit `SetValue` beschreiben. Ein Button zeigt eine **Beschriftung**
(Caption), aber keinen veränderbaren Wert — deshalb gibt es kein
`VerifyValue`, sondern `VerifyCaption`.

**Typische Vertreter:**

- Button / Pushbutton
- Link / Hyperlink
- MenuItem (Menüeintrag)

**Anwendbare Keywords:**

| Keyword | Zweck |
|---|---|
| `ClickOn` | Anklicken |
| `DoubleClickOn` | Doppelklicken |
| `MoveOver` | Maus darüber bewegen (Hover) |
| `VerifyCaption` | Beschriftung prüfen |
| `VerifyTooltip` | Tooltip prüfen |
| `VerifyExists` | Existenz prüfen (YES/NO) |
| `LogCaption` | Beschriftung protokollieren |
| `SelectMenu` | Menüeintrag auswählen (nur Menüs) |

**Beispiel:**

```robot
ClickOn         Anmelden
VerifyCaption   Anmelden    Anmelden
VerifyTooltip   Speichern   Dokument speichern (Strg+S)
```

```yaml
Anmelden:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '[data-test="login-button"]' }
```

---

## Eindimensionale Objekte

Objekte mit **einem Wert**. Man kann den Wert setzen, lesen und prüfen.

### TextField / MultilineField

Textfelder für eine Zeile oder mehrere Zeilen.

| Keyword | Zweck |
|---|---|
| `SetValue` | Text eingeben (vorherigen Inhalt ersetzen) |
| `TypeKey` | Text eintippen (ohne vorheriges Löschen) |
| `Delete` | Feldinhalt löschen |
| `VerifyValue` | Wert prüfen (EXACT, WCM, REGX) |
| `VerifyPlaceholder` | Platzhaltertext prüfen |
| `MemorizeValue` | Wert speichern |
| `LogValue` | Wert protokollieren |

```robot
SetValue       Benutzer    admin
VerifyValue    Benutzer    admin
Delete         Benutzer
VerifyValue    Benutzer    ${EMPTY}
```

```yaml
Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="username"]' }
```

### Checkbox

Binärer Zustand: an oder aus.

| Keyword | Zweck |
|---|---|
| `SetValue` | Zustand setzen (Checked/Unchecked oder YES/NO) |
| `ClickOn` | Zustand umschalten |
| `VerifyValue` | Zustand prüfen |

```robot
SetValue       AGB    Checked
VerifyValue    AGB    Checked
ClickOn        AGB
VerifyValue    AGB    Unchecked
```

```yaml
AGB:
  class: okw_web_selenium.widgets.webse_checkbox.WebSe_CheckBox
  locator: { id: accept-terms }
```

### ComboBox (Dropdown)

Auswahl eines Werts aus einer Liste.

| Keyword | Zweck |
|---|---|
| `Select` | Eintrag auswählen |
| `SetValue` | Eintrag auswählen (Alias für Select) |
| `VerifyValue` | Ausgewählten Wert prüfen |
| `VerifyListCount` | Anzahl der Einträge prüfen |

```robot
Select         Land    Deutschland
VerifyValue    Land    Deutschland
```

```yaml
Land:
  class: okw_web_selenium.widgets.webse_combobox.WebSe_ComboBox
  locator: { id: country-select }
```

### RadioList (Radiobutton-Gruppe)

Auswahl genau eines Werts aus einer Gruppe.

| Keyword | Zweck |
|---|---|
| `Select` | Option auswählen |
| `VerifyValue` | Ausgewählte Option prüfen |
| `VerifyListCount` | Anzahl der Optionen prüfen |

```robot
Select         Zahlungsart    Kreditkarte
VerifyValue    Zahlungsart    Kreditkarte
```

```yaml
Zahlungsart:
  class: okw_web_selenium.widgets.webse_radiolist.WebSe_RadioList
  locator: { css: '[name="payment-method"]' }
```

### ListBox (Mehrfachauswahl)

Liste mit einfacher oder mehrfacher Auswahl.

| Keyword | Zweck |
|---|---|
| `Select` | Eintrag auswählen |
| `VerifyValue` | Ausgewählten Wert prüfen |
| `VerifyListCount` | Anzahl der Einträge prüfen |
| `VerifySelectedCount` | Anzahl der ausgewählten Einträge prüfen |

```robot
Select                 Farben    Rot, Blau
VerifyValue            Farben    Rot, Blau
VerifySelectedCount    Farben    2
```

```yaml
Farben:
  class: okw_web_selenium.widgets.webse_listbox.WebSe_ListBox
  locator: { id: color-list }
```

### Label (Statischer Text)

Nur-Lese-Objekte — Text, der angezeigt, aber nicht editiert wird.

| Keyword | Zweck |
|---|---|
| `VerifyValue` | Angezeigten Text prüfen (EXACT, WCM, REGX) |
| `VerifyCaption` | Beschriftung prüfen |
| `MemorizeValue` | Text speichern |
| `LogValue` | Text protokollieren |

```robot
VerifyValue    Fehlermeldung    Epic sadface: Username is required
```

```yaml
Fehlermeldung:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="error"]' }
```

!!! note "Label ist kein Button"
    Ein Label hat keinen `SetValue` und keinen `ClickOn`. Wenn ein
    Text anklickbar ist, ist er ein Link oder ein Button — nicht
    ein Label.

---

## Mehrdimensionale Objekte

### Table

Tabellen haben zwei Dimensionen: **Zeile × Spalte**. Die Keywords
adressieren einzelne Zellen, ganze Zeilen, ganze Spalten oder die
gesamte Tabelle.

**Index-basierte Keywords** (Zeile/Spalte als Nummer, 1-basiert):

| Keyword | Parameter | Zweck |
|---|---|---|
| `VerifyTableCellValue` | Name, Zeile, Spalte, Erwartet | Einzelne Zelle prüfen |
| `VerifyTableRowContent` | Name, Zeile, ZeilenMuster | Ganze Zeile prüfen |
| `VerifyTableColumnContent` | Name, Spalte, SpaltenMuster | Ganze Spalte prüfen |
| `VerifyTableRowCount` | Name, Erwartet | Zeilenanzahl prüfen |
| `VerifyTableColumnCount` | Name, Erwartet | Spaltenanzahl prüfen |
| `VerifyTableHasRow` | Name, ZeilenMuster | Prüfen ob Zeile existiert |
| `VerifyTableContent` | Name, TabellenMuster | Gesamte Tabelle prüfen |

**Header-basierte Keywords** (Zeile per Schlüsselwert, Spalte per Überschrift):

| Keyword | Zweck |
|---|---|
| `VerifyTableCellValueByHeaders` | Zelle über Zeilen-Key + Spalten-Header |
| `VerifyTableRowContentByHeader` | Zeile über Header + Key |
| `VerifyTableColumnContentByHeader` | Spalte über Header |

```robot
# Index-basiert: Zeile 2, Spalte 3
VerifyTableCellValue    Ergebnistabelle    2    3    42.50

# Header-basiert: Zeile mit Name "Smith", Spalte "Alter"
VerifyTableCellValueByHeaders    Ergebnistabelle    Smith    Alter    35
```

```yaml
Ergebnistabelle:
  class: okw_web_selenium.widgets.webse_table.WebSe_Table
  locator: { css: 'table.results' }
```

!!! info "Trennzeichen"
    Zellen innerhalb einer Zeile werden mit `$TAB` getrennt, Zeilen
    mit `$LF`. Diese Tokens sind konfigurierbar.

---

## Rahmenobjekte (Context)

Webanwendungen enthalten häufig **wiederholende Strukturen** —
Produktkarten, Tabellenzeilen, Listeneinträge — die intern dieselbe
Struktur haben. Statt jede Instanz einzeln im YAML zu definieren,
fasst `SetContext` sie zusammen.

Ein Rahmenobjekt ist kein Widget — es ist ein **Container**, der
Kind-Widgets gruppiert und über einen Platzhalter identifiziert wird.

```robot
SetContext      ProduktKarte    Sauce Labs Backpack
VerifyValue     Produktpreis    $29.99
ClickOn         InDenWarenkorb
```

```yaml
ProduktKarte:
  __context__:
    locator: { xpath: '//div[@class="product"]
      [.//h3[text()="{ProduktName}"]]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/span[@class="price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button[contains(@class,"add-to-cart")]' }
```

**Regeln:**

- `__context__` ist ein reservierter Schlüssel — wie `__self__`.
- Platzhalter nutzen `{Name}`-Syntax: `SetContext ProduktKarte Sauce Labs Backpack`
  ersetzt `{ProduktName}` im Locator.
- Kind-Locatoren sind relativ (`.//...`) — scoped auf das Context-Element.
- `SelectWindow` löscht den Kontext automatisch.

!!! warning "Nur XPath"
    SetContext erfordert XPath — sowohl für den `__context__`-Locator als
    auch für die Kind-Locatoren. CSS-Selektoren unterstützen keine
    Textsuche und keine relative Pfadkomposition.

    Bibliotheken ohne XPath (Java RemoteSwing, SAP GUI) unterstützen
    **kein SetContext**.

Ausführliche Dokumentation: [SetContext](setcontext.md)

---

## Fensterobjekte

Ein **Fenster** in OKW ist das, was man als Fenster **definiert**.
Das kann eine ganze Seite sein, aber auch ein Teilbereich — z.B.
ein Tab-Register, ein Dialog oder ein Panel.

```robot
SelectWindow    Login
SetValue        Benutzer    admin

SelectWindow    Einstellungen
ClickOn         Speichern
```

`SelectWindow` legt fest, in welchem Bereich nachfolgende Keywords
wirken. Es ist der **Scope** für alle Widget-Operationen.

### Seiten als Fenster

Im Web ist eine Seite typischerweise ein Fenster:

```yaml
# locators/SauceDemoLogin.yaml
__self__:
  class: okw_web_selenium.widgets.webse_label.WebSe_Label
  locator: { css: '[data-test="login-container"]' }

Benutzer:
  class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
  locator: { css: '[data-test="username"]' }
```

### Tab-Bereiche als Fenster

Ein Tab-Register innerhalb einer Seite kann als eigenes Fenster
definiert werden — die Widgets auf dem Tab gehören logisch zusammen:

```yaml
# Tab "Persönliche Daten" als Fenster
PersoenlicheDaten:
  __self__:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { css: '#tab-personal' }
  Vorname:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#first-name' }
  Nachname:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#last-name' }

# Tab "Adresse" als Fenster
Adresse:
  __self__:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { css: '#tab-address' }
  Strasse:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#street' }
  PLZ:
    class: okw_web_selenium.widgets.webse_textfield.WebSe_TextField
    locator: { css: '#zip' }
```

```robot
SelectWindow    PersoenlicheDaten
SetValue        Vorname    Max
SetValue        Nachname   Mustermann

SelectWindow    Adresse
SetValue        Strasse    Hauptstr. 1
SetValue        PLZ        12345
```

### `__self__` als Pre-Condition

Das `__self__`-Element eines Fensters dient als **Pre-Condition**:
`SelectWindow` wartet, bis dieses Element existiert, bevor es
fortfährt. Wähle ein Element, das den Fensterbereich eindeutig
identifiziert — ein Container-`<div>`, ein Formular, ein Tab-Panel.

!!! tip "Fenster = logische Gruppierung"
    Ein Fenster ist kein technisches Konzept (kein Browser-Window,
    kein OS-Dialog). Es ist eine **logische Gruppierung** von
    GUI-Objekten, die zusammen getestet werden. Der Tester
    entscheidet, was ein Fenster ist.

---

## Keyword-Matrix

Die folgende Matrix zeigt, welche Keywords auf welche Objekt-Kategorie
anwendbar sind:

### Aktionen

| Keyword | Ohne Daten | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `ClickOn` | ✓ | ✓ | ✓ | | | | |
| `DoubleClickOn` | ✓ | | | | | | |
| `MoveOver` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `SetValue` | | ✓ | ✓ | ✓ | | | |
| `Select` | | | | ✓ | ✓ | ✓ | |
| `TypeKey` | | ✓ | | ✓ | | | |
| `Delete` | | ✓ | | | | | |
| `SelectMenu` | ✓ | | | | | | |

### Prüfungen

| Keyword | Ohne Daten | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `VerifyValue` | | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `VerifyCaption` | ✓ | | | | | | |
| `VerifyTooltip` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `VerifyExists` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `VerifyPlaceholder` | | ✓ | | ✓ | | | |
| `VerifyListCount` | | | | ✓ | ✓ | ✓ | |
| `VerifyTableCellValue` | | | | | | | ✓ |
| `VerifyTableRowCount` | | | | | | | ✓ |

### Speichern / Protokollieren

| Keyword | Ohne Daten | TextField | Checkbox | ComboBox | RadioList | ListBox | Table |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `MemorizeValue` | | ✓ | ✓ | ✓ | | ✓ | |
| `MemorizeCaption` | ✓ | | | | | | |
| `LogValue` | | ✓ | ✓ | ✓ | | ✓ | |
| `LogCaption` | ✓ | | | | | | |
