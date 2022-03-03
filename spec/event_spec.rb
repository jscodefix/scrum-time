require 'json'
require 'date'
require_relative '../lib/event'

module ScrumTime
  RSpec.describe Event do
    let(:event1) do
      {
        id: 1,
        user_id: 1,
        start_time: '2021-07-05T13:00:00',
        end_time: '2021-07-05T13:30:00',
      }
    end

    let(:event2) do
      {
        id: 2,
        user_id: 2,
        start_time: '2021-08-05T13:00:00',
        end_time: '2021-08-05T13:30:00',
      }
    end

    it 'creates a event object' do
      event = Event.new(event1)

      expect(event).to be
      expect(event).to have_attributes(:id => 1, :user_id => 1)
      expect(event.start_time).to be_a(DateTime)
      expect(event.end_time).to be_a(DateTime)
      expect(event.start_time.year).to eq 2021
      expect(event.end_time.to_s).to eq '2021-07-05T13:30:00+00:00'
    end

    it 'creates an array of event objects' do
      events_array = [event1, event2]
      events = Event.create_events(events_array)

      expect(events).to be_a(Array)
      expect(events.size).to eq 2
      expect(events[0]).to be_a(Event)
      expect(events[1]).to be_a(Event)
    end
  end
end
