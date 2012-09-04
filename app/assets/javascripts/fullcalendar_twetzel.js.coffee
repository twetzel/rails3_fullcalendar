//= require src/twetzel/defaults
//= require src/twetzel/main
//= require src/twetzel/Calendar
//= require src/twetzel/Header
//= require src/twetzel/EventManager
//= require src/twetzel/date_util
//= require src/twetzel/util
#
//= require src/twetzel/basic/MonthView
//= require src/twetzel/basic/BasicWeekView
//= require src/twetzel/basic/BasicDayView
//= require src/twetzel/basic/BasicView
//= require src/twetzel/basic/BasicEventRenderer
#
//= require src/twetzel/agenda/AgendaWorkWeekView
//= require src/twetzel/agenda/AgendaThreeDayView
#
//= require src/twetzel/agenda/AgendaWeekView
//= require src/twetzel/agenda/AgendaDayView
//= require src/twetzel/agenda/AgendaView
//= require src/twetzel/agenda/AgendaEventRenderer
#
//= require src/twetzel/resources/ResourceDayView
//= require src/twetzel/resources/ResourceView
//= require src/twetzel/resources/ResourceList
//= require src/twetzel/resources/ResourceEventRenderer
#
//= require src/twetzel/common/View
//= require src/twetzel/common/DayEventRenderer
//= require src/twetzel/common/SelectionManager
//= require src/twetzel/common/OverlayManager
//= require src/twetzel/common/CoordinateGrid
//= require src/twetzel/common/HoverListener
//= require src/twetzel/common/HorizontalPositionCache
#
//= require src/twetzel/gcal/gcal
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
	
	monthHead: false
	markAllDays: true
	oneDayHead: false
	speziTitleFormat:
		week: "d.[ MMMM][ yyyy]{ - d. MMMM yyyy}"
		day: "d.[ MMMM][ yyyy]{ - d. MMMM yyyy}"
	
	defaultView: 'resourceDay'
	header:
		left: 'prev,next today'
		center: 'title'
		right: 'month,agendaWeek,agendaWorkWeek,agendaThreeDay,agendaDay,resourceDay'
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

	$('#external-events .external-event').each ->
		# create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
		# it doesn't need to have a start or end
		eventObject =
			title: $.trim($(@).text()), # use the element's text as the event title
			resourceId: parseInt($(@).attr('data-employee'))

		# store the Event Object in the DOM element so we can get to it later
		#$(@).data('eventObject', eventObject)
		$(@).attr( 'data-eventObject', JSON.stringify( eventObject ) )
		$(@).attr( 'data-title', $.trim($(@).text()) )
		$(@).attr( 'data-resource', parseInt($(@).attr('data-employee')) )

		$(@).draggable(
			zIndex: 2999
			revert: true, # will cause the event to go back to its
			revertDuration: 0 #  original position after the drag
		)

