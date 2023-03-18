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
    tTime = the milliSeconds
    pData = [:]
    tmember = member(tParams)
    i = 1
    repeat with l = 1 to tmember.text.line.count
      tVal = value(tmember.text.line[l])
      if ilk(tVal) = #list then
        repeat with tItem in tVal
          tdata = [:]
          tdata[#code] = tItem[1]
          tdata[#name] = tItem[2]
          tdata[#description] = tItem[3]
          tdata[#specialText] = tItem[4]
          pData.setaProp(tItem[1], tdata)
        end repeat
      end if
    end repeat
    pDataLoaded = 1
  end if
end
