# discourse-wartungshinweis

Discourse-Plugin für forum.proretriever.de: zeigt vor einem Update allen Besuchern einen
Hinweis mit Countdown („Wartung beginnt in 14:32 (um 20:00 Uhr)“) und einem eigenen Text,
z. B. „Bitte speichert eure Beiträge und meldet euch ab.“

- Erscheint und verschwindet **sofort** bei allen, die das Forum offen haben, ohne Neuladen.
- Schwebt unter dem Kopf der Seite und bleibt beim Scrollen sichtbar.
- Lässt sich ausblenden, außer in den letzten 5 Minuten. Dann wird er rot.
- Ab dem Beginn steht dort: „Die Wartung beginnt jetzt. Das Forum ist gleich wieder erreichbar.“
- Bleibt der Schalter nach dem Update versehentlich an, verschwindet der Hinweis
  `wartungshinweis_dauer_minuten` nach dem Beginn von selbst.

## Benutzung

Admin → Einstellungen → nach `wartungshinweis` filtern.

**In 15 Minuten updaten:**
1. `wartungshinweis_vorlauf_minuten` auf 15 setzen (ist Standard).
2. `wartungshinweis_aktiv` einschalten. Der Countdown startet in diesem Moment.
3. Nach Ablauf das Update einspielen.
4. Wenn das Forum wieder läuft: `wartungshinweis_aktiv` ausschalten.

**Zu einer festen Uhrzeit:** `wartungshinweis_beginn` auf z. B. `2026-10-22 20:00` setzen
(Zeitzone: `wartungshinweis_zeitzone`, Standard Europe/Berlin), dann einschalten. So lässt sich
der Hinweis auch Stunden vorher ankündigen. Danach `wartungshinweis_beginn` wieder leeren.

Den Text kann man ändern, während der Countdown läuft; die Zeit wird dadurch nicht zurückgesetzt.
Eine Änderung von Vorlauf, Beginn oder Zeitzone startet den Countdown neu.

## Installation

In `/var/discourse/containers/app.yml` unter `hooks → after_code` eine weitere Zeile
(das Repository ist öffentlich, ein Token ist nicht nötig):

```yaml
          - git clone https://github.com/philippweller/discourse_maintenance.git discourse-wartungshinweis
```

Dann `./launcher rebuild app`.

## Tests

```bash
LOAD_PLUGINS=1 bin/rspec plugins/discourse-wartungshinweis/spec
```
