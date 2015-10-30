kilometers = 193.5

height = kilometers * 50

class Ramp
  (@name, @km, @dir = "both", @shape = "both", @special)->


ramps =
  # new Ramp "Chodov", 0.5, "brno", "on"
  new Ramp "Chodov", 1.5
  new Ramp "Průhonice", 5.6, "brno"
  new Ramp "Průhonice", 6.6, "praha"
  new Ramp "Modletice", 9.7, "brno", "both", "R1"
  new Ramp "Modletice", 11.7, "praha", "both", "R1"
  new Ramp "Všechromy", 15.6
  new Ramp "Mirošovice", 22.1, "both", "both", "Mirošovice"
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
  new Ramp "V. Meziříčí Z", 141
  new Ramp "V. Meziříčí V", 146
  new Ramp "Lhotka", 153
  new Ramp "Velká Bíteš", 162
  new Ramp "Devět Křížů", 168
  new Ramp "Ostrovačice", 178
  new Ramp "Kývalka", 182
  new Ramp "Brno-západ", 190


ig.setupHighway = (container) ->
  canvas = container.append \canvas
    ..attr \width 250
    ..attr \height height
  ctx = canvas.node!getContext \2d
  highway = new ig.Highway ctx, height, kilometers
  toPx = highway~kmToPx
  highway
    ..addGrass 0
    ..addGrass 8
    ..addGrassKm 7, 21, 193.5
    ..addGrassKm 1, 21, 193.5

  bridges =
    [22.353, 22.557]
    [23.737 23.992]
    [27.225, 27.723, withRiver: 4]
    [38.368 38.534]
    [44.561 44.748]
    [52.753 52.911]
    [62 62.241, withRiver: 3]
    [76.418 76.68, withRiver: 8]
    [81.116 81.331]
    [143.995 144.453, withRiver: 1]
  highway
    ..addGrass 4
  for bridge in bridges
    highway.addBridgeKm ...bridge

  for ramp in ramps
    if ramp.dir in <[praha both]>
      highway.prepareRamp do
        if ramp.km < 21 then 8 else 7
        ramp
    if ramp.dir in <[brno both]>
      highway.prepareRamp do
        if ramp.km < 21 then 0 else 1
        ramp
  highway
    ..addLaneEndKm 7, 21, 1, innerLane: yes, outerLane: yes
    ..addLaneEndKm 1, 21, 0, innerLane: yes, outerLane: yes
    ..addLaneKm 1, 0, 21
    ..addLane 2
    ..addLane 3
    ..addGuardrail 4
    ..addLane 5
    ..addLane 6
    ..addLaneKm 7, 0, 21

  for bridge in bridges
    highway.addBridgeFinishKm ...bridge

  highway
    ..addDelimKm 1, "full", 0, 21
    ..addDelimKm 2, "dash", 0, 19.5
    ..addDelimKm 2, "full", 21.5, 193.5, -20
    ..addDelim 3, "dash"
    ..addDelim 4, "full"
    ..addDelim 5, "full"
    ..addDelim 6, "dash"
    ..addDelimKm 7, "dash", 0, 19.5
    ..addDelimKm 7, "full", 21.5, 193.5, -20
    ..addDelimKm 8, "full", 0, 21


  highway.drawKm [1 to 193.5]
  for ramp in ramps
    if ramp.dir in <[praha both]>
      highway.finishRamp do
        if ramp.km < 21 then 8 else 7
        ramp
    if ramp.dir in <[brno both]>
      highway.finishRamp do
        if ramp.km < 21 then 0 else 1
        ramp
  data = ig.data.data.split "\n"
    ..shift!
  outData = for datum in data
    [km, diffR, diffL, minSpeed] = datum.split "\t"
    km = parseFloat km
    diffR = parseFloat diffR
    diffL = parseFloat diffL
    minSpeed  = parseFloat minSpeed
    {km, diffR, diffL, minSpeed}

  highway.addData outData

