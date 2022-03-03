#!/usr/bin/env ruby
require 'json'

raise "USAGE: #{$PROGRAM_NAME} <comma-separated-list-of-usernames>" if ARGV[0].nil?

requested_users = ARGV[0].split(',')

# read data files
user_file = File.read('./data/users.json')
user_hash = JSON.parse(user_file)

event_file = File.read('./data/events.json')
event_hash = JSON.parse(event_file)

# show_availability('2021-07-05', requested_users)
# show_availability('2021-07-06', requested_users)
# show_availability('2021-07-07', requested_users)
