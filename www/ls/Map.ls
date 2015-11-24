class Trigger
  (@latLng, @kmGroupsToLoad) ->

class ig.Map
  (@parentElement, @mapDownloader) ->
    ig.Events @
    @element = @parentElement.append \div
      ..attr \class \map
    @map = L.map do
      @element.node!
      maxZoom: 21
      minZoom: 16
    baseLayer = L.tileLayer do
      * "//m1.mapserver.mapy.cz/ophoto-m/{z}-{x}-{y}"
      * maxZoom: 21
        maxNativeZoom: 20
        attribution: '&copy; GEODIS BRNO, s.r.o, &copy; Seznam.cz, a.s.'
    baseLayer.addTo @map
    dataLayer = L.tileLayer do
      * "https://samizdat.cz/tiles/drncani-d1/{z}/{x}/{y}.png"
      * maxZoom: 20
        maxNativeZoom: 19
        attribution: 'data Samizdat, ČRo'
    dataLayer.addTo @map
    @triggers = []
    @displayed = {}
    @loading = {}
    @layerGroups = {}
    @dataGroups = {}
    @element.append \a
      ..attr do
          \href   : \https://mapy.cz
          \target : \_blank
          \class  : \szn-logo
      ..append \img
        ..attr \src \//api.mapy.cz/img/api/logo.png

  setScale: (@scale) ->

  setView: (km, goingBack = no) ->
    (err, centerDatum) <~ @displayData km, goingBack
    @map.setView centerDatum.latLng, 19
    @emit \time centerDatum.fromTime

  displayData: (km, goingBack = no, cb) ->
    kmGroup = Math.floor km
    @displayed[kmGroup] = yes
    (err, data) <~ @getData kmGroup
    position = (km % 1) / 2
    lastDiff = Infinity
    for datum in data
      continue if datum.goingBack isnt goingBack
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
    @dataGroups[kmGroup] = data
    cb err, data
