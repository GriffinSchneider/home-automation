require 'rest-client'
require 'JSON'
require 'colorize'


USERNAME="1234567890"
HUE_URL="http://192.168.1.145/api/#{USERNAME}"
LIGHTS_URL="#{HUE_URL}/lights"
GROUPS_URL="#{HUE_URL}/groups"

LIGHTS = [
  1,  # Right living room lamp
  3,  # 3-Lamp Mid
  4,  # 3-Lamp Top
  6,  # TV right
  7,  # Closet
  8,  # TV Left
  22, # TV light strip
  11, # 4-lamp top mid
  12, # 4-lamp bot mid
  13, # 4-lamp top
  14, # 4-lamp bot
  15, # 3-Lamp Bot
  16, # Battery Floor Lamp
  17, # Hall 1
  18, # Kitchen 1
  19, # Hall 2
  20, # Kitchen 2
  21, # Bathroom Lightstrip
  23, # Monitor Lightstrip
  9,  # Old light strip
]

BRIGHTNESS_FLOORED = [ 22, 21, 23 ]

BRIGHTNESS_SCALE = {
  23 => 0.4,
}

ROOMS = {
  "bed" => [3, 4, 7, 15, 22],
  "living" => [6, 9, 11, 12, 13, 14, 16, 17, 19],
  "kitchen" => [19, 20],
  "bath" => [21],
}

def find_room_name(r)
  ROOMS.select {|n| n.start_with? r}.keys[0]
end

def set_room_filter(room)
  return unless room
  $room_filter = find_room_name room
end

def filtered?(light)
  $room_filter == nil || ROOMS[$room_filter].include?(light)
end

THREADS = []

def req(url, json)
  THREADS << Thread.new do
    loop do
      begin
        response = RestClient.put url, json.to_json
      rescue Errno::ECONNRESET, Errno::EPIPE => e
        puts "#{url.blue}: " + "#{e}".red
        next
      end
      if response.code == 200
        puts "#{url.blue}:\n  #{response.body.green}"
        break 
      else
        puts "#{url.blue}:\n  #{response.body.red}"
      end
    end
  end
  sleep 0.05
end

def join_all_threads
  THREADS.each {|t| t.join}
end

def light_state(light, json)
  scaled_brightness = (json[:bri] * (BRIGHTNESS_SCALE[light] || 1)).round
  json[:bri] = [scaled_brightness, 40].max if json[:bri] and BRIGHTNESS_FLOORED.include? light
  req "#{LIGHTS_URL}/#{light}/state", json if filtered?(light)
end

def light_states(lights, json)
  lights.each {|l| light_state l, json}
end

def all_state(json)
  LIGHTS.each {|l| light_state l, json }
end


def light_pointsymbol(light, json)
  req "#{LIGHTS_URL}/#{light}/pointsymbol", json
end

def all_pointsymbol(json)
  LIGHTS.each {|l| light_pointsymbol l, json}
end

def transmit_symbol(symbol_selection, duration)
  req "#{GROUPS_URL}/0/transmitsymbol", symbolselection: symbol_selection, duration: duration
end


def allon
  all_state on: true
end

def alloff
  all_state on: false
end

def asleep
  alloff
end 


def bright 
  all_state bri: 255
end

def dim 
  all_state bri: 70
end

def dark 
  all_state bri: 5
end


def colorloop
  all_state effect: :colorloop, sat: 255, bri: 255
end

def noeffect
  all_state effect: :none
end


def morning
  all_state effect: :none, bri: 255, xy: [0.3151,0.3252]
end

def relax
  all_state bri: 144, xy: [0.5119,0.4147]
end

def brightlax
  all_state bri: 255, xy: [0.5119,0.4147]
end

def normal
  all_state bri: 255, ct: 350
end

def focus
  all_state bri: 255, ct: 235
end


def green
  all_state bri: 255,sat: 255, hue: 25717
end

def blue
  all_state bri: 255,sat: 255, hue: 46920
end

def red
  all_state bri: 255,sat: 255, hue: 0
end

def orange
  all_state bri: 255,sat: 255, hue: 6000
end


def night
  all_state bri:0, sat:255, hue:0, transitiontime:50 
end

def deepsea
  b = 46920
  r = 0
  colors = [b, b, r, r, r, r, b, r, b, b, r, r, r, r, r, b, b, b]
  colors.each_with_index {|c, l| light_state LIGHTS[l], bri: 255, sat: 255, hue: c}
end

def read
  light_state 15, bri: 144, xy: [0.5119,0.4147]
end
