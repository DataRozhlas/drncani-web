ig.fit!
element = d3.select ig.containers.base
container = element.append \div
  ..attr \class \highway-container
overlayIsActive = no
overlayHideTimeout = null

displayOverlay = ->
  if overlayHideTimeout
    clearTimeout overlayHideTimeout
    overlayHideTimeout := null
  return if overlayIsActive
  overlayIsActive := yes
  overlayContainer.classed \active yes

hideOverlay = ->
  return if overlayHideTimeout
  overlayHideTimeout := setTimeout do
    ->
      overlayIsActive := no
      overlayContainer.classed \active no
      overlayHideTimeout := null
    1500

highway = ig.setupHighway container
  ..on \km (pointedKm, goingBack) ->
    map.setView pointedKm, goingBack
  ..on \overlayMove (pointedY) ->
    overlayContainer.style \transform "translate(0, #{pointedY}px)"
  ..on \mouseover displayOverlay
  ..on \mouseout hideOverlay
overlayContainer = container.append \div
  ..attr \class \overlay-container
  ..append \div
    ..attr \class \triangle
  ..on \mouseover displayOverlay
  ..on \mouseout hideOverlay

downloader1 = new ig.MapDownloader
  ..setScale highway.scale
map = new ig.Map overlayContainer, downloader1
# downloader2 = new ig.MapDownloader
#   ..setScale highway.scale
# mapPlayerContainer = container.append \div
  # ..attr \class \map-player-container
# mapToPlayer = new ig.Map mapPlayerContainer, downloader2
# player = new ig.Player mapPlayerContainer
# mapToPlayer.on \time -> player.playByTrackTimestamp it
# player.on \time -> mapToPlayer.setViewByTimestamp it

