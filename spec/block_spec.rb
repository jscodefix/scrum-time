require 'time'
require_relative '../lib/scrum_time'
require_relative '../lib/block'

module ScrumTime
  RSpec.describe Block do
    let(:start_time) { Time.parse("2021-07-05T13:00:00#{ScrumTime::TIMEZONE}") }
    let(:end_time) { Time.parse("2021-07-05T13:00:00#{ScrumTime::TIMEZONE}") }
    let(:time_next_day) { Time.parse("2021-07-06T00:00:01#{ScrumTime::TIMEZONE}") }

    describe '#new' do
      it 'creates a day with start and end times' do
        block = Block.new(start_time, end_time)

        expect(block.start_time).to be_a(Time)
        expect(block.end_time).to be_a(Time)
      end

      it 'raises an error if start time and end time are not on same day' do
        expect { Block.new(start_time, time_next_day) }.to raise_error(RuntimeError)
      end
    end
  end
end
