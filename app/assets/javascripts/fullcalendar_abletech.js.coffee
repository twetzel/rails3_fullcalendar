//= require src/AbleTech/defaults
//= require src/AbleTech/main
//= require src/AbleTech/Calendar
//= require src/AbleTech/Header
//= require src/AbleTech/EventManager
//= require src/AbleTech/date_util
//= require src/AbleTech/util
#
//= require src/AbleTech/basic/MonthView
//= require src/AbleTech/basic/BasicWeekView
//= require src/AbleTech/basic/BasicDayView
//= require src/AbleTech/basic/BasicView
//= require src/AbleTech/basic/BasicEventRenderer
#
//= require src/AbleTech/agenda/AgendaWeekView
//= require src/AbleTech/agenda/AgendaDayView
//= require src/AbleTech/agenda/AgendaView
//= require src/AbleTech/agenda/AgendaEventRenderer
#
//= require src/AbleTech/resources/ResourceDayView
//= require src/AbleTech/resources/ResourceView
//= require src/AbleTech/resources/ResourceList
//= require src/AbleTech/resources/ResourceEventRenderer
#
//= require src/AbleTech/common/View
//= require src/AbleTech/common/DayEventRenderer
//= require src/AbleTech/common/SelectionManager
//= require src/AbleTech/common/OverlayManager
//= require src/AbleTech/common/CoordinateGrid
//= require src/AbleTech/common/HoverListener
//= require src/AbleTech/common/HorizontalPositionCache
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
  # resourceDay
  allDayText: 'all-day'
  
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
	select: (start, end, allDay, jsEvent, resourceObj) ->
		#selectEvent(start, end, allDay)
		selectResourceEvent(start, end, allDay, resourceObj)
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


	#$('#external-events .external-event').each ->
	#	# create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
	#	# it doesn't need to have a start or end
	#	eventObject =
	#		title: $.trim($(@).text()), # use the element's text as the event title
	#		resourceId: parseInt($(@).attr('employee'))
  #
	#	# store the Event Object in the DOM element so we can get to it later
	#	#$(@).data('eventObject', eventObject)
	#	$(@).attr('data-eventObject', eventObject)
  #
	#	$(@).draggable(
	#		zIndex: 2999
	#		revert: true, # will cause the event to go back to its
	#		revertDuration: 0 #  original position after the drag
	#	)


