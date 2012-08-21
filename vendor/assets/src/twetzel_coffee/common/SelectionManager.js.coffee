((window) ->
  #BUG: unselect needs to be triggered when events are dragged+dropped
  SelectionManager = ->
  
    # exports
  
    # imports
    opt = @opt
    trigger = @trigger
    defaultSelectionEnd = @defaultSelectionEnd
    renderSelection = @renderSelection
    clearSelection = @clearSelection
    selected = false
    t = this
    
    # locals
  
    # unselectAuto
    # could be optimized to stop after first match
    select = (startDate, endDate, allDay) ->
      unselect()
      endDate = defaultSelectionEnd(startDate, allDay)  unless endDate
      renderSelection startDate, endDate, allDay
      reportSelection startDate, endDate, allDay
    unselect = (ev) ->
      if selected
        selected = false
        clearSelection()
        trigger "unselect", null, ev
    reportSelection = (startDate, endDate, allDay, ev) ->
      selected = true
      resourceObj = false
      if @calendar.getView().name is "resourceDay"
      
        #Get the cell associated with the select function
        hoverListener = @getHoverListener()
        cell = hoverListener.stop()
        calendar = @calendar
        resources = calendar.getResources()
      
        #Get the resource from the selected cell and pass it to the select function as an argument		
        resourceObj = resources[cell.col]
      trigger "select", null, startDate, endDate, allDay, ev, resourceObj
    daySelectionMousedown = (ev) -> # not really a generic manager method, oh well
      cellDate = @cellDate
      cellIsAllDay = @cellIsAllDay
      hoverListener = @getHoverListener()
      reportDayClick = @reportDayClick # this is hacky and sort of weird
      if ev.which is 1 and opt("selectable") # which==1 means left mouse button
        unselect ev
        _mousedownElement = this
        dates = undefined
        hoverListener.start ((cell, origCell) -> # TODO: maybe put cellDate/cellIsAllDay info in cell
          clearSelection()
          if cell and cellIsAllDay(cell)
            dates = [cellDate(origCell), cellDate(cell)].sort(cmp)
            renderSelection dates[0], dates[1], true
          else
            dates = null
        ), ev
        $(document).one "mouseup", (ev) ->
          hoverListener.stop()
          if dates
            reportDayClick dates[0], true, ev  if +dates[0] is +dates[1]
            reportSelection dates[0], dates[1], true, ev

    
    @select = select
    @unselect = unselect
    @reportSelection = reportSelection
    @daySelectionMousedown = daySelectionMousedown
    
    if opt("selectable") and opt("unselectAuto")
      $(document).mousedown (ev) ->
        ignore = opt("unselectCancel")
        return  if $(ev.target).parents(ignore).length  if ignore
        unselect ev
)(window)