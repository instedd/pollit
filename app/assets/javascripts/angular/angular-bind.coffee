$(document).ready ->
  hasAngularElements = ($("div").filter(->
    $(this).attr "ng:controller"
  ).length > 0)
  if hasAngularElements
    ((window, previousOnLoad) ->
      window.onload = ->
        (previousOnLoad or angular.noop)()
        angular.compile(window.document)()
    ) window, window.onload