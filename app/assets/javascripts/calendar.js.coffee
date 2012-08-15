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
			title = prompt('Event Title:')
			if title
				createEvent( title, start.toString(), end.toString(), allDay )
				console?.log? "New Event: #{title} ... #{start} - #{end}"
			$('#calendar').fullCalendar('unselect')
		editable: true
		header:
			left: 'prev,next today'
			center: 'title'
			right: 'month,agendaWeek,agendaDay'
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
		defaultView: 'month'
		height: 500
		slotMinutes: 15
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