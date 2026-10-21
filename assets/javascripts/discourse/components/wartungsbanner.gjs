import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";

const CHANNEL = "/wartungshinweis";
// In den letzten fünf Minuten wird der Hinweis rot und lässt sich nicht mehr ausblenden.
const DRINGEND_MS = 5 * 60 * 1000;

const zweistellig = (n) => String(n).padStart(2, "0");

export default class Wartungsbanner extends Component {
  @service messageBus;
  @service siteSettings;

  @tracked aktiv = this.siteSettings.wartungshinweis_aktiv;
  @tracked beginn = this.siteSettings.wartungshinweis_beginn_utc;
  @tracked text = this.siteSettings.wartungshinweis_text;
  @tracked dauerMinuten = this.siteSettings.wartungshinweis_dauer_minuten;
  @tracked now = Date.now();
  @tracked ausgeblendetFuer = null;

  constructor() {
    super(...arguments);
    this.messageBus.subscribe(CHANNEL, this.onMessage);
    this.timer = setInterval(() => (this.now = Date.now()), 1000);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.messageBus.unsubscribe(CHANNEL, this.onMessage);
    clearInterval(this.timer);
  }

  @action
  onMessage(data) {
    this.aktiv = data.aktiv;
    this.beginn = data.beginn;
    this.text = data.text;
    this.dauerMinuten = data.dauer_minuten;
  }

  @action
  ausblenden() {
    this.ausgeblendetFuer = this.beginn;
  }

  get startMs() {
    const t = Date.parse(this.beginn);
    return Number.isNaN(t) ? null : t;
  }

  get restMs() {
    return this.startMs === null ? null : this.startMs - this.now;
  }

  get dringend() {
    return this.restMs !== null && this.restMs < DRINGEND_MS;
  }

  get laeuft() {
    return this.restMs !== null && this.restMs <= 0;
  }

  get sichtbar() {
    if (!this.aktiv) {
      return false;
    }
    if (this.restMs !== null && this.restMs < -this.dauerMinuten * 60 * 1000) {
      return false;
    }
    return this.dringend || this.ausgeblendetFuer !== this.beginn;
  }

  get countdown() {
    const s = Math.max(0, Math.ceil(this.restMs / 1000));
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const rest = `${zweistellig(m)}:${zweistellig(s % 60)}`;
    return h > 0 ? `${h}:${rest}` : rest;
  }

  get uhrzeit() {
    return new Date(this.startMs).toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  <template>
    {{#if this.sichtbar}}
      <div
        class={{concatClass
          "wartungshinweis"
          (if this.dringend "wartungshinweis--dringend")
        }}
        role="status"
      >
        <div class="wartungshinweis__inhalt">
          {{#if this.laeuft}}
            <strong>{{i18n "wartungshinweis.laeuft"}}</strong>
          {{else if this.startMs}}
            <span class="wartungshinweis__zeit">
              {{i18n "wartungshinweis.beginnt_in"}}
              <strong
                class="wartungshinweis__countdown"
                aria-hidden="true"
              >{{this.countdown}}</strong>
              ({{i18n "wartungshinweis.um" zeit=this.uhrzeit}})
            </span>
          {{else}}
            <strong>{{i18n "wartungshinweis.titel"}}</strong>
          {{/if}}
          {{#if this.text}}
            <span class="wartungshinweis__text">{{this.text}}</span>
          {{/if}}
        </div>
        {{#unless this.dringend}}
          <DButton
            @action={{this.ausblenden}}
            @icon="xmark"
            @title="wartungshinweis.ausblenden"
            class="btn-transparent wartungshinweis__schliessen"
          />
        {{/unless}}
      </div>
    {{/if}}
  </template>
}
