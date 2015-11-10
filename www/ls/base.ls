container = d3.select ig.containers.base

highway = ig.setupHighway container
  ..on \km (pointedKm) ->
    map.setView pointedKm
  ..on \overlayMove (pointedY) ->
    overlayContainer.style \transform "translate(0, #{pointedY}px)"

overlayContainer = container.append \div
  ..attr \class \overlay-container
  ..append \div
    ..attr \class \triangle
  ..style \transform "translate(0, 20px)"

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

