# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  $('#poll_type_button').on 'click', ->
    window.location = $('input:radio:checked').data('url')

  if $('#poll_form').length > 0

    ko.validation.init
      registerExtenders: true
      messagesOnModified: true
      insertMessages: true
      parseInputAttributes: true
      decorateInputElement: true
      errorClass: 'error'
    , true

    # HACK: Handle wajbar initialization manually so the validation message is displayed before the wajbar
    $('.wajbar')
      .bind 'focus', (evt) -> $(this).next('.TaskBox').css('opacity', 1)
      .bind 'blur',  (evt) -> $(this).next('.TaskBox').css('opacity', 0.3)
      .wajbar()

    $('#poll_form').each ->
      model = $(this).data('model')
      poll = new Poll(model)
      ko.applyBindings(poll, this)
      poll.initialize()

    $("#poll_form a#preview").fancybox()

    $('#poll_form #goto_import').on 'click', (evt) ->
      $("input[name='poll[form_url]']").focus()
      evt.preventDefault()
      false
