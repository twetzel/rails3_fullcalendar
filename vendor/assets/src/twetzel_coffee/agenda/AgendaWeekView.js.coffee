((window) ->
  AgendaWeekView = (element, calendar) ->
  
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
      t.title = formatDates(visStart, addDays(cloneDate(visEnd), -1), opt("titleFormat"))
      t.start = start
      t.end = end
      t.visStart = visStart
      t.visEnd = visEnd
      renderAgenda (if weekends then 7 else 5)
    t = this
    t.render = render
    AgendaView.call t, element, calendar, "agendaWeek"
    opt = t.opt
    renderAgenda = t.renderAgenda
    formatDates = calendar.formatDates
  @fcViews.agendaWeek = AgendaWeekView
)(window)