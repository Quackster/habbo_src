property pName, pMsg, pDate, pWindowName, pPlateObjID

on prepare me, tdata
  pPlateObjID = "trophy_plate"
  pName = EMPTY
  pMsg = EMPTY
  pDate = EMPTY
  pWindowName = "plate_gold.window"
  if tdata.ilk <> #propList then
    return error(me, "Incorrect data", #prepare, #major)
  end if
  if voidp(tdata[#stuffdata]) then
    return 1
  else
    tTemp = tdata[#stuffdata]
    tDelim = the itemDelimiter
    the itemDelimiter = TAB
    if tTemp.item.count > 2 then
      pName = tTemp.item[1]
      pDate = tTemp.item[2]
      pMsg = tTemp.item[3..tTemp.item.count]
      pMsg = replaceChunks(pMsg, "\r", RETURN)
    else
      if tTemp.item.count = 2 then
        pName = tTemp.item[1]
        pDate = tTemp.item[2]
      else
        pName = EMPTY
        pDate = EMPTY
        pMsg = EMPTY
        error(me, "Name and date missing", #prepare, #minor)
      end if
    end if
    the itemDelimiter = tDelim
    if me.pPartColors.ilk = #list then
      if me.pPartColors.count = 5 then
        tSilverDetected = 0
        tCol = me.pPartColors[3]
        if (chars(tCol, 2, 3) = chars(tCol, 4, 5)) and (chars(tCol, 2, 3) = chars(tCol, 6, 7)) then
          tSilverDetected = 1
        end if
        if tSilverDetected then
          pWindowName = "plate_silver.window"
        else
          if me.pPartColors[3] = "#996600" then
            pWindowName = "plate_bronze.window"
          end if
        end if
      end if
    end if
  end if
  return 1
end

on select me
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
  return 1
end
