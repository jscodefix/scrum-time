# frozen_string_literal: true
require 'scrum_time'
require 'time'

module ScrumTime
  WORK_START_TIME_HOUR = 9
  WORK_END_TIME_HOUR = 17
  DAY_DURATION = (24 * 60 * 60) - 1

  class Day
    attr_reader :day_start_time, :day_end_time, :work_start_time, :work_end_time, :unavailable_blocks

    def initialize(date)
      @day_start_time = Time.parse("#{date} 00:00:00 #{ScrumTime::TIMEZONE}")
      @day_end_time = @day_start_time + DAY_DURATION
      @unavailable_blocks = []
    end

    def work_start_time
      @work_start_time ||= @day_start_time + WORK_START_TIME_HOUR * 60 * 60
    end

    def work_end_time
      @work_end_time ||= @day_start_time + WORK_END_TIME_HOUR * 60 * 60
    end

    def add_block(block)
      return unavailable_blocks if block_outside_of_work_day(block)

      unavailable_blocks.push(block).sort_by!(&:start_time)
    end

    def consolidate_blocks(blocks)
      consolidated = []
      blocks.push(nil).reduce do |a, b|
        if b.nil? || a.relates_to(b) == Block::FOLLOWED_BY
          consolidated << a
          b
        else
          a.merge(b)
        end
      end

      consolidated
    end

    def availability
      availability_strings = []
      day_blocks = unavailable_blocks.dup
      day_blocks.unshift(before_work_day_block)
      day_blocks.push(after_work_day_block)
      consolidated = consolidate_blocks(day_blocks)

      consolidated.reduce do |a, b|
        availability_strings.push(inter_block_availability(a, b))
        b
      end

      (availability_strings.join("\n") + "\n") if !availability_strings.empty?
    end

    private

    def block_outside_of_work_day(block)
      block.start_time < day_start_time || block.start_time > day_end_time
    end

    def block_outside_work_hours(block)
      block.nil? || block.end_time < work_start_time || block.start_time > work_end_time
    end

    def before_work_day_block
      Block.new(day_start_time, work_start_time)
    end

    def after_work_day_block
      Block.new(work_end_time, day_end_time)
    end

    def inter_block_availability(a = nil, b = nil)
      date = day_start_time.strftime('%Y-%m-%d')
      begin_time = a.end_time.strftime('%H:%M')
      end_time = b.start_time.strftime('%H:%M')
      "#{date} #{begin_time} - #{end_time}"
    end
  end
end
