# SetContext — Wiederholende Strukturen

## Das Problem

Viele Anwendungen haben wiederholende GUI-Strukturen: Produktkarten in
einem Webshop, Zeilen in einer Tabelle, Einträge in einer Liste. Jede
Instanz hat die gleichen Elemente (Name, Preis, Button), aber mit
unterschiedlichen Werten.

Ohne `SetContext` müsste man jede Instanz einzeln in YAML definieren —
das skaliert nicht.

## Die Lösung: SetContext

`SetContext` scoped nachfolgende Widget-Operationen auf eine bestimmte
Instanz einer wiederholenden Struktur.

!!! warning "SetContext funktioniert nur mit XPath"
    **Beide** Locatoren müssen XPath sein:

    1. der **Rahmen** um das wiederholende Element (`__context__.locator`)
    2. alle **Elemente im Rahmen** (die Kind-Widgets) — als relativer
       XPath (`.//...`)

    Achtung: Ein CSS-Locator im Rahmen führt derzeit **nicht** zu einer
    Fehlermeldung — der Kontext wird ignoriert und das Kind-Widget auf
    der ganzen Seite gesucht. Der Test greift dann womöglich auf die
    falsche Instanz zu. Warum nur XPath funktioniert, erklärt
    [So funktioniert es](#so-funktioniert-es).

### YAML-Definition

```yaml
ProduktKarte:
  __context__:
    locator:
      xpath: '//div[@data-test="inventory-item"][.//div[text()="{ProduktName}"]]'
  Produktname:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-name"]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button[contains(@data-test,"add-to-cart")]' }
```

**Schlüsselelemente:**

- `__context__` — Reservierter Schlüssel mit dem Locator der wiederholenden Struktur
- `{ProduktName}` — Platzhalter, der durch `SetContext` ersetzt wird
- `.//...` — Relative XPaths, die sich auf den Context beziehen

### Test

```robot
*** Test Cases ***
Produkt in den Warenkorb legen
    OKW.SelectWindow   Products
    OKW.SetContext     ProduktKarte    Sauce Labs Backpack
    OKW.VerifyValue    Produktpreis    $29.99
    OKW.ClickOn        InDenWarenkorb

    OKW.SetContext     ProduktKarte    Sauce Labs Bike Light
    OKW.VerifyValue    Produktpreis    $9.99
    OKW.ClickOn        InDenWarenkorb
```

## So funktioniert es

### SetContext ist wie dynamisches SQL

Man kann sich `SetContext` wie **dynamisches SQL** vorstellen: Die
Abfrage steht nicht fertig im YAML, sondern entsteht **erst zur
Laufzeit** — aus einer Vorlage mit Platzhalter, dem Wert aus dem Test
und dem Teil für das gesuchte Element.

| Dynamisches SQL | SetContext |
|---|---|
| Vorlage mit Platzhalter: `… WHERE name = '{name}'` | `__context__`-Locator mit `{ProduktName}` |
| Welche Zeile? — Parameter zur Laufzeit einsetzen | `SetContext ProduktKarte Sauce Labs Backpack` |
| Welche Spalte? — `SELECT preis` | Kind-Widget `Produktpreis` mit relativem XPath |
| Die Datenbank führt die fertige Abfrage aus | Der Browser wertet den fertigen XPath aus |

### Schritt für Schritt

**1. Vorlage** — der Rahmen aus dem YAML, mit Platzhalter:

```
//div[@data-test="inventory-item"][.//div[text()="{ProduktName}"]]
```

**2. Parameter einsetzen** — `SetContext ProduktKarte Sauce Labs Backpack`
ersetzt `{ProduktName}`:

```
//div[@data-test="inventory-item"][.//div[text()="Sauce Labs Backpack"]]
```

**3. Verketten** — bei `VerifyValue Produktpreis` wird der relative
XPath des Kind-Widgets angehängt:

```
(//div[@data-test="inventory-item"][.//div[text()="Sauce Labs Backpack"]])/.//div[@data-test="inventory-item-price"]
```

Erst dieser zusammengesetzte Ausdruck wird im Browser ausgewertet. Er
findet **nur** den Preis in der Backpack-Karte. Der nächste
`SetContext` baut die Abfrage mit einem anderen Wert neu.

### Warum nur XPath?

XPath ist die einzige Locator-Strategie, die **beides** kann, was
SetContext braucht:

1. **Verkettung** — zwei XPath-Ausdrücke lassen sich als Text zu
   **einem** gültigen Ausdruck zusammensetzen: Rahmen + relativer
   Kind-Pfad. `id` und `name` lassen sich gar nicht verketten.
2. **Auswahl über Textinhalt** — der Rahmen muss die Instanz über ihren
   sichtbaren Inhalt finden: „die Karte, in der *Sauce Labs Backpack*
   steht“. CSS kann zwar Nachfahren verketten (`.karte .preis`), aber
   **nicht nach Text filtern**.

## Regeln

- `__context__` ist ein reservierter Schlüssel auf Widget-Gruppen-Ebene
- Platzhalter verwenden `{Name}`-Syntax und werden per `str.format()` ersetzt
- Mehrere Platzhalter sind möglich: `SetContext Tabelle Zeile=A Spalte=3`
- `SelectWindow` setzt den Context zurück (neues Fenster = kein Context)
- Widgets **außerhalb** der Context-Gruppe werden nicht beeinflusst
- **Nur XPath:** der Rahmen (`__context__.locator`) **und** alle
  Kind-Locators müssen XPath sein — siehe [Warum nur XPath?](#warum-nur-xpath)
- Kind-Locators verwenden relative Pfade (`.//...`)

## Wann SetContext verwenden?

| Situation | Lösung |
|---|---|
| Einmalige Elemente (Login-Felder, Buttons) | Normales Widget in YAML |
| Wiederholende Strukturen (Karten, Zeilen, Listen) | `SetContext` |
| Tabellen mit festen Spalten | Table-Widget (wenn verfügbar) oder `SetContext` |

Praxisbeispiele siehe
[Web Selenium → Wiederholende Strukturen](../gui/web-selenium/setcontext.md).
