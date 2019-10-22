property pData, pDataLoaded, pMemberName, pDownloadedData

on construct me 
  pDownloadedData = []
  pDataLoaded = 0
  pData = [:]
  pData.sort()
  pMemberName = getUniqueID()
  if variableExists("productdata.load.url") then
    tURL = getVariable("productdata.load.url")
    tHash = getSpecialServices().getSessionHash()
    if (tHash = "") then
      tHash = string(random(1000000))
    end if
    tURL = replaceChunks(tURL, "%hash%", tHash)
    me.initDownload(tURL)
  else
    fatalError(["error":"productdata_config"])
  end if
end

on deconstruct me 
  pData = [:]
end

on getProps me, tProductCode 
  return(pData.getaProp(tProductCode))
end

on getIsDataDownloaded me 
  return(pDataLoaded)
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
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member:tmember, #start:1, #count:2]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
  else
    fatalError(["error":"productdata"])
    return(error(me, "Failure while loading productdata", #downloadCallback, #critical))
  end if
end

on parseCallback me, tArgument 
  tmember = tArgument.getAt(#member)
  tStartingLine = tArgument.getAt(#start)
  tLineCount = tArgument.getAt(#count)
  if ilk(tmember) <> #member then
    fatalError(["error":"productdata_member"])
    return(error(me, "Failure with productdata member", #parseCallback, #critical))
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
        tdata.setAt(#code, tItem.getAt(1))
        tdata.setAt(#name, decodeUTF8(tItem.getAt(2)))
        tdata.setAt(#description, decodeUTF8(tItem.getAt(3)))
        tdata.setAt(#specialText, decodeUTF8(tItem.getAt(4)))
        pData.setaProp(tItem.getAt(1), tdata)
      end repeat
    else
      if (l = pDownloadedData.count) and pDownloadedData.count > 1 and (pDownloadedData.getAt(l) = "") then
        nothing()
      else
        gLogVarUrl = string(pDownloadedData)
        fatalError(["error":"productdata_malformed"])
        return(error(me, "Failure while parsing productdata", #parseOneLine, #critical))
      end if
    end if
    l = (1 + l)
  end repeat
  if (tStartingLine + tLineCount) >= pDownloadedData.count then
    pDataLoaded = 1
  else
    tNewArgument = [#start:(tStartingLine + tLineCount), #count:tLineCount]
    createTimeout(getUniqueID(), 250, #parseOneLine, me.getID(), tNewArgument, 1)
  end if
end
