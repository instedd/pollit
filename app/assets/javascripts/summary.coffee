@summaryBeforeDrawChart = (visualisation, data) ->
  $(visualisation.getContainer()).closest('.question-summary').toggleClass('nodata', data.getNumberOfRows() == 0)

$ ->
  $('#summary_occurrence').on 'change', () ->
    for id in gon.question_ids
      window["rgviz_draw_question_#{id}"]()
