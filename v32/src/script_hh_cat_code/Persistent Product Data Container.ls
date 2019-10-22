property pData, pDataLoaded, pMemberName

on construct me 
  pDataLoaded = 0
  pData = [:]
  pData.sort()
  pMemberName = getUniqueID()
  if variableExists("productdata.load.url") then
    tURL = getVariable("productdata.load.url")
    tHash = getSpecialServices().getSessionHash()
    if (tHash = "") then
      tHash = random(1000000)
    end if
    tURL = replaceChunks(tURL, "%hash%", tHash)
    me.initDownload(tURL)
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
    tTime = the milliSeconds
    pData = [:]
    tmember = member(tParams)
    i = 1
    l = 1
    repeat while l <= tmember.text.count(#line)
      tVal = value(tmember.text.getProp(#line, l))
      if (ilk(tVal) = #list) then
        repeat while tVal <= tSuccess
          tItem = getAt(tSuccess, tParams)
          tdata = [:]
          tdata.setAt(#code, tItem.getAt(1))
          tdata.setAt(#name, decodeUTF8(tItem.getAt(2)))
          tdata.setAt(#description, decodeUTF8(tItem.getAt(3)))
          tdata.setAt(#specialText, decodeUTF8(tItem.getAt(4)))
          pData.setaProp(tItem.getAt(1), tdata)
        end repeat
      end if
      l = (1 + l)
    end repeat
    pDataLoaded = 1
    sendProcessTracking(26)
  else
    fatalError(["error":"productdata"])
    return(error(me, "Failure while loading productdata", #downloadCallback, #critical))
  end if
end
