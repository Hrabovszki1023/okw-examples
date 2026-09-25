# Wiederholende Strukturen

Jeder Online-Shop hat Produktkarten, jedes Dashboard Datenzeilen, jedes
Postfach Nachrichten. Alle haben dasselbe Problem: **N gleiche
Strukturen, jede mit anderen Daten.**

Der klassische Weg: eine Methode mit Index, eine Schleife über alle
Elemente oder ein eigener Locator pro Instanz. Das wird schnell
unübersichtlich. Mit `SetContext` sagt der Test einfach: „Ich spreche
jetzt über die Karte *Sauce Labs Backpack*.“

Die Theorie steht in [Grundlagen → SetContext](../../grundlagen/setcontext.md).
Diese Seite zeigt die Praxis auf [saucedemo.com](https://www.saucedemo.com).

![SauceDemo Produktübersicht](images/02_saucedemo_products.png)

## Der Test

```robot
*** Keywords ***
Produktpreis Pruefen
    [Arguments]    ${produkt}    ${erwarteter_preis}
    SetContext         ProduktKarte    ${produkt}
    VerifyValue        Produktpreis    ${erwarteter_preis}

Produkt In Warenkorb Legen
    [Arguments]    ${produkt}
    SetContext         ProduktKarte    ${produkt}
    ClickOn            InDenWarenkorb

*** Test Cases ***
SetContext Produktpreise Pruefen
    SauceDemo Oeffnen Und Anmelden

    OnFailNOISE    SelectWindow   SauceDemoProducts
    OnFailNOISE    VerifyValue    Titel    Products
    Produktpreis Pruefen    Sauce Labs Backpack      $29.99
    Produktpreis Pruefen    Sauce Labs Bike Light    $9.99
    Produktpreis Pruefen    Sauce Labs Bolt T-Shirt  $15.99
    Produktpreis Pruefen    Sauce Labs Fleece Jacket  $49.99
    Produktpreis Pruefen    Sauce Labs Onesie        $7.99
    StopApp        MyAppChrome

SetContext Produkt In Warenkorb
    SauceDemo Oeffnen Und Anmelden

    OnFailNOISE    SelectWindow   SauceDemoProducts
    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    StopApp        MyAppChrome
```

Dasselbe Keyword (`VerifyValue Produktpreis`), jedes Mal ein anderes
Produkt. Keine Schleifen, keine Indizes, keine eigene Definition pro Karte.
Aktionen funktionieren genauso: Derselbe Button-Name `InDenWarenkorb`
wirkt auf die jeweils gesetzte Karte.

## Eine YAML für alle Karten

```yaml
# locators/SauceDemoProducts.yaml (Auszug)
ProduktKarte:
  __context__:
    locator: { xpath: '//div[@data-test="inventory-item"][.//div[@data-test="inventory-item-name" and text()="{ProduktName}"]]' }
  Produktname:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-name"]' }
  Produktbeschreibung:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-desc"]' }
  Produktpreis:
    class: okw_web_selenium.widgets.webse_label.WebSe_Label
    locator: { xpath: './/div[@data-test="inventory-item-price"]' }
  InDenWarenkorb:
    class: okw_web_selenium.widgets.webse_button.WebSe_Button
    locator: { xpath: './/button' }
```

Der `__context__`-Block definiert einen Container mit **Platzhalter**
`{ProduktName}`. Alle Kind-Widgets nutzen relative Locatoren (`.//`) —
sie werden innerhalb der gefundenen Karte ausgewertet.

## So funktioniert es

```
SetContext    ProduktKarte    Sauce Labs Backpack
                  │                    │
                  ▼                    ▼
          Kontext-Gruppe       Platzhalter-Wert
```

1. OKW findet `ProduktKarte.__context__.locator`.
2. `{ProduktName}` wird durch „Sauce Labs Backpack“ ersetzt.
3. Der aufgelöste XPath wird als aktiver Kontext gespeichert.
4. Beim Zugriff auf `Produktpreis` stellt OKW den Kontext-XPath dem
   relativen Kind-Locator voran.
5. Ergebnis: ein XPath, der genau den Preis in der Backpack-Karte findet.

Der nächste `SetContext` wechselt zur nächsten Karte. `SelectWindow`
löscht den Kontext.

!!! warning "Nur XPath"
    SetContext erfordert XPath — sowohl für den `__context__`-Locator als
    auch für die Kind-Locatoren. CSS-Selektoren können keinen Textinhalt
    matchen und unterstützen keine relative Pfadkomposition.

## Warum nicht einfach XPath mit dem Produktnamen?

Man könnte schreiben:

```robot
Click Element    xpath://div[contains(.,'Backpack')]//button[contains(@data-test,'add-to-cart')]
```

Dann aber:

- steht in jedem Test der vollständige XPath (NOISE im Testfall),
- fehlt die Widget-Information — keine Synchronisation, keine Screenshots,
  kein Retry,
- muss bei einer DOM-Änderung jede Testdatei angepasst werden,
- lässt sich das Locator-Muster nicht wiederverwenden.

Mit `SetContext` steht das Muster **einmal** in YAML. Der Test sagt,
**was er meint** — nicht, wie man es findet.

## Lauffähiges Beispiel

[`selenium/saucedemo/tests/SauceDemo_SetContext.robot`](https://github.com/Hrabovszki1023/okw-examples/blob/master/selenium/saucedemo/tests/SauceDemo_SetContext.robot)
