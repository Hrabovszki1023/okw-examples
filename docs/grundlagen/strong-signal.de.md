# Strong Signal

## Vom Signal zum starken Signal

[Signal vs. NOISE](signal-vs-noise.md) unterscheidet drei Testergebnisse:
**P** (Pass), **F** (echter SUT-Fehler) und **N** (NOISE, Ursache
außerhalb des SUT). Damit ist aber noch nicht gesagt, **wie gut** ein
Signal ist.

Ein roter Test, bei dem erst eine halbe Stunde Analyse klärt, was
eigentlich kaputt ist, liefert zwar ein F, aber ein **schwaches**. Ein
**Strong Signal** ist ein Testergebnis, das ohne weitere Analyse sofort
zeigt:

- **was** geprüft wurde,
- **welcher fachliche Aspekt** betroffen ist,
- **warum** der Test rot ist.

Ein Strong-Signal-Testfall liefert außerdem **nie ein irreführendes
Ergebnis**. Scheitert er an NOISE, bedeutet das eindeutig: Über diesen
fachlichen Aspekt liegt in diesem Lauf **keine gültige Aussage** vor.
Er täuscht weder ein Grün noch ein Rot vor, das nichts mit seiner
Prüfabsicht zu tun hat.

## Abgrenzung: Testentwurf und Testumsetzung

Ein Signal kann aus zwei verschiedenen Gründen schwach sein:

| Schwach durch ... | Frage | Beispiel | Thema dieser Seite? |
|---|---|---|---|
| **Testentwurf** | Ist der Testfall geeignet, einen Fehler zu finden? | Der n-te Testfall prüft einen Wert **mitten** in einer Äquivalenzklasse, statt an ihren **Rändern**. Er bringt keine neue Erkenntnis. | Nein |
| **Testumsetzung** | Lässt sich das Ergebnis eindeutig einem fachlichen Aspekt zuordnen? | Der Testfall ist mit anderen verkettet oder prüft mehrere Aspekte auf einmal. | **Ja** |

Ob die Methode der Testableitung geeignet ist, Fehler zu finden (etwa
Grenzwertanalyse statt beliebiger Werte aus der Mitte einer
Äquivalenzklasse), wird hier **nicht** diskutiert. Diese Seite setzt
einen sinnvoll abgeleiteten Testfall voraus und beschreibt, wie er
**geschrieben** sein muss, damit sein Signal stark sein **kann**: damit
es nicht durch Verkettung mit anderen Testfällen oder durch vermischte
Prüfabsichten geschwächt wird.

Ein gut abgeleiteter Testfall kann durch schlechte Umsetzung sein
Signal verlieren. Ein schlecht abgeleiteter Testfall gewinnt durch gute
Umsetzung keine Erkenntnis. Beides ist nötig.

## Die acht Eigenschaften

| # | Eigenschaft | Kurz |
|---|---|---|
| 1 | Eine Prüfabsicht | One test, one intent |
| 2 | Sofortiger Abbruch | Der erste Fehler beendet den Test |
| 3 | Keine unnötigen Schritte | Nur was der Prüfabsicht dient |
| 4 | Klare Prüfungen | Soll und Ist stehen in der Fehlermeldung |
| 5 | Flache Struktur | Keine Kontrollstrukturen im Testfall |
| 6 | Ein fachliches Akzeptanzkriterium | Eine Ursache, ein Rot |
| 7 | Deterministische Eingaben | Gleiche Eingabe, gleiches Ergebnis |
| 8 | Fachliche Namen | Der Test liest sich wie eine Anleitung |

### 1. Eine Prüfabsicht pro Testfall

Ein Testfall prüft **genau einen** fachlichen Aspekt. Die
Login-Tests für expandtesting.com zeigen das:

```robot
*** Test Cases ***
Fehlerhafter Benutzername
    SelectWindow       LoginPage
    SetValue           Benutzer       wrongUser
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *invalid*

Fehlerhaftes Passwort
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       WrongPassword
    ClickOn            Anmelden

    SelectWindow       LoginPage
    VerifyValueWCM     Fehlermeldung    *invalid*
```

Beide Fälle hätten in einen Test gepasst. Getrennt sagt ein Rot sofort,
**welcher** der beiden Fälle nicht mehr funktioniert.

### 2. Der erste Fehler beendet den Test

Nach einem Fehler weiterzumachen erzeugt Folgefehler und Protokolle, in
denen der eigentliche Fehler untergeht. Robot Framework bricht einen
Testfall beim ersten Fehler von sich aus ab. Diesen Schutz sollte man
nicht aushebeln:

| Vermeiden im Testfall | Warum |
|---|---|
| `Run Keyword And Continue On Failure` | Test läuft nach dem Fehler weiter, Folgefehler überdecken die Ursache |
| `Run Keyword And Ignore Error` | Ein Fehler verschwindet still, der Test kann grün werden, obwohl etwas kaputt ist |
| `TRY` / `EXCEPT` | Versteckte Recovery-Logik, das Ergebnis ist nicht mehr eindeutig |

Die einzige bewusste Ausnahme in OKW ist `OnFailIgnoreNOISE` für
Schritte, die fachlich keine Rolle spielen, zum Beispiel `RemoveAds`.

### 3. Keine unnötigen Schritte

Jeder zusätzliche Schritt ist eine weitere Stelle, an der der Test
scheitern kann, ohne dass die Prüfabsicht betroffen ist. Ein Test für
„falsches Passwort“ muss danach nicht zur Startseite navigieren, sich
abmelden oder das Layout prüfen.

Aufräumen gehört in den `Test Teardown`, nicht in den Testfall:

```robot
*** Settings ***
Test Setup     Login Seite Oeffnen
Test Teardown  StopApp    MyAppChrome
```

Das ist mehr als eine Stilfrage. In den SauceDemo-Tests stand `StopApp`
früher als letzte Zeile im Testfall. Scheiterte ein Test, wurde diese
Zeile nie erreicht, der Browser blieb offen, und die **folgenden** Tests
scheiterten gleich mit: Die Sortier-Tests liefen allein grün, im Verbund
rot. Ein Fehler in einem Test erzeugte so zwei N in anderen. Der Teardown
läuft dagegen immer, auch nach einem Fehler.

### 4. Klare Prüfungen

Bei einem Rot muss ohne Codeanalyse sichtbar sein, welcher Wert erwartet
wurde und welcher tatsächlich kam. Die `Verify*`-Keywords von OKW liefern
genau das:

```
[VerifyValue] 'Fehlermeldung'
Match failed (mode=MatchMode.EXACT).
Expected: 'Epic sadface: Password is required'
Actual:   'Epic sadface: Username is required'
```

Fachlicher Name, Soll und Ist stehen direkt untereinander. Eine
technische Prüfung wie `assert "inventory" in driver.current_url` sagt
im Fehlerfall dagegen nur, dass ein Text nicht in einer URL vorkam.

### 5. Flache Struktur

Der Testfall enthält **keine** `IF`, `FOR`, `WHILE` oder `TRY`. Alle
Schritte stehen linear untereinander. So ist jede Fehlerstelle eindeutig
und jeder Lauf nimmt denselben Weg.

High-Level Keywords, die das Testprojekt selbst zusammensetzt, sind
erlaubt. Sie dürfen aber selbst keine versteckte Logik oder verdeckte
Startbedingungen enthalten:

```robot
*** Test Cases ***
Login Gesperrter Benutzer
    Anmelden Mit    locked_out_user    secret_sauce
    Login Fehlgeschlagen Mit Meldung    Epic sadface: Sorry, this user has been locked out.
```

### 6. Ein fachliches Akzeptanzkriterium

Jeder Testfall endet mit **einem** fachlichen Akzeptanzkriterium: dem
Zustand, der nach der Aktion erreicht sein muss. Das kann mehrere
`Verify*`-Schritte umfassen, solange sie **denselben** Zustand
beschreiben:

```robot
Erfolgreicher Login
    SelectWindow       LoginPage
    SetValue           Benutzer       practice
    SetValue           Passwort       SuperSecretPassword!
    ClickOn            Anmelden

    SelectWindow       SecurePage
    VerifyValueWCM     Willkommensmeldung    *You logged into a secure area*
    VerifyValueWCM     Benutzername          *practice*
    VerifyExists       Abmelden              YES
```

Die drei Prüfungen beschreiben gemeinsam **einen** Zustand: „Der
Benutzer ist angemeldet.“ Würde derselbe Test anschließend noch
Produkte in den Warenkorb legen und die Summe prüfen, hätte er eine
**zweite** Prüfabsicht. Dann gehört das in einen eigenen Test.

!!! warning "Ohne Akzeptanzkriterium kein Signal"
    Ein Test ohne abschließendes `Verify*` wird nur rot, wenn technisch
    etwas scheitert. Ob die Anwendung fachlich das Richtige getan hat,
    erfährt man nie. Der Warenkorb-Test in diesem Repository legte
    früher zwei Produkte in den Warenkorb und endete dort. Erst die
    Prüfung `VerifyValue    WarenkorbAnzahl    2` macht daraus eine
    Aussage über das SUT.

### 7. Deterministische Eingaben

Gleiche Eingaben müssen zu gleichen Ergebnissen führen: keine
Zufallswerte, keine Abhängigkeit von Datum oder Uhrzeit, keine
Restdaten aus früheren Läufen.

Manchmal braucht ein Test trotzdem einen eindeutigen Wert. Der
Register-Test legt bei jedem Lauf einen neuen Benutzer an:

```robot
${ts}=             Evaluate    int(__import__('time').time())
SetValue           Benutzer              TestUser${ts}
```

Das ist vertretbar, weil der **Sollwert** davon nicht abhängt: Die
Erfolgsmeldung ist immer dieselbe. Eigentlich zeigt der Zeitstempel
aber eine fehlende [Steuerbarkeit](testbarkeit.md): Könnte der Test den
Benutzer vorher löschen, bräuchte er keinen eindeutigen Namen.

### 8. Fachliche Namen

Die Schritte lesen sich in der Sprache des Fachbereichs. In OKW sorgen
dafür drei Dinge:

| Ebene | Schwach | Stark |
|---|---|---|
| Widget-Name im YAML | `ClickOn    btnLogin45` | `ClickOn    Anmelden` |
| Testfall-Name | `Test 17` | `Login Gesperrter Benutzer` |
| High-Level Keyword | `Schritt 3` | `Login Fehlgeschlagen Mit Meldung` |

Wie die fachlichen Namen von den technischen IDs getrennt werden,
zeigt das Kapitel [YAML-Locator](yaml-locator.md).

## Beispiel: Weak Signal vs. Strong Signal

### Weak Signal

```robot
*** Test Cases ***
Shop Funktioniert
    SauceDemo Oeffnen Und Anmelden
    SelectWindow    SauceDemoProducts

    Select          Sortierung           Price (low to high)
    Run Keyword And Continue On Failure
    ...    VerifyValue    ErsterProduktname    Sauce Labs Onesie

    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    VerifyValue     WarenkorbAnzahl    2

    StopApp         MyAppChrome
```

Dieser Test prüft Sortierung und Warenkorb auf einmal, läuft nach einem
Sortierfehler einfach weiter und räumt im Testfall statt im Teardown
auf. Wird er rot, ist unklar, **welcher** Aspekt kaputt ist. Ist die
Sortierung falsch, der Warenkorb aber in Ordnung, wird trotzdem der
ganze Test rot, und jeder Leser muss das Log öffnen.

### Strong Signal

```robot
*** Settings ***
Test Teardown    StopApp    MyAppChrome

*** Test Cases ***
Produkte Nach Preis Aufsteigend Sortieren
    SauceDemo Oeffnen Und Anmelden
    SelectWindow   SauceDemoProducts
    Select         Sortierung           Price (low to high)
    VerifyValue    Sortierung           Price (low to high)
    VerifyValue    ErsterProduktname    Sauce Labs Onesie

SetContext Produkt In Warenkorb
    SauceDemo Oeffnen Und Anmelden
    OnFailNOISE    SelectWindow   SauceDemoProducts
    Produkt In Warenkorb Legen    Sauce Labs Backpack
    Produkt In Warenkorb Legen    Sauce Labs Bike Light
    VerifyValue        WarenkorbAnzahl    2
```

Zwei Tests, zwei Prüfabsichten. Wird einer rot, steht die Ursache schon
im Namen des Testfalls. Dass jeder Test sich selbst anmeldet, ist
gewollt: Keiner hängt vom Ergebnis eines anderen ab.

!!! note "Herkunft der Beispiele"
    Die Weak-Signal-Variante ist ein bewusst konstruiertes
    Gegenbeispiel. Die Strong-Signal-Tests stehen so in
    `selenium/saucedemo/tests/SauceDemo_Sortierung.robot` und
    `SauceDemo_SetContext.robot`.

## Ein N bleibt ein ehrliches N

Auch ein Strong-Signal-Test kann an NOISE scheitern. Der Unterschied:
Er sagt es. Schritte, die nur zur Vorbereitung gehören, werden mit
[`OnFailNOISE`](../gui/web-selenium/index.md#onfailnoise) abgesichert:

```robot
*** Keywords ***
Login Seite Oeffnen
    OnFailNOISE          StartApp       MyAppChrome
    OnFailNOISE          SelectWindow   Chrome
    OnFailNOISE          SetValue       URL    ${URL}
```

Scheitert einer dieser Schritte, bekommt der Test das Tag `NOISE` und
die Fehlermeldung das Präfix `[N]`. Das Ergebnis lautet dann nicht
„Login kaputt“, sondern „Login in diesem Lauf nicht geprüft“. Welche
Schritte das sind, beschreibt das
[5-Phasen-Modell](idempotenz.md#idempotenz-im-5-phasen-modell): Fehler
in den Phasen 1 bis 3 sind fast immer ein N.

### Auch „nicht getestet“ ist eine Information

Hier zeigt sich, warum **ein Aspekt pro Testfall** und **keine
Verkettung** zusammengehören. Selbst wenn ein solcher Testfall schon an
der Vorbereitung scheitert, liefert er eine präzise Aussage: **Genau
diese** Anforderung, dieser Zustand, dieser Anwendungsfall ist in diesem
Lauf nicht getestet worden.

Mit dieser Information lässt sich entscheiden:

- **Trotzdem ausliefern**, weil das Risiko für diesen Aspekt klein ist.
- **Trotzdem ausliefern**, weil man aus Erfahrung weiß, dass diese
  Funktion stabil ist und im betroffenen Bereich nichts geändert wurde.
- **Nachtesten**, gezielt nur diesen einen Testfall, oder manuell.

Bei verketteten Testfällen ist diese Entscheidung nicht möglich.
Scheitert in einer Kette von zehn Testfällen der dritte, sind die
Testfälle vier bis zehn ebenfalls rot oder gar nicht gelaufen. Welche
Anforderungen damit ungeprüft sind, muss erst mühsam rekonstruiert
werden, und ein roter Folgetestfall sieht aus wie ein Fehler in seiner
eigenen Funktion. Aus einem N werden so viele scheinbare F.

!!! info "Mehr dazu"
    Welche Formen der Verkettung es gibt, wie man sie erkennt und wie
    Testfälle unabhängig voneinander werden, beschreibt die Seite
    [Autonome Testfälle](autonome-testfaelle.md).

## Checkliste

!!! tip "Strong-Signal-Checkliste"
    **Fokus**

    - Der Test prüft genau einen fachlichen Aspekt.
    - Der Testfall-Name nennt diese Prüfabsicht.
    - Jeder Schritt dient direkt der Prüfabsicht.

    **Ausgangszustand**

    - Der Test hängt von keinem anderen Test ab.
    - Vorbereitungsschritte sind mit `OnFailNOISE` abgesichert.
    - Eingaben sind deterministisch.

    **Ablauf**

    - Kein `IF`, `FOR`, `TRY` im Testfall.
    - Kein `Run Keyword And Continue On Failure`, kein `Run Keyword And Ignore Error`.
    - Kein `Sleep`, keine Wait-Keywords (siehe [Testbarkeit](testbarkeit.md)).
    - Aufräumen steht im Teardown.

    **Prüfung**

    - Der Test endet mit einem fachlichen Akzeptanzkriterium.
    - Die Fehlermeldung zeigt Soll und Ist.

    **Die entscheidende Frage**

    - Wenn der Test rot wird: Sieht man **sofort**, was, wo und warum?

## Zusammenhang mit den anderen Grundlagen

Strong Signal ist das Ziel, die übrigen Grundlagen sind die Mittel:

| Grundlage | Beitrag zum Strong Signal |
|---|---|
| [YAML-Locator](yaml-locator.md) | Fachliche Namen im Test, Technik an einer Stelle |
| [Idempotenz](idempotenz.md) | Jeder Lauf erreicht denselben Ausgangszustand |
| [Testbarkeit](testbarkeit.md) | Der Test kann den Zustand erkennen und herstellen, ohne zu raten |
| [Tokens und Match Modes](tokens-und-match-modes.md) | Prüfungen drücken genau die fachliche Erwartung aus |

> **Ein Test, eine Prüfabsicht, ein eindeutiges Ergebnis.**
