class Trigger
  (@latLng, @kmGroupsToLoad) ->

class ig.Map
  (@parentElement, @mapDownloader) ->
    ig.Events @
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
    (err, centerDatum) <~ @displayData km
    @map.setView centerDatum.latLng, 19
    @emit \time centerDatum.fromTime

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
    cb? null, datum


  setViewByTimestamp: (timestamp) ->
    km = ig.getKmFromTimestamp timestamp
    return if km is void
    (err, data) <~ @getData km
    center = @findClosestDatumToTimestamp data, timestamp
    @map.setView center.latLng, 19


  findClosestDatumToTimestamp: (data, timestamp) ->
    lastDatum = null
    for datum in data
      if datum.fromTime > timestamp
        return lastDatum
      lastDatum := datum


  getData: (kmGroup, cb) ->
    if @dataGroups[kmGroup]
      cb null that
    else if !@loading[kmGroup]
      @downloadData kmGroup, cb

  downloadData: (kmGroup, cb) ->
    @loading[kmGroup] = yes
    (err, {data, layerGroup, lastRowToBrno}) <~ @mapDownloader.getData kmGroup
    @triggers.push new Trigger data[0].latLng, [kmGroup, kmGroup - 1]
    @triggers.push new Trigger lastRowToBrno.latLng, [kmGroup, kmGroup + 1]
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
