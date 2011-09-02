((window, previousOnLoad) ->
  window.onload = ->
    try
      (previousOnLoad||angular.noop)()
    catch error
    try
      angular.compile(window.document)()
    catch error
)(window, window.onload)