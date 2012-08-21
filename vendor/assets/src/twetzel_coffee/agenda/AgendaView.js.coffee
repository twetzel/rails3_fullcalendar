((window) ->
  # TODO: make it work in quirks mode (event corners, all-day height)
  # TODO: test liquid width, especially in IE6
  AgendaView = (element, calendar, viewName) ->
  
    # exports
    # !!??
    # selection mousedown hack
  
    # imports
    opt = @opt
    trigger = @trigger
    clearEvents = @clearEvents
    renderOverlay = @renderOverlay
    clearOverlays = @clearOverlays
    reportSelection = @reportSelection
    unselect = @unselect
    daySelectionMousedown = @daySelectionMousedown
    slotSegHtml = @slotSegHtml
    
    
    # locals
    formatDate = calendar.formatDate
    dayTable = undefined
    dayHead = undefined
    dayHeadCells = undefined
    dayBody = undefined
    dayBodyCells = undefined
    dayBodyCellInners = undefined
    dayBodyFirstCell = undefined
    dayBodyFirstCellStretcher = undefined
    slotLayer = undefined
    daySegmentContainer = undefined
    allDayTable = undefined
    allDayRow = undefined
    slotScroller = undefined
    slotContent = undefined
    slotSegmentContainer = undefined
    slotTable = undefined
    slotTableFirstInner = undefined
    axisFirstCells = undefined
    gutterCells = undefined
    selectionHelper = undefined
    viewWidth = undefined
    viewHeight = undefined
    axisWidth = undefined
    colWidth = undefined
    gutterWidth = undefined
    slotHeight = undefined
    savedScrollTop = undefined
    colCnt = undefined
    slotCnt = undefined
    coordinateGrid = undefined
    hoverListener = undefined
    colContentPositions = undefined
    slotTopCache = {}
    tm = undefined
    firstDay = undefined
    nwe = undefined
    rtl = undefined
    dis = undefined
    dit = undefined
    minMinute = undefined
    maxMinute = undefined
    colFormat = undefined
    
    # TODO: what if slotHeight changes? (see issue 650)
    # no weekends (int)
    # day index sign / translate
  
    # Rendering
    #	-----------------------------------------------------------------------------
    renderAgenda = (c) ->
      colCnt = c
      updateOptions()
      unless dayTable
        buildSkeleton()
      else
        clearEvents()
      updateCells()
    updateOptions = ->
      tm = (if opt("theme") then "ui" else "fc")
      nwe = (if opt("weekends") then 0 else 1)
      firstDay = opt("firstDay")
      if rtl = opt("isRTL")
        dis = -1
        dit = colCnt - 1
      else
        dis = 1
        dit = 0
      minMinute = parseTime(opt("minTime"))
      maxMinute = parseTime(opt("maxTime"))
      colFormat = opt("columnFormat")
    buildSkeleton = ->
      headerClass = tm + "-widget-header"
      contentClass = tm + "-widget-content"
      s = undefined
      i = undefined
      d = undefined
      maxd = undefined
      minutes = undefined
      slotNormal = opt("slotMinutes") % 15 is 0
      s = "<table style='width:100%' class='fc-agenda-days fc-border-separate' cellspacing='0'>" + "<thead>" + "<tr>" + "<th class='fc-agenda-axis " + headerClass + "'>&nbsp;</th>"
      i = 0
      while i < colCnt
        s += "<th class='fc- fc-col" + i + " " + headerClass + "'/>" # fc- needed for setDayID
        i++
      s += "<th class='fc-agenda-gutter " + headerClass + "'>&nbsp;</th>" + "</tr>" + "</thead>" + "<tbody>" + "<tr>" + "<th class='fc-agenda-axis " + headerClass + "'>&nbsp;</th>"
      i = 0
      while i < colCnt
        # fc- needed for setDayID
        s += "<td class='fc- fc-col" + i + " " + contentClass + "'>" + "<div>" + "<div class='fc-day-content'>" + "<div style='position:relative'>&nbsp;</div>" + "</div>" + "</div>" + "</td>"
        i++
      s += "<td class='fc-agenda-gutter " + contentClass + "'>&nbsp;</td>" + "</tr>" + "</tbody>" + "</table>"
      dayTable = $(s).appendTo(element)
      dayHead = dayTable.find("thead")
      dayHeadCells = dayHead.find("th").slice(1, -1)
      dayBody = dayTable.find("tbody")
      dayBodyCells = dayBody.find("td").slice(0, -1)
      dayBodyCellInners = dayBodyCells.find("div.fc-day-content div")
      dayBodyFirstCell = dayBodyCells.eq(0)
      dayBodyFirstCellStretcher = dayBodyFirstCell.find("> div")
      markFirstLast dayHead.add(dayHead.find("tr"))
      markFirstLast dayBody.add(dayBody.find("tr"))
      axisFirstCells = dayHead.find("th:first")
      gutterCells = dayTable.find(".fc-agenda-gutter")
      slotLayer = $("<div style='position:absolute;z-index:2;left:0;width:100%'/>").appendTo(element)
      if opt("allDaySlot")
        daySegmentContainer = $("<div style='position:absolute;z-index:8;top:0;left:0'/>").appendTo(slotLayer)
        s = "<table style='width:100%' class='fc-agenda-allday' cellspacing='0'>" + "<tr>" + "<th class='" + headerClass + " fc-agenda-axis'>" + opt("allDayText") + "</th>" + "<td>" + "<div class='fc-day-content'><div style='position:relative'/></div>" + "</td>" + "<th class='" + headerClass + " fc-agenda-gutter'>&nbsp;</th>" + "</tr>" + "</table>"
        allDayTable = $(s).appendTo(slotLayer)
        allDayRow = allDayTable.find("tr")
        dayBind allDayRow.find("td")
        axisFirstCells = axisFirstCells.add(allDayTable.find("th:first"))
        gutterCells = gutterCells.add(allDayTable.find("th.fc-agenda-gutter"))
        slotLayer.append "<div class='fc-agenda-divider " + headerClass + "'>" + "<div class='fc-agenda-divider-inner'/>" + "</div>"
      else
        daySegmentContainer = $([]) # in jQuery 1.4, we can just do $()
      slotScroller = $("<div style='position:absolute;width:100%;overflow-x:hidden;overflow-y:auto'/>").appendTo(slotLayer)
      slotContent = $("<div style='position:relative;width:100%;overflow:hidden'/>").appendTo(slotScroller)
      slotSegmentContainer = $("<div style='position:absolute;z-index:8;top:0;left:0'/>").appendTo(slotContent)
      s = "<table class='fc-agenda-slots' style='width:100%' cellspacing='0'>" + "<tbody>"
      d = zeroDate()
      maxd = addMinutes(cloneDate(d), maxMinute)
      addMinutes d, minMinute
      slotCnt = 0
      i = 0
      while d < maxd
        minutes = d.getMinutes()
        s += "<tr class='fc-slot" + i + " " + ((if not minutes then "" else "fc-minor")) + "'>" + "<th class='fc-agenda-axis " + headerClass + "'>" + ((if (not slotNormal or not minutes) then formatDate(d, opt("axisFormat")) else "&nbsp;")) + "</th>" + "<td class='" + contentClass + "'>" + "<div style='position:relative'>&nbsp;</div>" + "</td>" + "</tr>"
        addMinutes d, opt("slotMinutes")
        slotCnt++
        i++
      s += "</tbody>" + "</table>"
      slotTable = $(s).appendTo(slotContent)
      slotTableFirstInner = slotTable.find("div:first")
      slotBind slotTable.find("td")
      axisFirstCells = axisFirstCells.add(slotTable.find("th:first"))
    updateCells = ->
      i = undefined
      headCell = undefined
      bodyCell = undefined
      date = undefined
      today = clearTime(new Date())
      i = 0
      while i < colCnt
        date = colDate(i)
        headCell = dayHeadCells.eq(i)
        headCell.html formatDate(date, colFormat)
        bodyCell = dayBodyCells.eq(i)
        if +date is +today
          bodyCell.addClass tm + "-state-highlight fc-today"
        else
          bodyCell.removeClass tm + "-state-highlight fc-today"
        setDayID headCell.add(bodyCell), date
        i++
    setHeight = (height, dateChanged) ->
      height = viewHeight  if height is `undefined`
      viewHeight = height
      slotTopCache = {}
      headHeight = dayBody.position().top
      allDayHeight = slotScroller.position().top # including divider
      # total body height, including borders
      # when scrollbars
      bodyHeight = Math.min(height - headHeight, slotTable.height() + allDayHeight + 1) # when no scrollbars. +1 for bottom border
      dayBodyFirstCellStretcher.height bodyHeight - vsides(dayBodyFirstCell)
      slotLayer.css "top", headHeight
      slotScroller.height bodyHeight - allDayHeight - 1
      slotHeight = slotTableFirstInner.height() + 1 # +1 for border
      resetScroll()  if dateChanged
    setWidth = (width) ->
      viewWidth = width
      colContentPositions.clear()
      axisWidth = 0
      setOuterWidth axisFirstCells.width("").each((i, _cell) ->
        axisWidth = Math.max(axisWidth, $(_cell).outerWidth())
      ), axisWidth
      slotTableWidth = slotScroller[0].clientWidth # needs to be done after axisWidth (for IE7)
      #slotTable.width(slotTableWidth);
      gutterWidth = slotScroller.width() - slotTableWidth
      if gutterWidth
        setOuterWidth gutterCells, gutterWidth
        gutterCells.show().prev().removeClass "fc-last"
      else
        gutterCells.hide().prev().addClass "fc-last"
      colWidth = Math.floor((slotTableWidth - axisWidth) / colCnt)
      setOuterWidth dayHeadCells.slice(0, -1), colWidth
    resetScroll = ->
      # +1 for the border
      scroll = ->
        slotScroller.scrollTop top
      d0 = zeroDate()
      scrollDate = cloneDate(d0)
      scrollDate.setHours opt("firstHour")
      top = timePosition(d0, scrollDate) + 1
      scroll()
      setTimeout scroll, 0 # overrides any previous scroll state made by the browser
    beforeHide = ->
      savedScrollTop = slotScroller.scrollTop()
    afterShow = ->
      slotScroller.scrollTop savedScrollTop
  
    # Slot/Day clicking and binding
    #	-----------------------------------------------------------------------
    dayBind = (cells) ->
      cells.click(slotClick).mousedown daySelectionMousedown
    slotBind = (cells) ->
      cells.click(slotClick).mousedown slotSelectionMousedown
    slotClick = (ev) ->
      unless opt("selectable") # if selectable, SelectionManager will worry about dayClick
        col = Math.min(colCnt - 1, Math.floor((ev.pageX - dayTable.offset().left - axisWidth) / colWidth))
        date = colDate(col)
        rowMatch = @parentNode.className.match(/fc-slot(\d+)/) # TODO: maybe use data
        if rowMatch
          mins = parseInt(rowMatch[1]) * opt("slotMinutes")
          hours = Math.floor(mins / 60)
          date.setHours hours
          date.setMinutes mins % 60 + minMinute
          trigger "dayClick", dayBodyCells[col], date, false, ev
        else
          trigger "dayClick", dayBodyCells[col], date, true, ev
  
    # Semi-transparent Overlay Helpers
    #	-----------------------------------------------------
    renderDayOverlay = (startDate, endDate, refreshCoordinateGrid) -> # endDate is exclusive
      coordinateGrid.build()  if refreshCoordinateGrid
      visStart = cloneDate(t.visStart)
      startCol = undefined
      endCol = undefined
      if rtl
        startCol = dayDiff(endDate, visStart) * dis + dit + 1
        endCol = dayDiff(startDate, visStart) * dis + dit + 1
      else
        startCol = dayDiff(startDate, visStart)
        endCol = dayDiff(endDate, visStart)
      startCol = Math.max(0, startCol)
      endCol = Math.min(colCnt, endCol)
      dayBind renderCellOverlay(0, startCol, 0, endCol - 1)  if startCol < endCol
    renderCellOverlay = (row0, col0, row1, col1) -> # only for all-day?
      rect = coordinateGrid.rect(row0, col0, row1, col1, slotLayer)
      renderOverlay rect, slotLayer
    renderSlotOverlay = (overlayStart, overlayEnd) ->
      dayStart = cloneDate(t.visStart)
      dayEnd = addDays(cloneDate(dayStart), 1)
      i = 0

      while i < colCnt
        stretchStart = new Date(Math.max(dayStart, overlayStart))
        stretchEnd = new Date(Math.min(dayEnd, overlayEnd))
        if stretchStart < stretchEnd
          col = i * dis + dit
          rect = coordinateGrid.rect(0, col, 0, col, slotContent) # only use it for horizontal coords
          top = timePosition(dayStart, stretchStart)
          bottom = timePosition(dayStart, stretchEnd)
          rect.top = top
          rect.height = bottom - top
          slotBind renderOverlay(rect, slotContent)
        addDays dayStart, 1
        addDays dayEnd, 1
        i++
  
    # Coordinate Utilities
    #	-----------------------------------------------------------------------------
    colContentLeft = (col) ->
      colContentPositions.left col
    colContentRight = (col) ->
      colContentPositions.right col
    dateCell = (date) -> # "cell" terminology is now confusing
      row: Math.floor(dayDiff(date, @visStart) / 7)
      col: dayOfWeekCol(date.getDay())
    cellDate = (cell) ->
      d = colDate(cell.col)
      slotIndex = cell.row
      slotIndex--  if opt("allDaySlot")
      addMinutes d, minMinute + slotIndex * opt("slotMinutes")  if slotIndex >= 0
      d
    colDate = (col) -> # returns dates with 00:00:00
      addDays cloneDate(t.visStart), col * dis + dit
    cellIsAllDay = (cell) ->
      opt("allDaySlot") and not cell.row
    dayOfWeekCol = (dayOfWeek) ->
      ((dayOfWeek - Math.max(firstDay, nwe) + colCnt) % colCnt) * dis + dit
  
    # get the Y coordinate of the given time on the given day (both Date objects)
    timePosition = (day, time) -> # both date objects. day holds 00:00 of current day
      day = cloneDate(day, true)
      return 0  if time < addMinutes(cloneDate(day), minMinute)
      return slotTable.height()  if time >= addMinutes(cloneDate(day), maxMinute)
      slotMinutes = opt("slotMinutes")
      minutes = time.getHours() * 60 + time.getMinutes() - minMinute
      slotI = Math.floor(minutes / slotMinutes)
      slotTop = slotTopCache[slotI]
      slotTop = slotTopCache[slotI] = slotTable.find("tr:eq(" + slotI + ") td div")[0].offsetTop  if slotTop is `undefined` #.position().top; // need this optimization???
      Math.max 0, Math.round(slotTop - 1 + slotHeight * ((minutes % slotMinutes) / slotMinutes))
    allDayBounds = ->
      left: axisWidth
      right: viewWidth - gutterWidth
    getAllDayRow = (index) ->
      allDayRow
    defaultEventEnd = (event) ->
      start = cloneDate(event.start)
      return start  if event.allDay
      addMinutes start, opt("defaultEventMinutes")
  
    # Selection
    #	---------------------------------------------------------------------------------
    defaultSelectionEnd = (startDate, allDay) ->
      return cloneDate(startDate)  if allDay
      addMinutes cloneDate(startDate), opt("slotMinutes")
    renderSelection = (startDate, endDate, allDay) -> # only for all-day
      if allDay
        renderDayOverlay startDate, addDays(cloneDate(endDate), 1), true  if opt("allDaySlot")
      else
        renderSlotSelection startDate, endDate
    renderSlotSelection = (startDate, endDate) ->
      helperOption = opt("selectHelper")
      coordinateGrid.build()
      if helperOption
        col = dayDiff(startDate, @visStart) * dis + dit
        if col >= 0 and col < colCnt # only works when times are on same day
          rect = coordinateGrid.rect(0, col, 0, col, slotContent) # only for horizontal coords
          top = timePosition(startDate, startDate)
          bottom = timePosition(startDate, endDate)
          if bottom > top # protect against selections that are entirely before or after visible range
            rect.top = top
            rect.height = bottom - top
            rect.left += 2
            rect.width -= 5
            if $.isFunction(helperOption)
              helperRes = helperOption(startDate, endDate)
              if helperRes
                rect.position = "absolute"
                rect.zIndex = 8
                selectionHelper = $(helperRes).css(rect).appendTo(slotContent)
            else
              rect.isStart = true # conside rect a "seg" now
              rect.isEnd = true #
              selectionHelper = $(slotSegHtml(
                title: ""
                start: startDate
                end: endDate
                className: ["fc-select-helper"]
                editable: false
              , rect))
              selectionHelper.css "opacity", opt("dragOpacity")
            if selectionHelper
              slotBind selectionHelper
              slotContent.append selectionHelper
              setOuterWidth selectionHelper, rect.width, true # needs to be after appended
              setOuterHeight selectionHelper, rect.height, true
      else
        renderSlotOverlay startDate, endDate
    clearSelection = ->
      clearOverlays()
      if selectionHelper
        selectionHelper.remove()
        selectionHelper = null
    slotSelectionMousedown = (ev) ->
      if ev.which is 1 and opt("selectable") # ev.which==1 means left mouse button
        unselect ev
        dates = undefined
        hoverListener.start ((cell, origCell) ->
          clearSelection()
          if cell and cell.col is origCell.col and not cellIsAllDay(cell)
            d1 = cellDate(origCell)
            d2 = cellDate(cell)
            dates = [d1, addMinutes(cloneDate(d1), opt("slotMinutes")), d2, addMinutes(cloneDate(d2), opt("slotMinutes"))].sort(cmp)
            renderSlotSelection dates[0], dates[3]
          else
            dates = null
        ), ev
        $(document).one "mouseup", (ev) ->
          hoverListener.stop()
          if dates
            reportDayClick dates[0], false, ev  if +dates[0] is +dates[1]
            reportSelection dates[0], dates[3], false, ev

    reportDayClick = (date, allDay, ev) ->
      trigger "dayClick", dayBodyCells[dayOfWeekCol(date.getDay())], date, allDay, ev
  
    # External Dragging
    #	--------------------------------------------------------------------------------
    dragStart = (_dragElement, ev, ui) ->
      hoverListener.start ((cell) ->
        clearOverlays()
        if cell
          if cellIsAllDay(cell)
            renderCellOverlay cell.row, cell.col, cell.row, cell.col
          else
            d1 = cellDate(cell)
            d2 = addMinutes(cloneDate(d1), opt("defaultEventMinutes"))
            renderSlotOverlay d1, d2
      ), ev
    dragStop = (_dragElement, ev, ui) ->
      cell = hoverListener.stop()
      clearOverlays()
      trigger "drop", _dragElement, cellDate(cell), cellIsAllDay(cell), ev, ui, false  if cell

    @renderAgenda = renderAgenda
    @setWidth = setWidth
    @setHeight = setHeight
    @beforeHide = beforeHide
    @afterShow = afterShow
    @defaultEventEnd = defaultEventEnd
    @timePosition = timePosition
    @dayOfWeekCol = dayOfWeekCol
    @dateCell = dateCell
    @cellDate = cellDate
    @cellIsAllDay = cellIsAllDay
    @allDayRow = getAllDayRow
    @allDayBounds = allDayBounds
    @getHoverListener = ->
      hoverListener

    @colContentLeft = colContentLeft
    @colContentRight = colContentRight
    @getDaySegmentContainer = ->
      daySegmentContainer

    @getSlotSegmentContainer = ->
      slotSegmentContainer

    @getMinMinute = ->
      minMinute

    @getMaxMinute = ->
      maxMinute

    @getBodyContent = ->
      slotContent

    @getRowCnt = ->
      1

    @getColCnt = ->
      colCnt

    @getColWidth = ->
      colWidth

    @getSlotHeight = ->
      slotHeight

    @defaultSelectionEnd = defaultSelectionEnd
    @renderDayOverlay = renderDayOverlay
    @renderSelection = renderSelection
    @clearSelection = clearSelection
    @reportDayClick = reportDayClick
    @dragStart = dragStart
    @dragStop = dragStop
    View.call t, element, calendar, viewName
    OverlayManager.call t
    SelectionManager.call t
    AgendaEventRenderer.call t
    
    disableTextSelection element.addClass("fc-agenda")
    coordinateGrid = new CoordinateGrid((rows, cols) ->
      constrain = (n) ->
        Math.max slotScrollerTop, Math.min(slotScrollerBottom, n)
      e = undefined
      n = undefined
      p = undefined
      dayHeadCells.each (i, _e) ->
        e = $(_e)
        n = e.offset().left
        p[1] = n  if i
        p = [n]
        cols[i] = p

      p[1] = n + e.outerWidth()
      if opt("allDaySlot")
        e = allDayRow
        n = e.offset().top
        rows[0] = [n, n + e.outerHeight()]
      slotTableTop = slotContent.offset().top
      slotScrollerTop = slotScroller.offset().top
      slotScrollerBottom = slotScrollerTop + slotScroller.outerHeight()
      i = 0

      while i < slotCnt
        rows.push [constrain(slotTableTop + slotHeight * i), constrain(slotTableTop + slotHeight * (i + 1))]
        i++
    )
    hoverListener = new HoverListener(coordinateGrid)
    colContentPositions = new HorizontalPositionCache((col) ->
      dayBodyCellInners.eq col
    )
  setDefaults
    allDaySlot: true
    allDayText: "all-day"
    firstHour: 6
    slotMinutes: 30
    defaultEventMinutes: 120
    axisFormat: "h(:mm)tt"
    timeFormat:
      agenda: "h:mm{ - h:mm}"

    dragOpacity:
      agenda: .5

    minTime: 0
    maxTime: 24
)(window)