# compiled with:  http://js2coffee.org/
((window) ->
  # Date Math
  #-----------------------------------------------------------------------------
  @addYears = (d, n, keepTime) ->
    d.setFullYear d.getFullYear() + n
    clearTime d  unless keepTime
    d
  @addMonths = (d, n, keepTime) -> # prevents day overflow/underflow
    if +d # prevent infinite looping on invalid dates
      m = d.getMonth() + n
      check = cloneDate(d)
      check.setDate 1
      check.setMonth m
      d.setMonth m
      clearTime d  unless keepTime
      d.setDate d.getDate() + ((if d < check then 1 else -1))  until d.getMonth() is check.getMonth()
    d
  @addDays = (d, n, keepTime) -> # deals with daylight savings
    if +d
      dd = d.getDate() + n
      check = cloneDate(d)
      check.setHours 9 # set to middle of day
      check.setDate dd
      d.setDate dd
      clearTime d  unless keepTime
      fixDate d, check
    d
  @fixDate = (d, check) -> # force d to be on check's YMD, for daylight savings purposes
    # prevent infinite looping on invalid dates
    d.setTime +d + ((if d < check then 1 else -1)) * HOUR_MS  until d.getDate() is check.getDate()  if +d
  @addMinutes = (d, n) ->
    d.setMinutes d.getMinutes() + n
    d
  @clearTime = (d) ->
    d.setHours 0
    d.setMinutes 0
    d.setSeconds 0
    d.setMilliseconds 0
    d
  @cloneDate = (d, dontKeepTime) ->
    return clearTime(new Date(+d))  if dontKeepTime
    new Date(+d)
  @zeroDate = -> # returns a Date with time 00:00:00 and dateOfMonth=1
    i = 0
    d = undefined
    loop
      d = new Date(1970, i++, 1)
      break unless d.getHours() # != 0
    d
  @skipWeekend = (date, inc, excl) ->
    inc = inc or 1
    addDays date, inc  while not date.getDay() or (excl and date.getDay() is 1 or not excl and date.getDay() is 6)
    date
  @dayDiff = (d1, d2) -> # d1 - d2
    Math.round (cloneDate(d1, true) - cloneDate(d2, true)) / DAY_MS
  @setYMD = (date, y, m, d) ->
    if y isnt `undefined` and y isnt date.getFullYear()
      date.setDate 1
      date.setMonth 0
      date.setFullYear y
    if m isnt `undefined` and m isnt date.getMonth()
      date.setDate 1
      date.setMonth m
    date.setDate d  if d isnt `undefined`

  # Date Parsing
  #-----------------------------------------------------------------------------
  @parseDate = (s, ignoreTimezone) -> # ignoreTimezone defaults to true
    # already a Date object
    return s  if typeof s is "object"
    # a UNIX timestamp
    return new Date(s * 1000)  if typeof s is "number"
    if typeof s is "string"
      # a UNIX timestamp
      return new Date(parseFloat(s) * 1000)  if s.match(/^\d+(\.\d+)?$/)
      ignoreTimezone = true  if ignoreTimezone is `undefined`
      return parseISO8601(s, ignoreTimezone) or ((if s then new Date(s) else null))
  
    # TODO: never return invalid dates (like from new Date(<string>)), return null instead
    null
  @parseISO8601 = (s, ignoreTimezone) -> # ignoreTimezone defaults to false
    # derived from http://delete.me.uk/2005/03/iso8601.html
    # TODO: for a know glitch/feature, read tests/issue_206_parseDate_dst.html
    m = s.match(/^([0-9]{4})(-([0-9]{2})(-([0-9]{2})([T ]([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?(Z|(([-+])([0-9]{2})(:?([0-9]{2}))?))?)?)?)?$/)
    return null  unless m
    date = new Date(m[1], 0, 1)
    if ignoreTimezone or not m[14]
      check = new Date(m[1], 0, 1, 9, 0)
      if m[3]
        date.setMonth m[3] - 1
        check.setMonth m[3] - 1
      if m[5]
        date.setDate m[5]
        check.setDate m[5]
      fixDate date, check
      date.setHours m[7]  if m[7]
      date.setMinutes m[8]  if m[8]
      date.setSeconds m[10]  if m[10]
      date.setMilliseconds Number("0." + m[12]) * 1000  if m[12]
      fixDate date, check
    else
      date.setUTCFullYear m[1], (if m[3] then m[3] - 1 else 0), m[5] or 1
      date.setUTCHours m[7] or 0, m[8] or 0, m[10] or 0, (if m[12] then Number("0." + m[12]) * 1000 else 0)
      offset = Number(m[16]) * 60 + ((if m[18] then Number(m[18]) else 0))
      offset *= (if m[15] is "-" then 1 else -1)
      date = new Date(+date + (offset * 60 * 1000))
    date
  @parseTime = (s) -> # returns minutes since start of day
    # an hour
    return s * 60  if typeof s is "number"
    # a Date object
    return s.getHours() * 60 + s.getMinutes()  if typeof s is "object"
    m = s.match(/(\d+)(?::(\d+))?\s*(\w+)?/)
    if m
      h = parseInt(m[1], 10)
      if m[3]
        h %= 12
        h += 12  if m[3].toLowerCase().charAt(0) is "p"
      h * 60 + ((if m[2] then parseInt(m[2], 10) else 0))

  # Date Formatting
  #-----------------------------------------------------------------------------

  # TODO: use same function formatDate(date, [date2], format, [options])
  @formatDate = (date, format, options) ->
    formatDates date, null, format, options
  @formatDates = (date1, date2, format, options) ->
    options = options or defaults
    date = date1
    otherDate = date2
    i = undefined
    len = format.length
    c = undefined
    i2 = undefined
    formatter = undefined
    res = ""
    i = 0
    while i < len
      c = format.charAt(i)
      if c is "'"
        i2 = i + 1
        while i2 < len
          if format.charAt(i2) is "'"
            if date
              if i2 is i + 1
                res += "'"
              else
                res += format.substring(i + 1, i2)
              i = i2
            break
          i2++
      else if c is "("
        i2 = i + 1
        while i2 < len
          if format.charAt(i2) is ")"
            subres = formatDate(date, format.substring(i + 1, i2), options)
            res += subres  if parseInt(subres.replace(/\D/, ""), 10)
            i = i2
            break
          i2++
      else if c is "["
        i2 = i + 1
        while i2 < len
          if format.charAt(i2) is "]"
            subformat = format.substring(i + 1, i2)
            subres = formatDate(date, subformat, options)
            res += subres  unless subres is formatDate(otherDate, subformat, options)
            i = i2
            break
          i2++
      else if c is "{"
        date = date2
        otherDate = date1
      else if c is "}"
        date = date1
        otherDate = date2
      else
        i2 = len
        while i2 > i
          if formatter = dateFormatters[format.substring(i, i2)]
            res += formatter(date, options)  if date
            i = i2 - 1
            break
          i2--
        res += c  if date  if i2 is i
      i++
    res
  @fc.addDays = addDays
  @fc.cloneDate = cloneDate
  @fc.parseDate = parseDate
  @fc.parseISO8601 = parseISO8601
  @fc.parseTime = parseTime
  @fc.formatDate = formatDate
  @fc.formatDates = formatDates
  @dayIDs = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  @DAY_MS = 86400000
  @HOUR_MS = 3600000
  @MINUTE_MS = 60000
  @dateFormatters =
    s: (d) ->
      d.getSeconds()

    ss: (d) ->
      zeroPad d.getSeconds()

    m: (d) ->
      d.getMinutes()

    mm: (d) ->
      zeroPad d.getMinutes()

    h: (d) ->
      d.getHours() % 12 or 12

    hh: (d) ->
      zeroPad d.getHours() % 12 or 12

    H: (d) ->
      d.getHours()

    HH: (d) ->
      zeroPad d.getHours()

    d: (d) ->
      d.getDate()

    dd: (d) ->
      zeroPad d.getDate()

    ddd: (d, o) ->
      o.dayNamesShort[d.getDay()]

    dddd: (d, o) ->
      o.dayNames[d.getDay()]

    M: (d) ->
      d.getMonth() + 1

    MM: (d) ->
      zeroPad d.getMonth() + 1

    MMM: (d, o) ->
      o.monthNamesShort[d.getMonth()]

    MMMM: (d, o) ->
      o.monthNames[d.getMonth()]

    yy: (d) ->
      (d.getFullYear() + "").substring 2

    yyyy: (d) ->
      d.getFullYear()

    t: (d) ->
      (if d.getHours() < 12 then "a" else "p")

    tt: (d) ->
      (if d.getHours() < 12 then "am" else "pm")

    T: (d) ->
      (if d.getHours() < 12 then "A" else "P")

    TT: (d) ->
      (if d.getHours() < 12 then "AM" else "PM")

    u: (d) ->
      formatDate d, "yyyy-MM-dd'T'HH:mm:ss'Z'"

    S: (d) ->
      date = d.getDate()
      return "th"  if date > 10 and date < 20
      ["st", "nd", "rd"][date % 10 - 1] or "th"
    

)(window)