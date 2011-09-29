# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  setupValidation()
  $('.import_form_action').live 'click', ->
    if $('#poll_form_url').val() isnt ''
      $.post(
        "/polls/import_form"
        $('#poll_form_container form').serialize()
        (res) -> 
          $('#poll_form_container').replaceWith(res)
          window.reinitialize()
          formValidate()
          select_field(0)
      )
    false


setupValidation = () ->
  jQuery.validator.addMethod(
    "hasChildren"
    (value, element, options) ->
      return $(options[2], element.form).length > 0
    jQuery.format("The {0} must have at least one {1}.")
  )

  jQuery.validator.addMethod(
    "questionsValid"
    (value, element, options) ->
      return $("#formeditor .field[data-error=true]", element.form).length == 0
    jQuery.format("There are invalid questions in the poll.")
  )

  formValidate()

formValidate = () ->
  $('#poll_form').validate(
    onfocusout: false
    onkeyup: false
    onclick: false
    errorPlacement: (error, element) ->
      error.insertAfter(element)
      if element.attr('id') == 'questions_validation'
        $('.reload_from_google').focus()
        
    rules:
      'poll[form_url]': 
        hasChildren: ["poll", "question", '#formeditor .field']
      'questions_validation':
        questionsValid: true
  )
  