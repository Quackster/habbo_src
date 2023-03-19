property pData, pMemberName, pDataLoaded

on construct me
  pDataLoaded = 0
  pData = [:]
  pData.sort()
  pMemberName = getUniqueID()
  if variableExists("productdata.load.url") then
    tURL = getVariable("productdata.load.url")
    tHash = getSpecialServices().getSessionHash()
    if tHash = EMPTY then
      tHash = string(random(1000000))
    end if
    tURL = replaceChunks(tURL, "%hash%", tHash)
    me.initDownload(tURL)
  end if
end

on deconstruct me
  pData = [:]
end

on getProps me, tProductCode
  return pData.getaProp(tProductCode)
end

on getIsDataDownloaded me
  return pDataLoaded
end

on initDownload me, tSourceURL
  if not createMember(pMemberName, #field) then
    return error(me, "Could not create member!", #initDownload)
  end if
  tMemNum = queueDownload(tSourceURL, pMemberName, #field, 1)
  registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tMemNum)
end

on downloadCallback me, tParams, tSuccess
  if tSuccess then
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member: tmember, #start: 1, #count: 2]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
    executeMessage(#productDataReceived)
  else
    fatalError(["error": "productdata"])
    return error(me, "Failure while loading productdata", #downloadCallback, #critical)
  end if
end

on parseCallback me, tArgument
  tmember = tArgument[#member]
  tStartingLine = tArgument[#start]
  tLineCount = tArgument[#count]
  if (tStartingLine + tLineCount) > tmember.text.line.count then
    tLineCount = tmember.text.line.count - tStartingLine
  end if
  repeat with l = tStartingLine to tStartingLine + tLineCount
    tVal = value(tmember.text.line[l])
    if ilk(tVal) = #list then
      repeat with tItem in tVal
        tdata = [:]
        tdata[#code] = tItem[1]
        tdata[#name] = decodeUTF8(tItem[2])
        tdata[#description] = decodeUTF8(tItem[3])
        tdata[#specialText] = decodeUTF8(tItem[4])
        pData.setaProp(tItem[1], tdata)
      end repeat
    end if
  end repeat
  tNewArgument = [#member: tmember, #start: tStartingLine + tLineCount, #count: tLineCount]
  if (tStartingLine + tLineCount) >= tmember.text.line.count then
    pDataLoaded = 1
  else
    createTimeout(getUniqueID(), 333, #parseCallback, me.getID(), tNewArgument, 1)
  end if
end
