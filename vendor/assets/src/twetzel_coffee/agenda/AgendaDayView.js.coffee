((window) ->
  AgendaDayView = (element, calendar) ->
  
    # exports
  
    # imports
    render = (date, delta) ->
      if delta
        addDays date, delta
        skipWeekend date, (if delta < 0 then -1 else 1)  unless opt("weekends")
      start = cloneDate(date, true)
      end = addDays(cloneDate(start), 1)
      t.title = formatDate(date, opt("titleFormat"))
      t.start = t.visStart = start
      t.end = t.visEnd = end
      renderAgenda 1
    t = this
    t.render = render
    AgendaView.call t, element, calendar, "agendaDay"
    opt = t.opt
    renderAgenda = t.renderAgenda
    formatDate = calendar.formatDate
  @fcViews.agendaDay = AgendaDayView
)(window)