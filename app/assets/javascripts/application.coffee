window.reinitialize = (obj) -> 
  $('form.validate').validate()
  $.instedd.init_components($(obj)) if obj

$ ->
  $('.link').live 'click', ->
    url = $(this).data('url')
    window.location = url
  
  $('.language li').live 'click', ->
    req_locale = $(this).data('lang')
    window.location = '/locale/update?requested_locale=' + req_locale

  window.reinitialize()