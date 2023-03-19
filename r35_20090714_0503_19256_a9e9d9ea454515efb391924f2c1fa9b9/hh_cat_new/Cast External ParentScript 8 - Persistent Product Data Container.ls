property pData, pMemberName, pDataLoaded, pDownloadedData

on construct me
  pDownloadedData = []
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
  else
    fatalError(["error": "productdata_config"])
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
  else
    fatalError(["error": "productdata"])
    return error(me, "Failure while loading productdata", #downloadCallback, #critical)
  end if
end

on parseCallback me, tArgument
  tmember = tArgument[#member]
  tStartingLine = tArgument[#start]
  tLineCount = tArgument[#count]
  if ilk(tmember) <> #member then
    fatalError(["error": "productdata_member"])
    return error(me, "Failure with productdata member", #parseCallback, #critical)
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
        tdata[#code] = tItem[1]
        tdata[#name] = decodeUTF8(tItem[2])
        tdata[#description] = decodeUTF8(tItem[3])
        tdata[#specialText] = decodeUTF8(tItem[4])
        pData.setaProp(tItem[1], tdata)
      end repeat
      next repeat
    end if
    if (l = pDownloadedData.count) and (pDownloadedData.count > 1) and (pDownloadedData[l] = EMPTY) then
      nothing()
      next repeat
    end if
    gLogVarUrl = string(pDownloadedData)
    fatalError(["error": "productdata_malformed"])
    return error(me, "Failure while parsing productdata", #parseOneLine, #critical)
  end repeat
  if (tStartingLine + tLineCount) >= pDownloadedData.count then
    pDataLoaded = 1
  else
    tNewArgument = [#start: tStartingLine + tLineCount, #count: tLineCount]
    createTimeout(getUniqueID(), 250, #parseOneLine, me.getID(), tNewArgument, 1)
  end if
end
