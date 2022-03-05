# frozen_string_literal: true
require 'scrum_time'
require 'time'

module ScrumTime
  WORK_START_TIME_HOUR = 9
  WORK_END_TIME_HOUR = 17
  DAY_DURATION = (24 * 60 * 60) - 1

  class Day
    attr_reader :day_start_time, :day_end_time, :work_start_time, :work_end_time, :user_blocks

    def initialize(date)
      @day_start_time = Time.parse("#{date} 00:00:00 #{ScrumTime::TIMEZONE}")
      @day_end_time = @day_start_time + DAY_DURATION
      @user_blocks = []
    end

    def work_start_time
      @work_start_time ||= @day_start_time + WORK_START_TIME_HOUR * 60 * 60
    end

    def work_end_time
      @work_end_time ||= @day_start_time + WORK_END_TIME_HOUR * 60 * 60
    end

    def add_block(block)
      return user_blocks if block.start_time < day_start_time || block.start_time > day_end_time

      user_blocks.push(block).sort_by!(&:start_time)
    end

    def reduce_blocks
      blocks_reduced = []
      user_blocks.push(nil).reduce do |a, b|
        if b.nil? || a.relates_to(b) == Block::FOLLOWED_BY
          blocks_reduced << a
          b
        else
          a.merge(b)
        end
      end

      blocks_reduced
    end
  end
end
