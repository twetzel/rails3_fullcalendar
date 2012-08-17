# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.rest
//= require_self
# fullcalendar is loaded in view .. to change versions !!!
# require fullcalendar
# require gcal
# require calendar

$.ajaxSetup
	beforeSend: (xhr) ->
		xhr.setRequestHeader("Accept", "text/javascript")