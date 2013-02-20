# Applescript to hit a url:
# do shell script "curl http://localhost:4567/<url>"

require 'hue'
require 'terminal-notifier'
require 'webrick'
include WEBrick 

TV = 1
TABLE = 6

# Iniailize Hue
while true
  begin
    @h = Hue::Hue.new
    break
  rescue
    p "Failed to find hue. Retrying..."
  end
end

# Initialize server
config = {:Port => 4567}
server = HTTPServer.new(config)

# Iniailize state
@counter = 0

# Setup URLs
server.mount_proc("/incrementDial") do |req, resp|
  @counter += 1
  TerminalNotifier.notify("Counter: %d" % @counter, :title => "Hue thing", :group => "hue")
end
server.mount_proc("/decrementDial") do |req, resp|
  @counter -= 1
  TerminalNotifier.notify("Counter: %d" % @counter, :title => "Hue thing", :group => "hue")
end

# Cycle through all colors in sync
server.mount_proc("/cycle") do |req, resp|
  startProgram do
    @h.preset.cycle_thru_colors 0
  end
end

# Random walk
server.mount_proc("/randomWalk") do |req, resp|
  updateHues
  startProgram do
    @hues.each_with_index do |hue, i|
      newColor = hue[1] + (10000 * (2*rand - 1)) 
      newColor = Integer(newColor) % 65535
      @hues[i] = newColor
      @h.write(i+1, {hue: newColor})
    end
  end
end

# Slight changes to selected lights
lights_to_ripple = [TV]
server.mount_proc("/ripple") do |req, resp|
  updateHues
  startProgram do
    @hues.each_with_index do |hue, i|
      if lights_to_ripple.index(i+1)
        newColor = hue[1] + (5000 * (2*rand - 1)) 
        newColor = [Integer(newColor), 65535].min
        @h.write(i+1, {hue: newColor})
      end
    end
  end
end

# Stop the current program
server.mount_proc("/killProgram") do |req, resp|
  endProgram
end

# Helper functions
def startProgram(&block)
  endProgram
  @programThread = Thread.new{yield while true}
end
def endProgram
  @programThread.kill if @programThread and @programThread.alive?
end

def updateHues
  @hues = {}
  @h.lights.each_with_index do |light, i|
    @hues[i] = light[1]["state"]["hue"]
  end
  p @hues
end


server.start
