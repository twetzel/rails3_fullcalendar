((window) ->
  #TODO: when calendar's date starts out on a weekend, shouldn't happen
  BasicDayView = (element, calendar) ->
  
    # exports
  
    # imports
    render = (date, delta) ->
      if delta
        addDays date, delta
        skipWeekend date, (if delta < 0 then -1 else 1)  unless opt("weekends")
      @title = formatDate(date, opt("titleFormat"))
      @start = @visStart = cloneDate(date, true)
      @end = @visEnd = addDays(cloneDate(t.start), 1)
      renderBasic 1, 1, 1, false
    t = this
    @render = render
    BasicView.call @, element, calendar, "basicDay"
    opt = @opt
    renderBasic = @renderBasic
    formatDate = calendar.formatDate
  @fcViews.basicDay = BasicDayView
)(window)