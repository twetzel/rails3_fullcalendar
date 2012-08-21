((window) ->
  # method calling

  # would like to have this logic in EventManager, but needs to happen before options are recursively extended
  # TODO: look into memory leak implications

  # function for adding/overriding defaults
  @setDefaults = (d) ->
    $.extend true, defaults, d
  @fc = $.fullCalendar = version: "@VERSION"
  @fcViews = fc.views = {}
  $.fn.fullCalendar = (options) ->
    if typeof options is "string"
      args = Array::slice.call(arguments_, 1)
      res = undefined
      @each ->
        calendar = $.data(this, "fullCalendar")
        if calendar and $.isFunction(calendar[options])
          r = calendar[options].apply(calendar, args)
          res = r  if res is `undefined`
          $.removeData this, "fullCalendar"  if options is "destroy"

      return res  if res isnt `undefined`
      return this
    eventSources = options.eventSources or []
    delete options.eventSources

    if options.events
      eventSources.push options.events
      delete options.events
    eventResources = options.eventResources or []
    delete options.eventResources

    if options.resources
      eventResources = options.resources
      delete options.resources
    options = $.extend(true, {}, defaults, (if (options.isRTL or options.isRTL is `undefined` and defaults.isRTL) then rtlDefaults else {}), options)
    @each (i, _element) ->
      element = $(_element)
      calendar = new Calendar(element, options, eventSources, eventResources)
      element.data "fullCalendar", calendar
      calendar.render()

    this

)(window)