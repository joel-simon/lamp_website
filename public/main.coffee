window.hash_to_index = {}
window.index_to_hash = {}
window.images_loaded = false

$ ->
    is_mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)

    # Allow navigation input.
    $('.nav_ui').click () ->
        i = Number($(@).data('i'))
        move_scroll_to(i)

    # Bind resize and scroll events.
    on_resize()
    $(window).resize(on_resize)
    on_scroll()
    $('#scroll_container').scroll(on_scroll)

    # Create hashes from lamp names.
    $('.lamp_container').each (i) ->
        name = $(@).find('a.lamp_name').text()
        hash = '#'+name.replace(/\ /gi, "_").replace(/#/gi,"").toLowerCase()
        hash_to_index[hash] = i
        index_to_hash[i] = hash

    # Resize the window as images load.
    $('img').load () ->
        on_resize()

    # Enable vertical mousewheel input on scroll_container/
    $('#scroll_container').mousewheel (event, delta) ->
        $(@).scrollLeft (@scrollLeft - delta)

    # When all images have loaded.
    $(window).on "load", () ->
        window.images_loaded = true
        on_resize()
        hash = document.location.hash
        if hash_to_index[hash]?
            move_scroll_to(hash_to_index[hash])
        else
            console.log 'no hash', document.location.hash
            document.location.hash = ''

on_scroll = () ->
    return unless window.images_loaded

    make_active = (i) ->
        console.log i, index_to_hash[i]
        $td = $('.nav_menu').find('td').eq(i)
        window.location.hash = index_to_hash[i]
        $('.active').removeClass 'active'
        $td.addClass('active')

    $('.lamp_container').each (i) ->
        if percent_of_screen($(@)) >= .5
            make_active(i)

percent_of_screen = ($lamp_container) ->
    scroll = $('#scroll_container').scrollLeft()
    w_width = $(window).width()
    screen_left = $lamp_container.position().left
    screen_right = screen_left + $lamp_container.first().width()

    left = if screen_left < 0 then 0 else screen_left
    right = if screen_right < w_width then screen_right else w_width

    return Math.min((right - left) / w_width, 1)

move_scroll_to = (i) ->
    console.log 'move_scroll_to', i
    $lamp_container = $('.lamp_container').eq(i)
    scroll_amount = $('#scroll_container').scrollLeft()
    $('#scroll_container').scrollLeft(scroll_amount + $lamp_container.offset().left)

on_resize = () ->
    $('.lamp_container').each (i) ->
        height = $(@).height()
        margin_top = ($(window).height() - height) / 2
        $(@).css 'margin-top', margin_top

        name = $(@).find('a.lamp_name.vertical-text')
        # The element is transalted by 0 degrees - so .width() is screen height.
        name.css 'margin-top', (height - name.width()) / 2

