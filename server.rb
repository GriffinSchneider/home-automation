# Applescript to hit a url:
# do shell script "curl http://localhost:4567/<url>"

require 'hue'
require 'terminal-notifier'
require 'sinatra'

TV = 1
TABLE = 6


# Iniailize Hue
while true
  begin
    $h = Hue::Hue.new
    break
  rescue
    p "Failed to find hue. Retrying..."
  end
end

# Iniailize state
$counter = 0

# Setup URLs
get '/incrementDial' do
  $counter += 1
  TerminalNotifier.notify("Counter: %d" % $counter, :title => "Hue thing", :group => "hue")
end
get '/decrementDial' do
  $counter -= 1
  TerminalNotifier.notify("Counter: %d" % $counter, :title => "Hue thing", :group => "hue")
end

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

# Slight changes to selected lights
lights_to_ripple = [TV]
get '/ripple/:light' do
  updateHues
  startProgram do
    $hues.each_with_index do |hue, i|
      if lights_to_ripple.index(i+1)
        newColor = hue[1] + (5000 * (2*rand - 1)) 
        newColor = [Integer(newColor), 65535].min
        $h.write(i+1, {hue: newColor})
      end
    end
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
