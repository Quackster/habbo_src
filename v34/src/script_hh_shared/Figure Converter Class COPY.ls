property pValidSetIDList, pValidPartsList, pSelectablePartsList, pSelectableSetIDList

on construct me 
  pValidPartsList = [:]
  pValidSetIDList = [:]
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  pFigureDataMember = ""
  return(1)
end

on initializeValidPartLists me, tPartList 
  if not tPartList.ilk = #propList then
    error(me, "Can't initialize part list!", #initializeValidPartLists, #major)
    if memberExists("DefaultPartList") then
      tPartList = value(member(getmemnum("DefaultPartList")).text)
    else
      return(error(me, "Missing default part list!", #initializeValidPartLists, #major))
    end if
  end if
  pValidPartsList = tPartList
  pValidSetIDList = [:]
  repeat while ["M", "F"] <= undefined
    tsex = getAt(undefined, tPartList)
    pValidSetIDList.setAt(tsex, [:])
    tPartSet = 1
    repeat while tPartSet <= pValidPartsList.getAt(tsex).count
      tProp = pValidPartsList.getAt(tsex).getPropAt(tPartSet)
      tDesc = pValidPartsList.getAt(tsex).getAt(tProp)
      tP = 1
      repeat while tP <= tDesc.count
        tSetID = tDesc.getAt(tP).getAt("s")
        pValidSetIDList.getAt(tsex).addProp(tSetID, [#part:tProp, #location:tP])
        tP = 1 + tP
      end repeat
      tPartSet = 1 + tPartSet
    end repeat
  end repeat
end

on initializeSelectablePartList me, tSetIDList 
  if not tSetIDList.ilk = #list then
    return(error(me, "Can't initialize selectable partlist", #initializeSelectablePartList, #major))
  end if
  tTempSetIDList = [:]
  tTempSetIDList.setAt("M", [])
  tTempSetIDList.setAt("F", [])
  repeat while tSetIDList <= undefined
    tSetID = getAt(undefined, tSetIDList)
    if not voidp(pValidSetIDList.getAt("M").findPos(tSetID)) then
      tTempSetIDList.getAt("M").add(tSetID)
    else
      tTempSetIDList.getAt("F").add(tSetID)
    end if
  end repeat
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  repeat while tSetIDList <= undefined
    tsex = getAt(undefined, tSetIDList)
    pSelectablePartsList.setAt(tsex, [:])
    pSelectableSetIDList.setAt(tsex, [:])
    tSelectableIDs = tTempSetIDList.getAt(tsex)
    repeat while tSetIDList <= undefined
      tSetID = getAt(undefined, tSetIDList)
      if not voidp(pValidSetIDList.getAt(tsex).findPos(tSetID)) then
        tPart = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#part)
        tlocation = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#location)
        tPropList = pValidPartsList.getAt(tsex).getAt(tPart).getAt(tlocation)
        if voidp(pSelectablePartsList.getAt(tsex).getAt(tPart)) then
          pSelectablePartsList.getAt(tsex).setAt(tPart, [])
        end if
        pSelectablePartsList.getAt(tsex).getAt(tPart).add(tPropList)
        pSelectableSetIDList.getAt(tsex).addProp(tSetID, [#part:tPart, #location:pSelectablePartsList.getAt(tsex).getAt(tPart).count])
      end if
    end repeat
  end repeat
end

on GenerateFigureDataToServerMode me, tFigure, tsex 
  tFigure = me.checkAndFixFigure(tFigure, tsex)
  tFigureToServer = ""
  repeat while ["hr", "hd", "lg", "sh", "ch"] <= tsex
    tPart = getAt(tsex, tFigure)
    if not voidp(tFigure.getAt(tPart)) then
      if not voidp(tFigure.getAt(tPart).getAt("setid")) and not voidp(tFigure.getAt(tPart).getAt("colorid")) then
        tSetID = tFigure.getAt(tPart).getAt("setid")
        tColorId = tFigure.getAt(tPart).getAt("colorid")
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
        if tColorId.count(#char) = 1 then
          tColorId = "0" & tColorId
        end if
        tFigureToServer = tFigureToServer & tSetID & tColorId
      end if
    end if
  end repeat
  return(["figuretoServer":tFigureToServer, "parsedfigure":tFigure])
end

on checkAndFixFigure me, tFigure, tsex 
  if tFigure.ilk <> #propList then
    tFigure = [:]
  end if
  repeat while ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <= tsex
    tPart = getAt(tsex, tFigure)
    if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "ls" then
      if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "ch" then
        if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] = "rs" then
          tMainPart = "ch"
        else
          if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "hd" then
            if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "ey" then
              if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "fc" then
                if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "bd" then
                  if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] <> "lh" then
                    if ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"] = "rh" then
                      tMainPart = "hd"
                    else
                      tMainPart = tPart
                    end if
                    tChageParts = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(1).getAt("p")
                    tmodel = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(1).getAt("p").getAt(tPart)
                    tColorList = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(1).getAt("c").getAt(1)
                    tSetID = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(1).getAt("s")
                    if not listp(tColorList) then
                      tColorList = list(tColorList)
                    end if
                    if not voidp(tChageParts.findPos(tPart)) then
                      tColorId = tChageParts.findPos(tPart)
                    else
                      tColorId = 1
                    end if
                    if tColorList.count >= tColorId then
                      tColor = rgb(tColorList.getAt(tColorId))
                    else
                      tColor = rgb(tColorList.getAt(1))
                    end if
                    if tmodel.length = 1 then
                      tmodel = "00" & tmodel
                    else
                      if tmodel.length = 2 then
                        tmodel = "0" & tmodel
                      end if
                    end if
                    if voidp(tFigure.getAt(tPart)) then
                      tFigure.setAt(tPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":1])
                    else
                      if tFigure.getAt(tPart).ilk <> #propList then
                        tFigure.setAt(tPart, [:])
                      end if
                      if voidp(tFigure.getAt(tPart).getAt("model")) or voidp(tFigure.getAt(tPart).getAt("color")) or voidp(tFigure.getAt(tPart).getAt("setid")) or voidp(tFigure.getAt(tPart).getAt("colorid")) then
                        tFigure.setAt(tPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":1])
                      end if
                    end if
                    return(tFigure)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end repeat
end

on generateFigureDataToOldServerMode me, tFigure, tsex, tCheckValidParts 
  if voidp(tsex) then
    tsex = "M"
  end if
  if tsex contains "f" or tsex contains "F" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(tCheckValidParts) then
    tCheckValidParts = 0
  end if
  if tCheckValidParts then
    tNewFigure = me.GenerateFigureDataToServerMode(tFigure, tsex)
    tFigureData = me.ConvertServerModeFigureData(tNewFigure.getAt("parsedfigure"), tsex)
  else
    tFigureData = tFigure
  end if
  tTemp = the itemDelimiter
  the itemDelimiter = ","
  tNewFigure = "sd=001/0"
  if listp(tFigureData) then
    f = 1
    repeat while f <= tFigureData.count
      tPart = tFigureData.getPropAt(f)
      tmodel = tFigureData.getAt(tPart).getAt("model")
      tColor = tFigureData.getAt(tPart).getAt("color")
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
        if tColor.count(#item) < 3 then
          put("VIKAA SILMISS�")
        else
          tR = value(tColor.getPropRef(#item, 1).getProp(#char, 5, length(tColor.getProp(#item, 1))))
          tG = value(tColor.getProp(#item, 2))
          tB = value(tColor.getPropRef(#item, 3).getProp(#char, 1, length(tColor.getProp(#item, 3)) - 1))
          tColor = string(tR) & "," & string(tG) & "," & string(tB)
        end if
        if tPart = "ey" then
          tColor = "0"
        end if
        tNewFigure = tNewFigure & "&" & tPart & "=" & tmodel & "/" & tColor
      end if
      f = 1 + f
    end repeat
    exit repeat
  end if
  error(me, "Weirdness in figure data!!!", #generateFigureDataToOldServerMode, #minor)
  tNewFigure = tFigureData
  the itemDelimiter = tTemp
  return(["figuretoServer":tNewFigure])
end

on validateFigure me, tFigure, tsex 
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList.getAt(tsex)) then
    return(tFigure)
  end if
  if tFigure.ilk <> #propList then
    tFigure = [:]
  end if
  tTempFigure = [:]
  f = 1
  repeat while f <= tFigure.count
    if not voidp(tFigure.getAt(f).getAt("setid")) then
      if voidp(tFigure.getAt(f).getAt("setid")) then
        tColor = 1
      else
        tColor = tFigure.getAt(f).getAt("colorid")
      end if
      tPart = tFigure.getPropAt(1)
      tSetID = tFigure.getAt(f).getAt("setid")
      if not voidp(pSelectableSetIDList.getAt(tsex).getaProp(integer(tSetID))) then
        tTempFigure.setAt(string(tSetID), tColor)
      end if
    end if
    f = 1 + f
  end repeat
  tFigure = me.parseNewTypeFigure(tTempFigure, tsex)
  return(tFigure)
end

on parseFigure me, tFigureData, tsex, tClass, tCommand 
  if voidp(tClass) then
    tClass = "user"
  end if
  if voidp(tCommand) then
    tCommand = ""
  end if
  if tClass <> "user" then
    if tClass = "pelle" then
      tTempFigure = [:]
      if tFigureData.count(#char) = 25 and integerp(integer(tFigureData)) then
        tFigureData = tFigureData.getProp(#char, 1, tFigureData.count(#char))
        tPartCount = (tFigureData.count(#char) / 5)
        i = 0
        repeat while i <= tPartCount - 1
          tPart = tFigureData.getProp(#char, (i * 5) + 1, (i * 5) + 5)
          tSetID = tPart.getProp(#char, 1, 3)
          tColorId = tPart.getProp(#char, 4, 5)
          tTempFigure.setAt(tSetID, value(tColorId))
          i = 1 + i
        end repeat
      end if
      tFigure = me.parseNewTypeFigure(tTempFigure, tsex)
    else
      if tClass = "bot" then
        the itemDelimiter = "&"
        tPartCount = tFigureData.count(#item)
        tFigure = [:]
        i = 1
        repeat while i <= tPartCount
          tPart = tFigureData.getProp(#item, i)
          the itemDelimiter = "="
          tProp = tPart.getProp(#item, 1)
          tDesc = tPart.getProp(#item, 2)
          the itemDelimiter = "/"
          tValue = [:]
          tValue.setAt("model", tDesc.getProp(#item, 1))
          tColor = tDesc.getPropRef(#item, 2).getProp(#line, 1)
          the itemDelimiter = ","
          if tColor.count(#item) = 1 then
            if integer(tColor) = 0 then
              tValue.setAt("color", rgb("EEEEEE"))
            else
              tPalette = paletteIndex(integer(tColor))
              tValue.setAt("color", rgb(tPalette.red, tPalette.green, tPalette.blue))
            end if
          else
            if tColor.count(#item) = 3 then
              tValue.setAt("color", value("rgb(" & tColor & ")"))
              if voidp(tValue.getAt("color")) then
                tValue.setAt("color", rgb("EEEEEE"))
              end if
              if tValue.getAt("color").red + tValue.getAt("color").green + tValue.getAt("color").blue > (238 * 3) then
                tValue.setAt("color", rgb("EEEEEE"))
              end if
            else
              tValue.setAt("color", rgb("EEEEEE"))
            end if
          end if
          tFigure.setAt(tProp, tValue)
          the itemDelimiter = "&"
          i = 1 + i
        end repeat
        tRequiredParts = ["hr", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh"]
        repeat while tClass <= tsex
          tItem = getAt(tsex, tFigureData)
          if not listp(tFigure.getAt(tItem)) then
            tFigure.setAt(tItem, [:])
          end if
          if not ilk(tFigure.getAt(tItem).getAt("color"), #color) then
            tFigure.getAt(tItem).setAt("color", rgb(238, 238, 238))
          end if
          if not stringp(tFigure.getAt(tItem).getAt("model")) then
            tFigure.getAt(tItem).setAt("model", "001")
          end if
        end repeat
      else
        return(tFigureData)
      end if
    end if
    return(tFigure)
  end if
end

on parseNewTypeFigure me, tFigure, tsex 
  tMainPartsList = [:]
  if voidp(tsex) then
    tsex = "M"
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  f = 1
  repeat while f <= tFigure.count
    tSetID = tFigure.getPropAt(f)
    tColorId = value(tFigure.getAt(tSetID))
    if not voidp(value(tSetID)) then
      if voidp(tColorId) then
        tColorId = 1
      end if
      if not voidp(pValidSetIDList.getAt(tsex).getAt(tSetID)) then
        tMainPart = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#part)
        tlocation = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#location)
        tchangeparts = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(tlocation).getAt("p")
        tColorList = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(tlocation).getAt("c")
      end if
      if not voidp(tMainPart) then
        tMainPartsList.setAt(tMainPart, ["changeparts":tchangeparts, "setid":tSetID, "colorlist":tColorList, "colorID":tColorId])
      end if
    end if
    f = 1 + f
  end repeat
  tTempFigure = [:]
  repeat while ["hr", "hd", "lg", "sh", "ch"] <= tsex
    tMainPart = getAt(tsex, tFigure)
    if not voidp(tMainPartsList.getAt(tMainPart)) then
      tSetID = tMainPartsList.getAt(tMainPart).getAt("setid")
      tColorId = tMainPartsList.getAt(tMainPart).getAt("colorID")
      tColorList = tMainPartsList.getAt(tMainPart).getAt("colorlist")
      tchangeparts = tMainPartsList.getAt(tMainPart).getAt("changeparts")
      if value(tColorId) < 1 then
        tColorId = 1
      end if
      if not listp(tColorList) then
        tColor = rgb("#EEEEEE")
        tColorId = 1
        error(me, "Weirdness in the list of figure parts!", #parseNewTypeFigure, #minor)
      else
        if tColorId > tColorList.count then
          tColorId = 1
        end if
        if not listp(tColorList.getAt(tColorId)) then
          if voidp(tColorList.getAt(tColorId)) then
            tColor = rgb("#EEEEEE")
          end if
          tColor = rgb(tColorList.getAt(tColorId))
        end if
      end if
      i = 1
      repeat while i <= tchangeparts.count
        tPart = tchangeparts.getPropAt(i)
        tmodel = tchangeparts.getAt(tPart)
        if tmodel.count(#char) = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.count(#char) = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if listp(tColorList.getAt(tColorId)) then
          if tColorList.getAt(tColorId).count >= i then
            tPartColor = rgb(tColorList.getAt(tColorId).getAt(i))
          else
            tPartColor = rgb(tColorList.getAt(tColorId).getAt(1))
          end if
          tTempFigure.setAt(tPart, ["model":tmodel, "color":tPartColor, "setid":tSetID, "colorid":tColorId])
        else
          tTempFigure.setAt(tPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":tColorId])
        end if
        i = 1 + i
      end repeat
    end if
  end repeat
  tTempFigure = me.checkAndFixFigure(tTempFigure, tsex)
  return(tTempFigure)
end

on getDefaultFigure me, tsex 
  return(me.checkAndFixFigure([:], tsex))
end
