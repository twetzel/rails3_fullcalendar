((window) ->
  OverlayManager = ->
    
    # locals
    usedOverlays = []
    unusedOverlays = []
    t = this
    
    renderOverlay = (rect, parent) ->
      e = unusedOverlays.shift()
      e = $("<div class='fc-cell-overlay' style='position:absolute;z-index:3'/>")  unless e
      e.appendTo parent  unless e[0].parentNode is parent[0]
      usedOverlays.push e.css(rect).show()
      e
    clearOverlays = ->
      e = undefined
      unusedOverlays.push e.hide().unbind()  while e = usedOverlays.shift()
    
    # exports
    @renderOverlay = renderOverlay
    @clearOverlays = clearOverlays
    
)(window)