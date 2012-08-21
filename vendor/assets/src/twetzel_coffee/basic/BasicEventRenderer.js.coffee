((window) ->
  BasicEventRenderer = ->
  
    # exports
    # for DayEventRenderer
  
    # imports
    opt = @opt
    trigger = @trigger
    isEventDraggable = @isEventDraggable
    isEventResizable = @isEventResizable
    reportEvents = @reportEvents
    reportEventClear = @reportEventClear
    eventElementHandlers = @eventElementHandlers
    showEvents = @showEvents
    hideEvents = @hideEvents
    eventDrop = @eventDrop
    getDaySegmentContainer = @getDaySegmentContainer
    getHoverListener = @getHoverListener
    renderDayOverlay = @renderDayOverlay
    clearOverlays = @clearOverlays
    getRowCnt = @getRowCnt
    getColCnt = @getColCnt
    renderDaySegs = @renderDaySegs
    resizableDayEvent = @resizableDayEvent
  
    #var setOverflowHidden = @setOverflowHidden;
  
    # Rendering
    #	--------------------------------------------------------------------
    renderEvents = (events, modifiedEventId) ->
      reportEvents events
      renderDaySegs compileSegs(events), modifiedEventId
    clearEvents = ->
      reportEventClear()
      getDaySegmentContainer().empty()
    compileSegs = (events) ->
      rowCnt = getRowCnt()
      colCnt = getColCnt()
      d1 = cloneDate(t.visStart)
      d2 = addDays(cloneDate(d1), colCnt)
      visEventsEnds = $.map(events, exclEndDay)
      i = undefined
      row = undefined
      j = undefined
      level = undefined
      k = undefined
      seg = undefined
      segs = []
      i = 0
      while i < rowCnt
        row = stackSegs(sliceSegs(events, visEventsEnds, d1, d2))
        j = 0
        while j < row.length
          level = row[j]
          k = 0
          while k < level.length
            seg = level[k]
            seg.row = i
            seg.level = j # not needed anymore
            segs.push seg
            k++
          j++
        addDays d1, 7
        addDays d2, 7
        i++
      segs
    bindDaySeg = (event, eventElement, seg) ->
      draggableDayEvent event, eventElement  if isEventDraggable(event)
      resizableDayEvent event, eventElement, seg  if seg.isEnd and isEventResizable(event)
      eventElementHandlers event, eventElement
  
    # needs to be after, because resizableDayEvent might stopImmediatePropagation on click
  
    # Dragging
    #	----------------------------------------------------------------------------
    draggableDayEvent = (event, eventElement) ->
      hoverListener = getHoverListener()
      dayDelta = undefined
      eventElement.draggable
        zIndex: 9
        delay: 50
        opacity: opt("dragOpacity")
        revertDuration: opt("dragRevertDuration")
        start: (ev, ui) ->
          trigger "eventDragStart", eventElement, event, ev, ui
          hideEvents event, eventElement
          hoverListener.start ((cell, origCell, rowDelta, colDelta) ->
            eventElement.draggable "option", "revert", not cell or not rowDelta and not colDelta
            clearOverlays()
            if cell
            
              #setOverflowHidden(true);
              dayDelta = rowDelta * 7 + colDelta * ((if opt("isRTL") then -1 else 1))
              renderDayOverlay addDays(cloneDate(event.start), dayDelta), addDays(exclEndDay(event), dayDelta)
            else
            
              #setOverflowHidden(false);
              dayDelta = 0
          ), ev, "drag"

        stop: (ev, ui) ->
          hoverListener.stop()
          clearOverlays()
          trigger "eventDragStop", eventElement, event, ev, ui
          if dayDelta
            eventDrop this, event, dayDelta, 0, event.allDay, ev, ui
          else
            eventElement.css "filter", "" # clear IE opacity side-effects
            showEvents event, eventElement


    @renderEvents = renderEvents
    @compileDaySegs = compileSegs
    @clearEvents = clearEvents
    @bindDaySeg = bindDaySeg
    DayEventRenderer.call t
    

  #setOverflowHidden(false);
)(window)