# Testbarkeit: Beobachtbarkeit und Steuerbarkeit

## Das Problem: Warten ist geraten

Ein automatisierter Test ist schneller als jeder Mensch. Nach einem
Klick auf „Anmelden“ steht der nächste Schritt schon bereit, während die
Anwendung noch lädt, rendert oder auf den Server wartet. Der Test muss
also wissen: **Wann ist die Anwendung bereit?**

Die naheliegende Antwort ist ein `Sleep`:

```robot
ClickOn        Anmelden
Sleep          3s
VerifyExists   Produktliste    YES
```

Ein fester Sleep ist aber **nie richtig**:

- **Zu kurz:** Die Anwendung ist an diesem Tag etwas langsamer, der Test
  wird rot. Die Ursache liegt nicht im SUT, sondern im Test. Das ist
  ein **N** im Sinne von [Signal vs. NOISE](signal-vs-noise.md).
- **Zu lang:** Der Test wartet auch dann, wenn die Anwendung längst
  bereit ist. Die verschwendete Zeit wächst mit jeder Stelle, jedem
  Testfall und jedem Lauf.
- **Nicht wartbar:** Wird aus `3s` später `5s`, müssen alle Stellen
  angepasst werden.

### Was ein Sleep kostet

Die verschwendete Zeit pro Lauf ist
**Wartezeit × Stellen pro Test × Anzahl Tests**:

| Szenario | Wartezeit | Stellen pro Test | Tests | Verschwendung pro Lauf |
|---|---|---|---|---|
| Ein Sleep nach dem Login | 10 s | 1 | 5.000 | 50.000 s ≈ **13 h 53 min** |
| Drei kleine Sleeps | 2 s | 3 | 5.000 | 30.000 s ≈ **8 h 20 min** |
| Viele Mini-Sleeps | 1 s | 10 | 5.000 | 50.000 s ≈ **13 h 53 min** |

Bei einem nächtlichen Lauf an 20 Arbeitstagen wird daraus das
Zwanzigfache. Parallelisierung verkürzt nur die Laufzeit auf der Uhr.
Die Rechenzeit, und damit die Kosten, bleiben gleich.

!!! note "Ein Sleep ist ein Symptom"
    Ein Sleep im Test zeigt, dass eine Information fehlt: Der Test kann
    nicht **sehen**, ob die Anwendung bereit ist. Das Problem liegt also
    nicht in der Wartezeit, sondern in der **Testbarkeit** des SUT.

## Zwei Eigenschaften des SUT

Testbarkeit hat zwei Seiten:

| Eigenschaft | Frage | Beispiele |
|---|---|---|
| **Beobachtbarkeit** | Kann der Test den Zustand des SUT zuverlässig **erkennen**? | Element sichtbar und aktiv, Ladeanzeige verschwunden, `aria-busy="false"`, eindeutige Test-IDs |
| **Steuerbarkeit** | Kann der Test das SUT gezielt in einen Zustand **bringen**? | Testdaten per API anlegen, Animationen abschalten, Uhrzeit festlegen, Feature-Flags setzen |

Beides sind Eigenschaften der **Anwendung**, nicht des Testwerkzeugs.
Fehlen sie, muss der Testcode sie ausgleichen: mit Sleeps, mit
zerbrechlichen Locatoren, mit langen Klickstrecken durch die GUI, um
Testdaten anzulegen. Jede dieser Stellen ist eine **potenzielle
NOISE-Quelle**.

| Fehlt ... | Symptom im Test | Folge |
|---|---|---|
| Beobachtbarkeit des Ladezustands | `Sleep` | Zu kurz: N. Zu lang: verschwendete Zeit |
| Beobachtbarkeit der Elemente | XPath über Layout-Strukturen | Jede Layoutänderung erzeugt ein N |
| Steuerbarkeit der Testdaten | Daten über die GUI anlegen | Lange Vorbereitung, jeder Schritt kann ein N erzeugen |
| Steuerbarkeit der Zeit | Test hängt von Datum oder Uhrzeit ab | Test läuft nur an bestimmten Tagen grün |

## Wie OKW synchronisiert

OKW verlagert das Warten aus dem Testfall in die Bibliothek. Der
Testfall beschreibt nur, **was** geschieht. Wann ein Widget bereit ist,
entscheidet das Widget selbst.

```robot
*** Test Cases ***
Login mit gültigem Benutzer
    OKW.StartApp       MeinAppChrome

    OKW.SelectWindow   Login
    OKW.SetValue       Benutzername    standard_user
    OKW.SetValue       Kennwort        secret_sauce
    OKW.ClickOn        Anmelden

    OKW.SelectWindow   Products
    OKW.VerifyExists   Produktliste    YES

    OKW.StopApp
```

Kein Sleep, kein `Wait Until ...`. Trotzdem wartet der Test an genau
den richtigen Stellen, und zwar nur so lange wie nötig.

### Vor jeder Aktion: ist das Widget bereit?

Bevor Web Selenium eine Aktion wie `SetValue`, `ClickOn` oder `Select`
ausführt, prüft das Widget nacheinander:

1. **exists:** Das Element ist im DOM vorhanden.
2. **scroll_into_view:** Das Element wird in den sichtbaren Bereich gescrollt.
3. **visible:** Das Element ist sichtbar.
4. **enabled:** Das Element ist aktiv, nicht `disabled`.
5. **editable:** Das Eingabefeld ist beschreibbar, nicht `readonly`
   (nur bei Textfeldern).
6. **until_not_visible:** Projektweite Ladeanzeigen sind verschwunden
   (siehe unten).

Jede Prüfung wird alle 0,1 s wiederholt, bis sie erfüllt ist oder der
Timeout (Standard: 10 s) abläuft. Ist das Widget nach 0,3 s bereit,
geht es nach 0,3 s weiter.

!!! info "Treiberabhängig"
    Diese Aktions-Synchronisation ist heute in der Web-Selenium-Bibliothek
    umgesetzt. Das Prüfen mit Timeout (nächster Abschnitt) gilt dagegen
    für **alle** Treiber, weil es im OKW4Robot-Kern liegt.

### Bei jeder Prüfung: ist der Sollwert erreicht?

Alle `Verify*`-Keywords prüfen nicht einmal, sondern **wiederholt**: Sie
lesen den Istwert, vergleichen ihn mit dem Sollwert und versuchen es
erneut, bis er stimmt oder der Timeout abläuft.

```robot
ClickOn        Speichern
VerifyValue    Statusmeldung    Gespeichert    # wartet bis zu 10 s auf den Text
```

Damit ist die Prüfung selbst die Synchronisation. Ein vorgeschaltetes
Warten ist unnötig. Das funktioniert, weil `Verify*`-Keywords nur lesen
und damit [idempotent](idempotenz.md) sind: Sie dürfen beliebig oft
wiederholt werden.

| Variable | Standard | Wirkt auf |
|---|---|---|
| `${OKW_TIMEOUT_VERIFY_VALUE}` | 10 s | `VerifyValue` und Varianten |
| `${OKW_TIMEOUT_VERIFY_EXISTS}` | 2 s | `VerifyExists`, `VerifyWindowExists` |
| `${OKW_TIMEOUT_VERIFY_VISIBLE}` | 2 s | `VerifyIsVisible` |
| `${OKW_TIMEOUT_VERIFY_ENABLED}` | 2 s | `VerifyIsEnabled` |
| `${OKW_POLL_VERIFY}` | 0,1 s | Abfrageintervall aller `Verify*` |

### Timeout statt Wartezeit

Der entscheidende Unterschied zum Sleep:

| | Sleep | OKW-Timeout |
|---|---|---|
| Bedeutung | Feste Wartezeit | **Obergrenze** |
| Anwendung schnell | Wartet trotzdem die volle Zeit | Geht sofort weiter |
| Anwendung langsam | Wird rot (N) | Wartet bis zur Obergrenze |
| Wert erhöhen kostet | Zeit in **jedem** Lauf | Nur Zeit, wenn die Anwendung wirklich langsam ist |

Einen Timeout großzügig zu wählen ist daher fast kostenlos. Einen Sleep
großzügig zu wählen ist teuer.

## Beobachtbarkeit nutzen: Ladeanzeigen

Viele Anwendungen zeigen während des Ladens einen Spinner oder ein
halbtransparentes Overlay. Solange es sichtbar ist, sind die Elemente
darunter zwar vorhanden, aber nicht bedienbar. Genau hier entsteht
sonst der Impuls, einen Sleep einzubauen.

Wenn die Anwendung ihre Ladeanzeige **beobachtbar** macht, nutzt OKW
sie direkt. Projektweit genügt eine Variable:

```robot
*** Variables ***
${OKW_BUSY_SELECTORS_WRITE}    css:.spinner, css:.busy-overlay
```

Vor jeder Aktion wartet OKW dann zusätzlich, bis diese Elemente
verschwunden sind.

Braucht nur ein einzelnes Widget eine Sonderbehandlung, wird das im
YAML am Widget festgelegt. Der Test bleibt unverändert:

```yaml
Speichern:
  class: okw_web_selenium.widgets.webse_button.WebSe_Button
  locator: { css: '[data-testid="btn-save"]' }
  wait:
    write:
      timeout: 20
      until_not_visible:
        - css:.page-overlay
```

Die Regel dahinter ist dieselbe wie bei den [YAML-Locatoren](yaml-locator.md):
Technisches Wissen steht an **einer** Stelle, nicht in jedem Testfall.

## Timeouts richtig einstellen

| Ebene | Mechanismus | Wann |
|---|---|---|
| **Global** | Standardwerte | Passt meistens |
| **Projekt** | `*** Variables ***` in einer Resource-Datei | Die Anwendung ist generell langsamer |
| **Widget** | `wait:`-Block im YAML | Ein einzelnes Widget ist ein Sonderfall |
| **Testfall** | `SetOKWParameter    TimeOutVerifyValue    20s` | Ein Test braucht ausnahmsweise mehr Zeit |
| **Ausführung** | `robot --variable OKW_TIMEOUT_VERIFY_VALUE:30s` | Langsame CI-Umgebung, Debugging |

Faustregel: so weit oben wie möglich einstellen. Ein Timeout im
Testfall ist erlaubt, sollte aber die Ausnahme bleiben.

## Steuerbarkeit: was die Entwicklung beitragen kann

Beobachtbarkeit hilft dem Test beim **Warten**. Steuerbarkeit hilft
ihm, gar nicht erst warten zu müssen. Die folgenden Funktionen liegen
in der Anwendung. Das Testteam kann sie nicht selbst bauen, sollte sie
aber früh bei der Entwicklung anfragen:

| Funktion | Zweck | Wirkung auf den Test |
|---|---|---|
| **Test-Modus** | Anwendung erkennt, dass sie getestet wird | Schaltet die folgenden Funktionen gesammelt ein |
| **Animationen aus** | Keine Übergangseffekte | Weniger Wartezeit, keine halb sichtbaren Elemente |
| **Testdaten per API** | Ausgangszustand direkt anlegen | Kurze, stabile Vorbereitung statt GUI-Klickstrecke |
| **Uhr festlegen** | Datum und Uhrzeit bestimmen | Datumsabhängige Tests laufen jeden Tag gleich |
| **Feature-Flags** | Funktionen gezielt an- oder abschalten | Tests laufen unabhängig vom Ausbaustand |
| **Stabile Test-IDs** | `data-testid` an bedienbaren Elementen | Locatoren überstehen Layoutänderungen |

Testdaten per API lassen sich direkt mit der
[OKW-REST-Bibliothek](../spezial/rest-api.md) im selben Testfall
anlegen. So wird die Vorbereitung (Phase 1 und 2 im
[5-Phasen-Modell](idempotenz.md#idempotenz-im-5-phasen-modell)) kurz
und idempotent.

!!! warning "Test-Modus nie in Produktion"
    Ein Test-Modus, der Logins abkürzt oder die Uhr verstellt, darf in
    Produktion nicht aktivierbar sein. Er gehört hinter eine
    Umgebungskonfiguration, die es nur auf Testsystemen gibt.

## Beispiel aus diesem Repository

Der Register-Test für expandtesting.com enthält nach dem Entfernen der
Werbung einen Sleep:

```robot
Register Seite Oeffnen
    OnFailNOISE          StartApp       MyAppChrome

    OnFailNOISE          SelectWindow   Chrome
    OnFailNOISE          SetValue       URL    ${URL}
    OnFailIgnoreNOISE    RemoveAds
    Sleep    1
    OnFailNOISE          VerifyWindowExists    RegisterPage    YES
```

Auf den ersten Blick wirkt er überflüssig: `VerifyWindowExists` prüft
ohnehin wiederholt, und der Login-Test daneben hat denselben Ablauf ohne
Sleep. Eine Messung zeigt etwas anderes:

| Variante | Läufe | Ergebnis |
|---|---|---|
| Mit `Sleep 1` | 6 × 4 Tests | 24 grün |
| Ohne `Sleep` | 7 × 4 Tests | 26 grün, 2 rot |

Die beiden roten Tests scheiterten beim ersten `SetValue` mit
`element not interactable`, obwohl OKW vorher geprüft hatte, dass das
Feld existiert, sichtbar und aktiv ist. Das Feld war also für OKW
**scheinbar bereit**, aber noch nicht bedienbar. Beide Fehler sind ein
**N**: Die Registrierung selbst funktionierte einwandfrei.

Genau das meint dieses Kapitel: Der Sleep überbrückt ein **fehlendes
Signal**. Irgendetwas auf der Seite (etwa ein nachgeladenes Element oder
eine Layout-Verschiebung nach dem Entfernen der Werbung) macht das Feld
kurzzeitig unbedienbar, ohne dass es von außen beobachtbar ist. Die
richtige Lösung ist, die Ursache zu finden und als Busy-Selektor
einzutragen. Solange sie unbekannt ist, bleibt der Sleep eine bewusst
akzeptierte, **bekannte** NOISE-Quelle an genau einer Stelle, nicht in
jedem Testfall.

## Faustregeln

- **Kein `Sleep` im Testfall.** Wer einen braucht, hat ein fehlendes
  Signal gefunden.
- **Fehlendes Signal beheben, nicht überbrücken:** zuerst einen
  `Verify*`-Schritt als Synchronisation nutzen, dann eine Ladeanzeige
  als Busy-Selektor eintragen, zuletzt bei der Entwicklung ein Signal
  anfragen.
- **Timeouts sind Obergrenzen.** Großzügig wählen, zentral einstellen.
- **Testbarkeit ist eine Anforderung an das SUT.** Beobachtbarkeit und
  Steuerbarkeit gehören so früh wie möglich in die Entwicklung, nicht
  erst in die Testautomatisierung.
