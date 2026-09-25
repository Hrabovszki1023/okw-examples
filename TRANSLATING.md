# Translating the Handbuch

> Deutsche Version: siehe unten, [Kurzfassung auf Deutsch](#kurzfassung-auf-deutsch)

The OKW4Robot Handbuch (`docs/`) is bilingual. **German is the leading
(source) language.** English is translated from German.

## File Convention

| File | Language | Role |
|---|---|---|
| `docs/**/<page>.de.md` | German | Source — written and changed first |
| `docs/**/<page>.md` | English | Translation — updated from the German source |

The same convention applies to every OKW repository (`README.md` /
`README.de.md`). There is no `_de.md`.

## Workflow

1. Change the German page (`*.de.md`).
2. Update the English page (`*.md`) in the same working step.
3. Stamp the English page with the hash of the German source:

   ```bash
   python scripts/check-translations.py --stamp docs/grundlagen/keywords.de.md
   ```

4. Check that everything is in sync:

   ```bash
   python scripts/check-translations.py --strict
   ```

The CI workflow `docs.yml` runs the check on every push (report only).

**New page:** create `<page>.de.md` and `<page>.md`, add the page to the
`nav` in `mkdocs.yml` (English title) and add the German title to
`nav_translations` of the `de` language.

## What Is Translated

| Element | Translate? |
|---|---|
| Prose, headings, tables, admonition titles | Yes |
| Comments inside code blocks | Yes |
| Keywords (`SetValue`, `ClickOn`, ...) | No — already English |
| Widget, window and test names in examples (`Benutzer`, `ProduktKarte`) | **No** — examples come unchanged from runnable okw-examples tests |
| YAML keys and locators | No |
| File names and URLs (slugs) | No — same slug in both languages |

Where a German business name needs explaining, add the English meaning
in parentheses on first use: `Anmelden` (log in).

## Glossary

| German | English |
|---|---|
| Testfall | test case |
| Testfallsammlung / Testsuite | test suite |
| Fachtester | business tester |
| Domänenexperte | domain expert |
| fachlich / Fachbegriff | business / business term |
| fachlicher Name | business name |
| technischer Locator | technical locator |
| Signal vs. NOISE | Signal vs. NOISE (unchanged) |
| Low-Level Keyword | low-level keyword (ISO 29119-5 §3.14) |
| High-Level Keyword | high-level keyword (ISO 29119-5 §3.7) |
| zusammengesetztes Keyword | composite keyword (ISO 29119-5 §3.2) |
| Domain Layer / Decomposer / Test Interface Layer | unchanged (ISO 29119-5 terms) |
| GUI-Objekt | GUI object |
| Fenster | window |
| Rahmenobjekt | frame object |
| Eingabe-Keywords | input keywords |
| Lese-Keywords / Prüfung | read keywords / verification |
| Synchronisation | synchronisation |
| Platzhalter | placeholder |
| Handbuch | manual (site name: "OKW4Robot Manual") |
| Lauffähiges Beispiel | runnable example |
| In Bearbeitung | Work in progress |

## Kurzfassung auf Deutsch

- Deutsch ist führend: zuerst `*.de.md` ändern, dann `*.md` im selben
  Arbeitsschritt nachziehen.
- Danach `python scripts/check-translations.py --stamp <datei>.de.md`
  ausführen.
- Code-Beispiele bleiben unverändert (deutsche Business-Namen), nur
  Fließtext und Kommentare werden übersetzt.
- Begriffe laut Glossar oben übersetzen.
