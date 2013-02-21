
require 'hue'
require 'terminal-notifier'
require 'sinatra'

lights = {
  "tv" => 1,
  "ceiling" => 2,
  "hallway" => 3,
  "multilamp" => 4,
  "bathroom" => 5,
  "table" => 6,
  "bedroom" => 7,
  "kitchen" => 8,
}

# Iniailize Hue
while true
  begin
    $h = Hue::Hue.new
    break
  rescue
    p "Failed to find hue. Retrying..."
  end
end

####################################
# Stuff for handling the Griffin Powermate that controls
# the lights.
#
# Rotating the powermate should run an applescript like this:
#   do shell script "curl http://localhost:4567/<increment/decrement>Dial --max-time 1"
####################################

$lightDialValue = 0

# Setup URLs
get '/incrementDial' do
  $lightDialValue += 1
  $lightDialValue = 100 if $lightDialValue > 100
  # For some reason this puts fixes a bug where random requests will take like 30 seconds when
  # there's a bunch if increment/decrements in a row. Probably some threading thing, but a
  # mutex didn't seem to help...
  puts $lightDialValue
end
get '/decrementDial' do
  $lightDialValue -= 1
  $lightDialValue = 0 if $lightDialValue < 0
  puts $lightDialValue
end

# Spawn a thread to handle updating the brightness of all lights
# when the light-controlling powermate is rotated.
$lastBrightness = 0
Thread.new {
  while true do
    if $lastBrightness != $lightDialValue
      $lastBrightness = $lightDialValue
      $h.all_lights.write({bri: $lastBrightness * 255 / 100})
    else 
      sleep 0.4
    end
  end
}

# Spawn a thread to handle updating the glowing light on the
# light-controlling powermate by running some AppleScript.
Thread.new {
  while true do
    if $lastBrightness != $lightDialValue
      `osascript #{File.expand_path(File.dirname(__FILE__))}/setLightDialState.scpt #{$lightDialValue}`
    else
      sleep 0.1
    end
  end
}


# Cycle through all colors in sync
get '/cycle' do 
  startProgram do
    $h.preset.cycle_thru_colors 0
  end
end

# Random walk
get '/randomWalk' do
  updateHues
  startProgram do
    $hues.each_with_index do |hue, i|
      newColor = hue[1] + (10000 * (2*rand - 1)) 
      newColor = Integer(newColor) % 65535
      $hues[i] = newColor
      $h.write(i+1, {hue: newColor})
    end
  end
end

# Slight changes to selected light
get '/ripple/:light' do
  updateHues
  begin
    light = (lights[params[:light]] or Integer(params[:light]))
  rescue
    return "Invalid light: #{params[:light]}"
  end
  startProgram do
    hue = $hues[light - 1]
    newColor = hue + (5000 * (2*rand - 1)) 
    newColor = [Integer(newColor), 65535].min
    $h.write(light, {hue: newColor})
  end
end

# Stop the current program
get '/killProgram' do
  endProgram
end

# Helper functions
def startProgram(&block)
  endProgram
  $programThread = Thread.new{yield while true}
end
def endProgram
  $programThread.kill if $programThread and $programThread.alive?
end

def updateHues
  $hues = {}
  $h.lights.each_with_index do |light, i|
    $hues[i] = light[1]["state"]["hue"]
  end
  p $hues
end
