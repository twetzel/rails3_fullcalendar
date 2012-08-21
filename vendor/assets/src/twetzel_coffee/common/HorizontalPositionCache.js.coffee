((window) ->
  HorizontalPositionCache = (getElement) ->
    e = (i) ->
      elements[i] = elements[i] or getElement(i)
    t = this
    elements = {}
    lefts = {}
    rights = {}
    @left = (i) ->
      lefts[i] = (if lefts[i] is `undefined` then e(i).position().left else lefts[i])

    @right = (i) ->
      rights[i] = (if rights[i] is `undefined` then @left(i) + e(i).width() else rights[i])

    @clear = ->
      elements = {}
      lefts = {}
      rights = {}
)(window)