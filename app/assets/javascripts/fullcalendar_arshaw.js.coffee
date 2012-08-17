//= require src/arshaw/defaults
//= require src/arshaw/main
//= require src/arshaw/Calendar
//= require src/arshaw/Header
//= require src/arshaw/EventManager
//= require src/arshaw/date_util
//= require src/arshaw/util
#
//= require src/arshaw/basic/MonthView
//= require src/arshaw/basic/BasicWeekView
//= require src/arshaw/basic/BasicDayView
//= require src/arshaw/basic/BasicView
//= require src/arshaw/basic/BasicEventRenderer
#
//= require src/arshaw/agenda/AgendaWeekView
//= require src/arshaw/agenda/AgendaDayView
//= require src/arshaw/agenda/AgendaView
//= require src/arshaw/agenda/AgendaEventRenderer
#
//= require src/arshaw/common/View
//= require src/arshaw/common/DayEventRenderer
//= require src/arshaw/common/SelectionManager
//= require src/arshaw/common/OverlayManager
//= require src/arshaw/common/CoordinateGrid
//= require src/arshaw/common/HoverListener
//= require src/arshaw/common/HorizontalPositionCache
#
# require src/arshaw/gcal/gcal
#
//= require xdate
//= require fc_defaults
//= require fc_dialog
//= require fc_helper
//= require_self
#
# => individual options for fullCalendar
#
options =
	defaultView: 'month'
	header:
		left: 'prev,next today'
		center: 'title'
		right: 'month,agendaWeek,agendaDay'
	# new by twetzel .. make days and timeranges selectable
	select: (start, end, allDay) -> selectEvent(start, end, allDay)
	# http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
	eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
	eventResize: (event, dayDelta, minuteDelta, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/mouse/eventClick/
	eventClick: (event, jsEvent, view) ->
		openTheDialog(event)
		false
#
# => load fullCalender (default_options get merged) .. person-resource are loaded in layout
#
$ ->
	$('#calendar').fullCalendar( mergeOptions(options) )

