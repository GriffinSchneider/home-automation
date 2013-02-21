on run argv
  set dialValue to item 1 of argv as real
  tell application "PowerMate"
    tell device named "Lights"
      if (dialValue = 100) then
        make light state with properties {state type:pulsed, pulse rate:0.25, pulse length:0.1, name:"Light Level"}
      else
        make light state with properties {state type:steady, brightness:dialValue / 100, name:"Light Level"}
      end if 
    end tell
  end tell
end run
