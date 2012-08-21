((window) ->
  View = (element, calendar, viewName) ->
    #t.setOverflowHidden = setOverflowHidden;
  
    # @title
    # @start, @end
    # @visStart, @visEnd
  
    # imports
    # in EventManager
    t = this
    defaultEventEnd = @defaultEventEnd
    normalizeEvent = calendar.normalizeEvent
    reportEventChange = calendar.reportEventChange
    eventsByID = {}
    eventElements = []
    eventElementsByID = {}
    options = calendar.options
  
    # locals
    opt = (name, viewNameOverride) ->
      v = options[name]
      return smartProperty(v, viewNameOverride or viewName)  if typeof v is "object"
      v
    trigger = (name, thisObj) ->
      calendar.trigger.apply calendar, [name, thisObj or t].concat(Array::slice.call(arguments_, 2), [t])
  
    #
    #	function setOverflowHidden(bool) {
    #		element.css('overflow', bool ? 'hidden' : '');
    #	}
    #	
    isEventDraggable = (event) ->
      isEventEditable(event) and not opt("disableDragging")
    isEventResizable = (event) -> # but also need to make sure the seg.isEnd == true
      isEventEditable(event) and not opt("disableResizing")
    isEventEditable = (event) ->
      firstDefined event.editable, (event.source or {}).editable, opt("editable")
  
    # Event Data
    #	------------------------------------------------------------------------------
  
    # report when view receives new events
    reportEvents = (events) -> # events are already normalized at this point
      eventsByID = {}
      i = undefined
      len = events.length
      event = undefined
      i = 0
      while i < len
        event = events[i]
        if eventsByID[event._id]
          eventsByID[event._id].push event
        else
          eventsByID[event._id] = [event]
        i++
  
    # returns a Date object for an event's end
    eventEnd = (event) ->
      (if event.end then cloneDate(event.end) else defaultEventEnd(event))
  
    # Event Elements
    #	------------------------------------------------------------------------------
  
    # report when view creates an element for an event
    reportEventElement = (event, element) ->
      eventElements.push element
      if eventElementsByID[event._id]
        eventElementsByID[event._id].push element
      else
        eventElementsByID[event._id] = [element]
    reportEventClear = ->
      eventElements = []
      eventElementsByID = {}
  
    # attaches eventClick, eventMouseover, eventMouseout
    eventElementHandlers = (event, eventElement) ->
      eventElement.click((ev) ->
        trigger "eventClick", this, event, ev  if not eventElement.hasClass("ui-draggable-dragging") and not eventElement.hasClass("ui-resizable-resizing")
      ).hover ((ev) ->
        trigger "eventMouseover", this, event, ev
      ), (ev) ->
        trigger "eventMouseout", this, event, ev

  
    # TODO: don't fire eventMouseover/eventMouseout *while* dragging is occuring (on subject element)
    # TODO: same for resizing
    showEvents = (event, exceptElement) ->
      eachEventElement event, exceptElement, "show"
    hideEvents = (event, exceptElement) ->
      eachEventElement event, exceptElement, "hide"
    eachEventElement = (event, exceptElement, funcName) ->
      elements = eventElementsByID[event._id]
      i = undefined
      len = elements.length
      i = 0
      while i < len
        elements[i][funcName]()  if not exceptElement or elements[i][0] isnt exceptElement[0]
        i++
  
    # Event Modification Reporting
    #	---------------------------------------------------------------------------------
    eventDrop = (e, event, dayDelta, minuteDelta, allDay, ev, ui) ->
      oldAllDay = event.allDay
      eventId = event._id
      moveEvents eventsByID[eventId], dayDelta, minuteDelta, allDay
      trigger "eventDrop", e, event, dayDelta, minuteDelta, allDay, (->
      
        # TODO: investigate cases where this inverse technique might not work
        moveEvents eventsByID[eventId], -dayDelta, -minuteDelta, oldAllDay
        reportEventChange eventId
      ), ev, ui
      reportEventChange eventId
    eventResize = (e, event, dayDelta, minuteDelta, ev, ui) ->
      eventId = event._id
      elongateEvents eventsByID[eventId], dayDelta, minuteDelta
      trigger "eventResize", e, event, dayDelta, minuteDelta, (->
      
        # TODO: investigate cases where this inverse technique might not work
        elongateEvents eventsByID[eventId], -dayDelta, -minuteDelta
        reportEventChange eventId
      ), ev, ui
      reportEventChange eventId
  
    # Event Modification Math
    #	---------------------------------------------------------------------------------
    moveEvents = (events, dayDelta, minuteDelta, allDay) ->
      minuteDelta = minuteDelta or 0
      e = undefined
      len = events.length
      i = 0

      while i < len
        e = events[i]
        e.allDay = allDay  if allDay isnt `undefined`
        addMinutes addDays(e.start, dayDelta, true), minuteDelta
        e.end = addMinutes(addDays(e.end, dayDelta, true), minuteDelta)  if e.end
        normalizeEvent e, options
        i++
    elongateEvents = (events, dayDelta, minuteDelta) ->
      minuteDelta = minuteDelta or 0
      e = undefined
      len = events.length
      i = 0

      while i < len
        e = events[i]
        e.end = addMinutes(addDays(eventEnd(e), dayDelta, true), minuteDelta)
        normalizeEvent e, options
        i++
    
    # exports
    @element = element
    @calendar = calendar
    @name = viewName
    @opt = opt
    @trigger = trigger
    @isEventDraggable = isEventDraggable
    @isEventResizable = isEventResizable
    @reportEvents = reportEvents
    @eventEnd = eventEnd
    @reportEventElement = reportEventElement
    @reportEventClear = reportEventClear
    @eventElementHandlers = eventElementHandlers
    @showEvents = showEvents
    @hideEvents = hideEvents
    @eventDrop = eventDrop
    @eventResize = eventResize
    
)(window)