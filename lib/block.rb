# frozen_string_literal: true
require 'time'

module ScrumTime
  class Block
    attr_reader :start_time, :end_time

    def initialize(start_time, end_time)
      @start_time = start_time
      @end_time = end_time
      validate
    end

    def validate
      raise 'invalid start and end times' if start_end_on_different_days
    end

    def start_end_on_different_days
      start_time.year != end_time.year || start_time.yday != end_time.yday
    end
  end
end
