class ig.PlayerCue
  (@playerSeconds, @trackTimestamp) ->

class ig.Player
  (@parentElement, @videoId, @cues) ->
    ig.Events @
    @element = @parentElement.append \div
      ..attr \class \player
      ..attr \id "player-#{@videoId}"
    setInterval @~tick, 250
    @isFirstPlay = yes

  onPlayerStateChange: ({data}) ->
    if data == 1 and @isFirstPlay
      @player.seekTo @cues.0.playerSeconds
      @isFirstPlay = no
    if data == 1 and @stopAtFirstChance
      @player.pauseVideo!
      @stopAtFirstChance = no

  tick: ->
    return unless @player
    return if @player.getPlayerState! != 1
    return if @stopAtFirstChance
    timestamp = @secondsToTrackTimestamp @player.getCurrentTime!
    @emit \time timestamp if timestamp isnt null

  playByTrackTimestamp: (trackTimestamp) ->
    seconds = @trackTimestampToSeconds trackTimestamp
    @playAt seconds if seconds isnt null

  playAt: (seconds) ->
    return unless @player
    @player.seekTo seconds
    # @stopAtFirstChance = yes

  trackTimestampToSeconds: (trackTimestamp) ->
    cueToUse = null
    for cue in @cues
      if cue.trackTimestamp <= trackTimestamp
        cueToUse = cue
      else
        break
    return if cueToUse is null
    seconds = cueToUse.playerSeconds + (trackTimestamp - cueToUse.trackTimestamp) * 0.001

  secondsToTrackTimestamp: (seconds) ->
    cueToUse = null
    for cue in @cues
      if cue.playerSeconds <= seconds
        cueToUse = cue
      else
        break
    return if cueToUse is null
    trackTimestamp = cueToUse.trackTimestamp + (seconds - cueToUse.playerSeconds) * 1000
