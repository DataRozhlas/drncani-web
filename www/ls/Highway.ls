colors =
  light: \#626562
  dark: \#101010
laneWidth = 250 / 9
fullHeight = 800
class ig.Highway
  (@ctx) ->

  addLane: (number) ->
    width = laneWidth
    offset = Math.round number * laneWidth
    height = fullHeight
    @ctx
      ..beginPath!
      ..fillStyle = colors.light
      ..rect offset, 0, laneWidth, height
      ..fill!
    for sideColor, index in [40 to 90 by 10]
      x1 = offset + index * 2
      x2 = Math.round offset + width - index * 2
      @ctx
        ..beginPath!
        ..fillStyle = "rgb(#sideColor, #sideColor, #sideColor)"
        ..rect x1, 0, 2, height
        ..rect x2 - 1, 0, 2, height
        ..fill!
    @ctx
      ..beginPath!
      ..fillStyle = \#fff
      ..globalAlpha = 0.12
    for i in [0 to width * height / 10]
      x = offset + Math.round Math.random! * width
      y = Math.round Math.random! * height
      @ctx.rect x, y, 1, 1
    @ctx
      ..fill!
      ..globalAlpha = 1

  addDelim: (number, type) ->
    width = 2
    height = fullHeight
    offset = number * laneWidth - width * 0.5
    if type == "full"
      @addDelimFull width, height, offset
    else if type == "dash"
      @addDelimDash width, height, offset, 40, 20
    else if type == "dash-full"
      @addDelimDash width, height, offset , 20, 10
      @addDelimFull width, height, offset + 3

  addDelimFull: (width, height, offset) ->
    @ctx
      ..beginPath!
      ..globalAlpha = 0.8
      ..fillStyle = \white
      ..rect offset, 0, width, height
      ..fill!

  addDelimDash: (width, height, offset, dashHeight, dashFill) ->
    @ctx
      ..beginPath!
      ..globalAlpha = 0.8
      ..fillStyle = \white
    for heightOffset in [0 to height by dashHeight]
      @ctx.rect offset, heightOffset, width, dashFill
    @ctx
      ..fill!
      ..globalAlpha = 1

