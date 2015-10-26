colors =
  lane: \#D4D4D4
  laneFull: \#C6C6C6
  light: \#626562
  dark: \#101010
  grass: \#25482B
  grassLight: \#3F582E
  grassDark: \#3D6047

laneWidth = 250 / 9
class ig.Highway
  (@ctx, @height, @kilometers) ->
    @pxPerKm = @height / @kilometers

  addLane: (number) ->
    width = laneWidth
    offset = Math.round @getOffset number
    height = @height
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

    @sprinkle width * height / 10, offset, 0, width, height

    @ctx
      ..fill!
      ..globalAlpha = 1

  sprinkle: (count, offsetX, offsetY, width, height) ->
    count = Math.round count
    while count--
      x = offsetX + Math.round Math.random! * width
      y = offsetY + Math.round Math.random! * height
      @ctx.rect x, y, 1, 1

  addGrass: (number) ->
    height = @height
    width = laneWidth
    offset = Math.round @getOffset number
    @ctx
      ..beginPath!
      ..fillStyle = colors.grass
      ..rect offset, 0, laneWidth, height
      ..fill!
    @ctx.beginPath!
    @ctx.fillStyle = colors.grassLight
    @sprinkle width * height / 20, offset, 0, width, height
    @ctx.fill!
    @ctx.beginPath!
    @ctx.fillStyle = colors.grassDark
    @sprinkle width * height / 20, offset, 0, width, height
    @ctx.fill!

  addGuardrail: (number) ->
    height = @height
    offset = Math.round @getOffset number + 0.5
    offset -= 0.5
    @ctx
      ..beginPath!
      ..strokeStyle = \#666
      ..moveTo offset - 2, 0
      ..lineTo offset - 2, height
      ..moveTo offset + 2, 0
      ..lineTo offset + 2, height
      ..stroke!
      ..beginPath!
      ..strokeStyle = \#999
      ..moveTo offset - 3, 0
      ..lineTo offset - 3, height
      ..moveTo offset + 3, 0
      ..lineTo offset + 3, height
      ..stroke!

  addDelim: (number, type) ->
    width = 2
    height = @height
    offset = (@getOffset number) - width * 0.5
    if type == "full"
      @addDelimFull width, height, offset
    else if type == "dash"
      @addDelimDash width, height, offset, 40, 20
    else if type == "dash-full"
      @addDelimDash width, height, offset , 20, 10
      @addDelimFull width, height, offset + 3

  addRamp: (number, ramp) ->
    offsetY = @getPixel ramp.km
    offsetX = @getOffset number
    width = laneWidth
    height = 80
    if ramp.shape in <[both on]>
      offsetY -= height / 2
    if ramp.shape != "both"
      height /= 2
    @ctx
      ..beginPath!
      ..fillStyle = \#000
      ..rect offsetX, offsetY, width, height
      ..fill!

  addGasStation: (number, ramp) ->
    offsetY = @getPixel ramp.km
    offsetX = @getOffset number
    width = laneWidth
    height = 40
    offsetY -= height / 2
    @ctx
      ..beginPath!
      ..fillStyle = \#000
      ..rect offsetX, offsetY, width, height
      ..fill!

  getOffset: (number) ->
    number * laneWidth

  getPixel: (kilometer) ->
    kilometer * @pxPerKm

  addDelimFull: (width, height, offset) ->
    @ctx
      ..beginPath!
      ..fillStyle = colors.laneFull
      ..rect offset, 0, width, height
      ..fill!

  addDelimDash: (width, height, offset, dashHeight, dashFill) ->
    @ctx
      ..beginPath!
      ..fillStyle = colors.lane
    for heightOffset in [0 to height by dashHeight]
      @ctx.rect offset, heightOffset, width, dashFill
    @ctx
      ..fill!

  addData: (data) ->
    scale = d3.scale.quantile!
      ..domain data.map (.diffR)
      ..range ['rgb(165,0,38)','rgb(215,48,39)','rgb(244,109,67)','rgb(253,174,97)','rgb(254,224,139)','rgb(255,255,191)','rgb(217,239,139)','rgb(166,217,106)','rgb(102,189,99)','rgb(26,152,80)','rgb(0,104,55)'].reverse!

    referenceIndex = 0
    xLeft = 70
    xRight = 60
    for datum, index in data
      topPx = index
      if datum.km == 193.5
        referenceIndex = index
        xRight = 170
        xLeft = 180
      if referenceIndex
        topPx = referenceIndex - (topPx - referenceIndex)
      topPx += 0.5

      colorL = scale datum.diffL
      colorR = scale datum.diffR
      @ctx
        ..strokeStyle = colorR
        ..beginPath!
        ..moveTo xRight, topPx
        ..lineTo xRight + 10, topPx
        ..stroke!
        ..strokeStyle = colorL
        ..beginPath!
        ..moveTo xLeft, topPx
        ..lineTo xLeft + 10, topPx
        ..stroke!

  drawKm: (kms) ->
    for km in kms
      px = @getPixel km
      @ctx
        ..strokeStyle = \black
        ..fillText km, 260, px
