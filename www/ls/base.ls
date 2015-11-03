container = d3.select ig.containers.base
map = new ig.Map container
highway = ig.setupHighway container, map
map.setScale highway.scale
