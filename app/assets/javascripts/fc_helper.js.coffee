((window) ->

	# Update an existing Event
	@updateEvent = (the_event, rerender) ->
		if the_event.title and the_event.title != '' and the_event.start and the_event.start != ''
			daDialog.dialog('close')
			$.update(
				"/events/" + the_event.id
				event: 
					title: the_event.title
					starts_at: "#{the_event.start}"
					ends_at: "#{the_event.end}"
					description: the_event.description
					# a bit confusing, but AbleTech-version sends full resource
					person_id: if the_event.resource.id then the_event.resource.id else if the_event.resource then the_event.resource else null
				(reponse) ->
					console?.log? "updated event '#{reponse.title}'."
					if rerender
						$('#calendar').fullCalendar('refetchEvents')
						$('#calendar').fullCalendar('rerenderEvents')
			)
		else
			alert "Not enough data! .. please provide a title!"


	# Create a new Event (from Selection)
	@createEvent = (title, start, end, allday) ->
		if title and title != '' and start and start != ''
			daDialog.dialog('close')
			$.create(
				"/events"
				event:
					title: title
					starts_at: start
					ends_at: end
					all_day: allday
				(reponse) ->
					$('#calendar').fullCalendar('renderEvent', reponse, true )
				(response) ->
					alert "ERROR .. #{ getErrorMessages( response.responseText ) }"
					console?.log? response
			)
		else
			alert "Not enough data! .. please provide a title!"
		false


	@createResourceEvent = (title, start, end, allday, resource) ->
		if title and title != '' and start and start != ''
			daDialog.dialog('close')
			$.create(
				"/events"
				event:
					title: title
					starts_at: start
					ends_at: end
					all_day: allday
					person_id: resource
				(reponse) ->
					console?.log? "New Event: #{title} ... #{start} - #{end}"
					$('#calendar').fullCalendar('renderEvent', reponse, true )
				(response) ->
					alert "ERROR !\n#{ getErrorMessages( response.responseText ) }"
					console?.log? response
			)
		else
			alert "Not enough data! .. please provide a title!"
		false


	@getErrorMessages = (msg_obj) ->
		msgs = jQuery.parseJSON( msg_obj )
		console?.log? "Error-MSGs : " + msgs
		msg = ""
		for key of msgs
			if msgs.hasOwnProperty(key)
				obj = msgs[key]
				for prop of obj
					msg += "#{key} #{obj[prop]}\n" if obj.hasOwnProperty(prop)
		msg


	@selectResourceEvent = (start, end, allDay, resource) ->
		event = {}
		event.start = start
		event.end = end
		event.allDay = allDay
		event.resource = resource.id if resource and resource.id
		openTheDialog( event )
		false

	@selectEvent = (start, end, allDay) ->
		selectResourceEvent(start, end, allDay, false)


	@umanizeDateFormat = (this_date) ->
		if this_date and this_date != ""
			that_date = new XDate(this_date)
			# that_date.toString("d.M.yyyy - H:mm")
			that_date.toString("d.M.yyyy")
		else
			""


	@umanizeTimeFormat = (this_date) ->
		if this_date and this_date != ""
			that_date = new XDate(this_date)
			that_date.toString("H:mm")
		else
			""


	@realDateFormat = (this_date) ->
		if this_date and this_date != ""
			sdate = this_date.split(' - ')
			s_year = sdate[0].split('.')[2]
			s_month = parseInt( sdate[0].split('.')[1] ) - 1 # otherwise it doesnt work :(
			s_day = sdate[0].split('.')[0]
			s_hours = sdate[1].split(':')[0]
			s_mins = sdate[1].split(':')[1]
			console?.log? "#{s_year},#{s_month},#{s_day},#{s_hours},#{s_mins} >> #{new XDate( s_year, s_month, s_day, s_hours, s_mins ).toString()}"
			new XDate( s_year, s_month, s_day, s_hours, s_mins ).toString()
		else
			''


	@realDateTimeFormat = (this_date, this_time) ->
		if this_date and this_date != ""
			s_year = this_date.split('.')[2]
			s_month = parseInt( this_date.split('.')[1] ) - 1 # otherwise it doesnt work :(
			s_day = this_date.split('.')[0]
			if this_time and this_time != ""
				s_hours = this_time.split(':')[0]
				s_mins = this_time.split(':')[1]
			else
				s_hours = 0
				s_mins = 0
			console?.log? "#{s_year},#{s_month},#{s_day},#{s_hours},#{s_mins} >> #{new XDate( s_year, s_month, s_day, s_hours, s_mins ).toString()}"
			new XDate( s_year, s_month, s_day, s_hours, s_mins ).toString()
		else
			''


	@disableDialogTimeFields = ->
		$('#start_time').val('').attr('disabled', 'true')
		$('#end_time').val('').attr('disabled', 'true')

	@enableDialogTimeFields = (start, end) ->
		$('#start_time').val( if start then umanizeTimeFormat( start ) else '9:00').removeAttr('disabled')
		$('#end_time').val( if end then umanizeTimeFormat( end ) else '18:00').removeAttr('disabled')



	@openTheDialog = (event) ->
		$('#event_id').val( if event.id then event.id else '')
		$('#start_date').val( umanizeDateFormat(event.start) )
		$('#start_time').val( umanizeTimeFormat(event.start) )
		if event.end && event.end != ''
			$('#end_date').val( umanizeDateFormat(event.end) )
			$('#end_time').val( umanizeTimeFormat(event.end) )
		else
			$('#end_date').val( umanizeDateFormat(event.start) )
			$('#end_time').val( umanizeTimeFormat(event.start) )
		if event.allDay
			$('#all_day').attr('checked', true)
			disableDialogTimeFields()
		else
			$('#all_day').attr('checked', false)
			enableDialogTimeFields(event.start, event.end)
		$('#what').val( if event.title then event.title else '')
		$('#description').val( if event.description then event.description else '')
		if event.resource
			if event.resource.id
				$('#personresource').val( event.resource.id )
			else
				$('#personresource').val( event.resource )
		else
			$('#personresource').val( "" )
		#$('#personresource').val( if event.resource then event.resource else if event.resourceId then event.resourceId else '')
		if event.id and event.id != ''
			$('.deleteDialogButton').show()
			$('#event_dialog').dialog('open').dialog({ title: "Edit Event - <em>#{event.title}</em>" })
		else
			$('.deleteDialogButton').hide()
			$('#event_dialog').dialog('open').dialog({ title: "New Event" })
		


	@saveEventFromDialog = ->
		allDay = $('#all_day').is(':checked')
		event = {}
		event.id = $('#event_id').val()
		event.start = realDateTimeFormat( $('#start_date').val(), $('#start_time').val() )
		event.end = realDateTimeFormat( $('#end_date').val(), $('#end_time').val() )
		if $('#all_day').attr('checked') == "checked"
			event.allday = true
		else
			event.allday = false
		event.title = $('#what').val()
		event.description = $('#description').val()
		event.resource = $('#personresource').val()
		if event.id and event.id != ''
			console?.log? event.id
			updateEvent(event, true)
		else
			createResourceEvent(event.title, event.start, event.end, event.allday, event.resource)


	@deleteEventFromDialog = ->
		$.destroy( 
			"/events/#{$('#event_id').val()}"
			(response) ->
				$('#calendar').fullCalendar('refetchEvents')
				$('#calendar').fullCalendar('rerenderEvents')
		)
		daDialog.dialog('close')
)(window)