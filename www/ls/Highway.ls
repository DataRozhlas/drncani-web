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

  addLaneKm: (number, fromKm, toKm, options) ->
    offsetY = @kmToPx fromKm
    height = @kmToPx toKm - fromKm
    @addLane number, height, offsetY, options

  addLane: (number, height = @height, offsetY = 0, options = {}) ->
    width = laneWidth
    offsetX = Math.round @getOffset number
    @ctx
      ..beginPath!
      ..fillStyle = colors.light
      ..rect offsetX, offsetY, laneWidth, height
      ..fill!
    for sideColor, index in [40 to 90 by 10]
      x1 = offsetX + index * 2
      x2 = Math.round offsetX + width - index * 2
      @ctx
        ..beginPath!
        ..fillStyle = "rgb(#sideColor, #sideColor, #sideColor)"
        ..rect x1, offsetY, 2, height
        ..rect x2 - 1, offsetY, 2, height
        ..fill!
    @ctx
      ..beginPath!
      ..fillStyle = \#fff
      ..globalAlpha = 0.1

    @sprinkle width * height / 10, offsetX, 0, width, height

    @ctx
      ..globalAlpha = 1

  addLaneEndKm: (number, km, dir, options) ->
    @addLaneEnd do
      number
      @kmToPx km
      dir
      options

  addLaneEnd: (number, offsetY, dir, options = {}) ->
    offsetX = @getOffset number
    startAngle = dir * Math.PI / 2
    endAngle = startAngle + Math.PI / 2
    @ctx.lineWidth = 4

    # @ctx
    #   ..fillStyle = \red #colors.light
    #   ..fillRect offsetX, offsetY, laneWidth * 0.7, laneWidth * 1.2
    offsetXDouble = if dir == 0
      offsetX - laneWidth
    else if dir == 1
      offsetX + 2 * laneWidth

    # offsetXDouble = offsetX# - laneWidth
    for sideColor, index in [40 to 90 by 10]
      radius = 2 * (laneWidth - index) - 1
      @ctx
        ..beginPath!
        ..strokeStyle = "rgb(#sideColor, #sideColor, #sideColor)"
        ..arc offsetXDouble, offsetY, radius, startAngle, endAngle
        ..stroke!
      radius2 = laneWidth + 2 + 2 * index
      @ctx
        ..beginPath!
        ..arc offsetXDouble, offsetY, radius2, startAngle, endAngle
        ..stroke!
    index++
    radius = 2 * (laneWidth - index) - 1
    # centerline
    @ctx
      ..strokeStyle = colors.light
      ..beginPath!
      ..arc offsetXDouble, offsetY, radius, startAngle, endAngle
      ..stroke!
    radius = laneWidth * 2 + 0.5
    if dir == 0
      offsetXDouble += 2
    @ctx
      ..lineWidth = 2
      ..strokeStyle = colors.laneFull
      ..beginPath!
      ..arc offsetXDouble, offsetY, radius, startAngle, endAngle
      ..stroke!
    if options.innerLane
      @ctx
        ..beginPath!
        ..arc offsetXDouble, offsetY, radius - 29, startAngle, endAngle
        ..stroke!

    @ctx
      ..fillStyle = \#fff
      ..globalAlpha = 0.1

    @sprinkle do
      ((laneWidth ^ 2) / 2)
      Math.round offsetX
      Math.round offsetY
      laneWidth
      laneWidth * 1.8
    @ctx.globalAlpha = 1

  sprinkle: (count, offsetX, offsetY, width, height) ->
    return
    count = Math.round count
    @ctx.beginPath!
    while count--
      x = offsetX + Math.round Math.random! * width
      y = offsetY + Math.round Math.random! * height
      @ctx.rect x, y, 1, 1
    @ctx.fill!

  addGrassKm: (number, fromKm, toKm) ->
    offsetY = @kmToPx fromKm
    height = @kmToPx toKm - fromKm
    @addGrass number, offsetY, height

  addGrass: (number, offsetY = 0, height = @height) ->
    width = laneWidth + 0.5
    offsetX = Math.round @getOffset number
    @ctx
      ..beginPath!
      ..fillStyle = colors.grass
      ..rect offsetX, offsetY, width, height
      ..fill!
    @ctx.beginPath!
    @ctx.fillStyle = colors.grassLight
    @sprinkle width * height / 20, offsetX, offsetY, width, height
    @ctx.fill!
    @ctx.beginPath!
    @ctx.fillStyle = colors.grassDark
    @sprinkle width * height / 20, offsetX, offsetY, width, height
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

  addDelimKm: (number, type, fromKm, toKm, suplementalYOffset = 0) ->
    offsetY = suplementalYOffset + @kmToPx fromKm
    height = (@kmToPx toKm) - offsetY
    @addDelim number, type, offsetY, height

  addDelim: (number, type, offsetY = 0, height = @height) ->
    width = 2
    offsetX = Math.round (@getOffset number)
    if type == "full"
      @addDelimFull width, height, offsetX, offsetY
    else if type == "dash"
      @addDelimDash width, height, offsetX, offsetY, 40, 20
    else if type == "dash-short"
      @addDelimDash width, height, offsetX, offsetY, 20, 10
    else if type == "dash-full"
      @addDelimDash width, height, offsetX, offsetY, 20, 10
      @addDelimFull width, height, offsetX + 3, 0

  addRamp: (number, ramp) ->
    offsetY = @kmToPx ramp.km
    offsetX = @getOffset number
    if number > 4
      offsetX -= 2
    width = laneWidth + 2
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
    delimOffset = 0
    if number < 4
      delimOffset += laneWidth - 1
    @addDelimDash 2, height, offsetX + 0.5 + delimOffset, offsetY + 7, 15, 7

  addGasStation: (number, ramp) ->
    offsetY = @kmToPx ramp.km
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

  kmToPx: (kilometer) ->
    kilometer * @pxPerKm

  addDelimFull: (width, height, offsetX, offsetY) ->
    @ctx
      ..beginPath!
      ..fillStyle = colors.laneFull
      ..rect offsetX, offsetY, width, height
      ..fill!

  addDelimDash: (width, height, offsetX, offsetY, dashHeight, dashFill) ->
    @ctx
      ..beginPath!
      ..fillStyle = colors.lane
    for innerOffsetY in [0 to height by dashHeight]
      @ctx.rect offsetX, offsetY + innerOffsetY, width, dashFill
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
    @ctx
      ..textAlign = "center"
      ..strokeStyle = "black"
      ..fillStyle = \#FFC711
      ..lineWidth = 1
      ..beginPath!
    for km in kms
      px = @kmToPx km
      @ctx
        ..rect 114, px - 10, 20, 12
    @ctx.fill!
    @ctx.stroke!
    for km in kms
      px = @kmToPx km
      @ctx
        # ..fillStyle = \yellow
        # ..fillRect 114, px - 10, 20, 12
        # ..strokeRect 114, px - 10, 20, 12
        ..fillStyle = \black
        ..fillText km, 124, px
