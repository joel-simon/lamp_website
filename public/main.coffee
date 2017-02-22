$ ->
    $('.nav_ui').click () ->
        i = Number($(@).data('i'))
        make_active($(@).parent())
        move_scroll_to(i)

    on_resize()
    $(window).resize(on_resize)
    on_scroll()
    $('#scroll_container').scroll(on_scroll)


on_scroll = () ->
    $td = $('.nav_menu').find('td')
    $('.lamp_container').each (i) ->
        if percent_of_screen($(@)) >= .5
            make_active($td.eq(i))

percent_of_screen = ($lamp_container) ->
    scroll = $('#scroll_container').scrollLeft()
    w_width = $(window).width()
    screen_left = $lamp_container.position().left
    screen_right = screen_left + $lamp_container.first().width()

    left = if screen_left < 0 then 0 else screen_left
    right = if screen_right < w_width then screen_right else w_width

    return Math.min((right - left) / w_width, 1)

make_active = ($td) ->
    $('.active').removeClass 'active'
    $td.addClass 'active'

move_scroll_to = (i) ->
    $lamp_container = $('.lamp_container').eq(i)
    scroll_amount = $('#scroll_container').scrollLeft()
    $('#scroll_container').scrollLeft(scroll_amount + $lamp_container.offset().left)

on_resize = () ->
    h = $(window).width()
    $nav = $('.nav_container')
    $nav.css('left', h/2 - $nav.width()/2)
