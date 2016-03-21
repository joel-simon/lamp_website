$ ->

  $('.lamp.wall').width(300).height(600)
  $('.lamp.desk').width(300).height 300

  # console.log $('#lamps')
  $('#lamps').randomize('.lamp')
  # console.log $('#lamps')

  $('#lamps').packery {
    itemSelector: '.lamp'
    gutter: 0
    # columnWidth: 100
    # containerStyle: {
    #   top: 60
    # }
  }
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
      $('#lamps').packery()

      $('#information').hide()
      event.preventDefault()

  $('.buy').click (event) ->
    alert('You bought a lamp!')
    event.stopPropagation()
