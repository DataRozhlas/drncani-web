colors =
  lane: \#D4D4D4
  laneFull: \#C6C6C6
  light: \#888
  dark: \#505050
  verydark: \#282828
  grass: \#25482B
  grassLight: \#3F582E
  grassDark: \#3D6047
  river: \#234773
  bridge: \#bbb

laneWidth = 250 / 9


class ig.Highway
  (@ctx, @height, @kilometers, @heightHeader) ->
    @pxPerKm = (@height - 2 * @heightHeader) / @kilometers

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
    for sideColor, index in [80 to 130 by 10]
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

    offsetXDouble = if dir == 0 or dir == 3
      offsetX - laneWidth
    else
      offsetX + 2 * laneWidth
    if dir == 2
      offsetXDouble += 2

    for sideColor, index in [80 to 130 by 10]
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
    if options.outerLane
      @ctx
        ..beginPath!
        ..arc do
          offsetXDouble
          offsetY
          radius
          if options.outerLane is \partial then startAngle + 0.28 else startAngle
          if options.outerLane is \partial-2 then endAngle - 0.28 else endAngle
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

  addBridgeKm: (fromKm, toKm, options) ->
    offsetY = @kmToPx fromKm
    height = @kmToPx toKm - fromKm
    @addBridge offsetY, height, options

  addBridge: (offsetY = 0, height = @height, options) ->
    if options?withRiver
      width = 250
      @ctx
        ..beginPath!
        ..fillStyle = colors.river
        ..rect 0, offsetY + (height - options.withRiver) / 2, width, options.withRiver
        ..fill!
    width = laneWidth * 5
    offsetX = @getOffset 2
    @ctx
      ..beginPath!
      ..fillStyle = colors.bridge
      ..rect offsetX - 4, offsetY, width + 9, height
      ..fill!

  addBridgeFinishKm: (fromKm, toKm) ->
    offsetY = @kmToPx fromKm
    height = @kmToPx toKm - fromKm
    @addBridgeFinish offsetY, height

  addBridgeFinish: (offsetY = 0, height = @height) ->
    start = @getOffset 2
    start2 = @getOffset 5
    @ctx
      ..beginPath!
      ..globalAlpha = 0.4
      ..fillStyle = \black
      ..rect start, offsetY, laneWidth * 2, height
      ..rect start2, offsetY, laneWidth * 2, height
      ..fill!
      ..globalAlpha = 1


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

  prepareRamp: (number, ramp) ->
    {centerY, offsetX, offsetY, width, height} = @calculateRamp number, ramp

    textX = if number > 4 then 245 else 5
    @ctx
      ..save!
      ..translate textX, centerY
      ..rotate if number > 4 then Math.PI / 2 * 3 else Math.PI / 2
      ..font = "bold 30px arial"
      ..textAlign = "center"
      ..strokeStyle = \black
      ..fillStyle = \#777
      ..fillText ramp.name.toUpperCase!, 0, 0
      ..restore!

    secondLane = if number > 4 then laneWidth else laneWidth * -1

    @ctx
      ..fillStyle = colors.verydark
      ..beginPath!
      ..rect offsetX, offsetY, width, height
      ..rect offsetX + secondLane, offsetY + 15, width, height - 30
      ..fill!

    delimOffset = 0
    if number < 4
      delimOffset += laneWidth
    else
      delimOffset += 2

    if number > 4
      @ctx
        ..strokeStyle = colors.laneFull
        ..beginPath!
      @ctx
        ..moveTo offsetX, centerY
        ..lineTo offsetX + laneWidth + 12, centerY
      if ramp.km > 20
        for i in [10 to 46 by 8]
          @ctx
            ..lineWidth = 2
            ..moveTo offsetX + laneWidth, centerY - i
            ..lineTo offsetX - i, centerY
            ..moveTo offsetX + laneWidth, centerY + i
            ..lineTo offsetX - i, centerY
        @ctx.stroke!

      @addLaneEnd number, offsetY + height + laneWidth / 2, 0, outerLane: yes
      @addLaneEnd number, offsetY + height + laneWidth / 2, 2, innerLane: true, outerLane: \partial-2
      @addLaneEnd number, offsetY - laneWidth / 2, 1, innerLane: true, outerLane: \partial
      @addLaneEnd number, offsetY - laneWidth / 2, 3, outerLane: yes
    else
      @ctx
        ..strokeStyle = colors.laneFull
        ..beginPath!
      @ctx
        ..moveTo offsetX - 12, centerY
        ..lineTo offsetX + laneWidth, centerY
      if ramp.km > 20
        for i in [10 to 46 by 8]
          @ctx
            ..moveTo offsetX, centerY - i
            ..lineTo offsetX + laneWidth + i, centerY
            ..moveTo offsetX, centerY + i
            ..lineTo offsetX + laneWidth + i, centerY
        @ctx.stroke!
      @addLaneEnd number, offsetY + height + laneWidth / 2, 1, outerLane: yes
      @addLaneEnd number, offsetY + height + laneWidth / 2, 3, innerLane: true, outerLane: \partial
      @addLaneEnd number, offsetY - laneWidth / 2, 0, innerLane: true, outerLane: \partial-2
      @addLaneEnd number, offsetY - laneWidth / 2, 2, outerLane: yes


  finishRamp: (number, ramp) ->
    {centerY, offsetX, offsetY, width, height} = @calculateRamp number, ramp

    offsetX = @getOffset do
      if number > 4 then number else number + 1
    offsetX = Math.round offsetX
    height = 55
    @ctx
      ..beginPath!
      ..fillStyle = colors.dark
      ..rect offsetX, offsetY - 61, 3, height
      ..rect offsetX, offsetY + 87, 3, height
      ..fill!

    @addDelimDash 2, height, offsetX, offsetY - 61 + 6, 16, 8
    @addDelimDash 2, height, offsetX, offsetY + 87 + 6, 16, 8

    textX = if number > 4 then 245 else 5
    @ctx
      ..save!
      ..translate textX, centerY
      ..rotate if number > 4 then Math.PI / 2 * 3 else Math.PI / 2
      ..font = "bold 30px arial"
      ..textAlign = "center"
      ..strokeStyle = \black
      ..globalAlpha = 1
      # ..strokeText ramp.name.toUpperCase!, 0, 0
      ..globalAlpha = 0.6
      ..fillStyle = \white
      ..fillText ramp.name.toUpperCase!, 0, 0
      ..restore!

  calculateRamp: (number, ramp) ->
    centerY = offsetY = @kmToPx ramp.km
    offsetX = Math.round @getOffset number
    if number > 4
      offsetX -= 2
    width = laneWidth + 2
    height = 80
    if ramp.shape in <[both on]>
      offsetY -= height / 2
    if ramp.shape != "both"
      height /= 2
    {centerY, offsetX, offsetY, width, height}

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
    if kilometer
      @heightHeader + kilometer * @pxPerKm
    else
      0

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
    @scale = scale = d3.scale.quantile!
      ..domain data.map (.diffR)
      ..range ['rgb(165,0,38)','rgb(215,48,39)','rgb(244,109,67)','rgb(253,174,97)','rgb(254,224,139)','rgb(255,255,191)','rgb(217,239,139)','rgb(166,217,106)','rgb(102,189,99)','rgb(26,152,80)','rgb(0,104,55)'].reverse!
    # return
    referenceIndex = 0
    xLeft = 70
    xRight = 60
    for datum, index in data
      topPx = index + @heightHeader
      if datum.km == 193.5
        referenceIndex = index + @heightHeader
        xRight = 180
        xLeft = 170
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
      ..strokeStyle = "black"
      ..fillStyle = \#FFC711
      ..lineWidth = 1
      ..beginPath!
    for km in kms
      px = @kmToPx km
      @ctx
        ..rect 116, px - 10, 20, 12
    @ctx.fill!
    @ctx.stroke!
    @ctx
      ..textAlign = "center"
      ..font="10px arial"
      ..fillStyle = \black
    for km in kms
      px = @kmToPx km
      @ctx
        # ..fillStyle = \yellow
        # ..fillRect 114, px - 10, 20, 12
        # ..strokeRect 114, px - 10, 20, 12
        ..fillText km, 126, px
