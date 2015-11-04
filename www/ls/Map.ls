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
class Trigger
  (@latLng, @kmGroupsToLoad) ->

class ig.Map
  (@parentElement) ->
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
    @loading = {}
    @layerGroups = {}
    @dataGroups = {}
    @map.on \moveend @~checkForUpdate

  setScale: (@scale) ->

  setView: (km) ->
    (err, centerLatLng) <~ @displayData km
    @map.setView centerLatLng, 19

  displayData: (km, cb) ->
    kmGroup = Math.floor km
    @displayed[kmGroup] = yes
    (err, data) <~ @getData kmGroup
    position = (km % 1) / 2
    lastDiff = Math.abs data[0].km - km
    for datum in data
      diff = Math.abs datum.km - km
      if diff > lastDiff
        break
      lastDiff := diff
    cb? null, datum.latLng

  getData: (kmGroup, cb) ->
    if @dataGroups[kmGroup]
      cb null that
    else if !@loading[kmGroup]
      @downloadData kmGroup, cb

  downloadData: (kmGroup, cb) ->
    layerGroup = L.layerGroup!
    @loading[kmGroup] = yes
    previousRowToBrno = null
    (err, data) <~ d3.tsv do
      "../../drncani-postprocess/data/by-km/#{kmGroup}.tsv", (row) ~>
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
          if !row.goingBack
            row.km = if previousRowToBrno
              previousRowToBrno.km + 0.001 * previousRowToBrno.latLng.distanceTo row.latLng
            else
              kmGroup
            previousRowToBrno := row
        row

    @triggers.push new Trigger data[0].latLng, [kmGroup, kmGroup - 1]
    @triggers.push new Trigger previousRowToBrno.latLng, [kmGroup, kmGroup + 1]
    @dataGroups[kmGroup] = data
    @layerGroups[kmGroup] = layerGroup
      ..addTo @map
    cb err, data

  cleanUnusedData: (trigger) ->
    for kmGroup, layer of @layerGroups
      kmGroup = parseInt kmGroup, 10
      if kmGroup not in trigger.kmGroupsToLoad
        @map.removeLayer layer

  checkForUpdate: ->
    currentBounds = @map.getBounds!
    for trigger in @triggers
      if currentBounds.contains trigger.latLng
        for kmGroupToLoad in trigger.kmGroupsToLoad
          if @layerGroups[kmGroupToLoad]
            @layerGroups[kmGroupToLoad].addTo @map
          if !@displayed[kmGroupToLoad]
            @displayData kmGroupToLoad
        @cleanUnusedData trigger
        break
