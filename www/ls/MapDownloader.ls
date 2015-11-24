L.Icon.Default.imagePath = "https://samizdat.cz/tools/leaflet/images/"
radius = 0.000034
radiusBig = Math.sqrt ((radius ^ 2) + ((radius / 2)^2))
radiusSmall = radius / 2
angles1 =
  * Math.PI * 0.35
    0
    Math.PI
    Math.PI * 0.65
anglesR =
  * 0
    Math.PI * 1.65
    Math.PI * 1.35
    Math.PI

class ig.MapDownloader
  ->
    @kmGroups = {}

  setScale: (@scale) ->

  getData: (kmGroup, cb) ->
    if @kmGroups[kmGroup]
      console.log that
      cb null, that
    else
      @downloadData kmGroup, cb

  downloadData: (kmGroup, cb) ->
    layerGroup = L.layerGroup!
    previousRowToBrno = null
    previousRowToPrague = null
    (err, data) <~ d3.tsv do
      "https://samizdat.cz/data-r/drncani-postprocess/data/by-km/#{kmGroup}.tsv"
      (row) ~>
        for key, value of row
          row[key] = switch key
          | "goingBack" => value == "t"
          | "fromTime", "samplesL", "samplesR" => parseInt value, 10
          | otherwise => parseFloat value
        row.latLng = L.latLng [row.lat, row.lon]
        row.km = parseFloat row.km
        row
    @kmGroups[kmGroup] = {layerGroup, data}
    cb null @kmGroups[kmGroup]
