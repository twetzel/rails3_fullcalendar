# compiled with:  http://js2coffee.org/

((window) ->
  
  @Calendar = (element, options, eventSources, eventResources) ->
    
    # exports
  
    # imports
    t = this
    isFetchNeeded = @isFetchNeeded
    fetchEvents = @fetchEvents
    associateResourceWithEvent = @associateResourceWithEvent
    _element = element[0]
    resourceList = undefined
    resourceListElement = undefined
    header = undefined
    headerElement = undefined
    content = undefined
    tm = undefined
    currentView = undefined
    viewInstances = {}
    elementOuterWidth = undefined
    suggestedViewHeight = undefined
    absoluteViewElement = undefined
    resizeUID = 0
    ignoreWindowResize = 0
    date = new Date()
    events = []
    _dragElement = undefined
  
    # locals
    # for making theme classes
  
    # Main Rendering
    #	-----------------------------------------------------------------------------
    render = (inc, rebuildSkeleton) ->
      unless content
        initialRender()
      else
        calcSize()
        markSizesDirty()
        markEventsDirty()
        renderView inc, rebuildSkeleton
    initialRender = ->
      tm = (if options.theme then "ui" else "fc")
      element.addClass "fc"
      element.addClass "fc-rtl"  if options.isRTL
      element.addClass "ui-widget"  if options.theme
      content = $("<div class='fc-content' style='position:relative'/>").prependTo(element)
    
      # Render out the resource list before the Calendar (not applicable to all views?)
      resourceList = new ResourceList(t, options, eventResources)
      resourceListElement = resourceList.render()
      element.prepend resourceListElement  if resourceListElement
      header = new Header(t, options)
      headerElement = header.render()
      element.prepend headerElement  if headerElement
      changeView options.defaultView
      $(window).resize windowResize
    
      # needed for IE in a 0x0 iframe, b/c when it is resized, never triggers a windowResize
      lateRender()  unless bodyVisible()
  
    # called when we know the calendar couldn't be rendered when it was initialized,
    # but we think it's ready now
    lateRender = ->
      setTimeout (-> # IE7 needs this so dimensions are calculated correctly
        # !currentView.start makes sure this never happens more than once
        renderView()  if not currentView.start and bodyVisible()
      ), 0
    destroy = ->
      $(window).unbind "resize", windowResize
      header.destroy()
      content.remove()
      element.removeClass "fc fc-rtl ui-widget"
    elementVisible = ->
      _element.offsetWidth isnt 0
    bodyVisible = ->
      $("body")[0].offsetWidth isnt 0
  
    # View Rendering
    #	-----------------------------------------------------------------------------
  
    # TODO: improve view switching (still weird transition in IE, and FF has whiteout problem)
    changeView = (newViewName) ->
      if not currentView or newViewName isnt currentView.name
        ignoreWindowResize++ # because setMinHeight might change the height before render (and subsequently setSize) is reached
        unselect()
        oldView = currentView
        newViewElement = undefined
        if oldView
          (oldView.beforeHide or noop)() # called before changing min-height. if called after, scroll state is reset (in Opera)
          setMinHeight content, content.height()
          oldView.element.hide()
        else
          setMinHeight content, 1 # needs to be 1 (not 0) for IE7, or else view dimensions miscalculated
        content.css "overflow", "hidden"
        currentView = viewInstances[newViewName]
        if currentView
          currentView.element.show()
        else
          currentView = viewInstances[newViewName] = new fcViews[newViewName](newViewElement = absoluteViewElement = $("<div class='fc-view fc-view-" + newViewName + "' style='position:absolute'/>").appendTo(content), t) # the calendar object
        header.deactivateButton oldView.name  if oldView
        header.activateButton newViewName
        renderView() # after height has been set, will make absoluteViewElement's position=relative, then set to null
        content.css "overflow", ""
        setMinHeight content, 1  if oldView
        (currentView.afterShow or noop)()  unless newViewElement # called after setting min-height/overflow, so in final scroll state (for Opera)
        ignoreWindowResize--
    renderView = (inc, rebuildSkeleton) ->
      if elementVisible()
        ignoreWindowResize++ # because renderEvents might temporarily change the height before setSize is reached
        unselect()
        calcSize()  if suggestedViewHeight is `undefined`
        forceEventRender = false
        if not currentView.start or inc or date < currentView.start or date >= currentView.end or rebuildSkeleton
        
          # view must render an entire new date range (and refetch/render events)
          currentView.render date, inc or 0, rebuildSkeleton # responsible for clearing events
          setSize true
          forceEventRender = true
        else if currentView.sizeDirty
        
          # view must resize (and rerender events)
          currentView.clearEvents()
          setSize()
          forceEventRender = true
        else if currentView.eventsDirty
          currentView.clearEvents()
          forceEventRender = true
        currentView.sizeDirty = false
        currentView.eventsDirty = false
        updateEvents forceEventRender
        elementOuterWidth = element.outerWidth()
        header.updateTitle currentView.title
        today = new Date()
        if today >= currentView.start and today < currentView.end
          header.disableButton "today"
        else
          header.enableButton "today"
        ignoreWindowResize--
        currentView.trigger "viewDisplay", _element
  
    # Resizing
    #	-----------------------------------------------------------------------------
    updateSize = ->
      markSizesDirty()
      if elementVisible()
        calcSize()
        setSize()
        unselect()
        currentView.clearEvents()
        currentView.renderEvents events
        currentView.sizeDirty = false
    markSizesDirty = ->
      $.each viewInstances, (i, inst) ->
        inst.sizeDirty = true

    calcSize = ->
      if options.contentHeight
        suggestedViewHeight = options.contentHeight
      else if options.height
        suggestedViewHeight = options.height - ((if headerElement then headerElement.height() else 0)) - vsides(content)
      else
        suggestedViewHeight = Math.round(content.width() / Math.max(options.aspectRatio, .5))
    setSize = (dateChanged) -> # todo: dateChanged?
      ignoreWindowResize++
      currentView.setHeight suggestedViewHeight, dateChanged
      if absoluteViewElement
        absoluteViewElement.css "position", "relative"
        absoluteViewElement = null
      currentView.setWidth content.width(), dateChanged
      ignoreWindowResize--
    windowResize = ->
      unless ignoreWindowResize
        if currentView.start # view has already been rendered
          uid = ++resizeUID
          setTimeout (-> # add a delay
            if uid is resizeUID and not ignoreWindowResize and elementVisible()
              unless elementOuterWidth is (elementOuterWidth = element.outerWidth())
                ignoreWindowResize++ # in case the windowResize callback changes the height
                updateSize()
                currentView.trigger "windowResize", _element
                ignoreWindowResize--
          ), 200
        else
        
          # calendar must have been initialized in a 0x0 iframe that has just been resized
          lateRender()
  
    # Event Fetching/Rendering
    #	-----------------------------------------------------------------------------
  
    # fetches events if necessary, rerenders events if necessary (or if forced)
    updateEvents = (forceRender) ->
      if not options.lazyFetching or isFetchNeeded(currentView.visStart, currentView.visEnd)
        refetchEvents()
      else rerenderEvents()  if forceRender
    refetchEvents = ->
      fetchEvents currentView.visStart, currentView.visEnd # will call reportEvents
  
    # called when event data arrives
    reportEvents = (_events) ->
      events = _events
      rerenderEvents()
  
    # called when a single event's data has been changed
    reportEventChange = (eventID) ->
      rerenderEvents eventID
  
    # attempts to rerenderEvents
    rerenderEvents = (modifiedEventID) ->
      markEventsDirty()
      if elementVisible()
        currentView.clearEvents()
        currentView.renderEvents events, modifiedEventID
        currentView.eventsDirty = false
    markEventsDirty = ->
      $.each viewInstances, (i, inst) ->
        inst.eventsDirty = true

    addEventResource = (resource) ->
      eventResources.push resource
      i = 0

      while i < events.length
        associateResourceWithEvent events[i]
        i++
      render false, true
    removeEventResource = (resourceId) ->
      updatedResources = []
      i = 0

      while i < eventResources.length
        updatedResources.push eventResources[i]  unless eventResources[i].id is resourceId
        i++
      eventResources = updatedResources
      render false, true
  
    # Selection
    #	-----------------------------------------------------------------------------
    select = (start, end, allDay) ->
      currentView.select start, end, (if allDay is `undefined` then true else allDay)
    unselect = -> # safe to be called before renderView
      currentView.unselect()  if currentView
  
    # Date
    #	-----------------------------------------------------------------------------
    prev = ->
      renderView -1
    next = ->
      renderView 1
    prevYear = ->
      addYears date, -1
      renderView()
    nextYear = ->
      addYears date, 1
      renderView()
    today = ->
      date = new Date()
      renderView()
    gotoDate = (year, month, dateOfMonth) ->
      if year instanceof Date
        date = cloneDate(year) # provided 1 argument, a Date
      else
        setYMD date, year, month, dateOfMonth
      renderView()
    incrementDate = (years, months, days) ->
      addYears date, years  if years isnt `undefined`
      addMonths date, months  if months isnt `undefined`
      addDays date, days  if days isnt `undefined`
      renderView()
    getDate = ->
      cloneDate date
  
    # Misc
    #	-----------------------------------------------------------------------------
    getView = ->
      currentView
    option = (name, value) ->
      return options[name]  if value is `undefined`
      if name is "height" or name is "contentHeight" or name is "aspectRatio"
        options[name] = value
        updateSize()
    trigger = (name, thisObj) ->
      options[name].apply thisObj or _element, Array::slice.call(arguments_, 2)  if options[name]
    
    @options = options
    @render = render
    @destroy = destroy
    @refetchEvents = refetchEvents
    @reportEvents = reportEvents
    @reportEventChange = reportEventChange
    @rerenderEvents = rerenderEvents
    @changeView = changeView
    @select = select
    @unselect = unselect
    @prev = prev
    @next = next
    @prevYear = prevYear
    @nextYear = nextYear
    @today = today
    @gotoDate = gotoDate
    @incrementDate = incrementDate
    @formatDate = (format, date) ->
      formatDate format, date, options

    @formatDates = (format, date1, date2) ->
      formatDates format, date1, date2, options

    @getDate = getDate
    @getView = getView
    @option = option
    @trigger = trigger
    @getResources = ->
      eventResources

    @setResources = (resources) ->
      eventResources = resources
      render false, true

    @addEventResource = addEventResource
    @removeEventResource = removeEventResource
    EventManager.call t, options, eventSources, eventResources
    
    setYMD date, options.year, options.month, options.date
  
    # External Dragging
    #	------------------------------------------------------------------------
    if options.droppable
      # not already inside a calendar
      $(document).bind("dragstart", (ev, ui) ->
        _e = ev.target
        e = $(_e)
        unless e.parents(".fc").length
          accept = options.dropAccept
          if (if $.isFunction(accept) then accept.call(_e, e) else e.is(accept))
            _dragElement = _e
            currentView.dragStart _dragElement, ev, ui
      ).bind "dragstop", (ev, ui) ->
        if _dragElement
          currentView.dragStop _dragElement, ev, ui
          _dragElement = null

)(window)