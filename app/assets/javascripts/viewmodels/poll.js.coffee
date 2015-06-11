class @Question

  constructor: (@poll) ->
    @id = ko.observable()
    @kind = ko.observable().extend(required: true)
    @title = ko.observable().extend(required: true)
    @description = ko.observable()
    @field_name = ko.observable()
    @position = ko.observable()
    @numeric_min = ko.observable()
    @numeric_max = ko.observable()
    @options = ko.observableArray()

    @collects_respondent = ko.observable()
    @collects_respondent.subscribe (val) =>
      if val
        _.each @poll.questions(), (q) =>
          q.collects_respondent(false) if q != @

    @editable = @poll.editable
    @readonly =  ko.computed () => !@editable()
    @removable = ko.computed () => @editable() && !@id()
    @first = ko.computed () => @poll.questions()[0] == @
    @last = ko.computed () => !@editable() && @poll.questions()[@poll.questions().length-1] == @
    @active = ko.observable false

    @editor_class = ko.computed () =>
      (if @active() then 'active ' else ' ') + (@poll.editor_class_for(@kind()))

    @kind_numeric = ko.computed(() => @kind() == 'numeric').extend(throttle: 1)
    @kind_text    = ko.computed () => @kind() == 'text'
    @kind_options = ko.computed () => @kind() == 'options'

    @errors = ko.validation.group(@)
    @new_option = ko.observable new QuestionOption(@, "")


  remove: () ->
    @poll.questions.remove @

  set_active: () ->
    @poll.set_active_question(@)

  @mapping:
    options:
      create: (opts) ->
        new QuestionOption(opts.parent, opts.data)


class @QuestionOption

  constructor: (@question, text, hasFocus=false) ->
    @text = ko.observable text
    @focus= ko.observable hasFocus

  remove: () ->
    @question.options.remove @

  add: () ->
    @question.options.push @
    new_option = new QuestionOption(@question, "", true)
    @question.new_option(new_option)

  onEnter: (q, e) ->
    @add() if e.keyCode == 13 && @text().length > 0
    return true


class @Poll

  constructor: () ->
    @title = ko.observable(null).extend(required: true)
    @confirmation_words_text = ko.observable(null).extend(required: true)
    @welcome_message = ko.observable(null).extend(required: true, maxLength: 140)
    @goodbye_message = ko.observable(null).extend(required: true, maxLength: 140)

    @kind = ko.observable null
    @questions = ko.observableArray()

    # HACK: Could not attach a validator to the questions observable array,
    # so it is manually handled in a separate observable
    @questionsValidation = ko.observable().extend
      validation: [{
        validator: (q) => @questions().length > 0
        message: "There must be at least one question in the poll"
      }, {
        validator: (q) => _.all(@questions(), (q)-> q.errors().length == 0)
        message: "Please fix all errors in the questions"
      }]

    @importing = ko.observable(false)
    @errors = ko.validation.group(@)

    @editable = ko.computed () => (@kind() == 'manual')
    @active_question = ko.computed () =>
      _.find @questions(), (q) -> q.active()

  initialize: () ->

  import_form: (poll,evt) ->
    @importing true
    $.ajax
      url: "/polls/import_form"
      data: $(evt.target).closest('form').serialize()
      type: 'post'
      dataType: 'json'
      success: (data) =>
        ko.mapping.fromJS(data, Poll.mapping, @)
      complete: (args) =>
        @importing false

  submit: () ->
    for question, index in @questions()
      question.position(index+1)

    if @valid()
      return true
    else
      @show_error_messages()
      return false

  valid: () ->
    @errors().length == 0 && _.all(@questions(), (q)-> q.errors().length == 0)

  show_error_messages: () ->
    @errors.showAllMessages()
    _.each(@questions(), (q)-> q.errors.showAllMessages())

  set_active_question: (q) ->
    for question in @questions()
      question.active (question == q)

  add_question_handler: (kind) ->
    () =>
      question = new Question(@)
      question.kind(kind)
      question.title('New question')
      @questions.push(question)
      @set_active_question(question)

  editor_class_for: (kind) ->
    switch kind
      when 'text' then 'ltext'
      when 'options' then 'lsingleoption'
      when 'numeric' then 'lnumber'
      when 'unsupported' then 'lunknown'
      else ''

  @mapping:
    questions:
      create: (opts) ->
        ko.mapping.fromJS(opts.data, Question.mapping, new Question(opts.parent))
