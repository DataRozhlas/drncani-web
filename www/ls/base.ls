container = d3.select ig.containers.base
canvas = container.append \canvas
  ..attr \width 250
  ..attr \height 800

ctx = canvas.node!getContext \2d
highway = new ig.Highway ctx
  ..addLane 1
  ..addLane 2
  ..addLane 3
  ..addDelim 2, "full"
  ..addDelim 3, "dash"
  ..addLane 5
  ..addLane 6
  ..addLane 7
  ..addDelim 6, "dash"
  ..addDelim 7, "dash-full"
