require 'date'
require_relative '../lib/day'
require_relative '../lib/block'

module ScrumTime
  RSpec.describe Day do
    let(:day1_date) { '2001-07-04' }
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
  end
end
