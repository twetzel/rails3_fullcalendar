((window) ->
  @ResourceDayView = (element, calendar) ->
  
    # exports
  
    # imports
    opt = @opt
    renderResourceView = @renderResourceView
    formatDate = calendar.formatDate
    
    render = (date, delta, rebuildSkeleton) ->
      if delta
        addDays date, delta
        skipWeekend date, (if delta < 0 then -1 else 1)  unless opt("weekends")
      start = cloneDate(date, true)
      end = addDays(cloneDate(start), 1)
      @title = formatDate(date, opt("titleFormat"))
      @start = @visStart = start
      @end = @visEnd = end
      renderResourceView rebuildSkeleton
    t = this
    @render = render
    ResourceView.call t, element, calendar, "resourceDay"
    
  @fcViews.resourceDay = ResourceDayView
)(window)