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

    describe '#compares_to' do
      let(:time_08_00) { Time.parse("2021-07-05T08:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_09_00) { Time.parse("2021-07-05T09:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_10_00) { Time.parse("2021-07-05T10:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_10_30) { Time.parse("2021-07-05T10:30:00#{ScrumTime::TIMEZONE}") }
      let(:time_10_45) { Time.parse("2021-07-05T10:45:00#{ScrumTime::TIMEZONE}") }
      let(:time_11_00) { Time.parse("2021-07-05T11:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_12_00) { Time.parse("2021-07-05T12:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_15_00) { Time.parse("2021-07-05T15:00:00#{ScrumTime::TIMEZONE}") }

      let(:block1) { Block.new(time_08_00, time_09_00) }
      let(:block1_5) { Block.new(time_08_00, time_10_30) }
      let(:block2) { Block.new(time_10_00, time_11_00) }
      let(:block2_5) { Block.new(time_10_30, time_12_00) }
      let(:block3) { Block.new(time_12_00, time_15_00) }
      let(:block4) { Block.new(time_10_30, time_10_45) }
      let(:block5) { Block.new(time_09_00, time_15_00) }

      it 'checks block preceded by' do
        expect(block2.compares_to(block1)).to eq Block::PRECEDED_BY
      end

      it 'checks block intersected above by' do
        expect(block2.compares_to(block1_5)).to eq Block::INTERSECTED_ABOVE_BY
      end

      it 'checks block intersected below by' do
        expect(block2.compares_to(block2_5)).to eq Block::INTERSECTED_BELOW_BY
      end

      it 'checks block follows' do
        expect(block2.compares_to(block3)).to eq Block::FOLLOWED_BY
      end

      it 'checks block surrounds' do
        expect(block2.compares_to(block4)).to eq Block::SURROUNDS
      end

      it 'checks block surrounded by' do
        expect(block2.compares_to(block5)).to eq Block::SURROUNDED_BY
      end
    end
  end
end
