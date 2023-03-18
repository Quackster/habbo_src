property pStuffData, pWallitemData, pStuffDataByClass, pWallitemDataByClass, pMemberName, pRetryDownloadCount, pDownloadedData, pDownloadRetriesLeft

on construct me
  pDownloadRetriesLeft = 1
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
    fatalError(["error": "furnidata_config"])
  end if
end

on deconstruct me
  pStuffData = [:]
  pWallitemData = [:]
end

on getProps me, ttype, tID
  case ttype of
    "s":
      return pStuffData.getaProp(tID)
    "i", "e":
      return pWallitemData.getaProp(tID)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
end

on getPropsByClass me, ttype, tClass
  case ttype of
    "s":
      return pStuffDataByClass.getaProp(tClass)
    "i", "e":
      return pWallitemDataByClass.getaProp(tClass)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
end

on initDownload me
  tURL = getVariable("furnidata.load.url")
  pMemberName = tURL & "-" & pDownloadRetriesLeft
  tHash = getSpecialServices().getSessionHash()
  if tHash = EMPTY then
    tHash = string(random(1000000))
  end if
  tURL = replaceChunks(tURL, "%hash%", tHash)
  if not createMember(pMemberName, #field) then
    return error(me, "Could not create member!", #initDownload, #critical)
  end if
  tMemNum = queueDownload(tURL, pMemberName, #field, 1)
  registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tMemNum)
end

on downloadCallback me, tParams, tSuccess
  if tSuccess then
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member: tmember, #start: 1, #count: 1]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
  else
    fatalError(["error": "furnidata"])
    return error(me, "Failure while loading furnidata", #downloadCallback, #critical)
  end if
end

on parseCallback me, tArgument
  pDownloadedData = []
  tmember = tArgument[#member]
  if ilk(tmember) <> #member then
    fatalError(["error": "furnidata_member"])
    return error(me, "Failure with furnidata member", #parseCallback, #critical)
  end if
  repeat with tLineNo = 1 to tmember.text.line.count
    tLineTxt = tmember.text.line[tLineNo]
    pDownloadedData[tLineNo] = tLineTxt
  end repeat
  me.parseOneLine(tArgument)
end

on parseOneLine me, tArgument
  global gLogVarUrl
  tStartingLine = tArgument[#start]
  tLineCount = tArgument[#count]
  if (tStartingLine + tLineCount) > pDownloadedData.count then
    tLineCount = pDownloadedData.count - tStartingLine
  end if
  repeat with l = tStartingLine to tStartingLine + tLineCount
    tVal = value(pDownloadedData[l])
    if ilk(tVal) = #list then
      repeat with tItem in tVal
        tdata = [:]
        tdata[#type] = tItem[1]
        tdata[#classID] = value(tItem[2])
        tdata[#class] = tItem[3]
        tdata[#revision] = value(tItem[4])
        tdata[#defaultDir] = value(tItem[5])
        tdata[#xdim] = value(tItem[6])
        tdata[#ydim] = value(tItem[7])
        tdata[#partColors] = tItem[8]
        tdata[#localizedName] = decodeUTF8(tItem[9])
        tdata[#localizedDesc] = decodeUTF8(tItem[10])
        getThread("dynamicdownloader").getComponent().setFurniRevision(tdata[#class], tdata[#revision], tdata[#type] = "s")
        if tdata[#type] = "s" then
          pStuffData.setaProp(tdata[#classID], tdata)
          pStuffDataByClass.setaProp(tItem[3], tdata)
          next repeat
        end if
        pWallitemData.setaProp(tdata[#classID], tdata)
        pWallitemDataByClass.setaProp(tItem[3], tdata)
      end repeat
      next repeat
    end if
    if (l = pDownloadedData.count) and (pDownloadedData.count > 1) and (pDownloadedData[l] = EMPTY) then
      nothing()
      next repeat
    end if
    if pDownloadRetriesLeft > 0 then
      pDownloadRetriesLeft = pDownloadRetriesLeft - 1
      me.initDownload()
      return 0
      next repeat
    end if
    gLogVarUrl = string(pDownloadedData)
    fatalError(["error": "furnidata_malformed"])
    return error(me, "Failure while parsing furnitdata", #parseOneLine, #critical)
  end repeat
  if (tStartingLine + tLineCount) >= pDownloadedData.count then
    getThread("dynamicdownloader").getComponent().setFurniRevision(VOID)
    sendProcessTracking(25)
    executeMessage(#furnidataReceived)
  else
    tNewArgument = [#start: tStartingLine + tLineCount, #count: tLineCount]
    createTimeout(getUniqueID(), 250, #parseOneLine, me.getID(), tNewArgument, 1)
  end if
end
