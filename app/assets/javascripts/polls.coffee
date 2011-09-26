# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#import_form_action').live 'click', ->
    if $('#poll_form_url').val() isnt ''
      $.post(
        "/polls/import_form"
        $('#poll_form_container form').serialize()
        (res) -> $('#poll_form_container').replaceWith(res)
      )
    false
  