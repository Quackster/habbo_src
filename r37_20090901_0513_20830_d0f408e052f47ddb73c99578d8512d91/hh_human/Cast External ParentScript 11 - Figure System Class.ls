property pFigurePartListLoadedFlag, pAvailableSetListLoadedFlag, pFigureData, pDontProfile

on construct me
  pFigurePartListLoadedFlag = 0
  pAvailableSetListLoadedFlag = 0
  setVariable("figurepartlist.loaded", 0)
  setVariable("figure.xml.loaded", 0)
  me.regMsgList(1)
  me.loadPartSetXML()
  me.loadActionSetXML()
  me.loadAnimationSetXML()
  pFigureData = createObject(#temp, "Figure Data Class")
  me.setProfiling()
  return 1
end

on deconstruct me
  me.regMsgList(0)
  return 1
end

on setProfiling
  if voidp(pDontProfile) then
    pDontProfile = 1
    if getObjectManager().managerExists(#variable_manager) then
      if variableExists("profile.fields.enabled") then
        pDontProfile = 0
      end if
    end if
  end if
end

on define me, tProps
  if tProps.ilk <> #propList then
    tURL = getVariable("external.figurepartlist.txt")
    tProps = ["type": "url", "source": tURL]
  end if
  if voidp(tProps["type"]) then
    error(me, "source type of figure list is void", #define, #major)
  end if
  case tProps["type"] of
    "url":
      me.loadFigurePartList(tProps["source"])
    "proplist":
      tProlist = tProps["source"]
      initializeValidPartLists(tProlist)
    otherwise:
      error(me, "incorrect source type, can«t run define ", #define, #major)
  end case
end

on parseFigure me, tFigureData, tsex, tClass
  if voidp(tClass) then
    tClass = "user"
  end if
  case tClass of
    "user", "pelle", "bot":
      if (tClass = "bot") and (tFigureData contains "&") then
        return me.parseOldBotFigure(tFigureData, tsex, tClass)
      end if
      tTempFigure = [:]
      if ((tFigureData.char.count mod 5) = 0) and integerp(integer(tFigureData)) then
        tFigureData = tFigureData.char[1..tFigureData.char.count]
        tPartCount = tFigureData.char.count / 5
        repeat with i = 0 to tPartCount - 1
          tPart = tFigureData.char[(i * 5) + 1..(i * 5) + 5]
          tSetID = tPart.char[1..3]
          tColorId = tPart.char[4..5]
          tTempFigure[tSetID] = value(tColorId)
        end repeat
      else
        tDelim = the itemDelimiter
        the itemDelimiter = "."
        tPartCount = tFigureData.item.count
        repeat with i = 1 to tPartCount
          the itemDelimiter = "."
          tPartData = tFigureData.item[i]
          the itemDelimiter = "-"
          if tPartData.item.count >= 3 then
            tSetType = tPartData.item[1]
            tSetID = tPartData.item[2]
            tColorId = tPartData.item[3]
            tTempFigure[tSetID] = tColorId
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      tFigure = me.parseNewTypeFigure(tTempFigure, tsex)
    otherwise:
      return tFigureData
  end case
  return tFigure
end

on parseOldBotFigure me, tFigureData, tsex, tClass
  if tClass <> "bot" then
    return tFigureData
  end if
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
    repeat while tValue["model"].char[1] = "0"
      tValue["model"] = tValue["model"].char[2..tValue["model"].length]
    end repeat
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
  return tFigure
end

on parseNewTypeFigure me, tFigure, tsex
  tTempFigure = [:]
  tHiddenLayers = [:]
  repeat with f = 1 to tFigure.count
    tSetID = tFigure.getPropAt(f)
    tColorId = tFigure[tSetID]
    if voidp(tColorId) then
      tColorId = 1
    end if
    tColor = pFigureData.getColor(tColorId)
    if tColor = 0 then
      tColor = rgb("#EEEEEE")
    else
      tColor = rgb(tColor)
    end if
    tPartCount = pFigureData.getSetPartCount(tSetID)
    repeat with i = 1 to tPartCount
      tPartData = pFigureData.getSetPartData(tSetID, i)
      if tPartData <> 0 then
        tmodel = tPartData["id"]
        tPart = tPartData["type"]
        if tPartData["colorable"] then
          tTempFigure.addProp(tPart, ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId])
          next repeat
        end if
        tTempFigure.addProp(tPart, ["model": tmodel, "color": rgb("#EEEEEE"), "setid": tSetID, "colorid": tColorId])
      end if
    end repeat
    tHidden = pFigureData.getSetHiddenLayers(tSetID)
    tSetType = pFigureData.getSetType(tSetID)
    if (tHidden <> 0) and (tSetType <> 0) then
      tHiddenLayers[tSetType] = tHidden
    end if
  end repeat
  tTempFigure = me.checkAndFixFigure(tTempFigure, tHiddenLayers)
  return tTempFigure
end

on checkDataLoaded me
  tList = ["partsets.xml.loaded", "draworder.xml.loaded", "animation.xml.loaded", "figure.xml.loaded"]
  repeat with tName in tList
    if not variableExists(tName) then
      return 0
    end if
    if getVariable(tName) <> 1 then
      return 0
    end if
  end repeat
  tStamp = EMPTY
  repeat with tNo = 1 to 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  repeat with tCharNo = 1 to tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = (tChar * tCharNo) + 309203
    tReceipt[tCharNo] = tChar
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #checkDataLoaded, #critical)
    return 0
  end if
  setVariable("figurepartlist.loaded", 1)
  return 1
end

on loadFigurePartList me, tURL
  tMem = tURL
  tMemberCount = 0
  tCastList = ["hh_human_shirt", "hh_human_leg", "hh_human_shoe", "hh_human_body", "hh_human_face", "hh_human_hats", "hh_human_hair"]
  repeat with tCastName in tCastList
    tCastLib = castLib(tCastName)
    if tCastLib <> 0 then
      tMemberCount = tMemberCount + the number of castMembers of castLib tCastName
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
  return registerDownloadCallback(tmember, #partListLoaded, me.getID())
end

on partListLoaded me, tParams, tSuccess
  if not tSuccess then
    fatalError(["error": "part_list"])
    return error(me, "Failure while loading part list", #partListLoaded, #critical)
  end if
  tMemName = getVariable("external.figurepartlist.txt")
  if tMemName = 0 then
    tMemName = EMPTY
  end if
  if not pDontProfile then
    startProfilingTask("Figure System::partListLoaded")
  end if
  if not memberExists(tMemName) then
    tValidpartList = VOID
    error(me, "Failure while loading part list", #partListLoaded, #major)
  else
    tContent = member(getmemnum(tMemName)).text
    if not pFigureData.parseData(tContent) then
      return error(me, "Failure while parsing part list", #partListLoaded, #critical)
    end if
  end if
  pFigurePartListLoadedFlag = 1
  setVariable("figure.xml.loaded", 1)
  me.checkDataLoaded()
  if memberExists(tMemName) then
    removeMember(tMemName)
  end if
  if not pDontProfile then
    finishProfilingTask("Figure System::partListLoaded")
  end if
end

on checkAndFixFigure me, tFigure, tHiddenLayers
  if tFigure.ilk <> #propList then
    tFigure = [:]
  end if
  tFigure = tFigure.duplicate()
  if tHiddenLayers.ilk <> #propList then
    tHiddenLayers = [:]
  end if
  tPartDefinition = getVariableValue("human.parts.h")
  if tPartDefinition = 0 then
    tPartDefinition = []
  end if
  tHiddenLayersOrdered = [:]
  repeat with i = tPartDefinition.count down to 1
    tPartSymbol = tPartDefinition[i]
    if not voidp(tHiddenLayers[tPartSymbol]) then
      tHiddenLayersOrdered.addProp(tPartSymbol, tHiddenLayers[tPartSymbol])
    end if
  end repeat
  repeat with i = 1 to tHiddenLayersOrdered.count
    tRemoveList = tHiddenLayersOrdered[i]
    repeat with tPart in tRemoveList
      repeat while tFigure.findPos(tPart) > 0
        tFigure.deleteProp(tPart)
      end repeat
      if tHiddenLayersOrdered.findPos(tPart) > i then
        tHiddenLayersOrdered.deleteProp(tPart)
      end if
    end repeat
  end repeat
  tRemoveList = getVariable("human.parts.removeList")
  if ilk(tRemoveList) <> #propList then
    tRemoveList = [:]
  end if
  repeat with i = 1 to tRemoveList.count
    tPart = tRemoveList.getPropAt(i)
    if tFigure.findPos(tPart) > 0 then
      tRemovePart = tRemoveList[i]
      tFigure.deleteProp(tRemovePart)
    end if
  end repeat
  return tFigure
end

on loadPartSetXML me
  if variableExists("partsets.xml.loaded") then
    if getVariable("partsets.xml.loaded") = 1 then
      return 1
    end if
  end if
  tURL = getVariable("figure.partsets.xml")
  if tURL = 0 then
    return error(me, "Can't load partset XML - no URL configured", #loadPartSetXML, #critical)
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return registerDownloadCallback(tmember, #partSetLoaded, me.getID())
end

on loadActionSetXML me
  if variableExists("draworder.xml.loaded") then
    if getVariable("draworder.xml.loaded") = 1 then
      return 1
    end if
  end if
  tURL = getVariable("figure.draworder.xml")
  if tURL = 0 then
    return error(me, "Can't load action set XML - no URL configured", #loadActionSetXML, #critical)
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return registerDownloadCallback(tmember, #actionSetLoaded, me.getID())
end

on loadAnimationSetXML me
  if variableExists("animation.xml.loaded") then
    if getVariable("animation.xml.loaded") = 1 then
      return 1
    end if
  end if
  tURL = getVariable("figure.animation.xml")
  if tURL = 0 then
    return error(me, "Can't load animation XML - no URL configured", #loadAnimationSetXML, #critical)
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return registerDownloadCallback(tmember, #animationSetLoaded, me.getID())
end

on partSetLoaded me, tParams, tSuccess
  if not tSuccess then
    fatalError(["error": "part_sets"])
    return error(me, "Failure while loading partset XML", #partSetLoaded, #critical)
  end if
  tMemName = getVariable("figure.partsets.xml")
  if tMemName = 0 then
    return error(me, "Failure while loading partset XML", #partSetLoaded, #critical)
  end if
  if not memberExists(tMemName) then
    return error(me, "Failure while loading partset XML", #partSetLoaded, #critical)
  end if
  if not pDontProfile then
    startProfilingTask("Figure System::partSetLoaded")
  end if
  tdata = member(tMemName).text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if not voidp(errorString) then
      fatalError(["error": "part_sets_invalid"])
      return error(me, "Failure while parsing partset XML", #partSetLoaded, #critical)
    end if
    repeat with i = 1 to tParserObject.child.count
      tName = tParserObject.child[i].name
      if tName = "partSets" then
        repeat with j = 1 to tParserObject.child[i].child.count
          tElementPartSet = tParserObject.child[i].child[j]
          if tElementPartSet.name = "partSet" then
            tFullList = []
            tSwimList = []
            tSmallList = []
            tSwimSmallList = []
            tFlipList = [:]
            tRemoveList = [:]
            repeat with k = 1 to tElementPartSet.child.count
              tElementPart = tElementPartSet.child[k]
              if tElementPart.name = "part" then
                tAttributes = ["swim": 1, "small": 1]
                repeat with l = 1 to tElementPart.attributeName.count
                  tName = tElementPart.attributeName[l]
                  tValue = tElementPart.attributeValue[l]
                  tAttributes[tName] = tValue
                end repeat
                if not voidp(tAttributes["set-type"]) then
                  tFullList.add(tAttributes["set-type"])
                  if value(tAttributes["swim"]) then
                    tSwimList.add(tAttributes["set-type"])
                    if value(tAttributes["small"]) then
                      tSwimSmallList.add(tAttributes["set-type"])
                    end if
                  end if
                  if value(tAttributes["small"]) then
                    tSmallList.add(tAttributes["set-type"])
                  end if
                  if not voidp(tAttributes["flipped-set-type"]) then
                    tFlipList.addProp(tAttributes["set-type"], tAttributes["flipped-set-type"])
                  end if
                  if not voidp(tAttributes["remove-set-type"]) then
                    tRemoveList.addProp(tAttributes["set-type"], tAttributes["remove-set-type"])
                  end if
                  next repeat
                end if
                error(me, "missing set-type attribute for part in partSet element!", #loadPartSetXML, #major)
              end if
            end repeat
            setVariable("human.parts." & tPeopleSize, tFullList)
            setVariable("human.parts." & tPeopleSize50, tSmallList)
            setVariable("swimmer.parts." & tPeopleSize, tSwimList)
            setVariable("swimmer.parts." & tPeopleSize50, tSwimSmallList)
            setVariable("human.parts.flipList", tFlipList)
            setVariable("human.parts.removeList", tRemoveList)
            next repeat
          end if
          if tElementPartSet.name = "activePartSet" then
            tPartList = []
            tID = VOID
            repeat with l = 1 to tElementPartSet.attributeName.count
              tName = tElementPartSet.attributeName[l]
              tValue = tElementPartSet.attributeValue[l]
              if tName = "id" then
                tID = tValue
              end if
            end repeat
            if not voidp(tID) then
              repeat with k = 1 to tElementPartSet.child.count
                tElementPart = tElementPartSet.child[k]
                if tElementPart.name = "activePart" then
                  tAttributes = ["set-type": VOID]
                  repeat with l = 1 to tElementPart.attributeName.count
                    tName = tElementPart.attributeName[l]
                    tValue = tElementPart.attributeValue[l]
                    tAttributes[tName] = tValue
                  end repeat
                  if not voidp(tAttributes["set-type"]) then
                    tPartList.add(tAttributes["set-type"])
                  end if
                end if
              end repeat
              setVariable("human.partset." & tID & "." & tPeopleSize, tPartList)
              setVariable("human.partset." & tID & "." & tPeopleSize50, tPartList)
              next repeat
            end if
            error(me, "missing id attribute for activePartSet!", #loadPartSetXML, #major)
          end if
        end repeat
      end if
    end repeat
  end if
  setVariable("partsets.xml.loaded", 1)
  me.checkDataLoaded()
  if not pDontProfile then
    finishProfilingTask("Figure System::partSetLoaded")
  end if
end

on actionSetLoaded me, tParams, tSuccess
  if not tSuccess then
    fatalError(["error": "action_set"])
    return error(me, "Failure while loading action set XML", #actionSetLoaded, #critical)
  end if
  tMemName = getVariable("figure.draworder.xml")
  if tMemName = 0 then
    return error(me, "Failure while loading action set XML", #actionSetLoaded, #critical)
  end if
  if not memberExists(tMemName) then
    return error(me, "Failure while loading action set XML", #actionSetLoaded, #critical)
  end if
  if not pDontProfile then
    startProfilingTask("Figure System::actionSetLoaded")
  end if
  tdata = member(tMemName).text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if not voidp(errorString) then
      fatalError(["error": "action_set_invalid"])
      return error(me, "Failure while parsing action set XML", #actionSetLoaded, #critical)
    end if
    repeat with i = 1 to tParserObject.child.count
      tName = tParserObject.child[i].name
      if tName = "actionSet" then
        repeat with j = 1 to tParserObject.child[i].child.count
          tElementAction = tParserObject.child[i].child[j]
          if tElementAction.name = "action" then
            tID = VOID
            repeat with l = 1 to tElementAction.attributeName.count
              tName = tElementAction.attributeName[l]
              tValue = tElementAction.attributeValue[l]
              if tName = "id" then
                tID = tValue
              end if
            end repeat
            if not voidp(tID) then
              repeat with k = 1 to tElementAction.child.count
                tElementDirection = tElementAction.child[k]
                if tElementDirection.name = "direction" then
                  tDirection = VOID
                  repeat with l = 1 to tElementDirection.attributeName.count
                    tName = tElementDirection.attributeName[l]
                    tValue = tElementDirection.attributeValue[l]
                    if tName = "id" then
                      tDirection = tValue
                    end if
                  end repeat
                  if not voidp(tDirection) then
                    tPartList = []
                    repeat with l = 1 to tElementDirection.child.count
                      tElementPartList = tElementDirection.child[l]
                      if tElementPartList.name = "partList" then
                        tPartList = me.parsePartListXML(tElementPartList)
                      end if
                    end repeat
                    if tID = "std" then
                      setVariable("human.parts." & tPeopleSize & "." & tDirection, tPartList)
                      setVariable("human.parts." & tPeopleSize50 & "." & tDirection, tPartList)
                    else
                      setVariable("human.parts." & tPeopleSize & "." & tID & "." & tDirection, tPartList)
                      setVariable("human.parts." & tPeopleSize50 & "." & tID & "." & tDirection, tPartList)
                    end if
                    next repeat
                  end if
                end if
              end repeat
              next repeat
            end if
            error(me, "missing id attribute for partSet!", #loadPartSetXML, #major)
          end if
        end repeat
      end if
    end repeat
  end if
  setVariable("draworder.xml.loaded", 1)
  me.checkDataLoaded()
  if not pDontProfile then
    finishProfilingTask("Figure System::actionSetLoaded")
  end if
end

on animationSetLoaded me, tParams, tSuccess
  if not tSuccess then
    fatalError(["error": "animation_set"])
    return error(me, "Failure while loading animation XML", #animationSetLoaded, #critical)
  end if
  tAnimationData = [:]
  tMemName = getVariable("figure.animation.xml")
  if tMemName = 0 then
    return error(me, "Failure while loading animation XML", #animationSetLoaded, #critical)
  end if
  if not memberExists(tMemName) then
    return error(me, "Failure while loading animation XML", #animationSetLoaded, #critical)
  end if
  if not pDontProfile then
    startProfilingTask("Figure System::animationSetLoaded")
  end if
  tdata = member(tMemName).text
  if not voidp(tdata) then
    tPeopleSize = getVariable("human.size.64")
    tPeopleSize50 = getVariable("human.size.32")
    tParserObject = new(xtra("xmlparser"))
    errCode = tParserObject.parseString(tdata)
    errorString = tParserObject.getError()
    if not voidp(errorString) then
      fatalError(["error": "animation_set_invalid"])
      return error(me, "Failure while parsing animation XML", #animationSetLoaded, #critical)
    end if
    repeat with i = 1 to tParserObject.child.count
      tName = tParserObject.child[i].name
      if tName = "animationSet" then
        repeat with j = 1 to tParserObject.child[i].child.count
          tElementAction = tParserObject.child[i].child[j]
          if tElementAction.name = "action" then
            tID = VOID
            repeat with l = 1 to tElementAction.attributeName.count
              tName = tElementAction.attributeName[l]
              tValue = tElementAction.attributeValue[l]
              if tName = "id" then
                tID = tValue
              end if
            end repeat
            if not voidp(tID) then
              repeat with k = 1 to tElementAction.child.count
                tElementPart = tElementAction.child[k]
                if tElementPart.name = "part" then
                  tAttributes = ["set-type": VOID]
                  repeat with l = 1 to tElementPart.attributeName.count
                    tName = tElementPart.attributeName[l]
                    tValue = tElementPart.attributeValue[l]
                    tAttributes[tName] = tValue
                  end repeat
                  if not voidp(tAttributes["set-type"]) then
                    tFrameList = me.parseFrameListXML(tElementPart)
                    if voidp(tAnimationData[tAttributes["set-type"]]) then
                      tAnimationData[tAttributes["set-type"]] = [:]
                    end if
                    tAnimationData[tAttributes["set-type"]][tID] = tFrameList
                    next repeat
                  end if
                  error(me, "missing set-type attribute for part in action element!", #loadPartSetXML, #major)
                end if
              end repeat
            end if
            next repeat
          end if
          error(me, "missing id attribute in action element!", #loadPartSetXML, #major)
        end repeat
      end if
    end repeat
  end if
  setVariable("human.parts.animationList", tAnimationData)
  setVariable("animation.xml.loaded", 1)
  me.checkDataLoaded()
  if not pDontProfile then
    finishProfilingTask("Figure System::animationSetLoaded")
  end if
end

on parsePartListXML me, tElement
  tPartList = []
  tIndex = 1
  repeat with i = 1 to tElement.child.count
    tElementPart = tElement.child[i]
    if tElementPart.name = "part" then
      tAttributes = ["set-type": VOID]
      repeat with l = 1 to tElementPart.attributeName.count
        tName = tElementPart.attributeName[l]
        tValue = tElementPart.attributeValue[l]
        tAttributes[tName] = tValue
      end repeat
      if not voidp(tAttributes["set-type"]) then
        tPartList[tIndex] = tAttributes["set-type"]
        tIndex = tIndex + 1
        next repeat
      end if
      error(me, "missing set-type attribute for part!", #parsePartListXML, #major)
    end if
  end repeat
  return tPartList
end

on parseFrameListXML me, tElement
  tFrameList = []
  tIndex = 1
  repeat with i = 1 to tElement.child.count
    tElementFrame = tElement.child[i]
    if tElementFrame.name = "frame" then
      tAttributes = ["number": VOID]
      repeat with l = 1 to tElementFrame.attributeName.count
        tName = tElementFrame.attributeName[l]
        tValue = tElementFrame.attributeValue[l]
        tAttributes[tName] = tValue
      end repeat
      if not voidp(tAttributes["number"]) then
        tFrameList[tIndex] = tAttributes["number"]
        tIndex = tIndex + 1
        next repeat
      end if
      error(me, "missing number attribute for frame!", #parseFrameListXML, #major)
    end if
  end repeat
  return tFrameList
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
