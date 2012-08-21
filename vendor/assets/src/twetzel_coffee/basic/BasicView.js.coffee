((window) ->
  BasicView = (element, calendar, viewName) ->
  
    # exports
    # for selection (kinda hacky)
  
    # imports
    opt = @opt
    trigger = @trigger
    clearEvents = @clearEvents
    renderOverlay = @renderOverlay
    clearOverlays = @clearOverlays
    daySelectionMousedown = @daySelectionMousedown
    formatDate = calendar.formatDate
    head = undefined
    headCells = undefined
    body = undefined
    bodyRows = undefined
    bodyCells = undefined
    bodyFirstCells = undefined
    bodyCellTopInners = undefined
    daySegmentContainer = undefined
    viewWidth = undefined
    viewHeight = undefined
    colWidth = undefined
    rowCnt = undefined
    colCnt = undefined
    coordinateGrid = undefined
    hoverListener = undefined
    colContentPositions = undefined
    rtl = undefined
    dis = undefined
    dit = undefined
    firstDay = undefined
    nwe = undefined
    tm = undefined
    colFormat = undefined
  
    # locals
  
    # Rendering
    #	------------------------------------------------------------
    renderBasic = (maxr, r, c, showNumbers) ->
      rowCnt = r
      colCnt = c
      updateOptions()
      firstTime = not body
      if firstTime
        buildSkeleton maxr, showNumbers
      else
        clearEvents()
      updateCells firstTime
    updateOptions = ->
      rtl = opt("isRTL")
      if rtl
        dis = -1
        dit = colCnt - 1
      else
        dis = 1
        dit = 0
      firstDay = opt("firstDay")
      nwe = (if opt("weekends") then 0 else 1)
      tm = (if opt("theme") then "ui" else "fc")
      colFormat = opt("columnFormat")
    buildSkeleton = (maxRowCnt, showNumbers) ->
      s = undefined
      headerClass = tm + "-widget-header"
      contentClass = tm + "-widget-content"
      i = undefined
      j = undefined
      table = undefined
      s = "<table class='fc-border-separate' style='width:100%' cellspacing='0'>" + "<thead>" + "<tr>"
      i = 0
      while i < colCnt
        s += "<th class='fc- " + headerClass + "'/>" # need fc- for setDayID
        i++
      s += "</tr>" + "</thead>" + "<tbody>"
      i = 0
      while i < maxRowCnt
        s += "<tr class='fc-week" + i + "'>"
        j = 0
        while j < colCnt
          # need fc- for setDayID
          s += "<td class='fc- " + contentClass + " fc-day" + (i * colCnt + j) + "'>" + "<div>" + ((if showNumbers then "<div class='fc-day-number'/>" else "")) + "<div class='fc-day-content'>" + "<div style='position:relative'>&nbsp;</div>" + "</div>" + "</div>" + "</td>"
          j++
        s += "</tr>"
        i++
      s += "</tbody>" + "</table>"
      table = $(s).appendTo(element)
      head = table.find("thead")
      headCells = head.find("th")
      body = table.find("tbody")
      bodyRows = body.find("tr")
      bodyCells = body.find("td")
      bodyFirstCells = bodyCells.filter(":first-child")
      bodyCellTopInners = bodyRows.eq(0).find("div.fc-day-content div")
      markFirstLast head.add(head.find("tr")) # marks first+last tr/th's
      markFirstLast bodyRows # marks first+last td's
      bodyRows.eq(0).addClass "fc-first" # fc-last is done in updateCells
      dayBind bodyCells
      daySegmentContainer = $("<div style='position:absolute;z-index:8;top:0;left:0'/>").appendTo(element)
    updateCells = (firstTime) ->
      dowDirty = firstTime or rowCnt is 1 # could the cells' day-of-weeks need updating?
      month = @start.getMonth()
      today = clearTime(new Date())
      cell = undefined
      date = undefined
      row = undefined
      if dowDirty
        headCells.each (i, _cell) ->
          cell = $(_cell)
          date = indexDate(i)
          cell.html formatDate(date, colFormat)
          setDayID cell, date

      bodyCells.each (i, _cell) ->
        cell = $(_cell)
        date = indexDate(i)
        if date.getMonth() is month
          cell.removeClass "fc-other-month"
        else
          cell.addClass "fc-other-month"
        if +date is +today
          cell.addClass tm + "-state-highlight fc-today"
        else
          cell.removeClass tm + "-state-highlight fc-today"
        cell.find("div.fc-day-number").text date.getDate()
        setDayID cell, date  if dowDirty

      bodyRows.each (i, _row) ->
        row = $(_row)
        if i < rowCnt
          row.show()
          if i is rowCnt - 1
            row.addClass "fc-last"
          else
            row.removeClass "fc-last"
        else
          row.hide()

    setHeight = (height) ->
      viewHeight = height
      bodyHeight = viewHeight - head.height()
      rowHeight = undefined
      rowHeightLast = undefined
      cell = undefined
      if opt("weekMode") is "variable"
        rowHeight = rowHeightLast = Math.floor(bodyHeight / ((if rowCnt is 1 then 2 else 6)))
      else
        rowHeight = Math.floor(bodyHeight / rowCnt)
        rowHeightLast = bodyHeight - rowHeight * (rowCnt - 1)
      bodyFirstCells.each (i, _cell) ->
        if i < rowCnt
          cell = $(_cell)
          setMinHeight cell.find("> div"), ((if i is rowCnt - 1 then rowHeightLast else rowHeight)) - vsides(cell)

    setWidth = (width) ->
      viewWidth = width
      colContentPositions.clear()
      colWidth = Math.floor(viewWidth / colCnt)
      setOuterWidth headCells.slice(0, -1), colWidth
  
    # Day clicking and binding
    #	-----------------------------------------------------------
    dayBind = (days) ->
      days.click(dayClick).mousedown daySelectionMousedown
    dayClick = (ev) ->
      unless opt("selectable") # if selectable, SelectionManager will worry about dayClick
        index = parseInt(@className.match(/fc\-day(\d+)/)[1]) # TODO: maybe use .data
        date = indexDate(index)
        trigger "dayClick", this, date, true, ev
  
    # Semi-transparent Overlay Helpers
    #	------------------------------------------------------
    renderDayOverlay = (overlayStart, overlayEnd, refreshCoordinateGrid) -> # overlayEnd is exclusive
      coordinateGrid.build()  if refreshCoordinateGrid
      rowStart = cloneDate(t.visStart)
      rowEnd = addDays(cloneDate(rowStart), colCnt)
      i = 0

      while i < rowCnt
        stretchStart = new Date(Math.max(rowStart, overlayStart))
        stretchEnd = new Date(Math.min(rowEnd, overlayEnd))
        if stretchStart < stretchEnd
          colStart = undefined
          colEnd = undefined
          if rtl
            colStart = dayDiff(stretchEnd, rowStart) * dis + dit + 1
            colEnd = dayDiff(stretchStart, rowStart) * dis + dit + 1
          else
            colStart = dayDiff(stretchStart, rowStart)
            colEnd = dayDiff(stretchEnd, rowStart)
          dayBind renderCellOverlay(i, colStart, i, colEnd - 1)
        addDays rowStart, 7
        addDays rowEnd, 7
        i++
    renderCellOverlay = (row0, col0, row1, col1) -> # row1,col1 is inclusive
      rect = coordinateGrid.rect(row0, col0, row1, col1, element)
      renderOverlay rect, element
  
    # Selection
    #	-----------------------------------------------------------------------
    defaultSelectionEnd = (startDate, allDay) ->
      cloneDate startDate
    renderSelection = (startDate, endDate, allDay) ->
      renderDayOverlay startDate, addDays(cloneDate(endDate), 1), true # rebuild every time???
    clearSelection = ->
      clearOverlays()
    reportDayClick = (date, allDay, ev) ->
      cell = dateCell(date)
      _element = bodyCells[cell.row * colCnt + cell.col]
      trigger "dayClick", _element, date, allDay, ev
  
    # External Dragging
    #	-----------------------------------------------------------------------
    dragStart = (_dragElement, ev, ui) ->
      hoverListener.start ((cell) ->
        clearOverlays()
        renderCellOverlay cell.row, cell.col, cell.row, cell.col  if cell
      ), ev
    dragStop = (_dragElement, ev, ui) ->
      cell = hoverListener.stop()
      clearOverlays()
      if cell
        d = cellDate(cell)
        trigger "drop", _dragElement, d, true, ev, ui, false
  
    # Utilities
    #	--------------------------------------------------------
    defaultEventEnd = (event) ->
      cloneDate event.start
    colContentLeft = (col) ->
      colContentPositions.left col
    colContentRight = (col) ->
      colContentPositions.right col
    dateCell = (date) ->
      row: Math.floor(dayDiff(date, @visStart) / 7)
      col: dayOfWeekCol(date.getDay())
    cellDate = (cell) ->
      _cellDate cell.row, cell.col
    _cellDate = (row, col) ->
      addDays cloneDate(t.visStart), row * 7 + col * dis + dit
  
    # what about weekends in middle of week?
    indexDate = (index) ->
      _cellDate Math.floor(index / colCnt), index % colCnt
    dayOfWeekCol = (dayOfWeek) ->
      ((dayOfWeek - Math.max(firstDay, nwe) + colCnt) % colCnt) * dis + dit
    allDayRow = (i) ->
      bodyRows.eq i
    allDayBounds = (i) ->
      left: 0
      right: viewWidth
    t = this
    @renderBasic = renderBasic
    @setHeight = setHeight
    @setWidth = setWidth
    @renderDayOverlay = renderDayOverlay
    @defaultSelectionEnd = defaultSelectionEnd
    @renderSelection = renderSelection
    @clearSelection = clearSelection
    @reportDayClick = reportDayClick
    @dragStart = dragStart
    @dragStop = dragStop
    @defaultEventEnd = defaultEventEnd
    @getHoverListener = ->
      hoverListener

    @colContentLeft = colContentLeft
    @colContentRight = colContentRight
    @dayOfWeekCol = dayOfWeekCol
    @dateCell = dateCell
    @cellDate = cellDate
    @cellIsAllDay = ->
      true

    @allDayRow = allDayRow
    @allDayBounds = allDayBounds
    @getRowCnt = ->
      rowCnt

    @getColCnt = ->
      colCnt

    @getColWidth = ->
      colWidth

    @getDaySegmentContainer = ->
      daySegmentContainer

    View.call t, element, calendar, viewName
    OverlayManager.call t
    SelectionManager.call t
    BasicEventRenderer.call t
    
    disableTextSelection element.addClass("fc-grid")
    coordinateGrid = new CoordinateGrid((rows, cols) ->
      e = undefined
      n = undefined
      p = undefined
      headCells.each (i, _e) ->
        e = $(_e)
        n = e.offset().left
        p[1] = n  if i
        p = [n]
        cols[i] = p

      p[1] = n + e.outerWidth()
      bodyRows.each (i, _e) ->
        if i < rowCnt
          e = $(_e)
          n = e.offset().top
          p[1] = n  if i
          p = [n]
          rows[i] = p

      p[1] = n + e.outerHeight()
    )
    hoverListener = new HoverListener(coordinateGrid)
    colContentPositions = new HorizontalPositionCache((col) ->
      bodyCellTopInners.eq col
    )
  setDefaults weekMode: "fixed"
)(window)