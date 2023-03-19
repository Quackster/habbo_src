property pValidPartsList, pValidSetIDList, pSelectablePartsList, pSelectableSetIDList, pFigureDataMember

on construct me
  pValidPartsList = [:]
  pValidSetIDList = [:]
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  pFigureDataMember = EMPTY
  return 1
end

on initializeValidPartLists me, tPartList
  if not (tPartList.ilk = #propList) then
    error(me, "Can't initialize part list!", #initializeValidPartLists)
    if memberExists("DefaultPartList") then
      tPartList = value(member(getmemnum("DefaultPartList")).text)
    else
      return error(me, "Missing default part list!")
    end if
  end if
  pValidPartsList = tPartList
  pValidSetIDList = [:]
  repeat with tsex in ["M", "F"]
    pValidSetIDList[tsex] = [:]
    repeat with tPartSet = 1 to pValidPartsList[tsex].count
      tProp = pValidPartsList[tsex].getPropAt(tPartSet)
      tDesc = pValidPartsList[tsex][tProp]
      repeat with tP = 1 to tDesc.count
        tSetID = tDesc[tP]["s"]
        pValidSetIDList[tsex].addProp(tSetID, [#part: tProp, #location: tP])
      end repeat
    end repeat
  end repeat
end

on initializeSelectablePartList me, tSetIDList
  if not (tSetIDList.ilk = #list) then
    return error(me, "Can't initialize selectable partlist", #initializeSelectablePartList)
  end if
  tTempSetIDList = [:]
  tTempSetIDList["M"] = []
  tTempSetIDList["F"] = []
  repeat with tSetID in tSetIDList
    if not voidp(pValidSetIDList["M"].findPos(tSetID)) then
      tTempSetIDList["M"].add(tSetID)
      next repeat
    end if
    tTempSetIDList["F"].add(tSetID)
  end repeat
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  repeat with tsex in ["M", "F"]
    pSelectablePartsList[tsex] = [:]
    pSelectableSetIDList[tsex] = [:]
    tSelectableIDs = tTempSetIDList[tsex]
    repeat with tSetID in tSelectableIDs
      if not voidp(pValidSetIDList[tsex].findPos(tSetID)) then
        tPart = pValidSetIDList[tsex].getProp(tSetID)[#part]
        tlocation = pValidSetIDList[tsex].getProp(tSetID)[#location]
        tPropList = pValidPartsList[tsex][tPart][tlocation]
        if voidp(pSelectablePartsList[tsex][tPart]) then
          pSelectablePartsList[tsex][tPart] = []
        end if
        pSelectablePartsList[tsex][tPart].add(tPropList)
        pSelectableSetIDList[tsex].addProp(tSetID, [#part: tPart, #location: pSelectablePartsList[tsex][tPart].count])
      end if
    end repeat
  end repeat
end

on GenerateFigureDataToServerMode me, tFigure, tsex
  tFigure = me.checkAndFixFigure(tFigure, tsex)
  tFigureToServer = EMPTY
  repeat with tPart in ["hr", "hd", "lg", "sh", "ch"]
    if not voidp(tFigure[tPart]) then
      if not voidp(tFigure[tPart]["setid"]) and not voidp(tFigure[tPart]["colorid"]) then
        tSetID = tFigure[tPart]["setid"]
        tColorId = tFigure[tPart]["colorid"]
        if not stringp(tSetID) then
          tSetID = string(tSetID)
        end if
        if not stringp(tColorId) then
          tColorId = string(tColorId)
        end if
        if tSetID.length = 1 then
          tSetID = "00" & tSetID
        else
          if tSetID.length = 2 then
            tSetID = "0" & tSetID
          end if
        end if
        if tColorId.char.count = 1 then
          tColorId = "0" & tColorId
        end if
        tFigureToServer = tFigureToServer & tSetID & tColorId
      end if
    end if
  end repeat
  return ["figuretoServer": tFigureToServer, "parsedfigure": tFigure]
end

on checkAndFixFigure me, tFigure, tsex
  if tFigure.ilk <> #propList then
    tFigure = [:]
  end if
  repeat with tPart in ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"]
    case tPart of
      "ls", "ch", "rs":
        tMainPart = "ch"
      "hd", "ey", "fc", "bd", "lh", "rh":
        tMainPart = "hd"
      otherwise:
        tMainPart = tPart
    end case
    tChageParts = pValidPartsList[tsex][tMainPart][1]["p"]
    tmodel = pValidPartsList[tsex][tMainPart][1]["p"][tPart]
    tColorList = pValidPartsList[tsex][tMainPart][1]["c"][1]
    tSetID = pValidPartsList[tsex][tMainPart][1]["s"]
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    if not voidp(tChageParts.findPos(tPart)) then
      tColorId = tChageParts.findPos(tPart)
    else
      tColorId = 1
    end if
    if tColorList.count >= tColorId then
      tColor = rgb(tColorList[tColorId])
    else
      tColor = rgb(tColorList[1])
    end if
    if tmodel.length = 1 then
      tmodel = "00" & tmodel
    else
      if tmodel.length = 2 then
        tmodel = "0" & tmodel
      end if
    end if
    if voidp(tFigure[tPart]) then
      tFigure[tPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": 1]
      next repeat
    end if
    if tFigure[tPart].ilk <> #propList then
      tFigure[tPart] = [:]
    end if
    if voidp(tFigure[tPart]["model"]) or voidp(tFigure[tPart]["color"]) or voidp(tFigure[tPart]["setid"]) or voidp(tFigure[tPart]["colorid"]) then
      tFigure[tPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": 1]
    end if
  end repeat
  return tFigure
end

on generateFigureDataToOldServerMode me, tFigure, tsex, tCheckValidParts
  if voidp(tsex) then
    tsex = "M"
  end if
  if (tsex contains "f") or (tsex contains "F") then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(tCheckValidParts) then
    tCheckValidParts = 0
  end if
  if tCheckValidParts then
    tNewFigure = me.GenerateFigureDataToServerMode(tFigure, tsex)
    tFigureData = me.ConvertServerModeFigureData(tNewFigure["parsedfigure"], tsex)
  else
    tFigureData = tFigure
  end if
  tTemp = the itemDelimiter
  the itemDelimiter = ","
  tNewFigure = "sd=001/0"
  if listp(tFigureData) then
    repeat with f = 1 to tFigureData.count
      tPart = tFigureData.getPropAt(f)
      tmodel = tFigureData[tPart]["model"]
      tColor = tFigureData[tPart]["color"]
      if tPart <> "sd" then
        if tmodel.length = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.length = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if tColor = rgb("#EEEEEE") then
          tColor = rgb(255, 255, 255)
        end if
        tColor = string(tColor)
        if tColor.item.count < 3 then
          put "VIKAA SILMISSÄ"
        else
          tR = value(tColor.item[1].char[5..length(tColor.item[1])])
          tG = value(tColor.item[2])
          tB = value(tColor.item[3].char[1..length(tColor.item[3]) - 1])
          tColor = string(tR) & "," & string(tG) & "," & string(tB)
        end if
        if tPart = "ey" then
          tColor = "0"
        end if
        tNewFigure = tNewFigure & "&" & tPart & "=" & tmodel & "/" & tColor
      end if
    end repeat
  else
    error(me, "Weirdness in figure data!!!", #generateFigureDataToOldServerMode)
    tNewFigure = tFigureData
  end if
  the itemDelimiter = tTemp
  return ["figuretoServer": tNewFigure]
end

on validateFigure me, tFigure, tsex
  if (tsex.char[1] = "F") or (tsex.char[1] = "f") then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList[tsex]) then
    return tFigure
  end if
  if tFigure.ilk <> #propList then
    tFigure = [:]
  end if
  tTempFigure = [:]
  repeat with f = 1 to tFigure.count
    if not voidp(tFigure[f]["setid"]) then
      if voidp(tFigure[f]["setid"]) then
        tColor = 1
      else
        tColor = tFigure[f]["colorid"]
      end if
      tPart = tFigure.getPropAt(1)
      tSetID = tFigure[f]["setid"]
      if not voidp(pSelectableSetIDList[tsex].getaProp(integer(tSetID))) then
        tTempFigure[string(tSetID)] = tColor
      end if
    end if
  end repeat
  tFigure = me.parseNewTypeFigure(tTempFigure, tsex)
  return tFigure
end

on parseFigure me, tFigureData, tsex, tClass, tCommand
  if voidp(tClass) then
    tClass = "user"
  end if
  if voidp(tCommand) then
    tCommand = EMPTY
  end if
  case tClass of
    "user", "pelle":
      tTempFigure = [:]
      if (tFigureData.char.count = 25) and integerp(integer(tFigureData)) then
        tFigureData = tFigureData.char[1..tFigureData.char.count]
        tPartCount = tFigureData.char.count / 5
        repeat with i = 0 to tPartCount - 1
          tPart = tFigureData.char[(i * 5) + 1..(i * 5) + 5]
          tSetID = tPart.char[1..3]
          tColorId = tPart.char[4..5]
          tTempFigure[tSetID] = value(tColorId)
        end repeat
      end if
      tFigure = me.parseNewTypeFigure(tTempFigure, tsex)
    "bot":
      the itemDelimiter = "&"
      tPartCount = tFigureData.item.count
      tFigure = [:]
      repeat with i = 1 to tPartCount
        tPart = tFigureData.item[i]
        the itemDelimiter = "="
        tProp = tPart.item[1]
        tDesc = tPart.item[2]
        the itemDelimiter = "/"
        tValue = [:]
        tValue["model"] = tDesc.item[1]
        tColor = tDesc.item[2].line[1]
        the itemDelimiter = ","
        if tColor.item.count = 1 then
          if integer(tColor) = 0 then
            tValue["color"] = rgb("EEEEEE")
          else
            tPalette = paletteIndex(integer(tColor))
            tValue["color"] = rgb(tPalette.red, tPalette.green, tPalette.blue)
          end if
        else
          if tColor.item.count = 3 then
            tValue["color"] = value("rgb(" & tColor & ")")
            if voidp(tValue["color"]) then
              tValue["color"] = rgb("EEEEEE")
            end if
            if (tValue["color"].red + tValue["color"].green + tValue["color"].blue) > (238 * 3) then
              tValue["color"] = rgb("EEEEEE")
            end if
          else
            tValue["color"] = rgb("EEEEEE")
          end if
        end if
        tFigure[tProp] = tValue
        the itemDelimiter = "&"
      end repeat
      tRequiredParts = ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"]
      repeat with tItem in tRequiredParts
        if not listp(tFigure[tItem]) then
          tFigure[tItem] = [:]
        end if
        if not ilk(tFigure[tItem]["color"], #color) then
          tFigure[tItem]["color"] = rgb(238, 238, 238)
        end if
        if not stringp(tFigure[tItem]["model"]) then
          tFigure[tItem]["model"] = "001"
        end if
      end repeat
    otherwise:
      return tFigureData
  end case
  return tFigure
end

on parseNewTypeFigure me, tFigure, tsex
  tMainPartsList = [:]
  if voidp(tsex) then
    tsex = "M"
  end if
  if (tsex.char[1] = "F") or (tsex.char[1] = "f") then
    tsex = "F"
  else
    tsex = "M"
  end if
  repeat with f = 1 to tFigure.count
    tSetID = tFigure.getPropAt(f)
    tColorId = value(tFigure[tSetID])
    if not voidp(value(tSetID)) then
      if voidp(tColorId) then
        tColorId = 1
      end if
      if not voidp(pValidSetIDList[tsex][tSetID]) then
        tMainPart = pValidSetIDList[tsex].getProp(tSetID)[#part]
        tlocation = pValidSetIDList[tsex].getProp(tSetID)[#location]
        tchangeparts = pValidPartsList[tsex][tMainPart][tlocation]["p"]
        tColorList = pValidPartsList[tsex][tMainPart][tlocation]["c"]
      end if
      if not voidp(tMainPart) then
        tMainPartsList[tMainPart] = ["changeparts": tchangeparts, "setid": tSetID, "colorlist": tColorList, "colorID": tColorId]
      end if
    end if
  end repeat
  tTempFigure = [:]
  repeat with tMainPart in ["hr", "hd", "lg", "sh", "ch"]
    if not voidp(tMainPartsList[tMainPart]) then
      tSetID = tMainPartsList[tMainPart]["setid"]
      tColorId = tMainPartsList[tMainPart]["colorID"]
      tColorList = tMainPartsList[tMainPart]["colorlist"]
      tchangeparts = tMainPartsList[tMainPart]["changeparts"]
      if value(tColorId) < 1 then
        tColorId = 1
      end if
      if not listp(tColorList) then
        tColor = rgb("#EEEEEE")
        tColorId = 1
        error(me, "Weirdness in the list of figure parts!", #parseNewTypeFigure)
      else
        if tColorId > tColorList.count then
          tColorId = 1
        end if
        if not listp(tColorList[tColorId]) then
          if voidp(tColorList[tColorId]) then
            tColor = rgb("#EEEEEE")
          end if
          tColor = rgb(tColorList[tColorId])
        end if
      end if
      repeat with i = 1 to tchangeparts.count
        tPart = tchangeparts.getPropAt(i)
        tmodel = tchangeparts[tPart]
        if tmodel.char.count = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.char.count = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if listp(tColorList[tColorId]) then
          if tColorList[tColorId].count >= i then
            tPartColor = rgb(tColorList[tColorId][i])
          else
            tPartColor = rgb(tColorList[tColorId][1])
          end if
          tTempFigure[tPart] = ["model": tmodel, "color": tPartColor, "setid": tSetID, "colorid": tColorId]
          next repeat
        end if
        tTempFigure[tPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId]
      end repeat
    end if
  end repeat
  tTempFigure = me.checkAndFixFigure(tTempFigure, tsex)
  return tTempFigure
end

on getDefaultFigure me, tsex
  return me.checkAndFixFigure([:], tsex)
end
