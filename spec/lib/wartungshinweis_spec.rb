# frozen_string_literal: true

RSpec.describe Wartungshinweis do
  it "startet beim Einschalten den Countdown mit dem Vorlauf" do
    freeze_time
    SiteSetting.wartungshinweis_vorlauf_minuten = 10
    SiteSetting.wartungshinweis_aktiv = true

    expect(SiteSetting.wartungshinweis_beginn_utc).to eq(10.minutes.from_now.utc.iso8601)
  end

  it "rechnet einen festen Beginn aus der Zeitzone in UTC um" do
    SiteSetting.wartungshinweis_beginn = "2026-10-22 20:00"
    SiteSetting.wartungshinweis_aktiv = true

    expect(SiteSetting.wartungshinweis_beginn_utc).to eq("2026-10-22T18:00:00Z")
  end

  it "setzt den Countdown beim Ändern des Textes nicht zurück" do
    SiteSetting.wartungshinweis_aktiv = true
    beginn = SiteSetting.wartungshinweis_beginn_utc

    freeze_time 2.minutes.from_now
    SiteSetting.wartungshinweis_text = "Neuer Text"

    expect(SiteSetting.wartungshinweis_beginn_utc).to eq(beginn)
  end

  it "schickt das Ausschalten an alle offenen Seiten" do
    SiteSetting.wartungshinweis_aktiv = true
    messages = MessageBus.track_publish(described_class::CHANNEL) do
      SiteSetting.wartungshinweis_aktiv = false
    end

    expect(messages.last.data[:aktiv]).to eq(false)
    expect(messages.last.data[:beginn]).to eq("")
  end
end
