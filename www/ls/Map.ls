L.Icon.Default.imagePath = "https://samizdat.cz/tools/leaflet/images/"
class ig.Map
  (@parentElement, @scale) ->
    @element = @parentElement.append \div
      ..attr \class \map
    @map = L.map @element.node!, maxZoom: 21
    baseLayer = L.tileLayer do
      * "//m1.mapserver.mapy.cz/ophoto-m/{z}-{x}-{y}"
      * zIndex: 1
        opacity: 1
        maxZoom: 21
        maxNativeZoom: 20
        attribution: '&copy; GEODIS BRNO, s.r.o, &copy; Seznam.cz, a.s.'
    baseLayer.addTo @map

  setView: (km) ->
    kmGroup = Math.floor km
    (err, data) <~ d3.tsv "../../drncani-postprocess/data/by-km/#{kmGroup}.tsv", (row) ~>
      for key, value of row
        row[key] = switch key
        | "goingBack" => value == "t"
        | "fromTime", "samplesL", "samplesR" => parseInt value, 10
        | otherwise => parseFloat value
      row.latLng = L.latLng [row.lat, row.lon]
      colorL = if row.samplesL
        @scale row.diffL
      else
        '#ddd'
      colorR = if row.samplesR
        @scale row.diffR
      else
        '#ddd'
      leftDiv = "<div style='background-color: #{colorL}'></div>"
      rightDiv = "<div style='background-color: #{colorR}'></div>"
      row.icon = L.divIcon do
        html: "<div style='transform:rotate(#{row.track}deg)'>#{leftDiv}#{rightDiv}</div>"
        iconSize: [20, 10]
      L.marker row.latLng, {icon: row.icon, clickable: no}
        ..addTo @map
      row

    position = (km % 1) / 2
    console.log position
    @map.setView data[Math.round data.length * position].latLng, 19
    console.log data.0


