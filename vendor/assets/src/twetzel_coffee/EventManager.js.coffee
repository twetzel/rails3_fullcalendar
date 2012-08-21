((window) ->

  # compiled with:  http://js2coffee.org/
  @EventManager = (options, _sources, _resources) ->
  
    # exports
  
    # imports
    trigger = @trigger
    getView = @getView
    reportEvents = @reportEvents
    stickySource = events: []
    sources = [stickySource]
    rangeStart = undefined
    rangeEnd = undefined
    currentFetchID = 0
    pendingSourceCnt = 0
    loadingLevel = 0
    cache = []
  
    # locals
  
    # Fetching
    #	-----------------------------------------------------------------------------
    isFetchNeeded = (start, end) ->
      not rangeStart or start < rangeStart or end > rangeEnd
    fetchEvents = (start, end) ->
      rangeStart = start
      rangeEnd = end
      cache = []
      fetchID = ++currentFetchID
      len = sources.length
      pendingSourceCnt = len
      i = 0

      while i < len
        fetchEventSource sources[i], fetchID
        i++
    fetchEventSource = (source, fetchID) ->
      _fetchEventSource source, (events) ->
        if fetchID is currentFetchID
          if events
            i = 0

            while i < events.length
              events[i].source = source
              normalizeEvent events[i]
              i++
            cache = cache.concat(events)
          pendingSourceCnt--
          reportEvents cache  unless pendingSourceCnt

    _fetchEventSource = (source, callback) ->
      i = undefined
      fetchers = fc.sourceFetchers
      res = undefined
      i = 0
      while i < fetchers.length
        res = fetchers[i](source, rangeStart, rangeEnd, callback)
        if res is true
        
          # the fetcher is in charge. made its own async request
          return
        else if typeof res is "object"
        
          # the fetcher returned a new source. process it
          _fetchEventSource res, callback
          return
        i++
      events = source.events
      if events
        if $.isFunction(events)
          pushLoading()
          events cloneDate(rangeStart), cloneDate(rangeEnd), (events) ->
            callback events
            popLoading()

        else if $.isArray(events)
          callback events
        else
          callback()
      else
        url = source.url
        if url
          success = source.success
          error = source.error
          complete = source.complete
          data = $.extend({}, source.data or {})
          startParam = firstDefined(source.startParam, options.startParam)
          endParam = firstDefined(source.endParam, options.endParam)
          data[startParam] = Math.round(+rangeStart / 1000)  if startParam
          data[endParam] = Math.round(+rangeEnd / 1000)  if endParam
          pushLoading()
          $.ajax $.extend({}, ajaxDefaults, source,
            data: data
            success: (events) ->
              events = events or []
              res = applyAll(success, this, arguments_)
              events = res  if $.isArray(res)
              callback events

            error: ->
              applyAll error, this, arguments_
              callback()

            complete: ->
              applyAll complete, this, arguments_
              popLoading()
          )
        else
          callback()
  
    # Sources
    #	-----------------------------------------------------------------------------
    addEventSource = (source) ->
      source = _addEventSource(source)
      if source
        pendingSourceCnt++
        fetchEventSource source, currentFetchID # will eventually call reportEvents
    _addEventSource = (source) ->
      if $.isFunction(source) or $.isArray(source)
        source = events: source
      else source = url: source  if typeof source is "string"
      if typeof source is "object"
        normalizeSource source
        sources.push source
        source
    removeEventSource = (source) ->
      sources = $.grep(sources, (src) ->
        not isSourcesEqual(src, source)
      )
    
      # remove all client events from that source
      cache = $.grep(cache, (e) ->
        not isSourcesEqual(e.source, source)
      )
      reportEvents cache
  
    # Manipulation
    #	-----------------------------------------------------------------------------
    updateEvent = (event) -> # update an existing event
      i = undefined
      len = cache.length
      e = undefined
      defaultEventEnd = getView().defaultEventEnd # getView???
      startDelta = event.start - event._start
      # event._end would be null if event.end
      endDelta = (if event.end then (event.end - (event._end or defaultEventEnd(event))) else 0) # was null and event was just resized
      i = 0
      while i < len
        e = cache[i]
        if e._id is event._id and e isnt event
          e.start = new Date(+e.start + startDelta)
          if event.end
            if e.end
              e.end = new Date(+e.end + endDelta)
            else
              e.end = new Date(+defaultEventEnd(e) + endDelta)
          else
            e.end = null
          e.title = event.title
          e.url = event.url
          e.allDay = event.allDay
          e.className = event.className
          e.editable = event.editable
          e.color = event.color
          e.backgroudColor = event.backgroudColor
          e.borderColor = event.borderColor
          e.textColor = event.textColor
          normalizeEvent e
        i++
      normalizeEvent event
      reportEvents cache
    renderEvent = (event, stick) ->
      normalizeEvent event
      unless event.source
        if stick
          stickySource.events.push event
          event.source = stickySource
        cache.push event
      reportEvents cache
    removeEvents = (filter) ->
      unless filter # remove all
        cache = []
      
        # clear all array sources
        i = 0

        while i < sources.length
          sources[i].events = []  if $.isArray(sources[i].events)
          i++
      else
        unless $.isFunction(filter) # an event ID
          id = filter + ""
          filter = (e) ->
            e._id is id
        cache = $.grep(cache, filter, true)
      
        # remove events from array sources
        i = 0

        while i < sources.length
          sources[i].events = $.grep(sources[i].events, filter, true)  if $.isArray(sources[i].events)
          i++
      reportEvents cache
    clientEvents = (filter) ->
      if $.isFunction(filter)
        return $.grep(cache, filter)
      else if filter # an event ID
        filter += ""
        return $.grep(cache, (e) ->
          e._id is filter
        )
      cache # else, return all
  
    # Loading State
    #	-----------------------------------------------------------------------------
    pushLoading = ->
      trigger "loading", null, true  unless loadingLevel++
    popLoading = ->
      trigger "loading", null, false  unless --loadingLevel
  
    # Event Normalization
    #	-----------------------------------------------------------------------------
    normalizeEvent = (event) ->
      source = event.source or {}
      ignoreTimezone = firstDefined(source.ignoreTimezone, options.ignoreTimezone)
      event._id = event._id or ((if event.id is `undefined` then "_fc" + eventGUID++ else event.id + ""))
      if event.date
        event.start = event.date  unless event.start
        delete event.date
      event._start = cloneDate(event.start = parseDate(event.start, ignoreTimezone))
      event.end = parseDate(event.end, ignoreTimezone)
      event.end = null  if event.end and event.end <= event.start
      event._end = (if event.end then cloneDate(event.end) else null)
      event.allDay = firstDefined(source.allDayDefault, options.allDayDefault)  if event.allDay is `undefined`
      if event.className
        event.className = event.className.split(/\s+/)  if typeof event.className is "string"
      else
        event.className = []
    
      # TODO: if there is no start date, return false to indicate an invalid event
      associateResourceWithEvent event
  
    # Utils
    #	------------------------------------------------------------------------------
    normalizeSource = (source) ->
      if source.className
      
        # TODO: repeat code, same code for event classNames
        source.className = source.className.split(/\s+/)  if typeof source.className is "string"
      else
        source.className = []
      normalizers = fc.sourceNormalizers
      i = 0

      while i < normalizers.length
        normalizers[i] source
        i++
    isSourcesEqual = (source1, source2) ->
      source1 and source2 and getSourcePrimitive(source1) is getSourcePrimitive(source2)
    getSourcePrimitive = (source) ->
      ((if (typeof source is "object") then (source.events or source.url) else "")) or source
  
    # Resources
    #	------------------------------------------------------------------------------
    associateResourceWithEvent = (event) ->
      i = 0
      return  unless event.resourceId
      $.each resources, (intIndex, resource) ->
        if resource.id is event.resourceId
          event.resource = resource
          event.resource._col = i
          delete event.resourceId
        i++

    t = @
    @isFetchNeeded = isFetchNeeded
    @fetchEvents = fetchEvents
    @addEventSource = addEventSource
    @removeEventSource = removeEventSource
    @updateEvent = updateEvent
    @renderEvent = renderEvent
    @removeEvents = removeEvents
    @clientEvents = clientEvents
    @normalizeEvent = normalizeEvent
    @associateResourceWithEvent = associateResourceWithEvent
    
    resources = _resources
    i = 0

    while i < _sources.length
      _addEventSource _sources[i]
      i++
  @fc.sourceNormalizers = []
  @fc.sourceFetchers = []
  ajaxDefaults =
    dataType: "json"
    cache: false

  eventGUID = 1

)(window)