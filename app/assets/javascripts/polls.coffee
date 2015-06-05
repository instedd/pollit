# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  $('#poll_form').each ->
    ko.form(this)
    ko.dataFor(this).initialize()

#   setupValidation()
#   $('.import_form_action').live 'click', ->
#     if $('#poll_form_url').valid()
#       $(this).text(importing_label)
#       $(this).attr('disabled','disabled')
#       $(this).addClass('loading');
#       $.ajax(
#         url: "/polls/import_form"
#         data: $('#poll_form_container form').serialize()
#         type: 'post'
#         dataType: 'script'
#       )
#     else
#       $('#poll_form_url').focus()
#     false

# setupValidation = () ->
#   jQuery.validator.addMethod(
#     "hasChildren"
#     (value, element, options) ->
#       return $(options[2], element.form).length > 0
#     jQuery.format(must_have_at_least_one)
#   )

#   jQuery.validator.addMethod(
#     "questionsValid"
#     (value, element, options) ->
#       return $("#form-editor .field[data-error=true]", element.form).length == 0
#     jQuery.format(invalid_questions_in_the_poll)
#   )

#   window.formValidate()

# window.validator = null
# window.formValidate = () ->
#   window.validator = $('#poll_form').validate(
#     onfocusout: false
#     onkeyup: false
#     onclick: false
#     errorPlacement: (error, element) ->
#       if element.attr('id') == 'poll_form_url'
#         error.insertAfter('#poll_post_url')
#       else if element.attr('id') == 'questions_validation'
#         $('.reload_from_google').focus()
#         error.insertAfter(element)
#       else if element.attr('id') == 'has_questions'
#         error.insertAfter('#poll_form_url')
#         $('#poll_form_url').focus()
#       else
#         error.insertAfter(element)
#     rules:
#       'poll[form_url]':
#         required: true
#         url: true
#       'empty_questions_validation':
#         hasChildren: ["poll", "question", '#form-editor .feditor']
#       'questions_validation':
#         questionsValid: true
#   )
