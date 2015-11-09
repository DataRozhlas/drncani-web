container = d3.select ig.containers.base

highway = ig.setupHighway container
  ..on \km (pointedKm) -> mapToPlayer.setView pointedKm

mapPlayerContainer = container.append \div
  ..attr \class \map-player-container
mapToPlayer = new ig.Map mapPlayerContainer
  ..setScale highway.scale
player = new ig.Player mapPlayerContainer
mapToPlayer.on \time -> player.playByTrackTimestamp it
player.on \time -> mapToPlayer.setViewByTimestamp it
