require 'rest-client'
require 'JSON'
require 'colorize'


USERNAME="1234567890"
HUE_URL="http://192.168.1.125/api/#{USERNAME}"
LIGHTS_URL="#{HUE_URL}/lights"
GROUPS_URL="#{HUE_URL}/groups"

LIGHTS = [
  1,  # Hallway
  3,  # 3-Lamp Mid
  4,  # 3-Lamp Top
  6,  # Tube Light
  7,  # Sink
  8,  # Bathroom
  9,  # TV
  11, # Living Room BL
  12, # Living Room FR
  13, # Living Room BR
  14, # Living Room FL
  15  # Reading Lamp
]
BEDROOM_LIGHTS = [3, 4, 15]

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
  req "#{LIGHTS_URL}/#{light}/state", json
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
  light_states BEDROOM_LIGHTS, on: false
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


def green
  all_state bri: 255,sat: 255, hue: 25717
end

def blue
  all_state bri: 255,sat: 255, hue: 46920
end

def red
  all_state bri: 255,sat: 255, hue: 0
end


def night
  all_state bri:0, sat:255, hue:0, transitiontime:50 
end

def deepsea
  b = 46920
  r = 0
  colors = [b, r, b, b, r, r, r, r, r, b, b, r]
  colors.each_with_index {|c, l| light_state LIGHTS[l], bri: 255, sat: 255, hue: c}
end

def read
  light_state 15, bri: 144, xy: [0.5119,0.4147]
end
