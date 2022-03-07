# frozen_string_literal: true
require_relative './scrum_time'
require_relative './block'
require 'time'

module ScrumTime
  DEFAULT_WORK_START_HOUR = 9
  DEFAULT_WORK_END_HOUR = 17
  DAY_DURATION = (24 * 60 * 60) - 1

  class Day
    attr_reader :day_start_time, :day_end_time, :work_start_time, :work_end_time, :unavailable_blocks

    def initialize(date, work_start_hour = nil, work_end_hour = nil)
      @day_start_time = Time.parse("#{date} 00:00:00 #{ScrumTime::TIMEZONE}")
      @day_end_time = @day_start_time + DAY_DURATION
      @work_start_hour = work_start_hour || DEFAULT_WORK_START_HOUR
      @work_end_hour = work_end_hour || DEFAULT_WORK_END_HOUR
      @unavailable_blocks = []
    end

    def work_start_time
      @work_start_time ||= @day_start_time + @work_start_hour * 60 * 60
    end

    def work_end_time
      @work_end_time ||= @day_start_time + @work_end_hour * 60 * 60
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

      (availability_strings.join("\n") + "\n") unless availability_strings.empty?
    end

    private

    def block_outside_of_work_day(block)
      block.start_time < day_start_time || block.start_time > day_end_time
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
