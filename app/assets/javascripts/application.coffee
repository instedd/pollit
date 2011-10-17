$ ->
  window.reinitialize()

window.reinitialize = () -> 
  $('.link').live 'click', ->
    url = $(this).data('url');
    window.location = url;

  $('form.validate').validate()
  $('input[placeholder],textarea[placeholder]').placeholder()