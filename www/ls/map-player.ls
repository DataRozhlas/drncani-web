videoIds =
  "9xnWbD_X2FQ"
  "LhZUpSV8BB8"

cues =
  * new ig.PlayerCue 867, 1443948920776
    new ig.PlayerCue 3186, 1443952630590
  * new ig.PlayerCue 698,  1443964795687
    ...
class ig.TopFive
  (@timestamp, @text, @desc) ->
topFive =
  * new TopFive 1443953737994, "126,5 km" "mezi Velkým Beranovem a Měřínem"
    new TopFive 1443956092572, "186,5 km" "mezi Kývalkou a Brnem"
    new TopFive 1443955292690, "166,5 km" "mezi mezi Velkou Bíteší a Devíti Kříži"
    new TopFive 1443956058257, "185,5 km" "mezi Kývalkou a Brnem"
    new TopFive 1443954261282, "140,0 km" "před Velkým Meziříčím "
  * new TopFive 1443965498036, "178,0 km" "na sjezdu na Ostrovačice"
    new TopFive 1443965280026, "183,0 km" "před sjezdem na Kývalku"
    new TopFive 1443965899427, "167,5 km" "mezi mezi Devíti Kříži a Velkou Bíteší"
    new TopFive 1443968300706, "104,0 km" "na sjezdu na Větrný Jeníkov"
    new TopFive 1443965921229, "167,0 km" "za sjezdem na Devět Křížů"

tag = document.createElement 'script'
  ..src = "https://www.youtube.com/iframe_api";
firstScriptTag = document.getElementsByTagName 'script' .0
firstScriptTag.parentNode.insertBefore tag, firstScriptTag

players = for let name, index in <[ player-1 player-2 ]>
  return unless ig.containers['player-1']
  element = d3.select ig.containers[name]
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
  element.append \ol .selectAll \li .data topFive[index] .enter!append \li
    ..append \a
      ..html (.text)
      ..attr \href \#
      ..on \click ->
        d3.event.preventDefault!
        player.playByTrackTimestamp it.timestamp - 5000
    ..append \span
      ..html -> ": " + it.desc

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
