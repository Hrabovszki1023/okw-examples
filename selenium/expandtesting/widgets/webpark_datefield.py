"""WebPark_DateField -- Projektspezifisches Widget fuer Flatpickr-Datumsfelder.

Flatpickr setzt Input-Felder auf readonly. Normales SetValue (clear + input_text)
funktioniert daher nicht. Dieses Widget ueberschreibt okw_set_value() und
verwendet stattdessen:

1. Focus (Fokus ins Input-Feld setzen per JavaScript)
2. Ctrl+A (alles markieren — ersetzt beim naechsten Tippen)
3. Datum eingeben (ersetzt die Markierung)
4. Escape (Flatpickr-Kalender schliessen)

Wichtig: SeleniumLibrary's press_keys() klickt vor jedem Aufruf erneut
auf das Element (ActionChains.click), was eine bestehende Textmarkierung
aufhebt. Deshalb wird nach CTRL+a der Wert OHNE Locator (None) gesendet,
damit kein erneuter Click passiert.

Erbt von WebSe_TextField — alle anderen Methoden (get_value, type_key, etc.)
bleiben unveraendert.

Anwendung im YAML:
    EingangDatum:
      class: widgets.webpark_datefield.WebPark_DateField
      locator: { id: entryDate }
"""

from okw_web_selenium.widgets.webse_textfield import WebSe_TextField


class WebPark_DateField(WebSe_TextField):

    def okw_set_value(self, value: str):
        """Setzt ein Flatpickr-Datumsfeld per Tastatureingabe.

        Arguments:
        - ``value``: Datum im Format YYYY-MM-DD (z.B. '2026-06-01').
        """
        self._wait_before('write')

        # 1. Focus — Fokus per JavaScript ins Input-Feld setzen.
        #    Kein Click, weil Flatpickr den Fokus auf den Overlay verschiebt.
        self.adapter.focus(self.locator)

        # 2. Ctrl+A — alles markieren.
        #    press_keys MIT Locator: SeleniumLibrary klickt vorher auf
        #    das Element (setzt Fokus) und sendet dann CTRL+a.
        self.adapter.press_keys(self.locator, "CTRL+a")

        # 3. Datum eingeben — OHNE Locator (None), damit SeleniumLibrary
        #    NICHT erneut klickt und die Markierung aufhebt.
        #    Der erste Buchstabe ersetzt die Selektion (Browser-Standard).
        self.adapter.press_keys(None, value)

        # 4. Escape — Kalender schliessen (ohne Locator, Fokus bleibt)
        self.adapter.press_keys(None, "ESCAPE")
