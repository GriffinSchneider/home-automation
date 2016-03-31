#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require_relative 'common'

# Make sure we're in the directory this file is in
Dir.chdir(File.dirname(__FILE__))

options = OpenStruct.new

OptionParser.new do |opts|
  opts.banner = "Usage: cli.rb COMMAND [options]"
  opts.on("-b", "--bri BRIGHTNESS") do |brightness|
    options.bri = brightness
  end
  opts.on("-n", "--on") do |brightness|
    options.on = true
  end
  opts.on("-f", "--off") do |brightness|
    options.on = false
  end
  opts.on("-r", "--room ROOM") do |room|
    options.room = room
  end
end.parse! ARGV

if ARGV.empty?
  puts "Command required"
  exit 1
end

set_room_filter ARGV[1] || options.room
eval ARGV[0]
join_all_threads
