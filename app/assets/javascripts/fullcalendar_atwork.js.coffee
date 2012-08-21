//= require src/atwork/defaults
//= require src/atwork/main
//= require src/atwork/Calendar
//= require src/atwork/Header
//= require src/atwork/EventManager
//= require src/atwork/date_util
//= require src/atwork/util
#
//= require src/atwork/basic/MonthView
//= require src/atwork/basic/BasicWeekView
//= require src/atwork/basic/BasicDayView
//= require src/atwork/basic/BasicView
//= require src/atwork/basic/BasicEventRenderer
#
//= require src/atwork/agenda/AgendaWorkWeekView
//= require src/atwork/agenda/AgendaWeekView
//= require src/atwork/agenda/AgendaDayView
//= require src/atwork/agenda/AgendaView
//= require src/atwork/agenda/AgendaEventRenderer
#
//= require src/atwork/resources/ResourceWorkWeekView
//= require src/atwork/resources/ResourceDayView
//= require src/atwork/resources/ResourceView
//= require src/atwork/resources/ResourceList
//= require src/atwork/resources/ResourceEventRenderer
#
//= require src/atwork/common/View
//= require src/atwork/common/DayEventRenderer
//= require src/atwork/common/SelectionManager
//= require src/atwork/common/OverlayManager
//= require src/atwork/common/CoordinateGrid
//= require src/atwork/common/HoverListener
//= require src/atwork/common/HorizontalPositionCache
#
//= require src/atwork/gcal/gcal
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
	defaultView: 'resourceDay'
	header:
		left: 'prev,next today'
		center: 'title'
		right: 'month,agendaWeek,agendaWorkWeek,resourceWorkWeek,resourceDay'
		# right: 'month,agendaWeek,agendaWorkWeek,resourceWorkWeek,agendaDay,resourceDay'
	# resources: [
	# 	{ id: 1, name: 'Joe Bloggs', color: 'red', textColor: 'black' },
	# 	{ id: 2, name: 'Alan Black', color: 'blue' },
	# 	{ id: 4, name: 'Paul Green', color: 'green' },
	# 	{ id: 5, name: 'Jane Yellow', color: 'yellow', textColor: 'black' },
	# 	{ id: 6, name: 'Bob Orange', color: 'orange' }
	# ]
	resources: jQuery.parseJSON( all_peoples.responseText )
  #dayClick: ( date, allDay, jsEvent, view ) ->selectEvent(start, end, allDay)
	# http://arshaw.com/fullcalendar/docs/selection/select_callback/
	select: (start, end, allDay, jsEvent, resourceObj) -> selectResourceEvent(start, end, allDay, resourceObj)
	# http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
	eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
	eventResize: (event, dayDelta, minuteDelta, revertFunc) -> updateEvent(event)
	# http://arshaw.com/fullcalendar/docs/mouse/eventClick/
	eventClick: (event, jsEvent, view) ->
		if event.source and event.source.dataType and event.source.dataType == "gcal"
			openGCalDialog(event)
		else
			openTheDialog(event)
		false
#
# => load fullCalender (default_options get merged) .. person-resource are loaded in layout
#
$ ->
	$('#calendar').fullCalendar( mergeOptions(options) )



