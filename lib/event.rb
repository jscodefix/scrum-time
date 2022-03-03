# frozen_string_literal: true
require 'date'

module ScrumTime
  class Event
    attr_reader :id, :user_id, :start_time, :end_time

    def initialize(event_hash)
      @id = event_hash[:id]
      @user_id = event_hash[:user_id]
      @start_time = DateTime.iso8601(event_hash[:start_time])
      @end_time = DateTime.iso8601(event_hash[:end_time])
    end

    def self.create_events(event_array)
      event_array.map do |event|
        Event.new(event)
      end
    end
  end
end
