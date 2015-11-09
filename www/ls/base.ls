container = d3.select ig.containers.base

highway = ig.setupHighway container
  ..on \km (pointedKm) ->
    mapToPlayer.setView pointedKm
    map.setView pointedKm

downloader1 = new ig.MapDownloader
  ..setScale highway.scale

downloader2 = new ig.MapDownloader
  ..setScale highway.scale

mapPlayerContainer = container.append \div
  ..attr \class \map-player-container
mapToPlayer = new ig.Map mapPlayerContainer, downloader1

player = new ig.Player mapPlayerContainer
mapToPlayer.on \time -> player.playByTrackTimestamp it
player.on \time -> mapToPlayer.setViewByTimestamp it

overlayContainer = container.append \div
  ..attr \class \overlay-container

map = new ig.Map overlayContainer, downloader2
