# Web Selenium

!!! info "In Bearbeitung"
    Dieses Kapitel wird noch geschrieben.

## Überblick

Die Bibliothek `robotframework-okw-web-selenium` ist der OKW-Treiber für
Webanwendungen. Sie verwendet Selenium WebDriver und die SeleniumLibrary
für Robot Framework.

## Installation

```bash
pip install robotframework-okw-web-selenium
```

## Verfügbare Widgets

| Widget-Klasse | HTML-Element | Verwendung |
|---|---|---|
| `WebSe_TextField` | `<input>`, `<textarea>` | Textfelder |
| `WebSe_Button` | `<button>`, `<input type="submit">` | Buttons |
| `WebSe_Label` | `<span>`, `<div>`, `<p>`, `<label>` | Statische Texte |
| `WebSe_Checkbox` | `<input type="checkbox">` | Checkboxen |
| `WebSe_Select` | `<select>` | Dropdown-Auswahlen |
| `WebSe_Link` | `<a>` | Links |
| `WebSe_Table` | `<table>` | Tabellen |

## Lauffähige Beispiele

Siehe [selenium/](https://github.com/Hrabovszki1023/okw-examples/tree/master/selenium)
im okw-examples Repository.
