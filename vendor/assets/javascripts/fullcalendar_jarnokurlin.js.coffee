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
			right: 'month,agendaWeek,agendaDay,resourceDay,resourceWeek,resourceMonth'
			# => month,basicWeek,basicDay,agendaWeek,agendaDay,resourceDay,resourceWeek,resourceNextWeeks,resourceMonth
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