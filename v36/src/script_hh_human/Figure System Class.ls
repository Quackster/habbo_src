property pDontProfile, pFigureData

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
  return(1)
end

on deconstruct me 
  me.regMsgList(0)
  return(1)
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
    tProps = ["type":"url", "source":tURL]
  end if
  if voidp(tProps.getAt("type")) then
    error(me, "source type of figure list is void", #define, #major)
  end if
  if tProps.getAt("type") = "url" then
    me.loadFigurePartList(tProps.getAt("source"))
  else
    if tProps.getAt("type") = "proplist" then
      tProlist = tProps.getAt("source")
      initializeValidPartLists(tProlist)
    else
      error(me, "incorrect source type, can�t run define ", #define, #major)
    end if
  end if
end

on parseFigure me, tFigureData, tsex, tClass 
  if voidp(tClass) then
    tClass = "user"
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
        exit repeat
      end if
      tDelim = the itemDelimiter
      the itemDelimiter = "."
      tPartCount = tFigureData.count(#item)
      i = 1
      repeat while i <= tPartCount
        the itemDelimiter = "."
        tPartData = tFigureData.getProp(#item, i)
        the itemDelimiter = "-"
        if tPartData.count(#item) >= 3 then
          tSetType = tPartData.getProp(#item, 1)
          tSetID = tPartData.getProp(#item, 2)
          tColorId = tPartData.getProp(#item, 3)
          tTempFigure.setAt(tSetID, tColorId)
        end if
        i = 1 + i
      end repeat
      the itemDelimiter = tDelim
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
          repeat while tValue.getAt("model").getProp(#char, 1) = "0"
            tValue.setAt("model", tValue.getAt("model").getProp(#char, 2, tValue.getAt("model").length))
          end repeat
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
        exit repeat
      end if
      return(tFigureData)
    end if
    return(tFigure)
  end if
end

on parseNewTypeFigure me, tFigure, tsex 
  tTempFigure = [:]
  tHiddenLayers = [:]
  f = 1
  repeat while f <= tFigure.count
    tSetID = tFigure.getPropAt(f)
    tColorId = tFigure.getAt(tSetID)
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
    i = 1
    repeat while i <= tPartCount
      tPartData = pFigureData.getSetPartData(tSetID, i)
      if tPartData <> 0 then
        tmodel = tPartData.getAt("id")
        tPart = tPartData.getAt("type")
        if tPartData.getAt("colorable") then
          tTempFigure.addProp(tPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":tColorId])
        else
          tTempFigure.addProp(tPart, ["model":tmodel, "color":rgb("#EEEEEE"), "setid":tSetID, "colorid":tColorId])
        end if
      end if
      i = 1 + i
    end repeat
    tHidden = pFigureData.getSetHiddenLayers(tSetID)
    tSetType = pFigureData.getSetType(tSetID)
    if tHidden <> 0 and tSetType <> 0 then
      tHiddenLayers.setAt(tSetType, tHidden)
    end if
    f = 1 + f
  end repeat
  tTempFigure = me.checkAndFixFigure(tTempFigure, tHiddenLayers)
  return(tTempFigure)
end

on checkDataLoaded me 
  tList = ["partsets.xml.loaded", "draworder.xml.loaded", "animation.xml.loaded", "figure.xml.loaded"]
  repeat while tList <= undefined
    tName = getAt(undefined, undefined)
    if not variableExists(tName) then
      return(0)
    end if
    if getVariable(tName) <> 1 then
      return(0)
    end if
  end repeat
  tStamp = ""
  tNo = 1
  repeat while tNo <= 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
    tNo = 1 + tNo
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  tCharNo = 1
  repeat while tCharNo <= tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = (tChar * tCharNo) + 309203
    tReceipt.setAt(tCharNo, tChar)
    tCharNo = 1 + tCharNo
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #checkDataLoaded, #critical)
    return(0)
  end if
  setVariable("figurepartlist.loaded", 1)
  return(1)
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

on partListLoaded me, tParams, tSuccess 
  if not tSuccess then
    fatalError(["error":"part_list"])
    return(error(me, "Failure while loading part list", #partListLoaded, #critical))
  end if
  tMemName = getVariable("external.figurepartlist.txt")
  if tMemName = 0 then
    tMemName = ""
  end if
  if not pDontProfile then
    startProfilingTask("Figure System::partListLoaded")
  end if
  if not memberExists(tMemName) then
    tValidpartList = void()
    error(me, "Failure while loading part list", #partListLoaded, #major)
  else
    tContent = member(getmemnum(tMemName)).text
    if not pFigureData.parseData(tContent) then
      return(error(me, "Failure while parsing part list", #partListLoaded, #critical))
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
  i = tPartDefinition.count
  repeat while i >= 1
    tPartSymbol = tPartDefinition.getAt(i)
    if not voidp(tHiddenLayers.getAt(tPartSymbol)) then
      tHiddenLayersOrdered.addProp(tPartSymbol, tHiddenLayers.getAt(tPartSymbol))
    end if
    i = 255 + i
  end repeat
  i = 1
  repeat while i <= tHiddenLayersOrdered.count
    tRemoveList = tHiddenLayersOrdered.getAt(i)
    repeat while tRemoveList <= tHiddenLayers
      tPart = getAt(tHiddenLayers, tFigure)
      repeat while tFigure.findPos(tPart) > 0
        tFigure.deleteProp(tPart)
      end repeat
      if tHiddenLayersOrdered.findPos(tPart) > i then
        tHiddenLayersOrdered.deleteProp(tPart)
      end if
    end repeat
    i = 1 + i
  end repeat
  tRemoveList = getVariable("human.parts.removeList")
  if ilk(tRemoveList) <> #propList then
    tRemoveList = [:]
  end if
  i = 1
  repeat while i <= tRemoveList.count
    tPart = tRemoveList.getPropAt(i)
    if tFigure.findPos(tPart) > 0 then
      tRemovePart = tRemoveList.getAt(i)
      tFigure.deleteProp(tRemovePart)
    end if
    i = 1 + i
  end repeat
  return(tFigure)
end

on loadPartSetXML me 
  if variableExists("partsets.xml.loaded") then
    if getVariable("partsets.xml.loaded") = 1 then
      return(1)
    end if
  end if
  tURL = getVariable("figure.partsets.xml")
  if tURL = 0 then
    return(error(me, "Can't load partset XML - no URL configured", #loadPartSetXML, #critical))
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return(registerDownloadCallback(tmember, #partSetLoaded, me.getID()))
end

on loadActionSetXML me 
  if variableExists("draworder.xml.loaded") then
    if getVariable("draworder.xml.loaded") = 1 then
      return(1)
    end if
  end if
  tURL = getVariable("figure.draworder.xml")
  if tURL = 0 then
    return(error(me, "Can't load action set XML - no URL configured", #loadActionSetXML, #critical))
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return(registerDownloadCallback(tmember, #actionSetLoaded, me.getID()))
end

on loadAnimationSetXML me 
  if variableExists("animation.xml.loaded") then
    if getVariable("animation.xml.loaded") = 1 then
      return(1)
    end if
  end if
  tURL = getVariable("figure.animation.xml")
  if tURL = 0 then
    return(error(me, "Can't load animation XML - no URL configured", #loadAnimationSetXML, #critical))
  end if
  tMem = tURL
  tmember = queueDownload(tURL, tMem, #field, 1)
  return(registerDownloadCallback(tmember, #animationSetLoaded, me.getID()))
end

on partSetLoaded me, tParams, tSuccess 
  if not tSuccess then
    fatalError(["error":"part_sets"])
    return(error(me, "Failure while loading partset XML", #partSetLoaded, #critical))
  end if
  tMemName = getVariable("figure.partsets.xml")
  if tMemName = 0 then
    return(error(me, "Failure while loading partset XML", #partSetLoaded, #critical))
  end if
  if not memberExists(tMemName) then
    return(error(me, "Failure while loading partset XML", #partSetLoaded, #critical))
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
      fatalError(["error":"part_sets_invalid"])
      return(error(me, "Failure while parsing partset XML", #partSetLoaded, #critical))
    end if
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
            tRemoveList = [:]
            k = 1
            repeat while k <= tElementPartSet.count(#child)
              tElementPart = tElementPartSet.getProp(#child, k)
              if tElementPart.name = "part" then
                tAttributes = ["swim":1, "small":1]
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
                  if not voidp(tAttributes.getAt("remove-set-type")) then
                    tRemoveList.addProp(tAttributes.getAt("set-type"), tAttributes.getAt("remove-set-type"))
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
            setVariable("human.parts.removeList", tRemoveList)
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
  setVariable("partsets.xml.loaded", 1)
  me.checkDataLoaded()
  if not pDontProfile then
    finishProfilingTask("Figure System::partSetLoaded")
  end if
end

on actionSetLoaded me, tParams, tSuccess 
  if not tSuccess then
    fatalError(["error":"action_set"])
    return(error(me, "Failure while loading action set XML", #actionSetLoaded, #critical))
  end if
  tMemName = getVariable("figure.draworder.xml")
  if tMemName = 0 then
    return(error(me, "Failure while loading action set XML", #actionSetLoaded, #critical))
  end if
  if not memberExists(tMemName) then
    return(error(me, "Failure while loading action set XML", #actionSetLoaded, #critical))
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
      fatalError(["error":"action_set_invalid"])
      return(error(me, "Failure while parsing action set XML", #actionSetLoaded, #critical))
    end if
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
  setVariable("draworder.xml.loaded", 1)
  me.checkDataLoaded()
  if not pDontProfile then
    finishProfilingTask("Figure System::actionSetLoaded")
  end if
end

on animationSetLoaded me, tParams, tSuccess 
  if not tSuccess then
    fatalError(["error":"animation_set"])
    return(error(me, "Failure while loading animation XML", #animationSetLoaded, #critical))
  end if
  tAnimationData = [:]
  tMemName = getVariable("figure.animation.xml")
  if tMemName = 0 then
    return(error(me, "Failure while loading animation XML", #animationSetLoaded, #critical))
  end if
  if not memberExists(tMemName) then
    return(error(me, "Failure while loading animation XML", #animationSetLoaded, #critical))
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
      fatalError(["error":"animation_set_invalid"])
      return(error(me, "Failure while parsing animation XML", #animationSetLoaded, #critical))
    end if
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
