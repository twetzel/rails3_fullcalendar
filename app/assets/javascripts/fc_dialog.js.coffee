(($, window, document) ->

	$ ->
		window.daDialog = $('#event_dialog').dialog
			title: 'New Event'
			autoOpen: false
			width: 555
			# buttons: 
			# 	'Delete': -> deleteEventFromDialog()
			# 	'Cancel': -> $(@).dialog('close')
			# 	'Save': -> saveEventFromDialog()#
			buttons: [
				text: "Delete"
				class: "deleteDialogButton"
				click: ->
					console?.log? "daDialog => clicked 'Delete'"
					deleteEventFromDialog() if confirm "Realy delete this Event?"
			,
				text: "Cancel"
				class: "cancelDialogButton"
				click: ->
					console?.log? "daDialog => clicked 'Cancel'"
					$(@).dialog('close')
			,
				text: "Save"
				class: "saveDialogButton"
				click: ->
					console?.log? "daDialog => clicked 'Save'"
					saveEventFromDialog()
			]
		
		window.gCalDialog = $('#gcal_dialog').dialog
			title: 'gCal'
			autoOpen: false
			width: 555
			buttons: 
				'Close': -> $(@).dialog('close')


		$.datepicker.setDefaults({ dateFormat: 'd.m.yy' })
		$('#start_date').datepicker()
		$('#end_date').datepicker()
		
		$("#event_dialog").on 'change', '#all_day', (e) ->
			checked = $(@).is(':checked')
			if checked
				disableDialogTimeFields()
			else
				enableDialogTimeFields()
		
		$("#event_dialog").on 'keyup', 'input', (e) ->
			if e.keyCode is $.ui.keyCode.ENTER
						console?.log? "daDialog => hit 'Enter'"
						saveEventFromDialog()

)(jQuery, window, document)