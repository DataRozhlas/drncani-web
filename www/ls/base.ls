container = d3.select ig.containers.base
kilometers = 193.5
# kilometers = 50\
height = kilometers * 50

class Ramp
  (@name, @km, @dir = "both", @shape = "both", @special)->

class GasStation
  (@name, @km, @dir = "both", @shape = "both", @special)->
ramps =
  new Ramp "Chodov", 0.5, "brno", "on"
  new Ramp "Chodov", 2
  new Ramp "Průhonice", 6.2, "brno"
  new Ramp "Průhonice", 6.6, "praha"
  new Ramp "Modletice", 9.7, "brno", "both", "R1"
  new Ramp "Modletice", 11.7, "praha", "both", "R1"
  new Ramp "Všechromy", 15.6
  new Ramp "Hvězdonice", 29
  new Ramp "Ostředek", 34
  new Ramp "Štěrnov", 41
  new Ramp "Psáře", 49
  new Ramp "Soutice", 56
  new Ramp "Loket", 66
  new Ramp "Hořice", 75, "brno"
  new Ramp "Koberovice", 81, "praha"
  new Ramp "Humpolec", 90
  new Ramp "Větrný Jeníkov", 104
  new Ramp "Jihlava", 112
  new Ramp "Velký Beranov", 119
  new Ramp "Měřín", 134
  new Ramp "Velké Meziřící", 141
  new Ramp "Velké Meziřící", 146
  new Ramp "Lhotka", 153
  new Ramp "Velká Bíteš", 162
  new Ramp "Devět Křížů", 168
  new Ramp "Ostrovačice", 178
  new Ramp "Kývalka", 182
  new Ramp "Brno-západ", 190
# console.log kilometers / height * 1000
gasStations =
  new GasStation "Újezd", 4.5 # benzinka
  new GasStation "Újezd", 4.5 # benzinka
canvas = container.append \canvas
  ..attr \width 300
  ..attr \height height

ctx = canvas.node!getContext \2d
highway = new ig.Highway ctx, height, kilometers
toPx = highway~kmToPx
highway
  ..addGrass 0
  ..addGrass 8
  ..addGrassKm 7, 21, 193.5
  ..addGrassKm 1, 21, 193.5
  ..addLaneEndKm 7, 21, 1, innerLane: yes
  ..addLaneEndKm 1, 21, 0, innerLane: yes
  ..addLaneKm 1, 0, 21
  ..addLane 2
  ..addLane 3
  ..addGrass 4
  ..addGuardrail 4
  ..addLane 5
  ..addLane 6
  ..addLaneKm 7, 0, 21
  ..addDelimKm 1, "full", 0, 21
  ..addDelimKm 2, "dash", 0, 19.5
  ..addDelimKm 2, "dash-short", 20, 21.5
  ..addDelimKm 2, "full", 21.5, 193.5, -20
  ..addDelim 3, "dash"
  ..addDelim 4, "full"
  ..addDelim 5, "full"
  ..addDelim 6, "dash"
  ..addDelimKm 7, "dash", 0, 19.5
  ..addDelimKm 7, "dash-short", 20, 21.5
  ..addDelimKm 7, "full", 21.5, 193.5, -20
  ..addDelimKm 8, "full", 0, 21
highway.drawKm [1 to 193.5] #by 0.5]
for ramp in ramps
  if ramp.dir in <[praha both]>
    highway.addRamp 8, ramp
  if ramp.dir in <[brno both]>
    highway.addRamp 0, ramp

return


# return
for gasStation in gasStations
  if gasStation.dir in <[praha both]>
    highway.addGasStation 8, gasStation
  if gasStation.dir in <[brno both]>
    highway.addGasStation 0, gasStation
data = ig.data.data.split "\n"
  ..shift!
outData = for datum in data
  [km, diffR, diffL, minSpeed] = datum.split "\t"
  km = parseFloat km
  diffR = parseInt diffR, 10
  diffL = parseInt diffL, 10
  minSpeed  = parseFloat minSpeed
  {km, diffR, diffL, minSpeed}

highway.addData outData

