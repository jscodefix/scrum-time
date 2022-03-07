#!/usr/bin/env ruby
require 'json'
require './lib/block'
require './lib/day'

raise "USAGE: #{$PROGRAM_NAME} <comma-separated-list-of-usernames>" if ARGV[0].nil?

requested_users = ARGV[0].split(',')

WORK_START_HOUR = 13
WORK_END_HOUR = 21

# read data files
user_file = File.read('./data/users.json')
user_database = JSON.parse(user_file)
event_file = File.read('./data/events.json')
event_database = JSON.parse(event_file)

relevant_events = events_for_requested_users(requested_users, event_database, user_database)

%w[2021-07-05 2021-07-06 2021-07-07].each { |date|
  day = ScrumTime::Day.new(date, WORK_START_HOUR, WORK_END_HOUR)
  add_event_blocks(day, relevant_events)

  availability_text = day.availability
  puts "#{availability_text} \n" if !availability_text.nil?
}

BEGIN {
  def events_for_requested_users(requested_users, events, users)
    result = []
    requested_users.each do |username|
      user = users.find { |user| user['name'] == username }
      result += events.select { |event| event['user_id'] == user['id'] }
    end

    result
  end

  def add_event_blocks(day, events)
    events.each { |event|
      start_time = Time.parse("#{event['start_time']} #{ScrumTime::TIMEZONE}")
      end_time = Time.parse("#{event['end_time']} #{ScrumTime::TIMEZONE}")
      block = ScrumTime::Block.new(start_time, end_time)
      day.add_block(block)
    }
  end
}
