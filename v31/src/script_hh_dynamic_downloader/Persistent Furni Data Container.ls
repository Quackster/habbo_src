property pStuffData, pWallitemData, pStuffDataByClass, pWallitemDataByClass, pMemberName

on construct me 
  pStuffData = [:]
  pStuffData.sort()
  pWallitemData = [:]
  pWallitemData.sort()
  pStuffDataByClass = [:]
  pStuffDataByClass.sort()
  pWallitemDataByClass = [:]
  pWallitemDataByClass.sort()
  pMemberName = getUniqueID()
  pDownloadRetryCount = 1
  if variableExists("furnidata.load.url") then
    tURL = getVariable("furnidata.load.url")
    tHash = getSpecialServices().getSessionHash()
    if tHash = "" then
      tHash = string(random(1000000))
    end if
    tURL = replaceChunks(tURL, "%hash%", tHash)
    me.initDownload(tURL)
  end if
end

on deconstruct me 
  pStuffData = [:]
  pWallitemData = [:]
end

on getProps me, ttype, tID 
  if ttype = "s" then
    return(pStuffData.getaProp(tID))
  else
    if ttype <> "i" then
      if ttype = "e" then
        return(pWallitemData.getaProp(tID))
      else
        error(me, "invalid item type", #getProps, #minor)
      end if
    end if
  end if
end

on getPropsByClass me, ttype, tClass 
  if ttype = "s" then
    return(pStuffDataByClass.getaProp(tClass))
  else
    if ttype <> "i" then
      if ttype = "e" then
        return(pWallitemDataByClass.getaProp(tClass))
      else
        error(me, "invalid item type", #getProps, #minor)
      end if
    end if
  end if
end

on initDownload me, tSourceURL 
  if not createMember(pMemberName, #field) then
    return(error(me, "Could not create member!", #initDownload))
  end if
  tMemNum = queueDownload(tSourceURL, pMemberName, #field, 1)
  registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tMemNum)
end

on downloadCallback me, tParams, tSuccess 
  if tSuccess then
    tTime = the milliSeconds
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member:tmember, #start:1, #count:1]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
    executeMessage(#furnidataReceived)
  else
    fatalError(["error":"furnidata"])
    return(error(me, "Failure while loading furnidata", #downloadCallback, #critical))
  end if
end

on parseCallback me, tArgument 
  tmember = tArgument.getAt(#member)
  tStartingLine = tArgument.getAt(#start)
  tLineCount = tArgument.getAt(#count)
  if tmember > text.count(#line) then
    tLineCount = text.count(#line) - tStartingLine
  end if
  l = tStartingLine
  repeat while l <= tStartingLine + tLineCount
    tVal = value(text.getProp(#line, l))
    if ilk(tVal) = #list then
      repeat while tStartingLine + tLineCount <= undefined
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
        getThread("dynamicdownloader").getComponent().setFurniRevision(tdata.getAt(#class), tdata.getAt(#revision), tdata.getAt(#type) = "s")
        if tdata.getAt(#type) = "s" then
          pStuffData.setaProp(tdata.getAt(#classID), tdata)
          pStuffDataByClass.setaProp(tItem.getAt(3), tdata)
        else
          pWallitemData.setaProp(tdata.getAt(#classID), tdata)
          pWallitemDataByClass.setaProp(tItem.getAt(3), tdata)
        end if
      end repeat
    end if
    l = 1 + l
  end repeat
  tNewArgument = [#member:tmember, #start:tStartingLine + tLineCount, #count:tLineCount]
  if tmember >= text.count(#line) then
    getThread("dynamicdownloader").getComponent().setFurniRevision(void())
    sendProcessTracking(25)
  else
    createTimeout(getUniqueID(), 250, #parseCallback, me.getID(), tNewArgument, 1)
  end if
end
