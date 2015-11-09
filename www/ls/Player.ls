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
      new Cue 867, 1443948923776
      new Cue 3186, 1443952447886

    window.onYouTubeIframeAPIReady = ~>
      player = new YT.Player do
        * 'player'
        * height: '390',
          width: '640',
          videoId: '9xnWbD_X2FQ',
          events:
            \onReady : (evt) ~> @player = evt.target
            \onStateChange : @~onPlayerStateChange

    setInterval @~tick, 250

  onPlayerStateChange: ({data}) ->
    if data == 1 and @stopAtFirstChance
      @player.pauseVideo!
      @stopAtFirstChance = no

  tick: ->
    return unless @player
    return if @player.getPlayerState! != 1
    return if @stopAtFirstChance
    timestamp = @secondsToTrackTimestamp @player.getCurrentTime!
    @emit \time timestamp

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
      if cue.trackTimestamp <= trackTimestamp
        cueToUse = cue
      else
        break

    seconds = cueToUse.playerSeconds + (trackTimestamp - cueToUse.trackTimestamp) * 0.001

  secondsToTrackTimestamp: (seconds) ->
    cueToUse = null
    for cue in @cues
      if cue.playerSeconds <= seconds
        cueToUse = cue
      else
        break

    trackTimestamp = cueToUse.trackTimestamp + (seconds - cueToUse.playerSeconds) * 1000
