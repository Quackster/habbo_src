property pGroupId, pStatus, pLoadedSoFar, pCastList, pCastcount, pCallBack, pCurrPercent, pTempPercent, pLastPercent, pTmpLoadCount, pCurLoadCount

on define me, tdata
  pGroupId = tdata[#id]
  pStatus = tdata[#status]
  pLoadedSoFar = tdata[#sofar]
  pCastcount = tdata[#casts].count
  pCallBack = tdata[#callback]
  pCurrPercent = tdata[#Percent]
  pTempPercent = 0
  pLastPercent = 0
  pCurLoadCount = 0
  pTmpLoadCount = 0
  pCastList = [:]
  repeat with tCast in tdata[#casts]
    pCastList[tCast] = 0
  end repeat
  return 1
end

on OneCastDone me, tFile
  pLoadedSoFar = pLoadedSoFar + 1.0
  if integer(pLoadedSoFar) = pCastcount then
    pStatus = #ready
  end if
  pCastList[tFile] = 1
  repeat while 1
    if count(pCastList) = 0 then
      exit repeat
    end if
    if pCastList[1] = 1 then
      tCastName = pCastList.getPropAt(1)
      if getCastLoadManager().exists(tCastName) then
        getThreadManager().initThread(castLib(tCastName).number)
      end if
      pCastList.deleteProp(tCastName)
      next repeat
    end if
    exit repeat
  end repeat
  return 1
end

on changeLoadingCount me, tPosOrNeg
  pCurLoadCount = pCurLoadCount + tPosOrNeg
end

on resetPercentCounter me
  pTempPercent = 0
  pTmpLoadCount = 0
  return 1
end

on UpdateTaskPercent me, tInstancePercent, tFile
  pTmpLoadCount = pTmpLoadCount + 1
  pTempPercent = pTempPercent + tInstancePercent
  if pTmpLoadCount = pCurLoadCount then
    tTemp = 1.0 * (pTempPercent + pLoadedSoFar) / pCastcount
    if (tTemp <= 1.0) and (pLastPercent <= tTemp) then
      pCurrPercent = tTemp
    else
      pCurrPercent = pLastPercent
    end if
  end if
end

on getTaskState me
  return pStatus
end

on getTaskPercent me
  return pCurrPercent
end

on DoCallBack me
  if pStatus = #ready then
    if listp(pCallBack) then
      repeat with tCall in pCallBack
        if objectExists(tCall[#client]) then
          call(tCall[#method], getObject(tCall[#client]), tCall[#argument])
        end if
      end repeat
    end if
  end if
end

on addCallBack me, tid, tMethod, tClientID, tArgument
  if not symbolp(tMethod) then
    return error(me, "Symbol referring to handler expected:" && tMethod, #addCallBack)
  end if
  if not objectExists(tClientID) then
    return error(me, "Object not found:" && tClientID, #addCallBack)
  end if
  if not getObject(tClientID).handler(tMethod) then
    return error(me, "Handler not found in object:" && tMethod & "/" & tClientID, #addCallBack)
  end if
  if pStatus = #ready then
    call(tMethod, getObject(tClientID), tArgument)
    getCastLoadManager().removeCastLoadTask(pGroupId)
  else
    if pStatus = #LOADING then
      if voidp(pCallBack) then
        pCallBack = list([#method: tMethod, #client: tClientID, #argument: tArgument])
      else
        pCallBack.add([#method: tMethod, #client: tClientID, #argument: tArgument])
      end if
    end if
  end if
  return 1
end
