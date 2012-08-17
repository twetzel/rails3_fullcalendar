//= require src/jarnokurlin/defaults
//= require src/jarnokurlin/main
//= require src/jarnokurlin/Calendar
//= require src/jarnokurlin/Header
//= require src/jarnokurlin/EventManager
//= require src/jarnokurlin/date_util
//= require src/jarnokurlin/util
#
//= require src/jarnokurlin/basic/MonthView
//= require src/jarnokurlin/basic/BasicWeekView
//= require src/jarnokurlin/basic/BasicDayView
//= require src/jarnokurlin/basic/BasicView
//= require src/jarnokurlin/basic/BasicEventRenderer
#
//= require src/jarnokurlin/resource/ResourceDayView
//= require src/jarnokurlin/resource/ResourceWeekView
//= require src/jarnokurlin/resource/ResourceNextWeeksView
//= require src/jarnokurlin/resource/ResourceMonthView
//= require src/jarnokurlin/resource/ResourceView
//= require src/jarnokurlin/resource/ResourceEventRenderer
#
//= require src/jarnokurlin/agenda/AgendaWeekView
//= require src/jarnokurlin/agenda/AgendaDayView
//= require src/jarnokurlin/agenda/AgendaView
//= require src/jarnokurlin/agenda/AgendaEventRenderer
#
//= require src/jarnokurlin/common/View
//= require src/jarnokurlin/common/DayEventRenderer
//= require src/jarnokurlin/common/SelectionManager
//= require src/jarnokurlin/common/OverlayManager
//= require src/jarnokurlin/common/CoordinateGrid
//= require src/jarnokurlin/common/HoverListener
//= require src/jarnokurlin/common/HorizontalPositionCache
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
		right: 'month,agendaWeek,agendaDay,resourceDay,resourceWeek,resourceMonth'
		# => month,basicWeek,basicDay,agendaWeek,agendaDay,resourceDay,resourceWeek,resourceNextWeeks,resourceMonth
	minTime: 6
	# resources: [
	# 	{ id: 1, name: 'Joe Bloggs', color: 'red', textColor: 'black' },
	# 	{ id: 2, name: 'Alan Black', color: 'blue' },
	# 	{ id: 4, name: 'Paul Green', color: 'green' },
	# 	{ id: 5, name: 'Jane Yellow', color: 'yellow', textColor: 'black' },
	# 	{ id: 6, name: 'Bob Orange', color: 'orange' }
	# ]
	resources: jQuery.parseJSON( all_peoples.responseText )
	
	# new by twetzel .. make days and timeranges selectable
	# select: (start, end, allDay) -> selectEvent(start, end, allDay)
	select: (start, end, allDay, jsEvent, view, resource) -> selectResourceEvent(start, end, allDay, resource)
	
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
