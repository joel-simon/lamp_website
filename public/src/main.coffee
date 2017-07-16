window.hash_to_index = {}
window.index_to_hash = {}
window.images_loaded = false

bind_navigation = () ->
    # Allow navigation input.
    $('.nav_ui').click () ->
        i = Number($(@).data('i'))
        move_scroll_to(i)


$ ->
    is_mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)
    query = window.location.search

    bind_navigation()

    # Bind resize and scroll events.
    on_resize()
    $(window).resize(on_resize)
    on_scroll()
    $('#scroll_container').scroll(on_scroll)

    # history.pushState({'scrollLeft': 0}, "", "/")

    # Create hashes from lamp names.
    $('.lamp_container').each (i) ->
        name = $(@).data('name')
        path = $(@).data('path')
        # path = '/'     + path
        hash_to_index[path] = i
        index_to_hash[i] = path

    # $('.lamp_container').each (i) ->
    #     $(@).find('a.lamp_name').on 'click touch', () ->
    #         open_lamp_container(i)

    # $(window).on 'popstate', (e) ->
    #     lamp_idx = e.originalEvent?.state?.lamp_idx
    #     if lamp_idx?
    #         open_lamp_container(lamp_idx)

    #     old_scroll = e.originalEvent.state?.scrollLeft
    #     if old_scroll?
    #         $('.lamp_container').show()
    #         $('#scroll_container').scrollLeft(old_scroll)
    #         $('.nav_container').show()

    # Resize the window as images load.
    $('.lamp').load () ->
        on_resize()

    # Enable vertical mousewheel input on scroll_container
    unless is_mobile # Causes scroll stuttering on mobile.
        $('#scroll_container').mousewheel (event, delta) ->
            if Math.abs(event.deltaY) > Math.abs(event.deltaX)
                $(@).scrollLeft (@scrollLeft - delta)

    # When all images have loaded.
    $(window).on "load", () ->
        window.images_loaded = true
    #     on_resize()
    #     hash = document.location.pathname
    #     if hash_to_index[hash]?
    #         # open_lamp_container(hash_to_index[hash])
    #         move_scroll_to(hash_to_index[hash])
    #     else
    #         console.log 'no hash', document.location.hash
    #         document.location.hash = ''

    # Click header to go to front.
    $('#header h1').on 'click touch', () ->
        if window.location.pathname == '/'
            $('#scroll_container').scrollLeft(0)
        else
            window.location.pathname = '/'

    regex = new RegExp("(lamp=)([^&#]*)")
    if regex.test(query)
        results = regex.exec(query)
        idx = +results[2]
        if Number.isInteger(idx)
            open_lamp_container(idx)
        else
            throw 'Invalid lamp query' + results

    """ Image viewer.
    """
    $imgs = $('img.lamp')

    # Click image to make fullscreen.
    current_open_image = null
    $('img.lamp').click () ->
        current_open_image = $imgs.index($(@))
        open_image($(@))

    # Click again to hide.
    $('#image_wrapper').click () -> $(@).hide()

    $(document).keyup (e) ->
        ### Use escape to exit image view.
        ###
        escape_key = 27
        $('#image_wrapper').hide() if e.keyCode == escape_key

        if $('#image_wrapper').is(":visible")

            ### Use arrows to move images.
            ###

            if e.keyCode == 37 #Left
                current_open_image -= 1
                current_open_image = Math.max(current_open_image, 0)

            else if e.keyCode == 39 #Right
                current_open_image += 1
                current_open_image = Math.min(current_open_image, $imgs.length)

            open_image($('img.lamp').eq(current_open_image))

    # Arrows keys should rotate through images when image view is open,
    # prevent moving scroll as well.
    $(document).keydown (e) ->
        if $('#image_wrapper').is(":visible")
            e.preventDefault()

open_image = ($img) ->
    $('#image_wrapper img').attr 'src', $img.attr('src')
    $('#image_wrapper img').load () ->
        $('#image_wrapper').show()
    if $img.width() > $img.height()
        $('#image_wrapper img').removeClass('tall').addClass('wide')
    else
        $('#image_wrapper img').removeClass('wide').addClass('tall')


open_lamp_container = (i) ->
    $lamp_container = $('.lamp_container').eq(i)
    name = $lamp_container.data('name')

    # Switch header and lamp name.
    # $('#footer').append($lamp_container.find('a.lamp_name'))

    stateData = { 'scrollLeft': $('#scroll_container').scrollLeft()}
    window.history.replaceState(stateData, '', '/')
    history.pushState({'lamp_idx': i},  null, name_to_path(name))

    $('.lamp_container').not($lamp_container).hide()
    $('#scroll_container').scrollLeft(0)
    $('.nav_container').hide()

# close_lamp_container = (scroll_position) ->

# name_to_path = (name) ->
#     name.replace(/\ /gi, "_").replace(/#/gi,"").toLowerCase()

on_scroll = () ->
    return unless window.images_loaded

    make_active = (i) ->
        console.log i, index_to_hash[i]
        $td = $('.nav_menu').find('td').eq(i)
        window.location.hash = index_to_hash[i]
        $('.active').removeClass 'active'
        $td.addClass('active')

    make_active(most_visible_container())

most_visible_container = ( ) ->
    largest_percent = 0
    largest_container = null

    $('.lamp_container').each (i) ->
        pos = percent_of_screen($(@))
        if pos >= largest_percent or largest_container == null
            largest_container = i
            largest_percent = pos

    largest_container

percent_of_screen = ($lamp_container) ->
    scroll = $('#scroll_container').scrollLeft()
    w_width = $(window).width()
    screen_left = $lamp_container.position().left
    screen_right = screen_left + $lamp_container.first().width()

    left = if screen_left < 0 then 0 else screen_left
    right = if screen_right < w_width then screen_right else w_width

    return Math.min((right - left) / w_width, 1)

move_scroll_to = (i) ->
    $lamp_container = $('.lamp_container').eq(i)
    scroll_amount = $('#scroll_container').scrollLeft()

    x = $lamp_container.offset().left - parseInt($lamp_container.css('margin-left'))
    $('#scroll_container').scrollLeft(scroll_amount + x)

on_resize = () ->
    window_height = window.innerHeight
    # window_width =
    lamp_container_height_percent = .6
    # footer_height = '20vh'

    $('.lamp_container').each (i) ->
        ### Vertically center each lamp_container element.
        ###
        container_height = $(@).height()
        scroll_top = $('#scroll_container').position().top
        margin_top = ((window_height - container_height) / 2) - scroll_top
        $(@).css 'margin-top', margin_top

        ### The element is transalted by 0 degrees - so .width() is screen height.
        ###
        name = $(@).find('a.lamp_name.vertical-text')
        name.css 'margin-top', (container_height - name.width()) / 2

    ### Vertically center the header.
    ###
    $header = $('#header')
    header_height = $header.height()
    header_space  = window_height * ( 1 - lamp_container_height_percent) / 2
    $header.css('margin-top', Math.max((header_space - header_height) / 4), 0)

    ### Vertically center the footer.
    ###
    $footer = $('#footer')
    footer_height = $footer.height()
    footer_space  = window_height * ( 1 - lamp_container_height_percent) / 2
    $footer.css('bottom', (footer_space - footer_height) / 2)



