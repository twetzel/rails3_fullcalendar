((window) ->
  BasicWeekView = (element, calendar) ->
  
    # exports
  
    # imports
    render = (date, delta) ->
      addDays date, delta * 7  if delta
      start = addDays(cloneDate(date), -((date.getDay() - opt("firstDay") + 7) % 7))
      end = addDays(cloneDate(start), 7)
      visStart = cloneDate(start)
      visEnd = cloneDate(end)
      weekends = opt("weekends")
      unless weekends
        skipWeekend visStart
        skipWeekend visEnd, -1, true
      @title = formatDates(visStart, addDays(cloneDate(visEnd), -1), opt("titleFormat"))
      @start = start
      @end = end
      @visStart = visStart
      @visEnd = visEnd
      renderBasic 1, 1, (if weekends then 7 else 5), false
    t = this
    @render = render
    BasicView.call t, element, calendar, "basicWeek"
    opt = @opt
    renderBasic = @renderBasic
    formatDates = calendar.formatDates
  @fcViews.basicWeek = BasicWeekView
)(window)