((window) ->
	
	@allDayText_en = 'all-day'
	@allDayText_de = 'ganztägig'
	
	@fc_local_times =
		monthNames: ["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"]
		monthNamesShort: ["Jan","Feb","Mär","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"]
		dayNames: ["Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"]
		dayNamesShort: ["So","Mo","Di","Mi","Do","Fr","Sa"]

	@default_fc_options =
		# Behavior
		selectable: true
		selectHelper: true
		unselectCancel: "#event_dialog"
		editable: true
		# View
		theme: false # options:  true | false | :jquery_ui-themename
		aspectRatio: 1
		# height: 650
		weekMode: "variable"
		weekends: true
		dragOpacity: "0.5"
		slotMinutes: 30 # slotMinutes: 10 15 20 30 60
		# Source .. a future calendar might have many source
		eventSources: [
			{
				url: '/events'
				# color: '#ccc'
				# textColor: '#333'
				ignoreTimezone: false
			},
			# {
			# 	# US-Holidays (en)
			# 	url: 'http://www.google.com/calendar/feeds/usa__en%40holiday.calendar.google.com/public/basic'
			# 	className: 'us_holiday'
			# 	color: '#facaf6'
			# },
			# {
			# 	# DE-Holidays (en)
			# 	url: 'http://www.google.com/calendar/feeds/en.german%23holiday%40group.v.calendar.google.com/public/basic'
			# 	className: 'de_holiday'
			# 	color: '#d9f8c8'
			# },
			# {
			# 	# US-Holidays (de)
			# 	url: 'http://www.google.com/calendar/feeds/usa__de%40holiday.calendar.google.com/public/basic'
			# 	className: 'us_holiday'
			# 	color: '#facaf6'
			# },
			{
				# DE-Holidays (de)
				url: 'http://www.google.com/calendar/feeds/de.german%23holiday%40group.v.calendar.google.com/public/basic'
				className: 'de_holiday'
				backgroundColor: '#d9f8c8'
				borderColor: '#ccc'
				textColor: '#333'
			}
		]
		# loading info
		loading: (bool) -> if bool then $('#loading').show() else $('#loading').hide()
		# Default stuff Locale = de .. todo include i18n.js for that part !
		allDayText: "ganztägig"
		titleFormat:
			month: 'MMMM yyyy'
			week: "d.[ MMMM][ yyyy]{ - d. MMMM yyyy}"
			day: 'dddd, d.MMMM yyyy'
		columnFormat:
			month: 'ddd'
			week: 'ddd d.M.'
			day: 'dddd d.M.'
		timeFormat: 'H:mm { - H:mm} '
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
			resourceDay: 'Resourcen'
			agendaWorkWeek: 'Arbeitswoche'
		axisFormat: 'H:mm'


	@mergeOptions = ( options ) ->
		$.extend({}, default_fc_options, options);

)(window)
