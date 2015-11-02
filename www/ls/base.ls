container = d3.select ig.containers.base
highway = ig.setupHighway container

map = new ig.Map container, highway.scale
  ..setView 186.685

<~ setTimeout _, 1000
map.setView 186.7
