((window) ->
  HoverListener = (coordinateGrid) ->
    t = this
    bindType = undefined
    change = undefined
    firstCell = undefined
    cell = undefined
    mouse = (ev) ->
      _fixUIEvent ev # see below
      newCell = coordinateGrid.cell(ev.pageX, ev.pageY)
      if not newCell isnt not cell or newCell and (newCell.row isnt cell.row or newCell.col isnt cell.col)
        if newCell
          firstCell = newCell  unless firstCell
          change newCell, firstCell, newCell.row - firstCell.row, newCell.col - firstCell.col
        else
          change newCell, firstCell
        cell = newCell
    
    @start = (_change, ev, _bindType) ->
      change = _change
      firstCell = cell = null
      coordinateGrid.build()
      mouse ev
      bindType = _bindType or "mousemove"
      $(document).bind bindType, mouse

    @stop = ->
      $(document).unbind bindType, mouse
      cell

  # this fix was only necessary for jQuery UI 1.8.16 (and jQuery 1.7 or 1.7.1)
  # upgrading to jQuery UI 1.8.17 (and using either jQuery 1.7 or 1.7.1) fixed the problem
  # but keep this in here for 1.8.16 users
  # and maybe remove it down the line
  _fixUIEvent = (event) -> # for issue 1168
    if event.pageX is `undefined`
      event.pageX = event.originalEvent.pageX
      event.pageY = event.originalEvent.pageY
)(window)