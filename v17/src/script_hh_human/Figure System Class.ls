property pAvailableSetListLoadedFlag, pFigurePartListLoadedFlag, pValidSetIDList, pSelectablePartsList, pSelectableSetIDList, pValidPartsList

on construct me 
  pFigurePartListLoadedFlag = 0
  pAvailableSetListLoadedFlag = 0
  pValidPartsList = [:]
  pValidSetIDList = [:]
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  setVariable("figurepartlist.loaded", 0)
  me.regMsgList(1)
  me.loadPartSetXML()
  me.loadActionSetXML()
  me.loadAnimationSetXML()
  return(1)
end

on deconstruct me 
  me.regMsgList(0)
  return(1)
end

on define me, tProps 
  if tProps.ilk <> #propList then
    tURL = getVariable("external.figurepartlist.txt")
    tProps = ["type":"url", "source":tURL]
  end if
  if voidp(tProps.getAt("type")) then
    error(me, "source type of figure list is void", #define, #major)
  end if
  if tProps.getAt("type") = "url" then
    me.loadFigurePartList(tProps.getAt("source"))
  else
    if tProps.getAt("type") = "member" then
      tMemberName = tProps.getAt("source")
      me.createValidPartList(tMemberName)
    else
      if tProps.getAt("type") = "proplist" then
        tProlist = tProps.getAt("source")
        initializeValidPartLists(tProlist)
      else
        error(me, "incorrect source type, can�t run define ", #define, #major)
      end if
    end if
  end if
end

on isFigureSystemReady me 
  if pAvailableSetListLoadedFlag = 1 then
    return(1)
  else
    me.getAvailableSetList()
    return(0)
  end if
end

on getAvailableSetList me 
  if pFigurePartListLoadedFlag = 1 and pAvailableSetListLoadedFlag = 0 then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("GETAVAILABLESETS")
    end if
  end if
end

on setAvailableSetList me, tList 
  if pFigurePartListLoadedFlag and not voidp(tList) then
    me.initializeSelectablePartList(tList)
    pAvailableSetListLoadedFlag = 1
    executeMessage(#figure_ready)
  end if
end

on getPreventedPartsBySetID me, tsex, tModelID 
  if tsex = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  tmodellist = pValidSetIDList.getAt(tsex)
  if not voidp(integer(tModelID)) then
    tModelID = integer(tModelID)
  end if
  tmodel = getaProp(tmodellist, tModelID)
  if ilk(tmodel) = #propList then
    tHiddenParts = tmodel.getAt(#hideparts)
  else
    tHiddenParts = []
  end if
  return(tHiddenParts)
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
      if (tFigureData.count(#char) mod 5) = 0 and integerp(integer(tFigureData)) then
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
        tHairChangeList = [:]
        tHairChangeList.setAt("007", ["ha":"001", "fa":"001"])
        tHairChangeList.setAt("014", ["ha":"002"])
        tHairChangeList.setAt("015", ["ha":"003"])
        tHairChangeList.setAt("021", ["ha":"004"])
        tHairChangeList.setAt("022", ["ha":"005"])
        tHairChangeList.setAt("996", ["ha":"006"])
        tHairChangeList.setAt("458", ["ha":"008", "fa":"002"])
        tHairChangeList.setAt("013", ["ha":"010"])
        tHairChangeList.setAt("505", ["ha":"011", "fa":"002"])
        tHairChangeList.setAt("502", ["ha":"012"])
        if not voidp(tFigure.getAt("hr")) then
          tPos = tHairChangeList.findPos(tFigure.getAt("hr").getAt("model"))
          if tPos > 0 then
            tChangeList = tHairChangeList.getAt(tPos)
            k = 1
            repeat while k <= tChangeList.count
              tPart = tChangeList.getPropAt(k)
              if voidp(tFigure.getAt(tPart)) then
                tFigure.setAt(tPart, tFigure.getAt("hr"))
              end if
              k = 1 + k
            end repeat
            tFigure.setAt("hr", void())
          end if
        end if
        if voidp(tFigure.getAt("hrb")) and not voidp(tFigure.getAt("hr")) then
          tFigure.setAt("hrb", tFigure.getAt("hr"))
        end if
        tRequiredParts = ["hr", "hrb", "hd", "ey", "fc", "bd", "lh", "rh", "ch", "ls", "rs", "lg", "sh", "fa", "ea", "he", "ca"]
        repeat while tClass <= tsex
          tItem = getAt(tsex, tFigureData)
          if not listp(tFigure.getAt(tItem)) then
            tFigure.setAt(tItem, [:])
          end if
          if not ilk(tFigure.getAt(tItem).getAt("color"), #color) then
            tFigure.getAt(tItem).setAt("color", rgb(238, 238, 238))
          end if
          if not stringp(tFigure.getAt(tItem).getAt("model")) then
            tFigure.getAt(tItem).setAt("model", "000")
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
  tChangeList = member("figure_part_replace_list").text
  if not voidp(tChangeList) then
    tChangeList = value(replaceChunks(tChangeList, "\r", ""))
  end if
  tReverseMap = [:]
  if not voidp(pValidPartsList.getAt(tsex).getAt("hr")) then
    tHairList = pValidPartsList.getAt(tsex).getAt("hr")
    repeat while tHairList <= tsex
      tHairData = getAt(tsex, tFigure)
      tSetID = tHairData.getAt("s")
      tParts = tHairData.getAt("p")
      if not voidp(tParts.getAt("hr")) then
        tReverseMap.addProp(tSetID, tParts.getAt("hr"))
      end if
    end repeat
  end if
  if voidp(tChangeList) then
    tChangeList = [:]
  end if
  f = tFigure.count
  repeat while f >= 1
    tSetID = tFigure.getPropAt(f)
    tPos = tReverseMap.findPos(tSetID)
    if tPos > 0 then
      tMappedID = tReverseMap.getAt(tPos)
      tPos = tChangeList.findPos(tMappedID)
      if tPos > 0 then
        tdata = tFigure.getAt(f)
        tFigure.deleteAt(f)
        repeat while tHairList <= tsex
          tNewPart = getAt(tsex, tFigure)
          if not voidp(integer(tNewPart)) then
            i = 1
            repeat while i <= tReverseMap.count
              if tReverseMap.getAt(i) = tNewPart then
                tNewPart = string(tReverseMap.getPropAt(i))
              else
                i = 1 + i
              end if
            end repeat
          end if
          repeat while tNewPart.length < 1
            tNewPart = "0" & tNewPart
          end repeat
          tFigure.addProp(tNewPart, tdata)
        end repeat
      end if
    end if
    f = 255 + f
  end repeat
  f = 1
  repeat while f <= tFigure.count
    tSetID = tFigure.getPropAt(f)
    tColorId = value(tFigure.getAt(tSetID))
    if voidp(tColorId) then
      tColorId = 1
    end if
    if not voidp(pValidSetIDList.getAt(tsex).getAt(tSetID)) then
      tMainPart = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#part)
      tlocation = pValidSetIDList.getAt(tsex).getProp(tSetID).getAt(#location)
      tchangeparts = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(tlocation).getAt("p")
      tColorList = pValidPartsList.getAt(tsex).getAt(tMainPart).getAt(tlocation).getAt("c")
      if tMainPart = "hr" then
        if voidp(tchangeparts.getAt("hrb")) and not voidp(tchangeparts.getAt("hr")) then
          tchangeparts.setAt("hrb", tchangeparts.getAt("hr"))
        end if
      end if
      tMainPartsList.setAt(tMainPart, ["changeparts":tchangeparts, "setid":tSetID, "colorlist":tColorList, "colorID":tColorId])
    end if
    f = 1 + f
  end repeat
  tTempFigure = [:]
  k = 1
  repeat while k <= tMainPartsList.count
    tMainPart = tMainPartsList.getPropAt(k)
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
    k = 1 + k
  end repeat
  tTempFigure = me.checkAndFixFigure(tTempFigure, tsex)
  return(tTempFigure)
end

on getDefaultFigure me, tsex 
  return(me.checkAndFixFigure([:], tsex))
end

on getCountOfPart me, tPart, tsex 
  if voidp(tPart) or voidp(tsex) then
    return(error(me, "can�t get part count because tPart or tSex is VOID:" && tPart && tsex, #getCountOfPart, #major))
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList.getAt(tsex)) then
    return(0)
  end if
  if not voidp(pSelectablePartsList.getAt(tsex).getAt(tPart)) then
    return(pSelectablePartsList.getAt(tsex).getAt(tPart).count)
  else
    return(error(me, "Can�t get part count:" && tPart && tsex, #getCountOfPart, #major))
  end if
end

on getPartColors me, tSetID, tsex 
  if voidp(tSetID) or voidp(tsex) then
    return(error(me, "Can�t get part colors because setID or tSex is VOID" && tSetID && tsex, #getPartColors, #major))
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pValidPartsList.getAt(tsex)) then
    return(0)
  end if
  repeat while pValidPartsList.getAt(tsex) <= tsex
    tPartList = getAt(tsex, tSetID)
    repeat while pValidPartsList.getAt(tsex) <= tsex
      tPart = getAt(tsex, tSetID)
      if tPart.getAt("s") = tSetID then
        return(tPart.getAt("c"))
      end if
    end repeat
  end repeat
  return(void())
end

on getCountOfPartColors me, tPart, tSetID, tsex 
  if voidp(tPart) or voidp(tSetID) or voidp(tsex) then
    return(error(me, "Can�t get part color count because tPart or setid or tSex is VOID" && tPart && tsex, #getCountOfPartColors, #major))
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList.getAt(tsex)) then
    return(0)
  end if
  if voidp(pSelectablePartsList.getAt(tsex).getAt(tPart)) then
    return(error(me, "Figure part not found" && tPart, #getCountOfPartColors, #major))
  end if
  if voidp(pSelectableSetIDList.getAt(tsex).getaProp(tSetID)) then
    return(error(me, "SetID not found" && tSetID, #getCountOfPartColors, #major))
  end if
  tSetOrderNum = pSelectableSetIDList.getAt(tsex).getProp(tSetID).getAt(#location)
  if not voidp(pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c")) then
    return(pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c").count)
  else
    return(error(me, "Can�t get part color count" && tPart && tSetID && tsex, #getCountOfPartColors, #major))
  end if
end

on getModelOfPartByOrderNum me, tPart, tOrderNum, tsex 
  if voidp(tOrderNum) or voidp(tPart) or voidp(tsex) then
    return(error(me, "Can�t get the model of part becouse tOrderNum or tPart or tSex is VOID:" && tOrderNum && tPart && tsex, #getModelOfPartByOrderNum, #major))
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList.getAt(tsex)) then
    return(0)
  end if
  if voidp(pSelectablePartsList.getAt(tsex).getAt(tPart)) then
    return(error(me, "figure part not found" && tPart, #getModelOfPartByOrderNum, #major))
  end if
  if tOrderNum < 1 then
    tOrderNum = pSelectablePartsList.getAt(tsex).getAt(tPart).count
  end if
  if tOrderNum > pSelectablePartsList.getAt(tsex).getAt(tPart).count then
    tOrderNum = 1
  end if
  if not voidp(pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tOrderNum)) then
    tChangePartPropList = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tOrderNum).getAt("p")
    tSetID = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tOrderNum).getAt("s")
    tSelectedPart = tOrderNum
    tColor = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tOrderNum).getAt("c").getAt(1)
    return(["selectedpart":tSelectedPart, "changeparts":tChangePartPropList, "ordernum":tOrderNum, "firstcolor":tColor, "setid":tSetID])
  end if
end

on getColorOfPartByOrderNum me, tPart, tOrderNum, tSetID, tsex 
  if voidp(tOrderNum) or voidp(tPart) or voidp(tsex) then
    return(error(me, "Can�t get part color beaouse tOrderNum or tPart or tSex is VOID:" && tOrderNum && tPart && tsex, #getColorOfPartByOrderNum, #major))
  end if
  if voidp(tSetID) then
    return(error(me, "Can�t get part color because tSetID is VOID" && tsex, #getColorOfPartByOrderNum, #major))
  end if
  if tsex.getProp(#char, 1) = "F" or tsex.getProp(#char, 1) = "f" then
    tsex = "F"
  else
    tsex = "M"
  end if
  if voidp(pSelectablePartsList.getAt(tsex)) then
    return(0)
  end if
  if voidp(pSelectablePartsList.getAt(tsex).getAt(tPart)) then
    return(error(me, "Figure part not found:" && tPart, #getColorOfPartByOrderNum, #major))
  end if
  if voidp(pSelectableSetIDList.getAt(tsex).getaProp(tSetID)) then
    return(error(me, "SetID not found:" && tSetID, #getCountOfPartColors, #major))
  end if
  tSetOrderNum = pSelectableSetIDList.getAt(tsex).getProp(tSetID).getAt(#location)
  if tOrderNum < 1 then
    tOrderNum = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c").count
  end if
  if tOrderNum > pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c").count then
    tOrderNum = 1
  end if
  if not voidp(pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c").getAt(tOrderNum)) then
    tChangePartPropList = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("p")
    tColor = pSelectablePartsList.getAt(tsex).getAt(tPart).getAt(tSetOrderNum).getAt("c").getAt(tOrderNum)
    return(["color":tColor, "changeparts":tChangePartPropList, "ordernum":tOrderNum])
  end if
end

on loadFigurePartList me, tURL 
  tMem = tURL
  tMemberCount = 0
  tCastList = ["hh_human_shirt", "hh_human_leg", "hh_human_shoe", "hh_human_body", "hh_human_face", "hh_human_hats", "hh_human_hair"]
  repeat while tCastList <= undefined
    tCastName = getAt(undefined, tURL)
    tCastLib = castLib(tCastName)
    if tCastLib <> 0 then
      tMemberCount = tCastName + the number of castMembers
    end if
  end repeat
  tSeparator = "?"
  if tURL contains "?" then
    tSeparator = "&"
  end if
  if the moviePath contains "http://" then
    tURL = tURL & tSeparator & "graphcount=" & tMemberCount
  else
    if tURL contains "http://" then
      tURL = tURL & tSeparator & "graphcount=" & tMemberCount
    end if
  end if
  tmember = queueDownload(tURL, tMem, #field, 1)
  return(registerDownloadCallback(tmember, #partListLoaded, me.getID()))
end

on partListLoaded me 
  tMemName = getVariable("external.figurepartlist.txt")
  if tMemName = 0 then
    tMemName = ""
  end if
  if not memberExists(tMemName) then
    tValidpartList = void()
    error(me, "Failure while loading part list", #partListLoaded, #major)
  else
    try()
    tContent = member(getmemnum(tMemName)).text
    tContent = replaceChunks(tContent, "\r", "")
    tValidpartList = value(tContent)
    if catch() then
      tValidpartList = void()
    end if
    if voidp(tValidpartList) then
      outputList(tContent)
    end if
  end if
  me.initializeValidPartLists(tValidpartList)
  pFigurePartListLoadedFlag = 1
  setVariable("figurepartlist.loaded", 1)
  if memberExists(tMemName) then
    removeMember(tMemName)
  end if
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

on createValidPartList me, tmember 
  pValidPartsList = [:]
  pValidSetIDList = [:]
  pSelectablePartsList = [:]
  pSelectableSetIDList = [:]
  tTempItemdelimiter = the itemDelimiter
  repeat while ["Male", "Female"] <= undefined
    tsex = getAt(undefined, tmember)
    if not memberExists(tmember & tsex) then
      error(me, "Can't create list of valid figure parts, member not found:" && tmember & tsex, #createValidPartList, #major)
    else
      tFigureIds = member(getmemnum(tmember & tsex)).text
      tsex = tsex.getProp(#char, 1)
      if voidp(pValidPartsList.getAt(tsex)) then
        pValidPartsList.setAt(tsex, [:])
      end if
      ttempProp = void()
      tPartId = void()
      tMainPart = void()
      tMultiPartProps = void()
      tPartType = void()
      ttempColor = []
      f = 1
      repeat while f <= tFigureIds.count(#line)
        tLine = tFigureIds.getProp(#line, f)
        if tLine.getProp(#char, 1) <> "*" and tLine.count(#char) > 7 then
          the itemDelimiter = ":"
          if not voidp(ttempProp) then
            ttempColor.add(tLine.getProp(#item, 2))
          end if
        else
          if tLine.getProp(#char, 1) = "*" or f = tFigureIds.count(#line) then
            if not voidp(tMainPart) then
              if voidp(pValidPartsList.getAt(tsex).getAt(tMainPart)) then
                pValidPartsList.getAt(tsex).setAt(tMainPart, [])
              end if
            end if
            if not voidp(ttempProp) and ttempColor <> [:] then
              pValidPartsList.getAt(tsex).getAt(tMainPart).add(["s":value(tPartId), "p":tMultiPartProps, "c":ttempColor, "t":tPartType])
              if voidp(pValidSetIDList.getAt(tsex)) then
                pValidSetIDList.setAt(tsex, [:])
              end if
              if voidp(pValidSetIDList.getAt(tsex).getAt(tPartId)) then
                pValidSetIDList.getAt(tsex).addProp(value(tPartId), [#part:tMainPart, #location:pValidPartsList.getAt(tsex).getAt(tMainPart).count])
              end if
            end if
            ttempColor = []
            tMultiPartProps = [:]
            the itemDelimiter = "/"
            tPartId = tLine.getPropRef(#item, 2).getProp(#char, 8, tLine.getPropRef(#item, 2).count(#char))
            ttempProp = tLine.getProp(#item, 3)
            the itemDelimiter = "="
            tMainPart = ttempProp.getProp(#item, 1)
            tMainPartModel = ttempProp.getProp(#item, 2)
            the itemDelimiter = "/"
            tMultiPartProps.addProp(tMainPart, tMainPartModel)
            if tLine.count(#item) > 3 then
              tMultiParts = 4
              repeat while tMultiParts <= tLine.count(#item)
                tPartItem = tLine.getProp(#item, tMultiParts)
                ttempProp = ttempProp & "/" & tPartItem
                the itemDelimiter = "="
                tMultiPartProps.addProp(tPartItem.getProp(#item, 1), tPartItem.getProp(#item, 2))
                the itemDelimiter = "/"
                tMultiParts = 1 + tMultiParts
              end repeat
            end if
          end if
        end if
        f = 1 + f
      end repeat
    end if
  end repeat
  the itemDelimiter = tTempItemdelimiter
  pSelectablePartsList = pValidPartsList
  pSelectableSetIDList = pValidSetIDList
end

on initializeValidPartLists me, tPlist 
  if not tPlist.ilk = #propList then
    error(me, "Can't initialize valid part list", #initializeValidPartLists, #minor)
    if memberExists("DefaultPartList") then
      tPlist = value(member(getmemnum("DefaultPartList")).text)
    else
      return(error(me, "not found default part list", #initializeValidPartLists, #major))
    end if
  end if
  pValidPartsList = tPlist
  tChangeList = member("figure_part_replace_list").text
  if not voidp(tChangeList) then
    tChangeList = value(replaceChunks(tChangeList, "\r", ""))
  end if
  if voidp(tChangeList) then
    tChangeList = [:]
  end if
  tReverseMap = ["M":[:], "F":[:]]
  repeat while ["M", "F"] <= undefined
    tsex = getAt(undefined, tPlist)
    if not voidp(pValidPartsList.getAt(tsex).getAt("hr")) then
      tHairList = pValidPartsList.getAt(tsex).getAt("hr")
      repeat while ["M", "F"] <= undefined
        tHairData = getAt(undefined, tPlist)
        tSetID = tHairData.getAt("s")
        tParts = tHairData.getAt("p")
        if not voidp(tParts.getAt("hr")) then
          tPartId = tParts.getAt("hr")
          tPos = tChangeList.findPos(tPartId)
          if tPos > 0 then
            tReverseMap.getAt(tsex).addProp(tPartId, tSetID)
          end if
        end if
      end repeat
    end if
  end repeat
  tExtraList = member("figure_accessories_extra").text
  if not voidp(tExtraList) then
    tExtraList = value(replaceChunks(tExtraList, "\r", ""))
    if not voidp(tExtraList) then
      repeat while ["M", "F"] <= undefined
        tsex = getAt(undefined, tPlist)
        if not voidp(pValidPartsList.getAt(tsex)) then
          tList = tExtraList.getAt(tsex)
          if not voidp(tList) then
            i = 1
            repeat while i <= tList.count
              ttype = tList.getPropAt(i)
              if voidp(pValidPartsList.getAt(tsex).getAt(ttype)) then
                pValidPartsList.getAt(tsex).setAt(ttype, [])
              end if
              repeat while ["M", "F"] <= undefined
                tSet = getAt(undefined, tPlist)
                tColorList = void()
                j = 1
                repeat while j <= tChangeList.count
                  repeat while ["M", "F"] <= undefined
                    tReplacePart = getAt(undefined, tPlist)
                    if tReplacePart = tSet.getAt("s") then
                      tPartId = tChangeList.getPropAt(j)
                      tSetID = tReverseMap.getAt(tsex).getAt(tPartId)
                      if not voidp(tSetID) then
                        tColorList = me.getPartColors(tSetID, tsex)
                      end if
                    else
                    end if
                  end repeat
                  if not voidp(tColorList) then
                  else
                    j = 1 + j
                  end if
                end repeat
                if not voidp(tColorList) then
                  tSet.setAt("c", tColorList.duplicate())
                end if
                pValidPartsList.getAt(tsex).getAt(ttype).add(tSet)
              end repeat
              i = 1 + i
            end repeat
          end if
        end if
      end repeat
    end if
  end if
  pValidSetIDList = [:]
  repeat while ["M", "F"] <= undefined
    tsex = getAt(undefined, tPlist)
    pValidSetIDList.setAt(tsex, [:])
    tPartSet = 1
    repeat while tPartSet <= pValidPartsList.getAt(tsex).count
      tProp = pValidPartsList.getAt(tsex).getPropAt(tPartSet)
      tDesc = pValidPartsList.getAt(tsex).getAt(tProp)
      tP = 1
      repeat while tP <= tDesc.count
        tSetID = tDesc.getAt(tP).getAt("s")
        tAffectedParts = tDesc.getAt(tP).getAt("del")
        if tAffectedParts = void() then
          tAffectedParts = []
        end if
        pValidSetIDList.getAt(tsex).addProp(tSetID, [#part:tProp, #location:tP, #hideparts:tAffectedParts])
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

on loadPartSetXML me 
  tdata = member("partSets.XML").text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if voidp(errorString) then
      i = 1
      repeat while i <= tParserObject.count(#child)
        tName = tParserObject.getPropRef(#child, i).name
        if tName = "partSets" then
          j = 1
          repeat while j <= tParserObject.getPropRef(#child, i).count(#child)
            tElementPartSet = tParserObject.getPropRef(#child, i).getProp(#child, j)
            if tElementPartSet.name = "partSet" then
              tFullList = []
              tSwimList = []
              tSmallList = []
              tSwimSmallList = []
              tFlipList = [:]
              k = 1
              repeat while k <= tElementPartSet.count(#child)
                tElementPart = tElementPartSet.getProp(#child, k)
                if tElementPart.name = "part" then
                  tAttributes = ["set-type":void(), "swim":1, "small":1, "flipped-set-type":void()]
                  l = 1
                  repeat while l <= tElementPart.count(#attributeName)
                    tName = tElementPart.getProp(#attributeName, l)
                    tValue = tElementPart.getProp(#attributeValue, l)
                    tAttributes.setAt(tName, tValue)
                    l = 1 + l
                  end repeat
                  if not voidp(tAttributes.getAt("set-type")) then
                    tFullList.add(tAttributes.getAt("set-type"))
                    if value(tAttributes.getAt("swim")) then
                      tSwimList.add(tAttributes.getAt("set-type"))
                      if value(tAttributes.getAt("small")) then
                        tSwimSmallList.add(tAttributes.getAt("set-type"))
                      end if
                    end if
                    if value(tAttributes.getAt("small")) then
                      tSmallList.add(tAttributes.getAt("set-type"))
                    end if
                    if not voidp(tAttributes.getAt("flipped-set-type")) then
                      tFlipList.addProp(tAttributes.getAt("set-type"), tAttributes.getAt("flipped-set-type"))
                    end if
                  else
                    error(me, "missing set-type attribute for part in partSet element!", #loadPartSetXML, #major)
                  end if
                end if
                k = 1 + k
              end repeat
              setVariable("human.parts." & tPeopleSize, tFullList)
              setVariable("human.parts." & tPeopleSize50, tSmallList)
              setVariable("swimmer.parts." & tPeopleSize, tSwimList)
              setVariable("swimmer.parts." & tPeopleSize50, tSwimSmallList)
              setVariable("human.parts.flipList", tFlipList)
            else
              if tElementPartSet.name = "activePartSet" then
                tPartList = []
                tID = void()
                l = 1
                repeat while l <= tElementPartSet.count(#attributeName)
                  tName = tElementPartSet.getProp(#attributeName, l)
                  tValue = tElementPartSet.getProp(#attributeValue, l)
                  if tName = "id" then
                    tID = tValue
                  end if
                  l = 1 + l
                end repeat
                if not voidp(tID) then
                  k = 1
                  repeat while k <= tElementPartSet.count(#child)
                    tElementPart = tElementPartSet.getProp(#child, k)
                    if tElementPart.name = "activePart" then
                      tAttributes = ["set-type":void()]
                      l = 1
                      repeat while l <= tElementPart.count(#attributeName)
                        tName = tElementPart.getProp(#attributeName, l)
                        tValue = tElementPart.getProp(#attributeValue, l)
                        tAttributes.setAt(tName, tValue)
                        l = 1 + l
                      end repeat
                      if not voidp(tAttributes.getAt("set-type")) then
                        tPartList.add(tAttributes.getAt("set-type"))
                      end if
                    end if
                    k = 1 + k
                  end repeat
                  setVariable("human.partset." & tID & "." & tPeopleSize, tPartList)
                  setVariable("human.partset." & tID & "." & tPeopleSize50, tPartList)
                else
                  error(me, "missing id attribute for activePartSet!", #loadPartSetXML, #major)
                end if
              end if
            end if
            j = 1 + j
          end repeat
        end if
        i = 1 + i
      end repeat
    end if
  end if
end

on loadActionSetXML me 
  tdata = member("actionSet.XML").text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if voidp(errorString) then
      i = 1
      repeat while i <= tParserObject.count(#child)
        tName = tParserObject.getPropRef(#child, i).name
        if tName = "actionSet" then
          j = 1
          repeat while j <= tParserObject.getPropRef(#child, i).count(#child)
            tElementAction = tParserObject.getPropRef(#child, i).getProp(#child, j)
            if tElementAction.name = "action" then
              tID = void()
              l = 1
              repeat while l <= tElementAction.count(#attributeName)
                tName = tElementAction.getProp(#attributeName, l)
                tValue = tElementAction.getProp(#attributeValue, l)
                if tName = "id" then
                  tID = tValue
                end if
                l = 1 + l
              end repeat
              if not voidp(tID) then
                k = 1
                repeat while k <= tElementAction.count(#child)
                  tElementDirection = tElementAction.getProp(#child, k)
                  if tElementDirection.name = "direction" then
                    tDirection = void()
                    l = 1
                    repeat while l <= tElementDirection.count(#attributeName)
                      tName = tElementDirection.getProp(#attributeName, l)
                      tValue = tElementDirection.getProp(#attributeValue, l)
                      if tName = "id" then
                        tDirection = tValue
                      end if
                      l = 1 + l
                    end repeat
                    if not voidp(tDirection) then
                      tPartList = []
                      l = 1
                      repeat while l <= tElementDirection.count(#child)
                        tElementPartList = tElementDirection.getProp(#child, l)
                        if tElementPartList.name = "partList" then
                          tPartList = me.parsePartListXML(tElementPartList)
                        end if
                        l = 1 + l
                      end repeat
                      if tID = "std" then
                        setVariable("human.parts." & tPeopleSize & "." & tDirection, tPartList)
                        setVariable("human.parts." & tPeopleSize50 & "." & tDirection, tPartList)
                      else
                        setVariable("human.parts." & tPeopleSize & "." & tID & "." & tDirection, tPartList)
                        setVariable("human.parts." & tPeopleSize50 & "." & tID & "." & tDirection, tPartList)
                      end if
                    else
                    end if
                  end if
                  k = 1 + k
                end repeat
                exit repeat
              end if
              error(me, "missing id attribute for partSet!", #loadPartSetXML, #major)
            end if
            j = 1 + j
          end repeat
        end if
        i = 1 + i
      end repeat
    end if
  end if
end

on parsePartListXML me, tElement 
  tPartList = []
  tIndex = 1
  i = 1
  repeat while i <= tElement.count(#child)
    tElementPart = tElement.getProp(#child, i)
    if tElementPart.name = "part" then
      tAttributes = ["set-type":void()]
      l = 1
      repeat while l <= tElementPart.count(#attributeName)
        tName = tElementPart.getProp(#attributeName, l)
        tValue = tElementPart.getProp(#attributeValue, l)
        tAttributes.setAt(tName, tValue)
        l = 1 + l
      end repeat
      if not voidp(tAttributes.getAt("set-type")) then
        tPartList.setAt(tIndex, tAttributes.getAt("set-type"))
        tIndex = tIndex + 1
      else
        error(me, "missing set-type attribute for part!", #parsePartListXML, #major)
      end if
    end if
    i = 1 + i
  end repeat
  return(tPartList)
end

on loadAnimationSetXML me 
  tAnimationData = [:]
  tdata = member("animationSet.XML").text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if voidp(errorString) then
      i = 1
      repeat while i <= tParserObject.count(#child)
        tName = tParserObject.getPropRef(#child, i).name
        if tName = "animationSet" then
          j = 1
          repeat while j <= tParserObject.getPropRef(#child, i).count(#child)
            tElementAction = tParserObject.getPropRef(#child, i).getProp(#child, j)
            if tElementAction.name = "action" then
              tID = void()
              l = 1
              repeat while l <= tElementAction.count(#attributeName)
                tName = tElementAction.getProp(#attributeName, l)
                tValue = tElementAction.getProp(#attributeValue, l)
                if tName = "id" then
                  tID = tValue
                end if
                l = 1 + l
              end repeat
              if not voidp(tID) then
                k = 1
                repeat while k <= tElementAction.count(#child)
                  tElementPart = tElementAction.getProp(#child, k)
                  if tElementPart.name = "part" then
                    tAttributes = ["set-type":void()]
                    l = 1
                    repeat while l <= tElementPart.count(#attributeName)
                      tName = tElementPart.getProp(#attributeName, l)
                      tValue = tElementPart.getProp(#attributeValue, l)
                      tAttributes.setAt(tName, tValue)
                      l = 1 + l
                    end repeat
                    if not voidp(tAttributes.getAt("set-type")) then
                      tFrameList = me.parseFrameListXML(tElementPart)
                      if voidp(tAnimationData.getAt(tAttributes.getAt("set-type"))) then
                        tAnimationData.setAt(tAttributes.getAt("set-type"), [:])
                      end if
                      tAnimationData.getAt(tAttributes.getAt("set-type")).setAt(tID, tFrameList)
                    else
                      error(me, "missing set-type attribute for part in action element!", #loadPartSetXML, #major)
                    end if
                  end if
                  k = 1 + k
                end repeat
              end if
              exit repeat
            end if
            error(me, "missing id attribute in action element!", #loadPartSetXML, #major)
            j = 1 + j
          end repeat
        end if
        i = 1 + i
      end repeat
    end if
  end if
  setVariable("human.parts.animationList", tAnimationData)
end

on parseFrameListXML me, tElement 
  tFrameList = []
  tIndex = 1
  i = 1
  repeat while i <= tElement.count(#child)
    tElementFrame = tElement.getProp(#child, i)
    if tElementFrame.name = "frame" then
      tAttributes = ["number":void()]
      l = 1
      repeat while l <= tElementFrame.count(#attributeName)
        tName = tElementFrame.getProp(#attributeName, l)
        tValue = tElementFrame.getProp(#attributeValue, l)
        tAttributes.setAt(tName, tValue)
        l = 1 + l
      end repeat
      if not voidp(tAttributes.getAt("number")) then
        tFrameList.setAt(tIndex, tAttributes.getAt("number"))
        tIndex = tIndex + 1
      else
        error(me, "missing number attribute for frame!", #parseFrameListXML, #major)
      end if
    end if
    i = 1 + i
  end repeat
  return(tFrameList)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tCmds = [:]
  tCmds.setaProp("GETAVAILABLESETS", 9)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
end
