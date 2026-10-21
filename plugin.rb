# frozen_string_literal: true

# name: discourse-wartungshinweis
# about: Forumweiter Hinweis mit Countdown vor Wartungsarbeiten und Updates.
# version: 0.1.0
# authors: Proretriever e.V.
# url: https://forum.proretriever.de
# required_version: 3.4.0

# Bewusst ohne enabled_site_setting: Plugin-Ereignisse laufen nur, solange das Plugin
# aktiv ist. Das Ausschalten des Hinweises muss aber noch an alle offenen Seiten gehen.

register_asset "stylesheets/wartungshinweis.scss"

module ::Wartungshinweis
  CHANNEL = "/wartungshinweis"

  # Änderungen an diesen Einstellungen setzen den Countdown neu.
  TIMER_SETTINGS = %i[
    wartungshinweis_aktiv
    wartungshinweis_beginn
    wartungshinweis_vorlauf_minuten
    wartungshinweis_zeitzone
  ]
  SETTINGS = TIMER_SETTINGS + %i[wartungshinweis_text wartungshinweis_dauer_minuten]

  # Beginn als UTC-Zeitstempel, damit der Browser ohne Zeitzonen-Umrechnung zählen kann.
  def self.compute_start
    return "" unless SiteSetting.wartungshinweis_aktiv

    if SiteSetting.wartungshinweis_beginn.present?
      zone = ActiveSupport::TimeZone[SiteSetting.wartungshinweis_zeitzone] || Time.zone
      zone.parse(SiteSetting.wartungshinweis_beginn)&.utc&.iso8601.to_s
    else
      SiteSetting.wartungshinweis_vorlauf_minuten.minutes.from_now.utc.iso8601
    end
  rescue ArgumentError
    ""
  end

  def self.state
    {
      aktiv: SiteSetting.wartungshinweis_aktiv,
      beginn: SiteSetting.wartungshinweis_beginn_utc,
      text: SiteSetting.wartungshinweis_text,
      dauer_minuten: SiteSetting.wartungshinweis_dauer_minuten,
    }
  end

  def self.publish!
    MessageBus.publish(CHANNEL, state)
  end
end

after_initialize do
  on(:site_setting_changed) do |name, _old_value, _new_value|
    name = name.to_sym
    next unless ::Wartungshinweis::SETTINGS.include?(name)

    if ::Wartungshinweis::TIMER_SETTINGS.include?(name)
      SiteSetting.wartungshinweis_beginn_utc = ::Wartungshinweis.compute_start
    end
    ::Wartungshinweis.publish!
  end
end
