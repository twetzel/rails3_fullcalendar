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
# require src/buero-fuer-ideen/gcal/gcal
#
//= require_self
#
#
date = new Date()
d = date.getDate()
m = date.getMonth()
y = date.getFullYear()


updateEvent = (the_event) ->
	$.update(
		"/events/" + the_event.id
		event: 
			title: the_event.title
			starts_at: "" + the_event.start
			ends_at: "" + the_event.end
			description: the_event.description
		(reponse) -> alert "successfully updated event '#{reponse.title}'."
	)

createEvent = (title, start, end, allday) ->
	$.create(
		"/events"
		event:
			title: title
			starts_at: start
			ends_at: end
			all_day: allday
		(reponse) ->
			$('#calendar').fullCalendar('renderEvent', reponse, true )
	)

$ ->
	$('#calendar').fullCalendar
		selectable: true
		selectHelper: true
		select: (start, end, allDay) ->
			resourceObj = false
			if $('#calendar').fullCalendar.calender.getView().name=="resourceDay"
				# Get the cell associated with the select function
				hoverListener = t.getHoverListener()
				cell = hoverListener.stop()
				calendar = t.calendar
				resources = calendar.getResources()
				# Get the resource from the selected cell and pass it to the select function as an argument		
				resourceObj = resources[cell.col]
			title = prompt "Event Title: #{resourceObj}"
			if title
				createEvent( title, start.toString(), end.toString(), allDay )
				console?.log? "New Event: #{title} ... #{start} - #{end}"
			$('#calendar').fullCalendar('unselect')
		editable: true
		header:
			left: 'prev,next today'
			center: 'title'
			right: 'resourceDay,month,agendaWeek,agendaDay'
		# time formats
		titleFormat:
			month: 'MMMM yyyy'
			week: "d.[ MMMM][ yyyy]{ - d. MMMM yyyy}"
			day: 'dddd, d.MMMM yyyy'
		columnFormat:
			month: 'ddd'
			week: 'ddd d.M.'
			day: 'dddd d.M.'
		# timeFormat:
		# 	'': 'H(:mm)' # default: 'h(:mm)t'
		# locale
		isRTL: false
		firstDay: 1
		monthNames: ["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"]
		monthNamesShort: ["Jan","Feb","Mär","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"]
		dayNames: ["Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"]
		dayNamesShort: ["So","Mo","Di","Mi","Do","Fr","Sa"]
		buttonText:
			prev: "&nbsp;&#9668;&nbsp;"
			next: "&nbsp;&#9658;&nbsp;"
			prevYear: "&nbsp;&lt;&lt;&nbsp;"
			nextYear: "&nbsp;&gt;&gt;&nbsp;"
			today: "heute"
			month: "Monat"
			week: "Woche"
			day: "Tag"
		axisFormat: 'H:mm'
		defaultView: 'month'
		# height: 500
		# slotMinutes: 15
		slotMinutes: 30
		loading: (bool) ->
			if bool
				$('#loading').show()
			else
				$('#loading').hide()
		# a future calendar might have many sources.
		eventSources: [
			url: '/events'
			color: '#ccc'
			textColor: '#333'
			ignoreTimezone: false
		]
		resources: [
			{
				id: 1,
				name: 'Joe Bloggs',
				color: 'red',
				textColor: 'black'
			},
			{
				id: 2,
				name: 'Alan Black',
				color: 'blue'
			},
			{
				id: 4,
				name: 'Paul Green',
				color: 'green'
			},
			{
				id: 5,
				name: 'Jane Yellow',
				color: 'yellow',
				textColor: 'black'
			},
			{
				id: 6,
				name: 'Bob Orange',
				color: 'orange'
			}
		],
		timeFormat: 'H:mm { - H:mm} '
		dragOpacity: "0.5"
		# http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
		eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
			updateEvent(event)
		# http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
		eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
			updateEvent(event)
		# http://arshaw.com/fullcalendar/docs/mouse/eventClick/
		eventClick: (event, jsEvent, view) ->
			#would like a lightbox here.