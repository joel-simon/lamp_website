perc_div = (event, $) ->
  offset = $.offset()
  relX = event.pageX - offset.left
  relY = event.pageY - offset.top

  percX = relX / $.width()
  percY = relY / $.height()
  return { percX, percY }

openLamp = ($lamp) ->
  name = $lamp.data 'name'

  $("img.lamp.#{name}").show()
  $('img.lamp').not(".#{name}").hide()

  $lamp.data('viewer').reset()
  $('.lamp.open').removeClass 'open'
  $lamp.addClass 'open'
  $('#lamps').animate width:'25%'

  # $('.lamp.3d').not($lamp).animate 'opacity': 20

  # $lamp.css width: $(document).width()/2
  # $lamp.css height: $(document).height()
  # $lamp.data('viewer').resize()
  # $lamp.data('viewer').setScale 14

  $(document.body).animate({
    scrollTop: $lamp.offset().top - ($(window).height()-$lamp.height())/2
  });

  $(document.body).css 'overflow': 'hidden'


  $('#lampimages')
    .scrollTop(0)
    .animate(width:'75%')

closeLamp = ($lamp) ->
  $('#lamps').animate width:'100%'
  $('#lampimages')
    .animate(width:'0%')


  $(document.body).css 'overflow': ''
  $('.lamp.3d').not($lamp).animate 'opacity': 100
  $lamp.removeClass 'open'


lastMouse = {x:0, y:0}

# createModelViewers = ($lamps) ->
#   modelViewers = []
#   $lamps.each () ->
#     $lamp = $(@)
#     if $lamp.hasClass 'wall'
#       box_path = 'obj/box_wall.obj'
#     else
#       box_path = 'obj/box_desk.obj'
#     base_path = "#{$lamp.data('path')}.obj"
#     mtl_path = "#{$lamp.data('path')}.mtl"
#     viewer = new ModelViewer $lamp, base_path, mtl_path, box_path
#     modelViewers.push viewer
#     $lamp.data 'viewer', viewer

#   return modelViewers

createModelViewers = ($parents) ->
  modelViewers = []

  $parents.addClass 'active'
  $parents.addClass 'viewer'

  $parents.each () ->
    viewer = new ModelViewer($(@))
    $(@).data 'viewer', viewer
    modelViewers.push viewer

  return modelViewers

# lampClick = (event) ->
bindTilt = ($lamps) ->
  averages = []
  if window.DeviceMotionEvent
    $(window).on 'devicemotion', (ev) ->
      acc = ev.originalEvent.accelerationIncludingGravity
      averages.push -acc.y* Math.PI / 180 * 4

      if averages.length > 10
        averages.shift()
        average = averages.reduce((a, b)-> a + b) / 10
        console.log average
        for viewer in modelViewers
          viewer.rotation.x = average
      viewer.rotation.y = -acc.x* Math.PI / 180 * 4

bindMouseMoveRotate = ($lamps) ->
  $lamps.mousemove (event) ->
    $lamp = $(@)
    viewer = $lamp.data 'viewer'
    # Dont trigger mousemove if only page scrolled.
    if lastMouse.x == event.screenX and lastMouse.y == event.screenY
      return
    lastMouse.x = event.screenX
    lastMouse.y = event.screenY

    { percX, percY } = perc_div event, $lamp
    viewer.rotation.y = (percX)* Math.PI
    viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)
    viewer.default_rotation.y = if percX > .5 then Math.PI else 0

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

          source.removeClass 'viewer'
          source.data('viewer', null)
          viewer.moveTo $(@)
          $(@).data('viewer', viewer)
          $(@).addClass 'viewer'

        $(@).addClass 'active'

bindScrollRotate = () ->
  $lamps = $('.lamp.3d')
  $('.scrollcontainer').scroll (event) ->
    $lamps.each () ->
      if $(@).hasClass 'viewer'
        $lamp = $(@)
        viewer = $lamp.data 'viewer'

        left = $lamp.offset().left + ($lamp.width()/2)

        percX = left / $(window).width()
        percX = Math.max(percX, 0)
        percX = Math.min(percX, 1)

        viewer.rotation.y = ((percX) * (Math.PI)) + (-90 * Math.PI / 180)

        viewer.rotation.z = (((percX - 0.50)/12) * Math.PI)

bindResize = ($lamps) ->
  # $lamps.css
  #   width
  $( window ).resize () ->
    $lamps.each () ->
    # if $(@).index() == 2
      $(@).data('viewer').resize()

bindResetOnScroll = ($lamps) ->
  # $('.scrollcontainer').scroll (event) ->
  #   $lamps.each () ->
  #     viewer = $(@).data 'viewer'
  #     viewer.reset() if viewer.loaded and not viewer.animating

  $lamps.mouseout () ->
    viewer = $(@).data 'viewer'
    viewer.reset() if viewer.loaded and not viewer.animating

scrollTimer = null
bindScrollSnap = () ->
  scrollEnd = () ->
    min_lamp = null
    min_d = 9999
    center_x = $(window).width()/2
    $('.lamp').each () ->
      x = $(@).offset().left + $(@).width()/2
      d = Math.abs(center_x - x)
      if d < min_d
        min_d = d
        min_lamp = $(@)
    center min_lamp

  $('.scrollcontainer').scroll (event) ->
    clearTimeout scrollTimer
    scrollTimer = setTimeout(scrollEnd, 50)

center = ($lamp) ->
  lamp_center = $lamp.offset().left + $lamp.width()/2
  window_center = $(window).width()/2
  scroll = $('.scrollcontainer').scrollLeft()
  $('.scrollcontainer').animate({
    scrollLeft: scroll + lamp_center - window_center
  }, 200, 'swing')

$ ->
  # $("body").mousewheel (event, delta) ->
  #   $('.scrollcontainer')[0].scrollLeft -= delta
  #   event.preventDefault()


  $('.lamp.3d.wall').remove()

  $lamps = $('.lamp.3d')
  modelViewers = createModelViewers $lamps.slice(0,3)

  bindScrollRotate()
  bindScrollShow()
  bindScrollSnap()
  # bindResize $lamps
  center $lamps.first()
  # $('.scrollcontainer').trigger('scroll')

  # $lamps.click (event) ->
  #   $lamps.each () ->
  #     viewer = $(@).data 'viewer'
  #     viewer.reset() unless viewer.animating
  #   if $(@).hasClass 'open'
  #     closeLamp $(@)
  #   else
  #     openLamp $(@)

  # bindResetOnScroll $lamps

  # if $(window).width() < 1000
  # if true
    # bindTilt($lamps)
  # bindMouseMoveRotate $lamps

    # $lamp.on 'touchmove', ( event ) ->
    #   { percX, percY } = perc_div event.originalEvent.touches[0], $lamp
    #   viewer.rotation.y = (percX)* Math.PI
    #   viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)
    #   viewer.default_rotation.y = if percX > .5 then Math.PI else 0
    #   event.preventDefault()
    #   event.stopPropagation()

  animateAll = () ->
    for viewer in modelViewers
      viewer.animate() if viewer.loaded
    requestAnimationFrame animateAll
    TWEEN.update()

  animateAll()
