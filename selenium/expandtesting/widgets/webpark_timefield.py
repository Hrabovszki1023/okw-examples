"""WebPark_TimeField -- Projektspezifisches Widget fuer Flatpickr-Zeitfelder.

Gleiches Prinzip wie WebPark_DateField, aber fuer Uhrzeit-Eingaben.
Flatpickr setzt auch die Zeitfelder auf readonly.

Wichtig: SeleniumLibrary's press_keys() klickt vor jedem Aufruf erneut
auf das Element (ActionChains.click), was eine bestehende Textmarkierung
aufhebt. Deshalb wird nach CTRL+a der Wert OHNE Locator (None) gesendet,
damit kein erneuter Click passiert.

Anwendung im YAML:
    EingangZeit:
      class: widgets.webpark_timefield.WebPark_TimeField
      locator: { id: entryTime }
"""

from okw_web_selenium.widgets.webse_textfield import WebSe_TextField


class WebPark_TimeField(WebSe_TextField):

    def okw_set_value(self, value: str):
        """Setzt ein Flatpickr-Zeitfeld per Tastatureingabe.

        Arguments:
        - ``value``: Uhrzeit im Format HH:MM (z.B. '14:30').
        """
        self._wait_before('write')

        # 1. Focus — Fokus per JavaScript ins Input-Feld setzen.
        #    Kein Click, weil Flatpickr den Fokus auf den Overlay verschiebt.
        self.adapter.focus(self.locator)

        # 2. Ctrl+A — alles markieren.
        #    press_keys MIT Locator: SeleniumLibrary klickt vorher auf
        #    das Element (setzt Fokus) und sendet dann CTRL+a.
        self.adapter.press_keys(self.locator, "CTRL+a")

        # 3. Uhrzeit eingeben — OHNE Locator (None), damit SeleniumLibrary
        #    NICHT erneut klickt und die Markierung aufhebt.
        #    Der erste Buchstabe ersetzt die Selektion (Browser-Standard).
        self.adapter.press_keys(None, value)

        # 4. Escape — Time-Picker schliessen (ohne Locator, Fokus bleibt)
        self.adapter.press_keys(None, "ESCAPE")
