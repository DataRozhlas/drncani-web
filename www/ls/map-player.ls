videoIds =
  "LhZUpSV8BB8"
  "9xnWbD_X2FQ"

cues =
  * new ig.PlayerCue 867, 1443948923776
    new ig.PlayerCue 3186, 1443952447886
  * new ig.PlayerCue 698,  1443964818687
    ...

tag = document.createElement 'script'
  ..src = "https://www.youtube.com/iframe_api";
firstScriptTag = document.getElementsByTagName 'script' .0
firstScriptTag.parentNode.insertBefore tag, firstScriptTag

players = for let name, index in <[ player-1 player-2 ]>
  return unless ig.containers['player-1']
  element = d3.select ig.containers['player-1']
  downloader2 = new ig.MapDownloader
    ..setScale ig.highwayScale
  mapPlayerContainer = element.append \div
    ..attr \class \map-player-container
  mapToPlayer = new ig.Map mapPlayerContainer, downloader2
  player = new ig.Player do
    mapPlayerContainer
    videoIds[index]
    cues[index]
  mapToPlayer.on \time -> player.playByTrackTimestamp it
  player.on \time -> mapToPlayer.setViewByTimestamp it
  player

window.onYouTubeIframeAPIReady = ~>
  for let videoId, index in videoIds
    player = new YT.Player do
      * "player-#{videoId}"
      * height: '390',
        width: '640',
        videoId: videoId,
        events:
          \onReady : (evt) -> players[index].player = evt.target
          \onStateChange : -> players[index].onPlayerStateChange it
