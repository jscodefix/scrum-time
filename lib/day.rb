# frozen_string_literal: true
require 'scrum_time'
require 'time'

module ScrumTime
  WORK_START_TIME_HOUR = 9
  WORK_END_TIME_HOUR = 17
  DAY_DURATION = (24 * 60 + 60) - 1

  class Day
    attr_reader :day_start_time, :day_end_time, :work_start_time, :work_end_time, :blocks

    def initialize(date)
      @day_start_time = Time.parse(date + ScrumTime::TIMEZONE)
      @day_end_time = @day_start_time + DAY_DURATION
      @blocks = []
    end

    def work_start_time
      @work_start_time ||= @day_start_time + WORK_START_TIME_HOUR * 60 * 60
    end

    def work_end_time
      @work_end_time ||= @day_start_time + WORK_END_TIME_HOUR * 60 * 60
    end
  end
end
