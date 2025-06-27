var bind_navigation, most_visible_container, move_scroll_to, on_resize, on_scroll, open_image, open_lamp_container, percent_of_screen;

window.hash_to_index = {};

window.index_to_hash = {};

window.images_loaded = false;

bind_navigation = function() {
  // Allow navigation input.
  return $('.nav_ui').click(function() {
    var i;
    i = Number($(this).data('i'));
    return move_scroll_to(i);
  });
};

$(function() {
  var $imgs, current_open_image, idx, is_mobile, query, regex, results;
  is_mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent);
  query = window.location.search;
  bind_navigation();
  // Bind resize and scroll events.
  on_resize();
  $(window).resize(on_resize);
  on_scroll();
  $('#scroll_container').scroll(on_scroll);
  // history.pushState({'scrollLeft': 0}, "", "/")

  // Create hashes from lamp names.
  $('.lamp_container').each(function(i) {
    var name, path;
    name = $(this).data('name');
    path = $(this).data('path');
    // path = '/'     + path
    hash_to_index[path] = i;
    return index_to_hash[i] = path;
  });
  // $('.lamp_container').each (i) ->
  //     $(@).find('a.lamp_name').on 'click touch', () ->
  //         open_lamp_container(i)

  // $(window).on 'popstate', (e) ->
  //     lamp_idx = e.originalEvent?.state?.lamp_idx
  //     if lamp_idx?
  //         open_lamp_container(lamp_idx)

  //     old_scroll = e.originalEvent.state?.scrollLeft
  //     if old_scroll?
  //         $('.lamp_container').show()
  //         $('#scroll_container').scrollLeft(old_scroll)
  //         $('.nav_container').show()

  // Resize the window as images load.
  $('.lamp').load(function() {
    console.log('load');
    return on_resize();
  });
  // Enable vertical mousewheel input on scroll_container
  if (!is_mobile) { // Causes scroll stuttering on mobile.
    $('#scroll_container').mousewheel(function(event, delta) {
      if (Math.abs(event.deltaY) > Math.abs(event.deltaX)) {
        return $(this).scrollLeft(this.scrollLeft - delta);
      }
    });
  }
  // When all images have loaded.
  $(window).on("load", function() {
    return window.images_loaded = true;
  });
  //     on_resize()
  //     hash = document.location.pathname
  //     if hash_to_index[hash]?
  //         # open_lamp_container(hash_to_index[hash])
  //         move_scroll_to(hash_to_index[hash])
  //     else
  //         console.log 'no hash', document.location.hash
  //         document.location.hash = ''

  // Click header to go to front.
  $('#header h1').on('click touch', function() {
    if (window.location.pathname === '/') {
      return $('#scroll_container').scrollLeft(0);
    } else {
      return window.location.pathname = '/';
    }
  });
  regex = new RegExp("(lamp=)([^&#]*)");
  if (regex.test(query)) {
    results = regex.exec(query);
    idx = +results[2];
    if (Number.isInteger(idx)) {
      open_lamp_container(idx);
    } else {
      throw 'Invalid lamp query' + results;
    }
  }
  ` Image viewer.`;
  $imgs = $('img.lamp');
  // Click image to make fullscreen.
  current_open_image = null;
  $('img.lamp').click(function() {
    current_open_image = $imgs.index($(this));
    return open_image($(this));
  });
  // Click again to hide.
  $('#image_wrapper').click(function() {
    return $(this).hide();
  });
  $(document).keyup(function(e) {
    /* Use escape to exit image view.
           */
    var escape_key;
    escape_key = 27;
    if (e.keyCode === escape_key) {
      $('#image_wrapper').hide();
    }
    if ($('#image_wrapper').is(":visible")) {
      /* Use arrows to move images.
                 */
      if (e.keyCode === 37) { //Left
        current_open_image -= 1;
        current_open_image = Math.max(current_open_image, 0);
      } else if (e.keyCode === 39) { //Right
        current_open_image += 1;
        current_open_image = Math.min(current_open_image, $imgs.length);
      }
      return open_image($('img.lamp').eq(current_open_image));
    }
  });
  // Arrows keys should rotate through images when image view is open,
  // prevent moving scroll as well.
  return $(document).keydown(function(e) {
    if ($('#image_wrapper').is(":visible")) {
      return e.preventDefault();
    }
  });
});

open_image = function($img) {
  $('#image_wrapper img').attr('src', $img.attr('src'));
  $('#image_wrapper img').load(function() {
    return $('#image_wrapper').show();
  });
  if ($img.width() > $img.height()) {
    return $('#image_wrapper img').removeClass('tall').addClass('wide');
  } else {
    return $('#image_wrapper img').removeClass('wide').addClass('tall');
  }
};

open_lamp_container = function(i) {
  var $lamp_container, name, stateData;
  $lamp_container = $('.lamp_container').eq(i);
  name = $lamp_container.data('name');
  // Switch header and lamp name.
  // $('#footer').append($lamp_container.find('a.lamp_name'))
  stateData = {
    'scrollLeft': $('#scroll_container').scrollLeft()
  };
  window.history.replaceState(stateData, '', '/');
  history.pushState({
    'lamp_idx': i
  }, null, name_to_path(name));
  $('.lamp_container').not($lamp_container).hide();
  $('#scroll_container').scrollLeft(0);
  return $('.nav_container').hide();
};

// close_lamp_container = (scroll_position) ->

// name_to_path = (name) ->
//     name.replace(/\ /gi, "_").replace(/#/gi,"").toLowerCase()
on_scroll = function() {
  var make_active;
  if (!window.images_loaded) {
    return;
  }
  make_active = function(i) {
    var $td;
    console.log(i, index_to_hash[i]);
    $td = $('.nav_menu').find('td').eq(i);
    window.location.hash = index_to_hash[i];
    $('.active').removeClass('active');
    return $td.addClass('active');
  };
  return make_active(most_visible_container());
};

most_visible_container = function() {
  var largest_container, largest_percent;
  largest_percent = 0;
  largest_container = null;
  $('.lamp_container').each(function(i) {
    var pos;
    pos = percent_of_screen($(this));
    if (pos >= largest_percent || largest_container === null) {
      largest_container = i;
      return largest_percent = pos;
    }
  });
  return largest_container;
};

percent_of_screen = function($lamp_container) {
  var left, right, screen_left, screen_right, scroll, w_width;
  scroll = $('#scroll_container').scrollLeft();
  w_width = $(window).width();
  screen_left = $lamp_container.position().left;
  screen_right = screen_left + $lamp_container.first().width();
  left = screen_left < 0 ? 0 : screen_left;
  right = screen_right < w_width ? screen_right : w_width;
  return Math.min((right - left) / w_width, 1);
};

move_scroll_to = function(i) {
  var $lamp_container, scroll_amount, x;
  $lamp_container = $('.lamp_container').eq(i);
  scroll_amount = $('#scroll_container').scrollLeft();
  x = $lamp_container.offset().left - parseInt($lamp_container.css('margin-left'));
  return $('#scroll_container').scrollLeft(scroll_amount + x);
};

on_resize = function() {
  /* Vertically center the footer.
     */
  /* Vertically center the header.
     */
  var $footer, $header, container_height, footer_height, footer_space, header_height, header_space, lamp_container_height_percent, window_height;
  window_height = window.innerHeight;
  lamp_container_height_percent = .6;
  container_height = window_height * lamp_container_height_percent;
  $('.lamp_container').each(function(i) {
    /* The element is transalted by 0 degrees - so .width() is screen height.
           */
    /* Vertically center each lamp_container element.
           */
    var margin_top, name, scroll_top;
    scroll_top = $('#scroll_container').position().top;
    margin_top = ((window_height - container_height) / 2) - scroll_top;
    $(this).css('margin-top', margin_top);
    name = $(this).find('a.lamp_name.vertical-text');
    return name.css('margin-top', (container_height - name.width()) / 2);
  });
  $header = $('#header');
  header_height = $header.height();
  header_space = window_height * (1 - lamp_container_height_percent) / 2;
  $header.css('margin-top', Math.max((header_space - header_height) / 4), 0);
  $footer = $('#footer');
  footer_height = $footer.height();
  footer_space = window_height * (1 - lamp_container_height_percent) / 2;
  return $footer.css('bottom', (footer_space - footer_height) / 2);
};
