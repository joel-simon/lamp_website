$ ->

  $('.lamp.wall').width(300).height(600)
  $('.lamp.desk').width(300).height 300

  $('#lamps').randomize('.lamp')

  $('#lamps').packery {
    itemSelector: '.lamp'
    gutter: 0
  }

  $( 'img.lamp' ).hide()
  # $('img').load () ->
  #   $('#lamps').packery()

  $('.lamp').each () ->
    if $(@).hasClass 'wall'
      initModel $(@), "obj/#{$(@).data('name')}", 'obj/box_wall'
    else if $(@).hasClass 'desk'
      initModel $(@), "obj/#{$(@).data('name')}", 'obj/box_desk'

  $('#information').hide()
  $(document).click (event) ->
    if $('.lamp.open')
      $('.lamp.open').removeClass 'open'
      $('.lamp').show()
      $('.lamp').children().trigger 'mouseout'

      $( 'img.lamp' ).hide()
      $('#lamps').packery()
      $('#information').hide()
      event.preventDefault()

  $('.buy').click (event) ->
    alert('You bought a lamp!')
    event.stopPropagation()
