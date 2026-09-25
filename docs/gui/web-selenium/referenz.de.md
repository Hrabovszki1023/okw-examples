# Referenz

## Widget-Klassen

Jede Widget-Klasse kapselt eine HTML-Elementfamilie. Die Interaktion
einschließlich Synchronisation ist **einmal** in der Klasse implementiert
und gilt für jedes GUI-Objekt dieses Typs.

| Widget-Klasse | HTML-Elemente | Typische Keywords |
|---|---|---|
| `WebSe_TextField` | `<input>` | SetValue, VerifyValue, TypeKey, Delete |
| `WebSe_MultilineField` | `<textarea>` | SetValue, VerifyValue, TypeKey, Delete |
| `WebSe_Button` | `<button>`, `<input type=button>` | ClickOn, VerifyCaption |
| `WebSe_CheckBox` | `<input type=checkbox>` | ClickOn, SetValue, VerifyValue |
| `WebSe_ComboBox` | `<select>`, Custom-Dropdowns | Select, VerifyValue |
| `WebSe_ListBox` | `<select multiple>`, `<ul>` | Select, VerifyValue |
| `WebSe_RadioList` | `<input type=radio>` | Select, VerifyValue |
| `WebSe_Label` | `<span>`, `<div>`, `<p>`, `<label>` | VerifyValue, VerifyCaption |
| `WebSe_Link` | `<a>` | ClickOn, VerifyCaption |
| `WebSe_Table` | `<table>` | siehe [Tabellen](tabellen.md) |

Die Widget-Klasse wird im YAML-Feld `class` festgelegt. Im Testcode
taucht sie nie auf — der Test spricht nur Business-Sprache.

Alle Widgets beherrschen zusätzlich `MoveOver` ([Hover](hover.md)) und
Drag & Drop ([Drag & Drop](drag-and-drop.md)) über die Basisklasse
`WebSe_Base`.

## Locator-Strategien

Das `locator`-Feld im YAML unterstützt alle Selenium-Strategien:

| Strategie | Beispiel | Wann verwenden |
|---|---|---|
| `css` | `{ css: '[data-test="username"]' }` | Standard für die meisten Elemente |
| `xpath` | `{ xpath: '//div[@class="price"]' }` | Textsuche, komplexe Hierarchien, SetContext |
| `id` | `{ id: user-name }` | Wenn das Element eine stabile ID hat |
| `name` | `{ name: password }` | HTML-`name`-Attribut |

**Empfehlung:** CSS für einfache Elemente, XPath wenn Text-Matching oder
SetContext benötigt wird.

Zusätzliche YAML-Keys für Isolationsgrenzen:

| Key | Zweck | Seite |
|---|---|---|
| `shadow_host` | Element liegt in einem Shadow DOM (nur CSS) | [Shadow DOM und iFrames](shadow-dom-iframe.md) |
| `iframe` | Element liegt in einem iFrame | [Shadow DOM und iFrames](shadow-dom-iframe.md) |
| `__context__` | Wiederholende Struktur mit Platzhalter (nur XPath) | [Wiederholende Strukturen](setcontext.md) |

## Match Modes: Exakt, Wildcard, Regex

Alle `Verify*`-Keywords unterstützen drei Matching-Modi:

```robot
# Exakte Übereinstimmung (Standard)
VerifyValue        Titel    Products

# Wildcard: * = beliebige Zeichen, ? = ein Zeichen
VerifyValueWCM     Seitentitel    *IFrame*

# Regulärer Ausdruck
VerifyValueREGX    Preis    \$\d+\.\d{2}
```

Details: [Tokens und Match Modes](../../grundlagen/tokens-und-match-modes.md).

## Web-spezifische Keywords

Diese Keywords gibt es nur in der Selenium-Bibliothek:

| Keyword | Beschreibung |
|---|---|
| `ExecuteJS` | JavaScript im Browser-Kontext ausführen |
| `RemoveAds` | Werbe-Iframes/Overlays entfernen (per JS + MutationObserver) |

### RemoveAds

Entfernt Werbeelemente von der aktuellen Seite. Ein `MutationObserver`
wird installiert, der auch nachgeladene Ads entfernt.

```robot
# Standard (Google Ads):
OnFailIgnoreNOISE    RemoveAds

# Projektspezifische Selektoren:
OnFailIgnoreNOISE    RemoveAds    div.custom-banner    iframe[src*="ad-network"]
```

Am besten im Test-Setup mit `OnFailIgnoreNOISE` — wenn keine Ads da sind,
passiert nichts.

## Lauffähige Beispiele

Alle Beispiele aus diesem Kapitel stammen aus dem okw-examples Repository:

| Beispiel | Was es zeigt |
|---|---|
| [SauceDemo](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/saucedemo) | Login, OnFailNOISE, SetContext, ComboBox-Sortierung |
| [ExpandTesting](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/expandtesting) | Shadow DOM, iFrames, Drag & Drop, dynamische Tabellen, Hover |
| [The Internet](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium/the-internet) | Login, Checkboxen, Dropdown, Tabellen, Hover |

```bash
git clone https://github.com/Hrabovszki1023/okw-examples.git
cd okw-examples/selenium/saucedemo
pip install robotframework-okw-web-selenium
robot tests/
```
