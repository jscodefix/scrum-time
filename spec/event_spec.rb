require 'json'
require_relative '../lib/event'

module ScrumTime
  RSpec.describe Event do
    it 'creates a event object' do
      event_hash = {
        id: 1,
        user_id: 1,
        start_time: '2021-07-05T13:00:00',
        end_time: '2021-07-05T13:30:00',
      }

      event = Event.new(event_hash)
      expect(event).to be
      expect(event).to have_attributes(event_hash)
    end
  end
end
