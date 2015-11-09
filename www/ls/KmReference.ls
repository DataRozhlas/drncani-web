lines = d3.tsv.parse ig.data.'km-reference'
linesTotal = lines.length
points = new Array lines.length * 2 - 1

for line, index in lines
  line.km = parseInt line.km, 10
  line.time = parseInt line.time, 10
  line.timeBack = parseInt line.timeBack, 10
  line.lat = parseFloat line.lat
  line.lon = parseFloat line.lon
  i1 = index
  i2 = lines.length * 2 - index - 1
  points[i1] = {time:line.time, km:line.km}
  points[i2] = {time:line.timeBack, km:line.km}

ig.getKmFromTimestamp = (timestamp) ->
  lastPoint = null
  for point in points
    if point.time > timestamp
      return lastPoint.km
    lastPoint = point
