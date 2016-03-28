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
  $('#lamps').animate width:'50%'
  $('.lamp.3d').not($lamp).animate 'opacity': 0

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
    .animate(width:'50%')

closeLamp = ($lamp) ->
  $('#lamps').animate width:'100%'
  $('#lampimages')
    .animate(width:'0%')


  $(document.body).css 'overflow': ''
  $('.lamp.3d').not($lamp).animate 'opacity': 100
  $lamp.removeClass 'open'

modelViewers = []

$ ->
  d = 300  # Set dimensions.

  # Open / close lamp
  $('.lamp.3d').click (event) ->
    $('.lamp.3d').each () ->
      viewer = $(@).data 'viewer'
      viewer.reset() unless viewer.animating
    if $(@).hasClass 'open'
      closeLamp $(@)
    else
      openLamp $(@)


  $(document).scroll () ->
    for viewer in modelViewers
      viewer.reset() if viewer.loaded and not viewer.animating

  $('.lamp.3d').each () ->
    $lamp = $(@)
    $lamp.width d

    if $lamp.hasClass 'wall'
      box_path = 'obj/box_wall.obj'
      $lamp.height d*1.2
    else
      box_path = 'obj/box_desk.obj'
      $lamp.height d/2

    base_path = $lamp.data 'obj'
    viewer = new ModelViewer $lamp, base_path, box_path
    modelViewers.push viewer
    $lamp.data 'viewer', viewer

    $lamp.mousemove (event) ->
      { percX, percY } = perc_div event, $lamp
      viewer.rotation.y = (percX)* Math.PI
      viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)
      viewer.default_rotation.y = if percX > .5 then Math.PI else 0

    $lamp.on 'touchmove', ( event ) ->
      { percX, percY } = perc_div event.originalEvent.touches[0], $lamp
      viewer.rotation.y = (percX)* Math.PI
      viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)
      viewer.default_rotation.y = if percX > .5 then Math.PI else 0
      event.preventDefault()
      event.stopPropagation()

  animateAll = () ->
    for viewer in modelViewers
      viewer.animate() if viewer.loaded
    requestAnimationFrame animateAll
    TWEEN.update()

  animateAll()
  # requestAnimationFrame animateAll
    # $(document).scroll () ->


  # $(document).click (event) ->
  #   if $('.lamp.open')
  #     $('.lamp.open').removeClass 'open'
  #     $('.lamp').show()
  #     $('.lamp').children().trigger 'mouseout'

  #     $( 'img.lamp' ).hide()
  #     # $('#lamps').packery()
  #     # $('#information').hide()
  #     event.preventDefault()

  $('.buy').click (event) ->
    alert('You bought a lamp!')
    event.stopPropagation()
