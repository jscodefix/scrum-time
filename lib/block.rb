# frozen_string_literal: true
require 'time'

module ScrumTime
  class Block
    PRECEDED_BY = 1
    INTERSECTED_ABOVE_BY = 2
    INTERSECTED_BELOW_BY = 3
    FOLLOWED_BY = 4
    SURROUNDS = 5
    SURROUNDED_BY = 6

    attr_reader :start_time, :end_time

    def initialize(start_time, end_time)
      @start_time = time_as_object(start_time)
      @end_time = time_as_object(end_time)
      validate
    end

    def validate
      raise 'invalid start and end times' if start_end_on_different_days
    end

    def start_end_on_different_days
      start_time.year != end_time.year || start_time.yday != end_time.yday
    end

    def relates_to(other)
      return PRECEDED_BY if other.end_time < start_time
      return INTERSECTED_ABOVE_BY if other.start_time <= start_time && other.end_time <= end_time
      return SURROUNDED_BY if other.start_time <= start_time && other.end_time >= end_time
      return INTERSECTED_BELOW_BY if other.start_time <= end_time && other.end_time > end_time
      return FOLLOWED_BY if other.start_time >= end_time
      return SURROUNDS if other.start_time > start_time && other.end_time <= end_time

      raise 'comparison failed'
    end

    def merge(other)
      return self if other.nil?   # consider dup here
      return nil if self.relates_to(other) == PRECEDED_BY || self.relates_to(other) == FOLLOWED_BY

      earlier_start = [start_time, other.start_time].min
      later_end = [end_time, other.end_time].max
      Block.new(earlier_start, later_end)
    end

    private

    def time_as_object(timestamp)
      return timestamp if timestamp.is_a?(Time)
      return Time.parse("#{timestamp} #{ScrumTime::TIMEZONE}") if timestamp.is_a?(String)

      raise 'invalid timestamp specified'
    end
  end
end
