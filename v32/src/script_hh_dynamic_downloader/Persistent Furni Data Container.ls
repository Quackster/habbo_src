property pStuffData, pWallitemData, pStuffDataByClass, pWallitemDataByClass, pDownloadRetriesLeft, pMemberName, pDownloadedData

on construct me 
  pDownloadRetriesLeft = 5
  pStuffData = [:]
  pStuffData.sort()
  pWallitemData = [:]
  pWallitemData.sort()
  pStuffDataByClass = [:]
  pStuffDataByClass.sort()
  pWallitemDataByClass = [:]
  pWallitemDataByClass.sort()
  pDownloadRetryCount = 1
  pDownloadedData = []
  if variableExists("furnidata.load.url") then
    me.initDownload()
  else
    fatalError(["error":"furnidata_config"])
  end if
end

on deconstruct me 
  pStuffData = [:]
  pWallitemData = [:]
end

on getProps me, ttype, tID 
  if (ttype = "s") then
    return(pStuffData.getaProp(tID))
  else
    if ttype <> "i" then
      if (ttype = "e") then
        return(pWallitemData.getaProp(tID))
      else
        error(me, "invalid item type", #getProps, #minor)
      end if
    end if
  end if
end

on getPropsByClass me, ttype, tClass 
  if (ttype = "s") then
    return(pStuffDataByClass.getaProp(tClass))
  else
    if ttype <> "i" then
      if (ttype = "e") then
        return(pWallitemDataByClass.getaProp(tClass))
      else
        error(me, "invalid item type", #getProps, #minor)
      end if
    end if
  end if
end

on initDownload me 
  tURL = getVariable("furnidata.load.url")
  pMemberName = tURL & "-" & pDownloadRetriesLeft
  tHash = getSpecialServices().getSessionHash()
  if (tHash = "") then
    tHash = string(random(1000000))
  end if
  tURL = replaceChunks(tURL, "%hash%", tHash)
  if not createMember(pMemberName, #field) then
    return(error(me, "Could not create member!", #initDownload, #critical))
  end if
  tMemNum = queueDownload(tURL, pMemberName, #field, 1)
  registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tMemNum)
end

on downloadCallback me, tParams, tSuccess 
  if tSuccess then
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member:tmember, #start:1, #count:1]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
  else
    fatalError(["error":"furnidata"])
    return(error(me, "Failure while loading furnidata", #downloadCallback, #critical))
  end if
end

on parseCallback me, tArgument 
  pDownloadedData = []
  tmember = tArgument.getAt(#member)
  if ilk(tmember) <> #member then
    fatalError(["error":"furnidata_member"])
    return(error(me, "Failure with furnidata member", #parseCallback, #critical))
  end if
  tLineNo = 1
  repeat while tLineNo <= tmember.text.count(#line)
    tLineTxt = tmember.text.getProp(#line, tLineNo)
    pDownloadedData.setAt(tLineNo, tLineTxt)
    tLineNo = (1 + tLineNo)
  end repeat
  me.parseOneLine(tArgument)
end

on parseOneLine me, tArgument 
  tStartingLine = tArgument.getAt(#start)
  tLineCount = tArgument.getAt(#count)
  if (tStartingLine + tLineCount) > pDownloadedData.count then
    tLineCount = (pDownloadedData.count - tStartingLine)
  end if
  l = tStartingLine
  repeat while l <= (tStartingLine + tLineCount)
    tVal = value(pDownloadedData.getAt(l))
    if (ilk(tVal) = #list) then
      repeat while tVal <= undefined
        tItem = getAt(undefined, tArgument)
        tdata = [:]
        tdata.setAt(#type, tItem.getAt(1))
        tdata.setAt(#classID, value(tItem.getAt(2)))
        tdata.setAt(#class, tItem.getAt(3))
        tdata.setAt(#revision, value(tItem.getAt(4)))
        tdata.setAt(#defaultDir, value(tItem.getAt(5)))
        tdata.setAt(#xdim, value(tItem.getAt(6)))
        tdata.setAt(#ydim, value(tItem.getAt(7)))
        tdata.setAt(#partColors, tItem.getAt(8))
        tdata.setAt(#localizedName, decodeUTF8(tItem.getAt(9)))
        tdata.setAt(#localizedDesc, decodeUTF8(tItem.getAt(10)))
        getThread("dynamicdownloader").getComponent().setFurniRevision(tdata.getAt(#class), tdata.getAt(#revision), (tdata.getAt(#type) = "s"))
        if (tdata.getAt(#type) = "s") then
          pStuffData.setaProp(tdata.getAt(#classID), tdata)
          pStuffDataByClass.setaProp(tItem.getAt(3), tdata)
        else
          pWallitemData.setaProp(tdata.getAt(#classID), tdata)
          pWallitemDataByClass.setaProp(tItem.getAt(3), tdata)
        end if
      end repeat
    else
      if (l = pDownloadedData.count) and pDownloadedData.count > 1 and (pDownloadedData.getAt(l) = "") then
        nothing()
      else
        if pDownloadRetriesLeft > 0 then
          pDownloadRetriesLeft = (pDownloadRetriesLeft - 1)
          me.initDownload()
          return FALSE
        else
          gLogVarUrl = string(pDownloadedData)
          fatalError(["error":"furnidata_malformed"])
          return(error(me, "Failure while parsing furnitdata", #parseOneLine, #critical))
        end if
      end if
    end if
    l = (1 + l)
  end repeat
  if (tStartingLine + tLineCount) >= pDownloadedData.count then
    getThread("dynamicdownloader").getComponent().setFurniRevision(void())
    sendProcessTracking(25)
    executeMessage(#furnidataReceived)
  else
    tNewArgument = [#start:(tStartingLine + tLineCount), #count:tLineCount]
    createTimeout(getUniqueID(), 250, #parseOneLine, me.getID(), tNewArgument, 1)
  end if
end
