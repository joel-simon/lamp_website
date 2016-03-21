perc_div = (event, $) ->
  offset = $.offset()
  relX = event.pageX - offset.left
  relY = event.pageY - offset.top

  percX = relX / $.width()
  percY = relY / $.height()
  return { percX, percY }

$ ->
  # Randomize order of lamps.
  $('#lamps').randomize('.lamp')

  # Set dimensions.
  $('.lamp.wall').width(300).height 600
  $('.lamp.desk').width(300).height 300
  
  # Create packery instance.
  $('#lamps').packery
    itemSelector: '.lamp'
    gutter: 0

  $('.lamp').each () ->
    $lamp = $(@)
    box_path = if $lamp.hasClass 'desk' then 'obj/box_desk' else 'obj/box_wall'
    base_path = "obj/#{$lamp.data('name')}"
    viewer = new ModelViewer $lamp, base_path, box_path, (() ->)

    $lamp.mousemove ( event ) ->
      { percX, percY } = perc_div event, $lamp
      viewer.rotation.y = (percX)* Math.PI
      viewer.rotation.z = (((percY - 0.50)/4) * Math.PI)

    $lamp.mouseenter ( event ) ->
      # showBox()
      $lamp.css
        'z-index': 999
        # 'border-style': 'none'

    $lamp.mouseout (event) ->
      # hideBox() unless $parent.hasClass 'open'
      $lamp.css
        'z-index': 0
      
      { percX, percY } = perc_div event, $lamp
      viewer.default_rotation.y = if percX > .5 then Math.PI else 0
      viewer.reset()


    $lamp.click (event) ->
      console.log
      return if $('.lamp.open').length
      # $lamp.width '50%'
      # $lamp.height '100%'
      $lamp.addClass 'open'
      $('.lamp').not($lamp).hide()
      $('#lamps').packery()
      $('#information').show()
      # showBox()
      event.stopPropagation()

  $('#information').hide()
  $(document).click (event) ->
    if $('.lamp.open')
      $('.lamp.open').removeClass 'open'
      $('.lamp').show()
      $('.lamp').children().trigger 'mouseout'
      $('#lamps').packery()

      $('#information').hide()
      event.preventDefault()

  $('.buy').click (event) ->
    alert('You bought a lamp!')
    event.stopPropagation()
