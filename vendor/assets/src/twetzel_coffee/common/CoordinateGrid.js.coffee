((window) ->
  CoordinateGrid = (buildFunc) ->
    t = this
    rows = undefined
    cols = undefined
    @build = ->
      rows = []
      cols = []
      buildFunc rows, cols

    @cell = (x, y) ->
      rowCnt = rows.length
      colCnt = cols.length
      i = undefined
      r = -1
      c = -1
      i = 0
      while i < rowCnt
        if y >= rows[i][0] and y < rows[i][1]
          r = i
          break
        i++
      i = 0
      while i < colCnt
        if x >= cols[i][0] and x < cols[i][1]
          c = i
          break
        i++
      (if (r >= 0 and c >= 0)
        row: r
        col: c
       else null)

    @rect = (row0, col0, row1, col1, originElement) -> # row1,col1 is inclusive
      origin = originElement.offset()
      top: rows[row0][0] - origin.top
      left: cols[col0][0] - origin.left
      width: cols[col1][1] - cols[col0][0]
      height: rows[row1][1] - rows[row0][0]

)(window)