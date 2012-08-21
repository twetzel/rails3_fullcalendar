((window) ->
  # Event Date Math
  #-----------------------------------------------------------------------------
  @exclEndDay = (event) ->
    if event.end
      _exclEndDay event.end, event.allDay
    else
      addDays cloneDate(event.start), 1
  @_exclEndDay = (end, allDay) ->
    end = cloneDate(end)
    (if allDay or end.getHours() or end.getMinutes() then addDays(end, 1) else clearTime(end))
  @segCmp = (a, b) ->
    (b.msLength - a.msLength) * 100 + (a.event.start - b.event.start)
  @segsCollide = (seg1, seg2) ->
    seg1.end > seg2.start and seg1.start < seg2.end

  # Event Sorting
  #-----------------------------------------------------------------------------

  # event rendering utilities
  @sliceSegs = (events, visEventEnds, start, end) ->
    segs = []
    i = undefined
    len = events.length
    event = undefined
    eventStart = undefined
    eventEnd = undefined
    segStart = undefined
    segEnd = undefined
    isStart = undefined
    isEnd = undefined
    i = 0
    while i < len
      event = events[i]
      eventStart = event.start
      eventEnd = visEventEnds[i]
      if eventEnd > start and eventStart < end
        if eventStart < start
          segStart = cloneDate(start)
          isStart = false
        else
          segStart = eventStart
          isStart = true
        if eventEnd > end
          segEnd = cloneDate(end)
          isEnd = false
        else
          segEnd = eventEnd
          isEnd = true
        segs.push
          event: event
          start: segStart
          end: segEnd
          isStart: isStart
          isEnd: isEnd
          msLength: segEnd - segStart

      i++
    segs.sort segCmp

  # event rendering calculation utilities
  @stackSegs = (segs) ->
    levels = []
    i = undefined
    len = segs.length
    seg = undefined
    j = undefined
    collide = undefined
    k = undefined
    i = 0
    while i < len
      seg = segs[i]
      j = 0 # the level index where seg should belong
      loop
        collide = false
        if levels[j]
          k = 0
          while k < levels[j].length
            if segsCollide(levels[j][k], seg)
              collide = true
              break
            k++
        if collide
          j++
        else
          break
      if levels[j]
        levels[j].push seg
      else
        levels[j] = [seg]
      i++
    levels

  # Event Element Binding
  #-----------------------------------------------------------------------------
  @lazySegBind = (container, segs, bindHandlers) ->
    container.unbind("mouseover").mouseover (ev) ->
      parent = ev.target
      e = undefined
      i = undefined
      seg = undefined
      until parent is this
        e = parent
        parent = parent.parentNode
      if (i = e._fci) isnt `undefined`
        e._fci = `undefined`
        seg = segs[i]
        bindHandlers seg.event, seg.element, seg
        $(ev.target).trigger ev
      ev.stopPropagation()


  # Element Dimensions
  #-----------------------------------------------------------------------------
  @setOuterWidth = (element, width, includeMargins) ->
    i = 0
    e = undefined

    while i < element.length
      e = $(element[i])
      e.width Math.max(0, width - hsides(e, includeMargins))
      i++
  @setOuterHeight = (element, height, includeMargins) ->
    i = 0
    e = undefined

    while i < element.length
      e = $(element[i])
      e.height Math.max(0, height - vsides(e, includeMargins))
      i++

  # TODO: curCSS has been deprecated (jQuery 1.4.3 - 10/16/2010)
  @hsides = (element, includeMargins) ->
    hpadding(element) + hborders(element) + ((if includeMargins then hmargins(element) else 0))
  @hpadding = (element) ->
    (parseFloat($.curCSS(element[0], "paddingLeft", true)) or 0) + (parseFloat($.curCSS(element[0], "paddingRight", true)) or 0)
  @hmargins = (element) ->
    (parseFloat($.curCSS(element[0], "marginLeft", true)) or 0) + (parseFloat($.curCSS(element[0], "marginRight", true)) or 0)
  @hborders = (element) ->
    (parseFloat($.curCSS(element[0], "borderLeftWidth", true)) or 0) + (parseFloat($.curCSS(element[0], "borderRightWidth", true)) or 0)
  @vsides = (element, includeMargins) ->
    vpadding(element) + vborders(element) + ((if includeMargins then vmargins(element) else 0))
  @vpadding = (element) ->
    (parseFloat($.curCSS(element[0], "paddingTop", true)) or 0) + (parseFloat($.curCSS(element[0], "paddingBottom", true)) or 0)
  @vmargins = (element) ->
    (parseFloat($.curCSS(element[0], "marginTop", true)) or 0) + (parseFloat($.curCSS(element[0], "marginBottom", true)) or 0)
  @vborders = (element) ->
    (parseFloat($.curCSS(element[0], "borderTopWidth", true)) or 0) + (parseFloat($.curCSS(element[0], "borderBottomWidth", true)) or 0)
  @setMinHeight = (element, height) ->
    height = ((if typeof height is "number" then height + "px" else height))
    element.each (i, _element) ->
      _element.style.cssText += ";min-height:" + height + ";_height:" + height


  # why can't we just use .css() ? i forget

  # Misc Utils
  #-----------------------------------------------------------------------------

  #TODO: arraySlice
  #TODO: isFunction, grep ?
  @noop = ->
  @cmp = (a, b) ->
    a - b
  @arrayMax = (a) ->
    Math.max.apply Math, a
  @zeroPad = (n) ->
    ((if n < 10 then "0" else "")) + n
  @smartProperty = (obj, name) -> # get a camel-cased/namespaced property of an object
    return obj[name]  if obj[name] isnt `undefined`
    parts = name.split(/(?=[A-Z])/)
    i = parts.length - 1
    res = undefined
    while i >= 0
      res = obj[parts[i].toLowerCase()]
      return res  if res isnt `undefined`
      i--
    obj[""]
  @htmlEscape = (s) ->
    s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/'/g, "&#039;").replace(/"/g, "&quot;").replace /\n/g, "<br />"
  @cssKey = (_element) ->
    _element.id + "/" + _element.className + "/" + _element.style.cssText.replace(/(^|;)\s*(top|left|width|height)\s*:[^;]*/g, "")
  @disableTextSelection = (element) ->
    element.attr("unselectable", "on").css("MozUserSelect", "none").bind "selectstart.ui", ->
      false


  #
  #function enableTextSelection(element) {
  #	element
  #		.attr('unselectable', 'off')
  #		.css('MozUserSelect', '')
  #		.unbind('selectstart.ui');
  #}
  #
  @markFirstLast = (e) ->
    e.children().removeClass("fc-first fc-last").filter(":first-child").addClass("fc-first").end().filter(":last-child").addClass "fc-last"
  @setDayID = (cell, date) ->
    cell.each (i, _cell) ->
      _cell.className = _cell.className.replace(/^fc-\w*/, "fc-" + dayIDs[date.getDay()])


  # TODO: make a way that doesn't rely on order of classes
  @getSkinCss = (event, opt) ->
    source = event.source or {}
    eventColor = event.color
    sourceColor = source.color
    optionColor = opt("eventColor")
    backgroundColor = event.backgroundColor or eventColor or source.backgroundColor or sourceColor or opt("eventBackgroundColor") or optionColor
    borderColor = event.borderColor or eventColor or source.borderColor or sourceColor or opt("eventBorderColor") or optionColor
    textColor = event.textColor or source.textColor or opt("eventTextColor")
    statements = []
    statements.push "background-color:" + backgroundColor  if backgroundColor
    statements.push "border-color:" + borderColor  if borderColor
    statements.push "color:" + textColor  if textColor
    statements.join ";"
  @getSkinCssWithResource = (event, resource) ->
    source = event.source or {}
    eventColor = resource.color
    backgroundColor = eventColor
    borderColor = eventColor
    textColor = resource.textColor
    statements = []
    statements.push "background-color:" + backgroundColor  if backgroundColor
    statements.push "border-color:" + borderColor  if borderColor
    statements.push "color:" + textColor  if textColor
    statements.join ";"
  applyAll = (functions, thisObj, args) ->
    functions = [functions]  if $.isFunction(functions)
    if functions
      i = undefined
      ret = undefined
      i = 0
      while i < functions.length
        ret = functions[i].apply(thisObj, args) or ret
        i++
      ret
  @firstDefined = ->
    i = 0

    while i < arguments_.length
      return arguments_[i]  if arguments_[i] isnt `undefined`
      i++
  @fc.applyAll = applyAll

)(window)