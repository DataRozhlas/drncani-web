container = d3.select ig.containers.base

highway = ig.setupHighway container
  ..on \km (pointedKm) -> map.setView pointedKm

overlayContainer = container.append \div
  ..attr \class \overlay-container
map = new ig.Map overlayContainer
  ..setScale highway.scale
player = new ig.Player overlayContainer
map.on \time -> player.playByTrackTimestamp it
player.on \time -> map.setViewByTimestamp it
# map.setViewByTimestamp 1443949532184
