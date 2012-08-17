//= require src/buero-fuer-ideen/defaults
//= require src/buero-fuer-ideen/main
//= require src/buero-fuer-ideen/Calendar
//= require src/buero-fuer-ideen/Header
//= require src/buero-fuer-ideen/EventManager
//= require src/buero-fuer-ideen/date_util
//= require src/buero-fuer-ideen/util

//= require src/buero-fuer-ideen/basic/MonthView
//= require src/buero-fuer-ideen/basic/BasicWeekView
//= require src/buero-fuer-ideen/basic/BasicDayView
//= require src/buero-fuer-ideen/basic/BasicView
//= require src/buero-fuer-ideen/basic/BasicEventRenderer

//= require src/buero-fuer-ideen/agenda/AgendaWeekView
//= require src/buero-fuer-ideen/agenda/AgendaDayView
//= require src/buero-fuer-ideen/agenda/AgendaView
//= require src/buero-fuer-ideen/agenda/AgendaEventRenderer

//= require src/buero-fuer-ideen/resources/ResourceDayView
//= require src/buero-fuer-ideen/resources/ResourceView
//= require src/buero-fuer-ideen/resources/ResourceList
//= require src/buero-fuer-ideen/resources/ResourceEventRenderer

//= require src/buero-fuer-ideen/common/View
//= require src/buero-fuer-ideen/common/DayEventRenderer
//= require src/buero-fuer-ideen/common/SelectionManager
//= require src/buero-fuer-ideen/common/OverlayManager
//= require src/buero-fuer-ideen/common/CoordinateGrid
//= require src/buero-fuer-ideen/common/HoverListener
//= require src/buero-fuer-ideen/common/HorizontalPositionCache
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
		right: 'resourceDay,month,agendaWeek,agendaDay'
	# resources: [
	# 	{ id: 1, name: 'Joe Bloggs', color: 'red', textColor: 'black' },
	# 	{ id: 2, name: 'Alan Black', color: 'blue' },
	# 	{ id: 4, name: 'Paul Green', color: 'green' },
	# 	{ id: 5, name: 'Jane Yellow', color: 'yellow', textColor: 'black' },
	# 	{ id: 6, name: 'Bob Orange', color: 'orange' }
	# ]
	resources: jQuery.parseJSON( all_peoples.responseText )
	# new by twetzel .. make days and timeranges selectable
	select: (start, end, allDay) -> selectEvent(start, end, allDay)
	# => select: (start, end, allDay, jsEvent, view) -> 
	# => 	console?.log? "#{view.name} - #{view.getDaySegmentContainer() } - #{jsEvent.srcElement.outerHTML}"
	# => 	console?.log? jsEvent
	# => 	console?.log? view
	# http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
	eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
	eventResize: (event, dayDelta, minuteDelta, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/mouse/eventClick/
	eventClick: (event, jsEvent, view) -> # => would like a lightbox here.
#
# => load fullCalender (default_options get merged) .. person-resource are loaded in layout
#
$ ->
	$('#calendar').fullCalendar( mergeOptions(options) )
