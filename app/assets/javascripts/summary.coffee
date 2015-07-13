@summaryBeforeDrawChart = (visualisation, data) ->
  $(visualisation.getContainer()).closest('.question-summary').toggleClass('nodata', data.getNumberOfRows() == 0)
