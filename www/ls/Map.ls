L.Icon.Default.imagePath = "https://samizdat.cz/tools/leaflet/images/"
class Trigger
  (@latLng, @kmGroupToLoad, @dir) ->

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
    @triggers = []
    @displayed = {}
    @layerGroups = {}
    @map.on \moveend @~checkForUpdate

  setView: (km) ->
    (err, centerLatLng) <~ @displayData km
    @map.setView centerLatLng, 19

  displayData: (km, cb) ->
    kmGroup = Math.floor km
    @displayed[kmGroup] = yes
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
    layerGroup = L.layerGroup!
    (err, data) <~ d3.tsv "../../drncani-postprocess/data/by-km/#{kmGroup}.tsv", (row) ~>
      for key, value of row
        row[key] = switch key
        | "goingBack" => value == "t"
        | "fromTime", "samplesL", "samplesR" => parseInt value, 10
        | otherwise => parseFloat value
      row.latLng = L.latLng [row.lat, row.lon]
      trackInRads = (row.track * -1 + 90) / 180 * Math.PI
      latSkew = Math.cos row.lat / 180 * Math.PI
      if row.samplesL
        colorL = @scale row.diffL
        cornersL =
          L.latLng do
            * row.lat + (latSkew * radiusBig) * Math.sin angles1[0] + trackInRads
              row.lon + radiusBig * Math.cos angles1[0] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusSmall) * Math.sin angles1[1] + trackInRads
              row.lon + radiusSmall * Math.cos angles1[1] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusSmall) * Math.sin angles1[2] + trackInRads
              row.lon + radiusSmall * Math.cos angles1[2] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusBig) * Math.sin angles1[3] + trackInRads
              row.lon + radiusBig * Math.cos angles1[3] + trackInRads
        row.markerL = L.polygon do
          * cornersL
          * fillColor: colorL
            fillOpacity: 1
            stroke: no
        row.markerL.addTo layerGroup
      if row.samplesR
        colorR = @scale row.diffR
        cornersR =
          L.latLng do
            * row.lat + (latSkew * radiusSmall) * Math.sin anglesR[0] + trackInRads
              row.lon + radiusSmall * Math.cos anglesR[0] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusBig) * Math.sin anglesR[1] + trackInRads
              row.lon + radiusBig * Math.cos anglesR[1] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusBig) * Math.sin anglesR[2] + trackInRads
              row.lon + radiusBig * Math.cos anglesR[2] + trackInRads
          L.latLng do
            * row.lat + (latSkew * radiusSmall) * Math.sin anglesR[3] + trackInRads
              row.lon + radiusSmall * Math.cos anglesR[3] + trackInRads
        row.markerR = L.polygon do
          * cornersR
          * fillColor: colorR
            fillOpacity: 1
            stroke: no
        row.markerR.addTo layerGroup
      row

    position = (km % 1) / 2
    @triggers.push new Trigger data[0].latLng, kmGroup - 1, -1
    @triggers.push new Trigger data[Math.round data.length / 2].latLng, kmGroup + 1, +1
    @layerGroups[kmGroup] = layerGroup
      ..addTo @map
    cb? null, data[Math.round data.length * position].latLng

  cleanUnusedData: (trigger) ->
    currentKmGroup = trigger.kmGroupToLoad
    dir = trigger.dir
    otherKmGroup = currentKmGroup + 1 * (dir * -1)
    for kmGroup, layer of @layerGroups
      kmGroup = parseInt kmGroup, 10
      if kmGroup not in [currentKmGroup, otherKmGroup]
        @map.removeLayer layer

  checkForUpdate: ->
    currentBounds = @map.getBounds!
    for trigger in @triggers
      if currentBounds.contains trigger.latLng
        if @layerGroups[trigger.kmGroupToLoad]
          @cleanUnusedData trigger
          @layerGroups[trigger.kmGroupToLoad].addTo @map
          break
        if !@displayed[trigger.kmGroupToLoad]
          @displayData trigger.kmGroupToLoad
          @cleanUnusedData trigger
          break
