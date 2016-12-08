lastMouse = {x:0, y:0}

perc_div = (event, $) ->
  offset = $.offset()
  relX = event.pageX - offset.left
  relY = event.pageY - offset.top

  percX = relX / $.width()
  percY = relY / $.height()
  return { percX, percY }


bindMouseMoveRotate = ($frames) ->
  return
  $frames.mousemove (event) ->
    id = $(@).data().id
    object = objects[id]
    # Dont trigger mousemove if only page scrolled.
    if lastMouse.x == event.screenX and lastMouse.y == event.screenY
      return

    lastMouse.x = event.screenX
    lastMouse.y = event.screenY

    { percX, percY } = perc_div event, $(@)
    object.rotation.y = (percX)* Math.PI
    object.rotation.z = (((percY - 0.50)/4) * Math.PI)
    # obj.default_rotation.y = if percX > .5 then Math.PI else 0

bindScrollShow = () ->
  $lamps = $('.lamp.3d')
  margin = 0

  $('.scrollcontainer').scroll (event) ->
    $lamps.each () ->
      showLeft = $(@).offset().left + $(@).width() > margin
      showRight = $(@).offset().left < $(window).width() - margin

      if not(showLeft and showRight)
        # if $(@).hasClass 'active'
        $(@).removeClass 'active'
      else # is active
        if not ($(@).hasClass('active') and $(@).hasClass('viewer'))
          # viewer object on non active lamp
          source = $('.lamp.3d.viewer').not('.active').first()
          viewer = source.data('viewer')
          if viewer
            source.removeClass 'viewer'
            source.data('viewer', null)
            viewer.$parent = $(@)
            viewer.moveToParent()
            $(@).data('viewer', viewer)
            $(@).addClass 'viewer'

        $(@).addClass 'active'

bindResetOnScroll = ($lamps) ->
  # $('.scrollcontainer').scroll (event) ->
  #   $lamps.each () ->
  #     viewer = $(@).data 'viewer'
  #     viewer.reset() if viewer.loaded and not viewer.animating

  $lamps.mouseout () ->
    viewer = $(@).data 'viewer'
    viewer.reset() if viewer.loaded and not viewer.animating

class Lamp
  constructor: (@path, @type, @rx=0, @ry = 0, @rz = 0) ->
    # console.log @ry
    # @rx = rx
    # @ry = ry
    # @rz = rz

lamps = [
  new Lamp('lamps/desk_0/desk0.obj', 'desk', 0, -Math.PI/2),

  new Lamp('lamps/desk_1/desk1.obj', 'desk', 0, -Math.PI/2),
  new Lamp('lamps/desk_2/desk2.obj', 'desk', 0, -Math.PI/2),
  new Lamp('lamps/desk_3/desk3.obj', 'desk', 0, -Math.PI/2),
  new Lamp('lamps/desk_4/desk4.obj', 'desk', 0, -Math.PI/2),
  new Lamp('lamps/desk_5/desk5.obj', 'desk', 0, -Math.PI/2),

  new Lamp('lamps/wall_0/wall0.obj', 'wall', 0, 2*Math.PI),
  new Lamp('lamps/wall_1/wall1.obj', 'wall', 0, 2*Math.PI/2),
  new Lamp('lamps/wall_2/wall2.obj', 'wall', 0, 2*Math.PI/2),
  new Lamp('lamps/wall_3/wall3.obj', 'wall', 0, 2*Math.PI/2),
  new Lamp('lamps/wall_4/wall4.obj', 'wall', 0, 2*Math.PI/2),
  new Lamp('lamps/wall_5/wall5.obj', 'wall', 0, 2*Math.PI/2),

]

addLampPadding = (id) ->
  $frame = $('<div class="frame"></div>')
  $frame.append($('<div class="innerframe"></div>'))

  # $frame.append($('<div class="pics"></div>'))
  # $frame.append($('<div class="buy"></div>'))
  $frame.append($('<img class="pics" src="imgs/picture1.svg">'))
  # $frame.append($('<img class="buy" src="imgs/gift.svg">'))

  $frame.children('.innerframe').data 'id': id
  $('#framecontainer').append($frame)

main = () ->
  id = 0
  for lamp in lamps
    addLampPadding(id)
    id += 1

  $("#framecontainer").mousewheel (event, delta) ->
    $(@).scrollLeft @scrollLeft - delta
    # $('#scrollcontainer').scrollTop $('#framecontainer').scrollLeft()
  #    $('#framecontainer')[0].scrollLeft -= delta
    # console.log event
    # $('#scrollcontainer').trigger 'mousewheel', event

  # Connect vertical scrolling of page to horizontal scrolling of frames.
  # $('#scrollcontainer').scroll (event) ->
  #   $('#framecontainer').scrollLeft $('#scrollcontainer').scrollTop()

  # Frame container has a padding at beginning and end.
  $('#framecontainer').append $('<div class="framepadding">')

  # $('.innerframe').mousemove (event) ->
  #   tumble $(@).data().i, even

  $('.framepadding').width $(window).width()/2 - 300

  init(lamps)
  animate()

  bindMouseMoveRotate $('.innerframe')

  # bindScrollRotate()
  # bindScrollShow()
  # bindScrollSnap()
  # bindResize()
  # center $lamps.first()

    # $lamp.on 'touchmove', ( event ) ->
    #   { percX, percY } = perc_div event.originalEvent.touches[0], $lamp
    #   viewer.rotation.y = (percX)* Math.PI
    #   viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)
    #   viewer.default_rotation.y = if percX > .5 then Math.PI else 0
    #   event.preventDefault()
    #   event.stopPropagation()
