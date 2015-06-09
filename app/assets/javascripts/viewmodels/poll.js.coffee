class @Question

  constructor: (@poll) ->
    @id = ko.observable()
    @kind = ko.observable()
    @title = ko.observable()
    @description = ko.observable()
    @collects_respondent = ko.observable()
    @options = ko.observableArray()
    @field_name = ko.observable()
    @position = ko.observable()
    @numeric_min = ko.observable()
    @numeric_max = ko.observable()

    @editable = @poll.editable
    @readonly =  ko.computed () => !@editable()
    @removable = ko.computed () => @editable() && !@id()
    @first = ko.computed () => @poll.questions()[0] == @
    @last = ko.computed () => @poll.questions()[@poll.questions().length-1] == @
    @active = ko.observable false

    @editor_class = ko.computed () =>
      (if @active() then 'active ' else ' ') + (@poll.editor_class_for(@kind()))

    @kind_numeric = ko.computed(() => @kind() == 'numeric').extend(throttle: 1)
    @kind_text    = ko.computed () => @kind() == 'text'
    @kind_options = ko.computed () => @kind() == 'options'

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

  constructor: (@question, text) ->
    @text = ko.observable text

  remove: () ->
    @question.options.remove @

  add: () ->
    @question.options.push @
    @question.new_option(new QuestionOption(@question, ""))


class @Poll

  constructor: () ->
    @importing = ko.observable false
    @manual = ko.observable false
    @kind = ko.observable null
    @editable = ko.computed () => (@kind() == 'manual')
    @questions = ko.observableArray()
    @active_question = ko.computed () =>
      _.find @questions(), (q) -> q.active()

  initialize: () ->

  create_manually: () ->
    @manual true
    @imported false

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
      question.position = index+1
    true

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
