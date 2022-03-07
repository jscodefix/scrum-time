require 'time'
require_relative '../lib/scrum_time'
require_relative '../lib/block'

module ScrumTime
  RSpec.describe Block do
    let(:start_time_as_object) { Time.parse("2021-07-05T13:00:00 #{ScrumTime::TIMEZONE}") }
    let(:end_time_as_object) { Time.parse("2021-07-05T13:00:00 #{ScrumTime::TIMEZONE}") }
    let(:time_next_day) { Time.parse("2021-07-06T00:00:01 #{ScrumTime::TIMEZONE}") }

    let(:time_08_00) { "2021-07-05T08:00:00" }
    let(:time_09_00) { "2021-07-05T09:00:00" }
    let(:time_10_00) { "2021-07-05T10:00:00" }
    let(:time_10_30) { "2021-07-05T10:30:00" }
    let(:time_10_45) { "2021-07-05T10:45:00" }
    let(:time_11_00) { "2021-07-05T11:00:00" }
    let(:time_12_00) { "2021-07-05T12:00:00" }
    let(:time_15_00) { "2021-07-05T15:00:00" }

    let(:block_8_to_9) { Block.new(time_08_00, time_09_00) }
    let(:block_8_to_1030) { Block.new(time_08_00, time_10_30) }
    let(:block2) { Block.new(time_10_00, time_11_00) }
    let(:block_1030_to_12) { Block.new(time_10_30, time_12_00) }
    let(:block_12_to_15) { Block.new(time_12_00, time_15_00) }
    let(:block_1030_to_1045) { Block.new(time_10_30, time_10_45) }
    let(:block_9_to_15) { Block.new(time_09_00, time_15_00) }

    describe '#new' do
      context 'timestamps specified as Time objects' do
        it 'creates a block with start and end times' do
          block = Block.new(start_time_as_object, end_time_as_object)

          expect(block.start_time).to be_a(Time)
          expect(block.end_time).to be_a(Time)
        end
      end

      context 'timestamps specified as strings without a timezone' do
        it 'creates a block with start and end times in the UTC timezone' do
          start_time_string = '2021-07-05T13:00:00'
          end_time_string = '2021-07-05T14:00:00'
          block = Block.new(start_time_string, end_time_string)

          expect(block.start_time).to be_a(Time)
          expect(block.end_time).to be_a(Time)
          expect(block.start_time.to_s).to eq '2021-07-05 13:00:00 UTC'
          expect(block.end_time.to_s).to eq '2021-07-05 14:00:00 UTC'
        end
      end

      it 'raises an error if start time and end time are not on same day' do
        expect { Block.new(start_time_as_object, time_next_day) }.to raise_error(RuntimeError)
      end

      it 'raises an error if the timestamp is not a valid time string' do
        expect { Block.new("bogus timestamp", end_time_as_object) }.to raise_error(ArgumentError)
      end

      it 'raises an error if the timestamp is not a string or a Time object' do
        expect { Block.new(Hash.new, end_time_as_object) }.to raise_error(RuntimeError)
      end
    end

    describe '#relates_to' do
      it 'checks block preceded by' do
        expect(block2.relates_to(block_8_to_9)).to eq Block::PRECEDED_BY
      end

      it 'checks block intersected above by' do
        expect(block2.relates_to(block_8_to_1030)).to eq Block::INTERSECTED_ABOVE_BY
      end

      it 'checks block intersected below by' do
        expect(block2.relates_to(block_1030_to_12)).to eq Block::INTERSECTED_BELOW_BY
      end

      it 'checks block follows' do
        expect(block2.relates_to(block_12_to_15)).to eq Block::FOLLOWED_BY
      end

      it 'checks block surrounds' do
        expect(block2.relates_to(block_1030_to_1045)).to eq Block::SURROUNDS
      end

      it 'checks block surrounded by' do
        expect(block2.relates_to(block_9_to_15)).to eq Block::SURROUNDED_BY
      end
    end

    describe '#merge' do
      it 'returns nil if block is preceded by' do
        expect(block2.merge(block_8_to_9)).to be nil
      end

      it 'returns nil if block is followed by' do
        expect(block_8_to_9.merge(block2)).to be nil
      end

      it 'merges intersecting blocks' do
        result = block2.merge(block_1030_to_12)

        expect(result.start_time.hour).to eq 10
        expect(result.end_time.hour).to eq 12
      end

      it 'merges surrounded blocks' do
        result = block_1030_to_1045.merge(block_9_to_15)

        expect(result.start_time.hour).to eq 9
        expect(result.end_time.hour).to eq 15
      end

      it 'returns the single block if argument is nil' do
        expect(block_1030_to_1045.merge(nil)).to be block_1030_to_1045
      end
    end
  end
end
