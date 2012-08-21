//= require src/twetzel_coffee/defaults
//= require src/twetzel_coffee/main
//= require src/twetzel_coffee/Calendar
//= require src/twetzel_coffee/Header
//= require src/twetzel_coffee/EventManager
//= require src/twetzel_coffee/date_util
//= require src/twetzel_coffee/util
#
//= require src/twetzel_coffee/basic/MonthView
//= require src/twetzel_coffee/basic/BasicWeekView
//= require src/twetzel_coffee/basic/BasicDayView
//= require src/twetzel_coffee/basic/BasicView
//= require src/twetzel_coffee/basic/BasicEventRenderer
#
//= require src/twetzel_coffee/agenda/AgendaWeekView
//= require src/twetzel_coffee/agenda/AgendaDayView
//= require src/twetzel_coffee/agenda/AgendaView
//= require src/twetzel_coffee/agenda/AgendaEventRenderer
#
//= require src/twetzel_coffee/resources/ResourceDayView
//= require src/twetzel_coffee/resources/ResourceView
//= require src/twetzel_coffee/resources/ResourceList
//= require src/twetzel_coffee/resources/ResourceEventRenderer
#
//= require src/twetzel_coffee/common/View
//= require src/twetzel_coffee/common/DayEventRenderer
//= require src/twetzel_coffee/common/SelectionManager
//= require src/twetzel_coffee/common/OverlayManager
//= require src/twetzel_coffee/common/CoordinateGrid
//= require src/twetzel_coffee/common/HoverListener
//= require src/twetzel_coffee/common/HorizontalPositionCache
#
//= require src/twetzel_coffee/gcal/gcal
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
	#resources: jQuery.parseJSON( all_peoples.responseText )
  dayClick: ( date, allDay, jsEvent, view ) ->
    selectResourceEvent(start, end, allDay)
	# new by twetzel .. make days and timeranges selectable
	select: (start, end, allDay, jsEvent, resourceObj) ->
		#selectEvent(start, end, allDay)
		selectResourceEvent(start, end, allDay, resourceObj)
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



