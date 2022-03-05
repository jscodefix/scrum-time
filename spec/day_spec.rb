require 'date'
require_relative '../lib/day'
require_relative '../lib/block'

module ScrumTime
  RSpec.describe Day do
    let(:day1_date) { '2021-07-05' }
    let(:day1) { Day.new(day1_date) }

    let(:time_08_00) { Time.parse("2021-07-05T08:00:00 #{ScrumTime::TIMEZONE}") }
    let(:time_10_00) { Time.parse("2021-07-05T10:00:00 #{ScrumTime::TIMEZONE}") }
    let(:time_11_00) { Time.parse("2021-07-05T11:00:00 #{ScrumTime::TIMEZONE}") }
    let(:time_12_00) { Time.parse("2021-07-05T12:00:00 #{ScrumTime::TIMEZONE}") }
    let(:time_15_00) { Time.parse("2021-07-05T15:00:00 #{ScrumTime::TIMEZONE}") }

    let(:block1) { Block.new(time_08_00, time_10_00) }
    let(:block2) { Block.new(time_10_00, time_11_00) }
    let(:block3) { Block.new(time_12_00, time_15_00) }
    let(:block4) { Block.new(time_10_00, time_15_00) }

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
        expect(day1.unavailable_blocks).to be_a(Array)
        expect(day1.unavailable_blocks).to be_empty
      end
    end

    describe '#add_block' do
      it 'allows addition of first block' do
        day1.add_block(block1)
        expect(day1.unavailable_blocks.size).to eq 1
        expect(day1.unavailable_blocks.first.start_time.hour).to eq 8
        expect(day1.unavailable_blocks.first.end_time.hour).to eq 10
      end

      it 'allows addition of multiple blocks' do
        day1.add_block(block1)
        day1.add_block(block2)
        expect(day1.unavailable_blocks.size).to eq 2
      end

      it 'sorts blocks by start time' do
        day1.add_block(block2)
        day1.add_block(block1)
        day1.add_block(block3)
        day1.add_block(block4)
        expect(day1.unavailable_blocks[0].start_time.hour).to be <= day1.unavailable_blocks[1].start_time.hour
        expect(day1.unavailable_blocks[1].start_time.hour).to be <= day1.unavailable_blocks[2].start_time.hour
        expect(day1.unavailable_blocks[2].start_time.hour).to be <= day1.unavailable_blocks[3].start_time.hour
      end

      it 'rejects blocks with start times before the day start time' do
        block_wrong_day = Block.new(
          Time.parse("2021-07-04T08:00:00 #{ScrumTime::TIMEZONE}"),
          Time.parse("2021-07-04T09:00:00 #{ScrumTime::TIMEZONE}")
        )

        day1.add_block(block_wrong_day)
        expect(day1.unavailable_blocks.size).to eq 0
      end

      it 'rejects blocks with start times after the day end time' do
        block_wrong_day = Block.new(
          Time.parse("2021-07-06T08:00:00 #{ScrumTime::TIMEZONE}"),
          Time.parse("2021-07-06T09:00:00 #{ScrumTime::TIMEZONE}")
        )

        day1.add_block(block_wrong_day)
        expect(day1.unavailable_blocks.size).to eq 0
      end
    end

    describe '#reduce_blocks' do
      let(:time_10_30) { Time.parse("2021-07-05T10:30:00 #{ScrumTime::TIMEZONE}") }
      let(:time_11_30) { Time.parse("2021-07-05T11:30:00 #{ScrumTime::TIMEZONE}") }
      let(:time_13_30) { Time.parse("2021-07-05T13:30:00 #{ScrumTime::TIMEZONE}") }
      let(:time_14_30) { Time.parse("2021-07-05T14:30:00 #{ScrumTime::TIMEZONE}") }

      let(:block5) { Block.new(time_10_30, time_11_30) }
      let(:block6) { Block.new(time_13_30, time_14_30) }

      it 'handles a single block' do
        day1.add_block(block2)
        result = day1.consolidate_blocks

        expect(result.size).to eq 1
        expect(result.first.start_time.hour).to eq 10
        expect(result.first.end_time.hour).to eq 11
      end

      it 'handles two non-intersecting block' do
        day1.add_block(block2)
        day1.add_block(block3)
        result = day1.consolidate_blocks

        expect(result.size).to eq 2
        expect(result[0].start_time.hour).to eq 10
        expect(result[0].end_time.hour).to eq 11
        expect(result[1].start_time.hour).to eq 12
        expect(result[1].end_time.hour).to eq 15
      end

      it 'handles two intersecting block' do
        day1.add_block(block2)
        day1.add_block(block5)
        result = day1.consolidate_blocks

        expect(result.size).to eq 1
        expect(result.first.start_time.hour).to eq 10
        expect(result.first.end_time.strftime('%H:%M')).to eq '11:30'
      end

      it 'handles two intersecting block followed by a non-intersecting block' do
        day1.add_block(block2)
        day1.add_block(block5)
        day1.add_block(block3)
        result = day1.consolidate_blocks

        expect(result.size).to eq 2
        expect(result[0].start_time.hour).to eq 10
        expect(result[0].end_time.strftime('%H:%M')).to eq '11:30'
        expect(result[1].start_time.hour).to eq 12
        expect(result[1].end_time.hour).to eq 15
      end

      it 'handles a non-intersecting block followed by a surrounding block' do
        day1.add_block(block5)
        day1.add_block(block3)
        day1.add_block(block6)
        result = day1.consolidate_blocks

        expect(result.size).to eq 2
        expect(result[0].start_time.strftime('%H:%M')).to eq '10:30'
        expect(result[0].end_time.strftime('%H:%M')).to eq '11:30'
        expect(result[1].start_time.hour).to eq 12
        expect(result[1].end_time.hour).to eq 15
      end

      it 'handles many intersecting blocks' do
        day1.add_block(block1)
        day1.add_block(block2)
        day1.add_block(block3)
        day1.add_block(block4)
        day1.add_block(block5)
        day1.add_block(block6)
        result = day1.consolidate_blocks

        expect(result.size).to eq 1
        expect(result.first.start_time.hour).to eq 8
        expect(result.first.end_time.hour).to eq 15
      end
    end

    describe '#availability' do
      let(:time_20_00) { Time.parse("2021-07-05T20:00:00 #{ScrumTime::TIMEZONE}") }
      let(:time_09_00) { Time.parse("2021-07-05T09:00:00 #{ScrumTime::TIMEZONE}") }
      let(:time_16_00) { Time.parse("2021-07-05T16:00:00 #{ScrumTime::TIMEZONE}") }
      let(:time_17_00) { Time.parse("2021-07-05T17:00:00 #{ScrumTime::TIMEZONE}") }

      let(:block7) { Block.new(time_15_00, time_20_00) }
      let(:block8) { Block.new(time_09_00, time_10_00) }
      let(:block9) { Block.new(time_16_00, time_17_00) }

      it 'handles a single block in the middle of the work day' do
        expected_output = <<-HEREEND
2021-07-05 09:00 - 10:00
2021-07-05 11:00 - 17:00
HEREEND

        day1.add_block(block2)
        result = day1.availability

        expect(result).to eq expected_output
      end

      it 'handles blocks overlapping work day start and end times' do
        expected_output = <<-HEREEND
2021-07-05 10:00 - 15:00
HEREEND

        day1.add_block(block1)
        day1.add_block(block7)
        result = day1.availability

        expect(result).to eq expected_output
      end

      it 'handles blocks on boundaries of the work day start and end times' do
        expected_output = <<-HEREEND
2021-07-05 10:00 - 12:00
2021-07-05 15:00 - 16:00
HEREEND

        day1.add_block(block9)
        day1.add_block(block8)
        day1.add_block(block3)
        result = day1.availability

        expect(result).to eq expected_output
      end
    end
  end
end
