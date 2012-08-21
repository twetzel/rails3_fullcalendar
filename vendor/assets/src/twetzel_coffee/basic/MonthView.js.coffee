((window) ->
  MonthView = (element, calendar) ->
  
    # exports
  
    # imports
    render = (date, delta) ->
      if delta
        addMonths date, delta
        date.setDate 1
      start = cloneDate(date, true)
      start.setDate 1
      end = addMonths(cloneDate(start), 1)
      visStart = cloneDate(start)
      visEnd = cloneDate(end)
      firstDay = opt("firstDay")
      nwe = (if opt("weekends") then 0 else 1)
      if nwe
        skipWeekend visStart
        skipWeekend visEnd, -1, true
      addDays visStart, -((visStart.getDay() - Math.max(firstDay, nwe) + 7) % 7)
      addDays visEnd, (7 - visEnd.getDay() + Math.max(firstDay, nwe)) % 7
      rowCnt = Math.round((visEnd - visStart) / (DAY_MS * 7))
      if opt("weekMode") is "fixed"
        addDays visEnd, (6 - rowCnt) * 7
        rowCnt = 6
      @title = formatDate(start, opt("titleFormat"))
      @start = start
      @end = end
      @visStart = visStart
      @visEnd = visEnd
      renderBasic 6, rowCnt, (if nwe then 5 else 7), true
    t = this
    @render = render
    BasicView.call t, element, calendar, "month"
    opt = @opt
    renderBasic = @renderBasic
    formatDate = calendar.formatDate
  fcViews.month = MonthView
)(window)