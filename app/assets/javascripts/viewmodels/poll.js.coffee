class @Question

  constructor: (data, poll) ->
    @data = data
    @poll = poll
    @id = ko.observable(data.id)
    @kind = ko.observable(data.kind).extend(required: true)
    @title = ko.observable(data.title).extend(required: true)
    @description = ko.observable(data.description)
    @field_name = ko.observable(data.field_name)
    @position = ko.observable(data.position)
    @numeric_min = ko.observable(data.numeric_min)
    @numeric_max = ko.observable(data.numeric_max)
    @min_length = ko.observable(data.min_length)
    @max_length = ko.observable(data.max_length)
    @must_contain = ko.observable(data.must_contain)

    # Options list
    @options = ko.observableArray(_.map(data.options, (opt) => new QuestionOption(@, opt)))

    # Toggle collect respondent
    @collects_respondent = ko.observable(data.collects_respondent)
    @collects_respondent.subscribe (val) =>
      if val
        _.each @poll.questions(), (q) =>
          q.collects_respondent(false) if q != @

    @editable =  ko.computed () => @poll.editable()
    @readonly =  ko.computed () => !@editable()
    @removable = ko.computed () => @editable() && !@id() #!
    @first = ko.computed () => @poll.questions()[0] == @
    @last = ko.computed () => !@editable() && @poll.questions()[@poll.questions().length-1] == @
    @active = ko.observable false
    @new_option = ko.observable new QuestionOption(@, "")

    @editor_class = ko.computed () =>
      (if @active() then 'active ' else ' ') + (@poll.editor_class_for(@kind()))

    # Selecting next question. Serialize and deserialize next_question_definition
    @next_question = ko.observable()
    @next_question_definition = ko.pureComputed
      owner: @
      read: () =>
        if @next_question()
          ko.toJSON({next: @next_question()?.position})
        else if @kind() == 'options'
          cases = {}
          _.each @options(), (opt) ->
            cases[opt.text()] = opt.next_question()?.position
          ko.toJSON({case: cases})
        else
          ko.toJSON({})
      write: (value) =>
        if value.next == 'end'
          @next_question(@poll.end_option)
        else if value.next?
          @next_question(_.find(@poll.questions(), (q) -> q.position() == value.next))
        else if value.case?
          for opt, pos of value.case
            option = _.find(@options(), (o) -> o.text() == opt)
            question = _.find(@poll.questions(), (q) -> q.position() == pos)
            option.next_question(question)
        else
          true
    .extend(throttle: 1)

    @next_questions = ko.computed(() =>
      (@poll.questions()[@position()..]).concat([@poll.end_option])
    ).extend(throttle: 1)
    @title_for_options = ko.computed () =>
      "#{if @position > 9 then '' else '0'}#{@position()} \u00A0\u00A0\u00A0 #{@title()}"
    @options_caption = "\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0 Next question"

    # Helpers for kinds
    @kind_numeric = ko.computed () => @kind() == 'numeric'
    @kind_text    = ko.computed () => @kind() == 'text'
    @kind_options = ko.computed () => @kind() == 'options'

    # Validation
    @errors = ko.validation.group(@)

  initialize: () ->
    @next_question_definition(@data.next_question_definition)

  remove: () ->
    @poll.questions.remove @
    @poll.update_positions()

  set_active: () ->
    @poll.set_active_question(@)

  position_updated: () ->
    true

  # @mapping:
  #   options:
  #     create: (opts) ->
  #       new QuestionOption(opts.parent, opts.data)


class @QuestionOption

  constructor: (@question, text, hasFocus=false) ->
    @text = ko.observable text
    @focus= ko.observable hasFocus
    @next_question = ko.observable()
    # @next_question.subscribe (val) =>
    #   current = JSON.parse(@question.next_question_definition()).case or { case: {} }
    #   current[@text] = val.position
    #   updated = ko.toJSON(_.extend(current, {@text: val.}))
    #   @question.next_question_definition(updated)

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

  constructor: (data) ->
    # Poll attributes
    @title = ko.observable(data.title).extend(required: true)
    @confirmation_words_text = ko.observable(data.confirmation_words_text).extend(required: true)
    @welcome_message = ko.observable(data.welcome_message).extend(required: true, maxLength: 140)
    @goodbye_message = ko.observable(data.goodbye_message).extend(required: true, maxLength: 140)
    @form_url = ko.observable(data.form_url)
    @post_url = ko.observable(data.post_url)
    @description = ko.observable(data.description)
    @recurrence_rule = ko.observable(data.recurrence_rule)

    # Poll kind, state and helpers
    @kind = ko.observable(data.kind)
    @kind_manual = ko.observable(data.kind == 'manual')
    @kind_gforms = ko.observable(data.kind == 'gforms')
    @status = ko.observable(data.status)
    @status_started = ko.observable(data.status == 'started')
    @editable = ko.observable(@kind_manual() && !status_started())

    # True iif waiting for ajax request of import to complete
    @importing = ko.observable(false)

    # Option to be displayed as "end poll" when selecting "go to" after answer
    @end_option = {title: 'End poll', title_for_options: 'End \u00A0 End poll', position: 'end'}

    # Questions array must be initialized first since the question model constructor requires the poll to have a questions array
    @questions = ko.observableArray()
    @questions(_.map(data.questions, (q) => new Question(q, @)))
    @active_question = ko.computed () =>
      _.find @questions(), (q) -> q.active()

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
    @errors = ko.validation.group(@)

  initialize: () ->
    _.each @questions(), (q) -> q.initialize()

  import_form: (poll,evt) ->
    @importing true
    $.ajax
      url: "/polls/import_form"
      data: $(evt.target).closest('form').serialize()
      type: 'post'
      dataType: 'json'
      success: (data) =>
        @form_url(data.form_url)
        @post_url(data.post_url)
        @title(data.title)
        @description(data.description)
        @questions(_.map(data.questions, (q) => new Question(q, @)))
        @initialize()
      complete: (args) =>
        @importing false

  submit: () ->
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
      question.position(@questions().length+1)
      @questions.push(question)
      @set_active_question(question)

  editor_class_for: (kind) ->
    switch kind
      when 'text' then 'ltext'
      when 'options' then 'lsingleoption'
      when 'numeric' then 'lnumber'
      when 'unsupported' then 'lunknown'
      else ''

  update_positions: () ->
    for question, index in @questions()
      for listener in @questions()
        listener.position_updated(question.position(), index+1)
      question.position(index+1)

  onQuestionMoved: (q) ->
    q.item.poll.update_positions()
