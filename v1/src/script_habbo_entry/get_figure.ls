global figurePartList, figureColorList, MyfigurePartList, MyfigureColorList

on mouseDown me
  sendAllSprites(#getMyFigureData)
  getResults(me)
end

on getResults me
  MyfigurePartList = [:]
  MyfigureColorList = [:]
  tmpStr = EMPTY
  put figurePartList
  put figureColorList
  repeat with c = 1 to figurePartList.count
    if (c < figurePartList.count) then
      tmpStr = ((((tmpStr & figurePartList[c]) & "/") & figureColorList[c]) & "&")
    else
      tmpStr = (((tmpStr & figurePartList[c]) & "/") & figureColorList[c])
    end if
    MyfigurePartList.addProp(getPropAt(figurePartList, c), figurePartList[c].char[(length(figurePartList[c]) - 2)])
    if (((figureColorList[c] = "0") or (figureColorList[c] = EMPTY)) or voidp(figureColorList[c])) then
      MyfigureColorList.addProp(getPropAt(figureColorList, c), paletteIndex(0))
      next repeat
    end if
    MyfigureColorList.addProp(getPropAt(figureColorList, c), value((("color(#rgb," & figureColorList[c]) & ")")))
  end repeat
  put tmpStr into field "figure_field"
end
