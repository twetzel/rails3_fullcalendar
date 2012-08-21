((window) ->
  AgendaEventRenderer = ->
  
    # exports
    # for DayEventRenderer
  
    # imports
  
    #var setOverflowHidden = @setOverflowHidden;
    # TODO: streamline binding architecture
  
    # Rendering
    #	----------------------------------------------------------------------------
    renderEvents = (events, modifiedEventId) ->
      reportEvents events
      i = undefined
      len = events.length
      dayEvents = []
      slotEvents = []
      i = 0
      while i < len
        if events[i].allDay
          dayEvents.push events[i]
        else
          slotEvents.push events[i]
        i++
      if opt("allDaySlot")
        renderDaySegs compileDaySegs(dayEvents), modifiedEventId
        setHeight() # no params means set to viewHeight
      renderSlotSegs compileSlotSegs(slotEvents), modifiedEventId
    clearEvents = ->
      reportEventClear()
      getDaySegmentContainer().empty()
      getSlotSegmentContainer().empty()
    compileDaySegs = (events) ->
      levels = stackSegs(sliceSegs(events, $.map(events, exclEndDay), @visStart, @visEnd))
      i = undefined
      levelCnt = levels.length
      level = undefined
      j = undefined
      seg = undefined
      segs = []
      i = 0
      while i < levelCnt
        level = levels[i]
        j = 0
        while j < level.length
          seg = level[j]
          seg.row = 0
          seg.level = i # not needed anymore
          segs.push seg
          j++
        i++
      segs
    compileSlotSegs = (events) ->
      colCnt = getColCnt()
      minMinute = getMinMinute()
      maxMinute = getMaxMinute()
      d = addMinutes(cloneDate(t.visStart), minMinute)
      visEventEnds = $.map(events, slotEventEnd)
      i = undefined
      col = undefined
      j = undefined
      level = undefined
      k = undefined
      seg = undefined
      segs = []
      i = 0
      while i < colCnt
        col = stackSegs(sliceSegs(events, visEventEnds, d, addMinutes(cloneDate(d), maxMinute - minMinute)))
        countForwardSegs col
        j = 0
        while j < col.length
          level = col[j]
          k = 0
          while k < level.length
            seg = level[k]
            seg.col = i
            seg.level = j
            segs.push seg
            k++
          j++
        addDays d, 1, true
        i++
      segs
    slotEventEnd = (event) ->
      if event.end
        cloneDate event.end
      else
        addMinutes cloneDate(event.start), opt("defaultEventMinutes")
  
    # renders events in the 'time slots' at the bottom
    renderSlotSegs = (segs, modifiedEventId) ->
      i = undefined
      segCnt = segs.length
      seg = undefined
      event = undefined
      classes = undefined
      top = undefined
      bottom = undefined
      colI = undefined
      levelI = undefined
      forward = undefined
      leftmost = undefined
      availWidth = undefined
      outerWidth = undefined
      left = undefined
      html = ""
      eventElements = undefined
      eventElement = undefined
      triggerRes = undefined
      vsideCache = {}
      hsideCache = {}
      key = undefined
      val = undefined
      contentElement = undefined
      height = undefined
      slotSegmentContainer = getSlotSegmentContainer()
      rtl = undefined
      dis = undefined
      dit = undefined
      colCnt = getColCnt()
      if rtl = opt("isRTL")
        dis = -1
        dit = colCnt - 1
      else
        dis = 1
        dit = 0
    
      # calculate position/dimensions, create html
      i = 0
      while i < segCnt
        seg = segs[i]
        event = seg.event
        top = timePosition(seg.start, seg.start)
        bottom = timePosition(seg.start, seg.end)
        colI = seg.col
        levelI = seg.level
        forward = seg.forward or 0
        leftmost = colContentLeft(colI * dis + dit)
        availWidth = colContentRight(colI * dis + dit) - leftmost
        availWidth = Math.min(availWidth - 6, availWidth * .95) # TODO: move this to CSS
        if levelI
        
          # indented and thin
          outerWidth = availWidth / (levelI + forward + 1)
        else
          if forward
          
            # moderately wide, aligned left still
            outerWidth = ((availWidth / (forward + 1)) - (12 / 2)) * 2 # 12 is the predicted width of resizer =
          else
          
            # can be entire width, aligned left
            outerWidth = availWidth
        # leftmost possible
        # indentation
        left = leftmost + (availWidth / (levelI + forward + 1) * levelI) * dis + ((if rtl then availWidth - outerWidth else 0)) # rtl
        seg.top = top
        seg.left = left
        seg.outerWidth = outerWidth
        seg.outerHeight = bottom - top
        html += slotSegHtml(event, seg)
        i++
      slotSegmentContainer[0].innerHTML = html # faster than html()
      eventElements = slotSegmentContainer.children()
    
      # retrieve elements, run through eventRender callback, bind event handlers
      i = 0
      while i < segCnt
        seg = segs[i]
        event = seg.event
        eventElement = $(eventElements[i]) # faster than eq()
        triggerRes = trigger("eventRender", event, event, eventElement)
        if triggerRes is false
          eventElement.remove()
        else
          if triggerRes and triggerRes isnt true
            eventElement.remove()
            eventElement = $(triggerRes).css(
              position: "absolute"
              top: seg.top
              left: seg.left
            ).appendTo(slotSegmentContainer)
          seg.element = eventElement
          if event._id is modifiedEventId
            bindSlotSeg event, eventElement, seg
          else
            eventElement[0]._fci = i # for lazySegBind
          reportEventElement event, eventElement
        i++
      lazySegBind slotSegmentContainer, segs, bindSlotSeg
    
      # record event sides and title positions
      i = 0
      while i < segCnt
        seg = segs[i]
        if eventElement = seg.element
          val = vsideCache[key = seg.key = cssKey(eventElement[0])]
          seg.vsides = (if val is `undefined` then (vsideCache[key] = vsides(eventElement, true)) else val)
          val = hsideCache[key]
          seg.hsides = (if val is `undefined` then (hsideCache[key] = hsides(eventElement, true)) else val)
          contentElement = eventElement.find("div.fc-event-content")
          seg.contentTop = contentElement[0].offsetTop  if contentElement.length
        i++
    
      # set all positions/dimensions at once
      i = 0
      while i < segCnt
        seg = segs[i]
        if eventElement = seg.element
          eventElement[0].style.width = Math.max(0, seg.outerWidth - seg.hsides) + "px"
          height = Math.max(0, seg.outerHeight - seg.vsides)
          eventElement[0].style.height = height + "px"
          event = seg.event
          if seg.contentTop isnt `undefined` and height - seg.contentTop < 10
          
            # not enough room for title, put it in the time header
            eventElement.find("div.fc-event-time").text formatDate(event.start, opt("timeFormat")) + " - " + event.title
            eventElement.find("div.fc-event-title").remove()
          trigger "eventAfterRender", event, event, eventElement
        i++
    slotSegHtml = (event, seg) ->
      html = "<"
      url = event.url
      skinCss = $("")
      if event.resource
        skinCss = getSkinCssWithResource(event, event.resource) # PA TODO - merge getSkinCssWithResource into getSkinCss
      else
        skinCss = getSkinCss(event, opt)
      skinCssAttr = ((if skinCss then " style='" + skinCss + "'" else ""))
      classes = ["fc-event", "fc-event-skin", "fc-event-vert"]
      classes.push "fc-event-draggable"  if isEventDraggable(event)
      classes.push "fc-corner-top"  if seg.isStart
      classes.push "fc-corner-bottom"  if seg.isEnd
      classes = classes.concat(event.className)
      classes = classes.concat(event.source.className or [])  if event.source
      if url
        html += "a href='" + htmlEscape(event.url) + "'"
      else
        html += "div"
      html += " class='" + classes.join(" ") + "'" + " style='position:absolute;z-index:8;top:" + seg.top + "px;left:" + seg.left + "px;" + skinCss + "'" + ">" + "<div class='fc-event-inner fc-event-skin'" + skinCssAttr + ">" + "<div class='fc-event-head fc-event-skin'" + skinCssAttr + ">" + "<div class='fc-event-time'>" + htmlEscape(formatDates(event.start, event.end, opt("timeFormat"))) + "</div>" + "</div>" + "<div class='fc-event-content'>" + "<div class='fc-event-title'>" + htmlEscape(event.title) + "</div>" + "</div>" + "<div class='fc-event-bg'></div>" + "</div>" # close inner
      html += "<div class='ui-resizable-handle ui-resizable-s'>=</div>"  if seg.isEnd and isEventResizable(event)
      html += "</" + ((if url then "a" else "div")) + ">"
      html
    bindDaySeg = (event, eventElement, seg) ->
      draggableDayEvent event, eventElement, seg.isStart  if isEventDraggable(event)
      resizableDayEvent event, eventElement, seg  if seg.isEnd and isEventResizable(event)
      eventElementHandlers event, eventElement
  
    # needs to be after, because resizableDayEvent might stopImmediatePropagation on click
    bindSlotSeg = (event, eventElement, seg) ->
      timeElement = eventElement.find("div.fc-event-time")
      draggableSlotEvent event, eventElement, timeElement  if isEventDraggable(event)
      resizableSlotEvent event, eventElement, timeElement  if seg.isEnd and isEventResizable(event)
      eventElementHandlers event, eventElement
  
    # Dragging
    #	-----------------------------------------------------------------------------------
  
    # when event starts out FULL-DAY
    draggableDayEvent = (event, eventElement, isStart) ->
      # use whatever the month view was using
    
      #setOverflowHidden(true);
    
      # on full-days
    
      # mouse is over bottom slots
    
      # convert event to temporary slot-event
      # don't use entire width
    
      #setOverflowHidden(false);
    
      # hasn't moved or is out of bounds (draggable has already reverted)
      # clear IE opacity side-effects
    
      # changed!
    
      #setOverflowHidden(false);
      resetElement = ->
        unless allDay
          eventElement.width(origWidth).height("").draggable "option", "grid", null
          allDay = true
      origWidth = undefined
      revert = undefined
      allDay = true
      dayDelta = undefined
      dis = (if opt("isRTL") then -1 else 1)
      hoverListener = getHoverListener()
      colWidth = getColWidth()
      slotHeight = getSlotHeight()
      minMinute = getMinMinute()
      eventElement.draggable
        zIndex: 9
        opacity: opt("dragOpacity", "month")
        revertDuration: opt("dragRevertDuration")
        start: (ev, ui) ->
          trigger "eventDragStart", eventElement, event, ev, ui
          hideEvents event, eventElement
          origWidth = eventElement.width()
          hoverListener.start ((cell, origCell, rowDelta, colDelta) ->
            clearOverlays()
            if cell
              revert = false
              dayDelta = colDelta * dis
              unless cell.row
                renderDayOverlay addDays(cloneDate(event.start), dayDelta), addDays(exclEndDay(event), dayDelta)
                resetElement()
              else
                if isStart
                  if allDay
                    eventElement.width colWidth - 10
                    setOuterHeight eventElement, slotHeight * Math.round(((if event.end then ((event.end - event.start) / MINUTE_MS) else opt("defaultEventMinutes"))) / opt("slotMinutes"))
                    eventElement.draggable "option", "grid", [colWidth, 1]
                    allDay = false
                else
                  revert = true
              revert = revert or (allDay and not dayDelta)
            else
              resetElement()
              revert = true
            eventElement.draggable "option", "revert", revert
          ), ev, "drag"

        stop: (ev, ui) ->
          hoverListener.stop()
          clearOverlays()
          trigger "eventDragStop", eventElement, event, ev, ui
          if revert
            resetElement()
            eventElement.css "filter", ""
            showEvents event, eventElement
          else
            minuteDelta = 0
            minuteDelta = Math.round((eventElement.offset().top - getBodyContent().offset().top) / slotHeight) * opt("slotMinutes") + minMinute - (event.start.getHours() * 60 + event.start.getMinutes())  unless allDay
            eventDrop this, event, dayDelta, minuteDelta, allDay, ev, ui

  
    # when event starts out IN TIMESLOTS
    draggableSlotEvent = (event, eventElement, timeElement) ->
    
      # over full days
    
      # convert to temporary all-day event
    
      # on slots
    
      # changed!
    
      # either no change or out-of-bounds (draggable has already reverted)
      # clear IE opacity side-effects
      # sometimes fast drags make event revert to wrong position
      updateTimeText = (minuteDelta) ->
        newStart = addMinutes(cloneDate(event.start), minuteDelta)
        newEnd = undefined
        newEnd = addMinutes(cloneDate(event.end), minuteDelta)  if event.end
        timeElement.text formatDates(newStart, newEnd, opt("timeFormat"))
      resetElement = ->
      
        # convert back to original slot-event
        if allDay
          timeElement.css "display", "" # show() was causing display=inline
          eventElement.draggable "option", "grid", [colWidth, slotHeight]
          allDay = false
      origPosition = undefined
      allDay = false
      dayDelta = undefined
      minuteDelta = undefined
      prevMinuteDelta = undefined
      dis = (if opt("isRTL") then -1 else 1)
      hoverListener = getHoverListener()
      colCnt = getColCnt()
      colWidth = getColWidth()
      slotHeight = getSlotHeight()
      eventElement.draggable
        zIndex: 9
        scroll: false
        grid: [colWidth, slotHeight]
        axis: (if colCnt is 1 then "y" else false)
        opacity: opt("dragOpacity")
        revertDuration: opt("dragRevertDuration")
        start: (ev, ui) ->
          trigger "eventDragStart", eventElement, event, ev, ui
          hideEvents event, eventElement
          origPosition = eventElement.position()
          minuteDelta = prevMinuteDelta = 0
          hoverListener.start ((cell, origCell, rowDelta, colDelta) ->
            eventElement.draggable "option", "revert", not cell
            clearOverlays()
            if cell
              dayDelta = colDelta * dis
              if opt("allDaySlot") and not cell.row
                unless allDay
                  allDay = true
                  timeElement.hide()
                  eventElement.draggable "option", "grid", null
                renderDayOverlay addDays(cloneDate(event.start), dayDelta), addDays(exclEndDay(event), dayDelta)
              else
                resetElement()
          ), ev, "drag"

        drag: (ev, ui) ->
          minuteDelta = Math.round((ui.position.top - origPosition.top) / slotHeight) * opt("slotMinutes")
          unless minuteDelta is prevMinuteDelta
            updateTimeText minuteDelta  unless allDay
            prevMinuteDelta = minuteDelta

        stop: (ev, ui) ->
          cell = hoverListener.stop()
          clearOverlays()
          trigger "eventDragStop", eventElement, event, ev, ui
          if cell and (dayDelta or minuteDelta or allDay)
            eventDrop this, event, dayDelta, (if allDay then 0 else minuteDelta), allDay, ev, ui
          else
            resetElement()
            eventElement.css "filter", ""
            eventElement.css origPosition
            updateTimeText 0
            showEvents event, eventElement

  
    # Resizing
    #	--------------------------------------------------------------------------------------
    resizableSlotEvent = (event, eventElement, timeElement) ->
      slotDelta = undefined
      prevSlotDelta = undefined
      slotHeight = getSlotHeight()
      eventElement.resizable
        handles:
          s: "div.ui-resizable-s"

        grid: slotHeight
        start: (ev, ui) ->
          slotDelta = prevSlotDelta = 0
          hideEvents event, eventElement
          eventElement.css "z-index", 9
          trigger "eventResizeStart", this, event, ev, ui

        resize: (ev, ui) ->
        
          # don't rely on ui.size.height, doesn't take grid into account
          slotDelta = Math.round((Math.max(slotHeight, eventElement.height()) - ui.originalSize.height) / slotHeight)
          unless slotDelta is prevSlotDelta
            # no change, so don't display time range
            timeElement.text formatDates(event.start, (if (not slotDelta and not event.end) then null else addMinutes(eventEnd(event), opt("slotMinutes") * slotDelta)), opt("timeFormat"))
            prevSlotDelta = slotDelta

        stop: (ev, ui) ->
          trigger "eventResizeStop", this, event, ev, ui
          if slotDelta
            eventResize this, event, 0, opt("slotMinutes") * slotDelta, ev, ui
          else
            eventElement.css "z-index", 8
            showEvents event, eventElement

    @renderEvents = renderEvents
    @compileDaySegs = compileDaySegs
    @clearEvents = clearEvents
    @slotSegHtml = slotSegHtml
    @bindDaySeg = bindDaySeg
    DayEventRenderer.call t
    opt = @opt
    trigger = @trigger
    isEventDraggable = @isEventDraggable
    isEventResizable = @isEventResizable
    eventEnd = @eventEnd
    reportEvents = @reportEvents
    reportEventClear = @reportEventClear
    eventElementHandlers = @eventElementHandlers
    setHeight = @setHeight
    getDaySegmentContainer = @getDaySegmentContainer
    getSlotSegmentContainer = @getSlotSegmentContainer
    getHoverListener = @getHoverListener
    getMaxMinute = @getMaxMinute
    getMinMinute = @getMinMinute
    timePosition = @timePosition
    colContentLeft = @colContentLeft
    colContentRight = @colContentRight
    renderDaySegs = @renderDaySegs
    resizableDayEvent = @resizableDayEvent
    getColCnt = @getColCnt
    getColWidth = @getColWidth
    getSlotHeight = @getSlotHeight
    getBodyContent = @getBodyContent
    reportEventElement = @reportEventElement
    showEvents = @showEvents
    hideEvents = @hideEvents
    eventDrop = @eventDrop
    eventResize = @eventResize
    renderDayOverlay = @renderDayOverlay
    clearOverlays = @clearOverlays
    calendar = @calendar
    formatDate = calendar.formatDate
    formatDates = calendar.formatDates

  # BUG: if event was really short, need to put title back in span
  countForwardSegs = (levels) ->
    i = undefined
    j = undefined
    k = undefined
    level = undefined
    segForward = undefined
    segBack = undefined
    i = levels.length - 1
    while i > 0
      level = levels[i]
      j = 0
      while j < level.length
        segForward = level[j]
        k = 0
        while k < levels[i - 1].length
          segBack = levels[i - 1][k]
          segBack.forward = Math.max(segBack.forward or 0, (segForward.forward or 0) + 1)  if segsCollide(segForward, segBack)
          k++
        j++
      i--
)(window)