container = d3.select ig.containers.base
map = new ig.Map container
highway = ig.setupHighway container
  ..on \km (pointedKm) -> map.setView pointedKm
map.setScale highway.scale
