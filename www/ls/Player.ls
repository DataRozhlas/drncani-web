class Cue
  (@playerSeconds, @trackTimestamp) ->

class ig.Player
  (@parentElement) ->
    ig.Events @
    @element = @parentElement.append \div
      ..attr \class \player
      ..attr \id \player
    tag = document.createElement 'script'
      ..src = "https://www.youtube.com/iframe_api";
    firstScriptTag = document.getElementsByTagName 'script' .0
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag
    @cues =
      new Cue 0, 1443948923776
      new Cue 20, 1443955077936
      new Cue 1343, 1443956333804

    window.onYouTubeIframeAPIReady = ~>
      player = new YT.Player do
        * 'player'
        * height: '390',
          width: '640',
          videoId: 'M7lc1UVf-VE',
          events:
            \onReady : (evt) ~> @player = evt.target
            \onStateChange : @~onPlayerStateChange

    setInterval @~tick, 200

  onPlayerStateChange: ({data}) ->
    if data == 1 and @stopAtFirstChance
      @player.pauseVideo!
      @stopAtFirstChance = no

  tick: ->
    return unless @player
    return if @player.getPlayerState! != 1

  playByTrackTimestamp: (trackTimestamp) ->
    seconds = @trackTimestampToSeconds trackTimestamp
    @playAt seconds

  playAt: (seconds) ->
    return unless @player
    @player.seekTo seconds
    @stopAtFirstChance = yes

  trackTimestampToSeconds: (trackTimestamp) ->
    cueToUse = null
    for cue in @cues
      if cue.trackTimestamp > trackTimestamp
        cueToUse = cue
      else
        break
    seconds = cue.playerSeconds + (trackTimestamp - cue.trackTimestamp) * 0.001
