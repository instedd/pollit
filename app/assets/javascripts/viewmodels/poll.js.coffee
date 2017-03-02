class @Question

  @palette = ["#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f","#e5c494","#b3b3b3"]

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

    # Custom messages
    custom_messages = data.custom_messages || {}
    @custom_message_empty = ko.observable(custom_messages.empty)
    @custom_message_invalid_length = ko.observable(custom_messages.invalid_length)
    @custom_message_doesnt_contain = ko.observable(custom_messages.doesnt_contain)
    @custom_message_not_a_number = ko.observable(custom_messages.not_a_number)
    @custom_message_number_not_in_range = ko.observable(custom_messages.number_not_in_range)
    @custom_message_not_an_option = ko.observable(custom_messages.not_an_option)
    @custom_message_options_explanation = ko.observable(custom_messages.options_explanation)

    # Numeric conditions
    @numeric_condition = ko.observable(new QuestionNumericCondition(@))
    @numeric_conditions = ko.observableArray()

    # Options list
    @options = ko.observableArray(_.map(data.options, (opt) =>
      if typeof(opt) == "string"
        new QuestionOption(@, opt)
      else
        new QuestionOption(@, opt[0], opt[1])
      ))

    # Toggle collect respondent
    @collects_respondent = ko.observable(data.collects_respondent)
    @collects_respondent.subscribe (val) =>
      if val
        _.each @poll.questions(), (q) =>
          q.collects_respondent(false) if q != @

    @editable =  ko.computed () => @poll.editable()
    @readonly =  ko.computed () => !@editable()
    @removable = ko.computed () => @editable()
    @first = ko.computed () => @poll.questions()[0] == @
    @last = ko.computed () => !@editable() && @poll.questions()[@poll.questions().length-1] == @
    @active = ko.observable false
    @new_option = ko.observable new QuestionOption(@, "", "")

    @editor_class = ko.computed () =>
      (if @active() then 'active ' else ' ') + (@poll.editor_class_for(@kind()))

    # Selecting next question. Serialize and deserialize next_question_definition
    @next_question = ko.observable()

    @next_question_colour = ko.computed () => @next_question()?.question_colour?() || 'transparent'

    @next_questions = ko.computed(() =>
      (@poll.questions()[@position()..]).concat([@poll.end_option])
    ).extend(throttle: 1)

    @title_for_options = ko.computed () =>
      "#{if @position > 9 then '' else '0'}#{@position()} \u00A0\u00A0\u00A0 #{@title()}"
    @options_caption = "\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0 Next question"

    @highlighted = ko.computed(() =>
      @poll.initialized() and (active = @poll.active_question()) and active? and (active.next_question() == @ or _.some(active.options(), (opt) => opt.next_question() == @))
    ).extend(throttle: 10)
    @question_colour = ko.computed () => Question.palette[@position() % Question.palette.length]

    # Helpers for kinds
    @kind_numeric = ko.computed () => @kind() == 'numeric'
    @kind_text    = ko.computed () => @kind() == 'text'
    @kind_options = ko.computed () => @kind() == 'options'

    # Validation
    @errors = ko.validation.group(@)

    @next_question_definition = ko.computed
      owner: @
      read: () =>
        if @kind() == 'numeric'
          cases = []
          _.each @numeric_conditions(), (condition) ->
            cases.push min: condition.min(), max: condition.max(), next: condition.next_question()?.position
          ko.toJSON({cases: cases, next: @next_question()?.position})
        else if @next_question()
          ko.toJSON({next: @next_question()?.position})
        else if @kind() == 'options'
          cases = {}
          _.each @options(), (opt) ->
            cases[opt.text()] = opt.next_question()?.position
          ko.toJSON({case: cases})
        else
          ko.toJSON({})
      write: (value) =>
        if @kind() == 'numeric'
          if value.cases
            _.each value.cases, (a_case) =>
              @numeric_conditions.push(new QuestionNumericCondition(@, a_case))
          if value.next == 'end'
            @next_question(@poll.end_option)
          else if value.next?
            @next_question(_.find(@poll.questions(), (q) -> q.position() == value.next))
        else if value.next == 'end'
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

  initialize: () ->
    @next_question_definition(@data.next_question_definition)

  remove: () ->
    @poll.questions.remove @
    @poll.update_positions()

  set_active: () ->
    @poll.set_active_question(@)

  position_updated: () ->
    true

  add_numeric_condition: =>
    @numeric_conditions.push @numeric_condition()
    @numeric_condition(new QuestionNumericCondition(@))

class @QuestionOption

  constructor: (@question, text, key, hasFocus=false) ->
    @text = ko.observable text
    @key = ko.observable key
    @focus= ko.observable hasFocus
    @next_question = ko.observable()
    @next_question_colour = ko.computed () => @next_question()?.question_colour?() || 'transparent'

  remove: () ->
    @question.options.remove @

  add: () ->
    @question.options.push @
    new_option = new QuestionOption(@question, "", "", true)
    @question.new_option(new_option)

  onEnter: (q, e) ->
    @add() if e.keyCode == 13 && @text().length > 0
    return true

class @QuestionNumericCondition
  constructor: (@question, data) ->
    @min = ko.observable(data?.min)
    @max = ko.observable(data?.max)
    @next_question = ko.observable()

    if data?.next
      if data.next == 'end'
        @next_question(@question.poll.end_option)
      else
        @next_question(_.find(@question.poll.questions(), (q) -> q.position() == data.next))

  remove: =>
    @question.numeric_conditions.remove(@)

class @Poll

  constructor: (data) ->
    # Poll attributes
    @initialized = ko.observable(false)
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
    @editable = ko.observable(@kind_manual() && !@status_started())

    # True iif waiting for ajax request of import to complete
    @importing = ko.observable(false)

    # Option to be displayed as "end poll" when selecting "go to" after answer
    @end_option = {title: 'End poll', title_for_options: 'End \u00A0 End poll', position: 'end'}

    # Questions array must be initialized first since the question model constructor requires the poll to have a questions array
    @questions = ko.observableArray()
    @questions(_.map(data.questions, (q) => new Question(q, @)))

    # Initialize the questions: some properties depend on the `next_questions` property, but this is only
    # known once all poll questions are assigned: we can't do it as we instantiate the questions.
    _.each @questions(), (q) -> q.initialize()

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
    @initialized(true)

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
      question = new Question
        kind: kind
        title: 'New question'
        position: @questions().length+1
      , @
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
