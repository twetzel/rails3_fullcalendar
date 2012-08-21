((window) ->
  DayEventRenderer = ->
  
    # exports
  
    # imports
    opt = @opt
    trigger = @trigger
    isEventDraggable = @isEventDraggable
    isEventResizable = @isEventResizable
    eventEnd = @eventEnd
    reportEventElement = @reportEventElement
    showEvents = @showEvents
    hideEvents = @hideEvents
    eventResize = @eventResize
    getRowCnt = @getRowCnt
    getColCnt = @getColCnt
    getColWidth = @getColWidth
    allDayRow = @allDayRow
    allDayBounds = @allDayBounds
    colContentLeft = @colContentLeft
    colContentRight = @colContentRight
    dayOfWeekCol = @dayOfWeekCol
    dateCell = @dateCell
    compileDaySegs = @compileDaySegs
    getDaySegmentContainer = @getDaySegmentContainer
    bindDaySeg = @bindDaySeg
    formatDates = @calendar.formatDates
    renderDayOverlay = @renderDayOverlay
    clearOverlays = @clearOverlays
    clearSelection = @clearSelection
    #TODO: streamline this
  
    # Rendering
    #	-----------------------------------------------------------------------------
    renderDaySegs = (segs, modifiedEventId, isResourceView) ->
      segmentContainer = getDaySegmentContainer()
      rowDivs = undefined
      rowCnt = getRowCnt()
      colCnt = getColCnt()
      i = 0
      rowI = undefined
      levelI = undefined
      colHeights = undefined
      j = undefined
      segCnt = segs.length
      seg = undefined
      top = undefined
      k = undefined
      segmentContainer[0].innerHTML = daySegHTML(segs, isResourceView) # faster than .html()
      daySegElementResolve segs, segmentContainer.children()
      daySegElementReport segs
      daySegHandlers segs, segmentContainer, modifiedEventId
      daySegCalcHSides segs
      daySegSetWidths segs
      daySegCalcHeights segs
      rowDivs = getRowDivs()
    
      # set row heights, calculate event tops (in relation to row top)
      rowI = 0
      while rowI < rowCnt
        levelI = 0
        colHeights = []
        j = 0
        while j < colCnt
          colHeights[j] = 0
          j++
        while i < segCnt and (seg = segs[i]).row is rowI
        
          # loop through segs in a row
          top = arrayMax(colHeights.slice(seg.startCol, seg.endCol))
          seg.top = top
          top += seg.outerHeight
          k = seg.startCol
          while k < seg.endCol
            colHeights[k] = top
            k++
          i++
        rowDivs[rowI].height arrayMax(colHeights)
        rowI++
      daySegSetTops segs, getRowTops(rowDivs)
    renderTempDaySegs = (segs, adjustRow, adjustTop) ->
      tempContainer = $("<div/>")
      elements = undefined
      segmentContainer = getDaySegmentContainer()
      i = undefined
      segCnt = segs.length
      element = undefined
      tempContainer[0].innerHTML = daySegHTML(segs) # faster than .html()
      elements = tempContainer.children()
      segmentContainer.append elements
      daySegElementResolve segs, elements
      daySegCalcHSides segs
      daySegSetWidths segs
      daySegCalcHeights segs
      daySegSetTops segs, getRowTops(getRowDivs())
      elements = []
      i = 0
      while i < segCnt
        element = segs[i].element
        if element
          element.css "top", adjustTop  if segs[i].row is adjustRow
          elements.push element[0]
        i++
      $ elements
    daySegHTML = (segs, isResourceView) -> # also sets seg.left and seg.outerWidth
      rtl = opt("isRTL")
      i = undefined
      segCnt = segs.length
      seg = undefined
      event = undefined
      url = undefined
      classes = undefined
      bounds = allDayBounds()
      minLeft = bounds.left
      maxLeft = bounds.right
      leftCol = undefined
      rightCol = undefined
      left = undefined
      right = undefined
      skinCss = $("")
      html = ""
    
      # calculate desired position/dimensions, create html
      i = 0
      while i < segCnt
        seg = segs[i]
        event = seg.event
        classes = ["fc-event", "fc-event-skin", "fc-event-hori"]
        classes.push "fc-event-draggable"  if isEventDraggable(event)
        if isResourceView
          classes.push "fc-corner-left"
          classes.push "fc-corner-right"
          if event.resource
            leftCol = event.resource._col
          else
            leftCol = 0
          rightCol = leftCol
          left = colContentLeft(leftCol)
          right = colContentRight(rightCol)
        else
          if rtl
            classes.push "fc-corner-right"  if seg.isStart
            classes.push "fc-corner-left"  if seg.isEnd
            leftCol = dayOfWeekCol(seg.end.getDay() - 1)
            rightCol = dayOfWeekCol(seg.start.getDay())
            left = (if seg.isEnd then colContentLeft(leftCol) else minLeft)
            right = (if seg.isStart then colContentRight(rightCol) else maxLeft)
          else
            classes.push "fc-corner-left"  if seg.isStart
            classes.push "fc-corner-right"  if seg.isEnd
            leftCol = dayOfWeekCol(seg.start.getDay())
            rightCol = dayOfWeekCol(seg.end.getDay() - 1)
            left = (if seg.isStart then colContentLeft(leftCol) else minLeft)
            right = (if seg.isEnd then colContentRight(rightCol) else maxLeft)
        classes = classes.concat(event.className)
        classes = classes.concat(event.source.className or [])  if event.source
        url = event.url
        if event.resource
          skinCss = getSkinCssWithResource(event, event.resource) # PA TODO - merge getSkinCssWithResource into getSkinCss
        else
          skinCss = getSkinCss(event, opt)
        if url
          html += "<a href='" + htmlEscape(url) + "'"
        else
          html += "<div"
        html += " class='" + classes.join(" ") + "'" + " style='position:absolute;z-index:8;left:" + left + "px;" + skinCss + "'" + ">" + "<div" + " class='fc-event-inner fc-event-skin'" + ((if skinCss then " style='" + skinCss + "'" else "")) + ">"
        html += "<span class='fc-event-time'>" + htmlEscape(formatDates(event.start, event.end, opt("timeFormat"))) + "</span>"  if not event.allDay and seg.isStart
        html += "<span class='fc-event-title'>" + htmlEscape(event.title) + "</span>" + "</div>"
        # makes hit area a lot better for IE6/7
        html += "<div class='ui-resizable-handle ui-resizable-" + ((if rtl then "w" else "e")) + "'>" + "&nbsp;&nbsp;&nbsp;" + "</div>"  if seg.isEnd and isEventResizable(event) and not (event.allDay and isResourceView)
        html += "</" + ((if url then "a" else "div")) + ">"
        seg.left = left
        seg.outerWidth = right - left
        seg.startCol = leftCol
        seg.endCol = rightCol + 1 # needs to be exclusive
        i++
      html
    daySegElementResolve = (segs, elements) -> # sets seg.element
      i = undefined
      segCnt = segs.length
      seg = undefined
      event = undefined
      element = undefined
      triggerRes = undefined
      i = 0
      while i < segCnt
        seg = segs[i]
        event = seg.event
        element = $(elements[i]) # faster than .eq()
        triggerRes = trigger("eventRender", event, event, element)
        if triggerRes is false
          element.remove()
        else
          if triggerRes and triggerRes isnt true
            triggerRes = $(triggerRes).css(
              position: "absolute"
              left: seg.left
            )
            element.replaceWith triggerRes
            element = triggerRes
          seg.element = element
        i++
    daySegElementReport = (segs) ->
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        reportEventElement seg.event, element  if element
        i++
    daySegHandlers = (segs, segmentContainer, modifiedEventId) ->
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      event = undefined
    
      # retrieve elements, run through eventRender callback, bind handlers
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        if element
          event = seg.event
          if event._id is modifiedEventId
            bindDaySeg event, element, seg
          else
            element[0]._fci = i # for lazySegBind
        i++
      lazySegBind segmentContainer, segs, bindDaySeg
    daySegCalcHSides = (segs) -> # also sets seg.key
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      key = undefined
      val = undefined
      hsideCache = {}
    
      # record event horizontal sides
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        if element
          key = seg.key = cssKey(element[0])
          val = hsideCache[key]
          val = hsideCache[key] = hsides(element, true)  if val is `undefined`
          seg.hsides = val
        i++
    daySegSetWidths = (segs) ->
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        element[0].style.width = Math.max(0, seg.outerWidth - seg.hsides) + "px"  if element
        i++
    daySegCalcHeights = (segs) ->
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      key = undefined
      val = undefined
      vmarginCache = {}
    
      # record event heights
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        if element
          key = seg.key # created in daySegCalcHSides
          val = vmarginCache[key]
          val = vmarginCache[key] = vmargins(element)  if val is `undefined`
          seg.outerHeight = element[0].offsetHeight + val
        i++
    getRowDivs = ->
      i = undefined
      rowCnt = getRowCnt()
      rowDivs = []
      i = 0
      while i < rowCnt
        rowDivs[i] = allDayRow(i).find("td:first div.fc-day-content > div") # optimal selector?
        i++
      rowDivs
    getRowTops = (rowDivs) ->
      i = undefined
      rowCnt = rowDivs.length
      tops = []
      i = 0
      while i < rowCnt
        tops[i] = rowDivs[i][0].offsetTop # !!?? but this means the element needs position:relative if in a table cell!!!!
        i++
      tops
    daySegSetTops = (segs, rowTops) -> # also triggers eventAfterRender
      i = undefined
      segCnt = segs.length
      seg = undefined
      element = undefined
      event = undefined
      i = 0
      while i < segCnt
        seg = segs[i]
        element = seg.element
        if element
          element[0].style.top = rowTops[seg.row] + (seg.top or 0) + "px"
          event = seg.event
          trigger "eventAfterRender", event, event, element
        i++
  
    # Resizing
    #	-----------------------------------------------------------------------------------
    resizableDayEvent = (event, element, seg) ->
      rtl = opt("isRTL")
      direction = (if rtl then "w" else "e")
      handle = element.find("div.ui-resizable-" + direction)
      isResizing = false
    
      # TODO: look into using jquery-ui mouse widget for this stuff
      disableTextSelection element # prevent native <a> selection for IE
      # prevent native <a> selection for others
      element.mousedown((ev) ->
        ev.preventDefault()
      ).click (ev) ->
        if isResizing
          ev.preventDefault() # prevent link from being visited (only method that worked in IE6)
          ev.stopImmediatePropagation() # prevent fullcalendar eventClick handler from being called

      # (eventElementHandlers needs to be bound after resizableDayEvent)
      handle.mousedown (ev) ->
        # needs to be left mouse button
        # hack for all-day area in agenda views
        # coordinate grid already rebuild at hoverListener.start
        mouseup = (ev) ->
          trigger "eventResizeStop", this, event, ev
          $("body").css "cursor", ""
          hoverListener.stop()
          clearOverlays()
          eventResize this, event, dayDelta, 0, ev  if dayDelta
        
          # event redraw will clear helpers
        
          # otherwise, the drag handler already restored the old events
          setTimeout (-> # make this happen after the element's click event
            isResizing = false
          ), 0
        return  unless ev.which is 1
        isResizing = true
        hoverListener = @getHoverListener()
        rowCnt = getRowCnt()
        colCnt = getColCnt()
        dis = (if rtl then -1 else 1)
        dit = (if rtl then colCnt - 1 else 0)
        elementTop = element.css("top")
        dayDelta = undefined
        helpers = undefined
        eventCopy = $.extend({}, event)
        minCell = dateCell(event.start)
        clearSelection()
        $("body").css("cursor", direction + "-resize").one "mouseup", mouseup
        trigger "eventResizeStart", this, event, ev
        hoverListener.start ((cell, origCell) ->
          if cell
            r = Math.max(minCell.row, cell.row)
            c = cell.col
            r = 0  if rowCnt is 1
            if r is minCell.row
              if rtl
                c = Math.min(minCell.col, c)
              else
                c = Math.max(minCell.col, c)
            dayDelta = (r * 7 + c * dis + dit) - (origCell.row * 7 + origCell.col * dis + dit)
            newEnd = addDays(eventEnd(event), dayDelta, true)
            if dayDelta
              eventCopy.end = newEnd
              oldHelpers = helpers
              helpers = renderTempDaySegs(compileDaySegs([eventCopy]), seg.row, elementTop)
              helpers.find("*").css "cursor", direction + "-resize"
              oldHelpers.remove()  if oldHelpers
              hideEvents event
            else
              if helpers
                showEvents event
                helpers.remove()
                helpers = null
            clearOverlays()
            renderDayOverlay event.start, addDays(cloneDate(newEnd), 1)
        ), ev

    t = this
    @renderDaySegs = renderDaySegs
    @resizableDayEvent = resizableDayEvent
    
)(window)