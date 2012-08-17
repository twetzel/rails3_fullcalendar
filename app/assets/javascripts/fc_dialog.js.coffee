(($, window, document) ->

	$ ->
		window.daDialog = $('#event_dialog').dialog
			title: 'New Event'
			autoOpen: false
			width: 555
			buttons: 
				'Cancel': -> $(@).dialog('close')
				'Save': -> saveEventFromDialog()#

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