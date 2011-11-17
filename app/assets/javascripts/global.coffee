window.reinitialize = (obj) -> 
  $('form.validate').validate()
  $.instedd.init_components($(obj)) if obj

$ ->
  $('.link').live 'click', ->
    url = $(this).data('url')
    window.location = url

  $('.language li a').live 'click', ->
    req_locale = $(this).data('lang')
    window.location = '/locale/update?requested_locale=' + req_locale
    return false

  $('#lang_bubble_trigger').bubble
    position : 'top'
    content: $("#lang_bubble_content")
    closeSelector: '#lang_bubble_close'
    themeName:  'bubble'
    innerHtmlStyle:
      color:'#000000',
      'background-color': 'white'
    themePath: 'http://theme.instedd.org/theme/images/'
    click: true

  window.reinitialize()