property pStuffData, pWallitemData, pStuffDataByClass, pWallitemDataByClass, pMemberName, pRetryDownloadCount

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
    if tHash = EMPTY then
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
  case ttype of
    "s":
      return pStuffData.getaProp(tID)
    "i":
      return pWallitemData.getaProp(tID)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
end

on getPropsByClass me, ttype, tClass
  case ttype of
    "s":
      return pStuffDataByClass.getaProp(tClass)
    "i":
      return pWallitemDataByClass.getaProp(tClass)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
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
      end if
    end repeat
    getThread("dynamicdownloader").getComponent().setFurniRevision(VOID)
    sendProcessTracking(25)
  else
    fatalError(["error": "furnidata"])
    return error(me, "Failure while loading furnidata", #downloadCallback, #critical)
  end if
end
