container = d3.select ig.containers.base
highway = ig.setupHighway container

new ig.Map container, highway.scale
  ..setView 22.95
