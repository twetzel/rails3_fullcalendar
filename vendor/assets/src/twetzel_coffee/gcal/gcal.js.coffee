#
# * FullCalendar v@VERSION Google Calendar Plugin
# *
# * Copyright (c) 2011 Adam Shaw
# * Dual licensed under the MIT and GPL licenses, located in
# * MIT-LICENSE.txt and GPL-LICENSE.txt respectively.
# *
# * Date: @DATE
# *
# 
(($) ->
  transformOptions = (sourceOptions, start, end) ->
    success = sourceOptions.success
    data = $.extend({}, sourceOptions.data or {},
      "start-min": formatDate(start, "u")
      "start-max": formatDate(end, "u")
      singleevents: true
      "max-results": 9999
    )
    ctz = sourceOptions.currentTimezone
    data.ctz = ctz = ctz.replace(" ", "_")  if ctz
    $.extend {}, sourceOptions,
      url: sourceOptions.url.replace(/\/basic$/, "/full") + "?alt=json-in-script&callback=?"
      dataType: "jsonp"
      data: data
      startParam: false
      endParam: false
      success: (data) ->
        events = []
        if data.feed.entry
          $.each data.feed.entry, (i, entry) ->
            startStr = entry["gd$when"][0]["startTime"]
            start = parseISO8601(startStr, true)
            end = parseISO8601(entry["gd$when"][0]["endTime"], true)
            allDay = startStr.indexOf("T") is -1
            url = undefined
            $.each entry.link, (i, link) ->
              if link.type is "text/html"
                url = link.href
                url += ((if url.indexOf("?") is -1 then "?" else "&")) + "ctz=" + ctz  if ctz

            addDays end, -1  if allDay # make inclusive
            events.push
              id: entry["gCal$uid"]["value"]
              title: entry["title"]["$t"]
              # new twetzel
              gcalendar: entry['author'][0]['name']['$t']
              # end of new Stuff
              url: url
              start: start
              end: end
              allDay: allDay
              location: entry["gd$where"][0]["valueString"]
              description: entry["content"]["$t"]


        args = [events].concat(Array::slice.call(arguments_, 1))
        res = applyAll(success, this, args)
        return res  if $.isArray(res)
        events

  fc = $.fullCalendar
  formatDate = fc.formatDate
  parseISO8601 = fc.parseISO8601
  addDays = fc.addDays
  applyAll = fc.applyAll
  fc.sourceNormalizers.push (sourceOptions) ->
    if sourceOptions.dataType is "gcal" or sourceOptions.dataType is `undefined` and (sourceOptions.url or "").match(/^(http|https):\/\/www.google.com\/calendar\/feeds\//)
      sourceOptions.dataType = "gcal"
      sourceOptions.editable = false  if sourceOptions.editable is `undefined`

  fc.sourceFetchers.push (sourceOptions, start, end) ->
    transformOptions sourceOptions, start, end  if sourceOptions.dataType is "gcal"

  
  # legacy
  fc.gcalFeed = (url, sourceOptions) ->
    $.extend {}, sourceOptions,
      url: url
      dataType: "gcal"

) jQuery
