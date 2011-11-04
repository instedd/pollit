window.reinitialize = (obj) -> 
  $('.link').live 'click', ->
    url = $(this).data('url')
    window.location = url
  $('form.validate').validate()
  $.instedd.init_components($(obj)) if obj

$ ->
  window.reinitialize()