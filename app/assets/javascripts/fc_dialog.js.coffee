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
			open: ->
				# without unbind fires enter for every previous opened dialog ( first = 1, second = 2, and so on)
				daDialog.unbind('keyup')
				# catch enter on dialog .. maybe move in on-function
				daDialog.keyup (e) ->
					if e.keyCode is $.ui.keyCode.ENTER
						console?.log? "daDialog => hit 'Enter'"
						saveEventFromDialog()
						false
				#$('.ui-dialog input').keyup (e) ->
				#	alert "Enter key was pressed."  if e.keyCode is 13


		$('#all_day').change ->
			checked = $(@).is(':checked')
			if checked
				disableDialogTimeFields()
			else
				enableDialogTimeFields()

		$.datepicker.setDefaults({ dateFormat: 'd.m.yy' })
		$('#start_date').datepicker()
		$('#end_date').datepicker()

)(jQuery, window, document)