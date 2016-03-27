perc_div = (event, $) ->
  offset = $.offset()
  relX = event.pageX - offset.left
  relY = event.pageY - offset.top

  percX = relX / $.width()
  percY = relY / $.height()
  return { percX, percY }


$ ->
  # Randomize order of lamps.
  # $('#lamps').randomize('.lamp')

  # Set dimensions.
  d = 200
  $('.lamp.wall').width(d).height d*2
  $('.lamp.desk').width(d).height d

  $('#lampimages').hide()

  # Opem / close lamp
  $('.lamp.3d').click (event) ->
    $lamp = $(@)
    if $lamp.hasClass 'open'
      console.log 'has class open'
      $('#lamps').animate width:'100%'
      $('#lampimages').hide()
      $lamp.removeClass 'open'
    else
      console.log 'does not have class open'
      $('.lamp.open').removeClass 'open'
      $lamp.addClass 'open'
      $('#lamps').animate width:'50%'
      $('#lampimages').show()

  $('.lamp.3d').each () ->
    $lamp = $(@)
    box_path = if $lamp.hasClass 'desk' then 'obj/box_desk' else 'obj/box_wall'
    base_path = "obj/#{$lamp.data('name')}"
    viewer = new ModelViewer $lamp, base_path, box_path, (() ->)

    $lamp.mousemove ( event ) ->
      { percX, percY } = perc_div event, $lamp
      viewer.rotation.y = (percX)* Math.PI
      viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)

    $lamp.mouseenter ( event ) ->
      $lamp.css 'z-index': 999

    # $lamp.mouseout (event) ->
    $(document).scroll () ->
      $lamp.css 'z-index': 0
      { percX, percY } = perc_div event, $lamp
      viewer.default_rotation.y = if percX > .5 then Math.PI else 0
      viewer.reset()

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
