on prepare(me, tdata)
  pPlateObjID = "trophy_plate"
  pName = ""
  pMsg = ""
  pDate = ""
  pWindowName = "plate_gold.window"
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect data", #prepare))
  end if
  if voidp(tdata.getAt(#stuffdata)) then
    return(1)
  else
    tTemp = tdata.getAt(#stuffdata)
    tDelim = the itemDelimiter
    the itemDelimiter = "\t"
    if tTemp.count(#item) > 2 then
      pName = tTemp.getProp(#item, 1)
      pDate = tTemp.getProp(#item, 2)
      pMsg = tTemp.getProp(#item, 3, tTemp.count(#item))
      pMsg = replaceChunks(pMsg, "\\r", "\r")
    else
      if tTemp.count(#item) = 2 then
        pName = tTemp.getProp(#item, 1)
        pDate = tTemp.getProp(#item, 2)
      else
        pName = ""
        pDate = ""
        pMsg = ""
        error(me, "Name and date missing", #prepare)
      end if
    end if
    the itemDelimiter = tDelim
    if pPartColors.ilk = #list then
      if me.count(#pPartColors) = 5 then
        if me.getProp(#pPartColors, 3) = "#ffffff" then
          pWindowName = "plate_silver.window"
        else
          if me.getProp(#pPartColors, 3) = "#996600" then
            pWindowName = "plate_bronze.window"
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on select(me)
  if the doubleClick then
    if not objectExists(pPlateObjID) then
      tObj = createObject(pPlateObjID, "Plate Class")
    else
      tObj = getObject(pPlateObjID)
    end if
    if tObj <> 0 then
      tObj.show(pName, pDate, pMsg, pWindowName)
    end if
  end if
  return(1)
  exit
end