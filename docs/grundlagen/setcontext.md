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

### Was passiert intern?

1. `SetContext ProduktKarte Sauce Labs Backpack` setzt `{ProduktName}` = `Sauce Labs Backpack`
2. Bei `VerifyValue Produktpreis` wird:
    - `{ProduktName}` im `__context__`-Locator ersetzt
    - Der aufgelöste Context-XPath dem relativen Kind-Locator vorangestellt
3. Das Ergebnis: nur das Preiselement innerhalb der richtigen Produktkarte wird gelesen

## Regeln

- `__context__` ist ein reservierter Schlüssel auf Widget-Gruppen-Ebene
- Platzhalter verwenden `{Name}`-Syntax und werden per `str.format()` ersetzt
- Mehrere Platzhalter sind möglich: `SetContext Tabelle Zeile=A Spalte=3`
- `SelectWindow` setzt den Context zurück (neues Fenster = kein Context)
- Widgets **außerhalb** der Context-Gruppe werden nicht beeinflusst
- Context-Locators müssen **XPath** verwenden (kein CSS — keine Textauswahl,
  keine relative Pfadkomposition möglich)
- Kind-Locators verwenden relative Pfade (`.//...`)

## Wann SetContext verwenden?

| Situation | Lösung |
|---|---|
| Einmalige Elemente (Login-Felder, Buttons) | Normales Widget in YAML |
| Wiederholende Strukturen (Karten, Zeilen, Listen) | `SetContext` |
| Tabellen mit festen Spalten | Table-Widget (wenn verfügbar) oder `SetContext` |
