require 'date'
require_relative '../lib/day'
require_relative '../lib/block'

module ScrumTime
  RSpec.describe Day do
    let(:day1_date) { '2021-07-05' }
    let(:day1) { Day.new(day1_date) }

    describe '#new' do
      it 'has a day start and end time' do
        expect(day1.day_start_time).to be_a(Time)
        expect(day1.day_end_time).to be_a(Time)
      end

      it 'has a work start and end time' do
        expect(day1.work_start_time).to be_a(Time)
        expect(day1.work_end_time).to be_a(Time)
      end

      it 'begins with an empty blocks array' do
        expect(day1.blocks).to be_a(Array)
        expect(day1.blocks).to be_empty
      end
    end

    describe '#add_block' do
      let(:time_08_00) { Time.parse("2021-07-05T08:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_10_00) { Time.parse("2021-07-05T10:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_11_00) { Time.parse("2021-07-05T11:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_12_00) { Time.parse("2021-07-05T12:00:00#{ScrumTime::TIMEZONE}") }
      let(:time_15_00) { Time.parse("2021-07-05T15:00:00#{ScrumTime::TIMEZONE}") }

      let(:block1) { Block.new(time_08_00, time_10_00) }
      let(:block2) { Block.new(time_10_00, time_11_00) }
      let(:block3) { Block.new(time_12_00, time_15_00) }
      let(:block4) { Block.new(time_10_00, time_15_00) }

      it 'allows addition of first block' do
        day1.add_block(block1)
        expect(day1.blocks.size).to eq 1
        expect(day1.blocks[0].start_time.hour).to eq 8
        expect(day1.blocks[0].end_time.hour).to eq 10
      end

      it 'allows addition of multiple blocks' do
        day1.add_block(block1)
        day1.add_block(block2)
        expect(day1.blocks.size).to eq 2
      end

      it 'sorts blocks by start time' do
        day1.add_block(block2)
        day1.add_block(block1)
        day1.add_block(block3)
        day1.add_block(block4)
        expect(day1.blocks[0].start_time.hour).to be <= day1.blocks[1].start_time.hour
        expect(day1.blocks[1].start_time.hour).to be <= day1.blocks[2].start_time.hour
        expect(day1.blocks[2].start_time.hour).to be <= day1.blocks[3].start_time.hour
      end

      it 'rejects blocks with start times before the day start time' do
        block_wrong_day = Block.new(
          Time.parse("2021-07-04T08:00:00#{ScrumTime::TIMEZONE}"),
          Time.parse("2021-07-04T09:00:00#{ScrumTime::TIMEZONE}")
        )

        day1.add_block(block_wrong_day)
        expect(day1.blocks.size).to eq 0
      end

      it 'rejects blocks with start times after the day end time' do
        block_wrong_day = Block.new(
          Time.parse("2021-07-06T08:00:00#{ScrumTime::TIMEZONE}"),
          Time.parse("2021-07-06T09:00:00#{ScrumTime::TIMEZONE}")
        )

        day1.add_block(block_wrong_day)
        expect(day1.blocks.size).to eq 0
      end
    end
  end
end