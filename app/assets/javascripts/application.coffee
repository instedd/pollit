$ ->
  $('.link').live 'click', ->
    url = $(this).data('url');
    window.location = url;