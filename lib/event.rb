# frozen_string_literal: true
require 'scrum_time'
require 'time'

module ScrumTime
  class Event
    attr_reader :id, :user_id, :start_time, :end_time

    def initialize(event_hash)
      @id = event_hash[:id]
      @user_id = event_hash[:user_id]
      @start_time = Time.parse(event_hash[:start_time] + ScrumTime::TIMEZONE)
      @end_time = Time.parse(event_hash[:end_time] + ScrumTime::TIMEZONE)
    end

    def self.create_events(event_array)
      event_array.map do |event|
        Event.new(event)
      end
    end
  end
end
