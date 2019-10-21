property pContinentList, pCountryList, pWriterObjID, pWriterObjUnderLineID, pWriterObj, pWriterObjUnderLine, pSelection, pImgBuffer, pLineHeight

on construct me 
  pContinentList = [:]
  pCountryList = [:]
  pLineHeight = getStructVariable("struct.font.plain").getaProp(#lineHeight)
  pSelection = [#number:0, #name:void(), #continent:void()]
  pImgBuffer = void()
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  if memberExists("char_continent_list") then
    tStr = member(getmemnum("char_continent_list")).text
    i = 1
    repeat while i <= tStr.count(#line)
      tLine = tStr.getProp(#line, i)
      if tLine <> "" then
        if tLine.getProp(#char, 1) <> "#" then
          pContinentList.addProp(tLine.getProp(#item, 2), [#number:integer(tLine.getProp(#item, 1)), #type:symbol(tLine.getProp(#item, 3))])
        end if
      end if
      i = (1 + i)
    end repeat
    exit repeat
  end if
  error(me, "Continent list not found!", #construct)
  if memberExists("char_country_list") then
    tStr = member(getmemnum("char_country_list")).text
    i = 1
    repeat while i <= tStr.count(#line)
      tLine = tStr.getProp(#line, i)
      if tLine <> "" then
        if tLine.getProp(#char, 1) <> "#" then
          tNumber = integer(tLine.getProp(#item, 1))
          tContID = integer(tLine.getProp(#item, 2))
          tName = tLine.getProp(#item, 3)
          tStruct = pCountryList.getaProp(tContID)
          if voidp(tStruct) then
            tStruct = []
            pCountryList.setaProp(tContID, tStruct)
          end if
          tStruct.add([#number:tNumber, #name:tName])
        end if
      end if
      i = (1 + i)
    end repeat
    exit repeat
  end if
  error(me, "Country list not found!", #construct)
  the itemDelimiter = tDelim
  i = 1
  repeat while i <= pContinentList.count
    createText("char_cont_" & i, pContinentList.getPropAt(i))
    i = (1 + i)
  end repeat
  pWriterObjID = me.getID() && the milliSeconds
  tMetrics = getStructVariable("struct.font.plain")
  createWriter(pWriterObjID, tMetrics)
  pWriterObj = getWriter(pWriterObjID)
  pWriterObjUnderLineID = me.getID() && "underline" && the milliSeconds
  tMetrics = getStructVariable("struct.font.link")
  createWriter(pWriterObjUnderLineID, tMetrics)
  pWriterObjUnderLine = getWriter(pWriterObjUnderLineID)
  return TRUE
end

on deconstruct me 
  pContinentList = [:]
  pCountryList = [:]
  if objectp(pWriterObj) then
    removeWriter(pWriterObjID)
    pWriterObj = void()
  end if
  if objectp(pWriterObjUnderLine) then
    removeWriter(pWriterObjUnderLineID)
    pWriterObjUnderLine = void()
  end if
  return TRUE
end

on getContinentData me, tContinent 
  return(pContinentList.getAt(tContinent))
end

on getSelectedCountryID me 
  return(pSelection.getAt(#number))
end

on getCountryList me, tContinentKey 
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    if voidp(pContinentList.getAt(tContinent)) then
      return([])
    end if
    tContNum = pContinentList.getAt(tContinent).number
  else
    if voidp(pCountryList.getaProp(tContinent)) then
      return([])
    end if
    tContNum = tContinent
  end if
  tStr = ""
  tList = pCountryList.getaProp(tContNum)
  if voidp(tList) then
    return([:])
  else
    return(tList)
  end if
end

on getCountryListStr me, tContinentKey 
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    if voidp(pContinentList.getAt(tContinent)) then
      return("")
    end if
    tContNum = pContinentList.getAt(tContinent).number
  else
    if voidp(pCountryList.getaProp(tContinent)) then
      return("")
    end if
    tContNum = tContinent
  end if
  tStr = ""
  tList = pCountryList.getaProp(tContNum)
  if voidp(tList) then
    return("")
  end if
  repeat while tList <= undefined
    tItem = getAt(undefined, tContinentKey)
    if length(tStr) > 0 then
      tStr = tStr & "\r"
    end if
    tStr = tStr & tItem.name
  end repeat
  return(tStr)
end

on getCountryListImg me, tContinentKey 
  tContinent = getText(tContinentKey)
  if pSelection.getAt(#continent) <> tContinent or voidp(pImgBuffer) then
    pImgBuffer = pWriterObj.render(me.getCountryListStr(tContinentKey)).duplicate()
    pSelection = [#number:0, #name:void(), #continent:void()]
  end if
  return(pImgBuffer)
end

on getNthCountryNum me, tNth, tContinentKey 
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    tContNum = pContinentList.getAt(tContinent).number
  else
    tContNum = tContinent
  end if
  if tNth > pCountryList.getaProp(tContNum).count then
    return FALSE
  end if
  return(pCountryList.getaProp(tContNum).getAt(tNth).number)
end

on getNthCountryName me, tNth, tContinentKey 
  tContinent = getText(tContinentKey)
  if voidp(pContinentList.getAt(tContinent)) then
    return FALSE
  end if
  if stringp(tContinent) then
    tContNum = pContinentList.getAt(tContinent).number
  else
    tContNum = tContinent
  end if
  if tNth > pCountryList.getaProp(tContNum).count then
    return FALSE
  end if
  return(pCountryList.getaProp(tContNum).getAt(tNth).name)
end

on getCountryOrderNum me, tCountry, tContinentKey 
  tContinent = getText(tContinentKey)
  if voidp(pContinentList.getAt(tContinent)) then
    return FALSE
  end if
  if stringp(tContinent) then
    tContNum = pContinentList.getAt(tContinent).number
  else
    tContNum = tContinent
  end if
  tCountryList = pCountryList.getaProp(tContNum)
  if listp(tCountryList) then
    i = 1
    repeat while i <= tCountryList.count
      if (tCountryList.getAt(i).name = tCountry) then
        return(i)
      end if
      i = (1 + i)
    end repeat
  end if
end

on getClickedLineNum me, tpoint 
  tLine = (tpoint.locV / pLineHeight)
  if (tpoint.locV mod pLineHeight) > 0 then
    tLine = (tLine + 1)
  end if
  if tLine < 1 then
    tLine = 1
  end if
  return(tLine)
end

on selectCountry me, tCountryName, tContinentKey 
  tContinent = getText(tContinentKey)
  if not voidp(pSelection.getAt(#name)) then
    me.unselectCountry(pSelection.getAt(#name), tContinentKey)
  end if
  tImg = pWriterObjUnderLine.render(tCountryName)
  tPos = me.getCountryOrderNum(tCountryName, tContinentKey)
  pSelection = [#number:me.getNthCountryNum(tPos, tContinentKey), #name:tCountryName, #continent:tContinent]
  tY = ((tPos * pLineHeight) - pLineHeight)
  pImgBuffer.copyPixels(tImg, rect(0, tY, tImg.width, (tY + tImg.height)), tImg.rect)
  return TRUE
end

on unselectCountry me, tCountryName, tContinentKey 
  tContinent = getText(tContinentKey)
  if tContinent <> pSelection.getAt(#continent) then
    return FALSE
  end if
  tImg = pWriterObj.render(tCountryName)
  tPos = me.getCountryOrderNum(tCountryName, tContinentKey)
  pSelection.setAt(#name, void())
  pSelection.setAt(#number, void())
  tY = ((tPos * pLineHeight) - pLineHeight)
  pImgBuffer.copyPixels(tImg, rect(0, tY, tImg.width, (tY + tImg.height)), tImg.rect)
  return TRUE
end
