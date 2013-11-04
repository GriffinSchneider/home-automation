numberoflights=8

hueusername='1234567890'

hueurl='http://192.168.1.105/api/'$hueusername
lightsurl=$hueurl'/lights'
groupsurl=$hueurl'/groups'

# Argument 1: data to PUT
# Argument 2: URL to PUT to
function makerequest {
    echo $1 "${2}"
    curl -s --request PUT --data $1 "${2}" | ruby -rawesome_print -rjson -e "ap JSON.parse(STDIN.read)"
}

function getstate {
    curl -s --request GET $lightsurl | ruby -rawesome_print -rjson -e "ap JSON.parse(STDIN.read)"
    for i in $(seq 1 $numberoflights)
    do
        echo "#${i} :"
        curl -s --request GET $lightsurl'/'$i | ruby -rawesome_print -rjson -e "ap JSON.parse(STDIN.read)"
    done
}

# Argument 1: JSON String with state settings.
# Argument 2: Light number
function lightstate {
    makerequest $1 $lightsurl'/'$2'/state'
}

# Argument 1: JSON String with state settings.
function allstate {
    for i in $(seq 1 $numberoflights)
    do
        lightstate $1 $i
    done
}

# Argument 1: pointsymbol JSON string
# Argument 2: Light number
function pointsymbol {
    makerequest $1 $lightsurl'/'$2'/pointsymbol'
}

# Argument 1: pointsymbol JSON string
function allpointsymbol {
    for i in $(seq 1 $numberoflights)
    do
        pointsymbol $1 $i
    done
}

# Argument 1: symbolselection string
# Argument 2: duration
function transmitsymbol {
    makerequest '{"symbolselection":"'$1'","duration":'$2'}' $groupsurl'/0/transmitsymbol'
}

function colorloop {
    allstate '{"effect":"colorloop","sat":255}'
}

function noeffect {
    allstate '{"effect":"none"}'
}

function alloff {
    allstate '{"on":false}'
}

function allon {
    allstate '{"on":true}'
}

function morning {
    allstate '{"on":true,"effect":"none","bri":255,"sat":232,"hue":34495}'
}

function warning {
    allstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":0,"transitiontime":10}'
}

function relax {
    allstate '{"on":true,"effect":"none","bri":144,"sat":211,"hue":13122,"transitiontime":10}'
}

function green {
    allstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":25717,"transitiontime":10}'
}

function deepsea {
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":65527,"transitiontime":10}' 1
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":46359,"transitiontime":10}' 2
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":65527,"transitiontime":10}' 3
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":46624,"transitiontime":10}' 4
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":46166,"transitiontime":10}' 5
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":65527,"transitiontime":10}' 6
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":45370,"transitiontime":10}' 7
    lightstate '{"on":true,"effect":"none","bri":255,"sat":255,"hue":43991,"transitiontime":10}' 8
}

function night {
    lightstate '{"on":false,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 1
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 2
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 3
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 4
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 5
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 6
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 7
    lightstate '{"on":true,"effect":"none","bri":1,"sat":255,"hue":0,"transitiontime":50}' 8
}

function asleep {
    lightstate '{"on":false}' 4
    lightstate '{"on":false}' 7
}

function slowstrobe {
    allpointsymbol '{"1":"040000FFFF00003333000033330000FFFFFFFFFF"}'
    transmitsymbol "01010801010102010301040105010601070108" 60000
}

function strobe {
    allpointsymbol '{"1":"0A00F1F01F1F1001F1FF100000000001F2F"}'
    transmitsymbol "01010801010102010301040105010601070108" 60000
}

function greenstrobe {
    allpointsymbol '{"1":"0F0000FFFF00FF3333000033330000FFFFFFFFFF"}'
    transmitsymbol "01010801010102010301040105010601070108" 60000
}

function destrobe {
    transmitsymbol "" 1
}

