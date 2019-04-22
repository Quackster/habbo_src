property pCastList, pLoadedSoFar, pCastcount, pCurLoadCount, pTmpLoadCount, pTempPercent, pLastPercent, pStatus, pCurrPercent, pAllowindexing, pCallBack, pGroupId

on define me, tdata 
  pGroupId = tdata.getAt(#id)
  pStatus = tdata.getAt(#status)
  pLoadedSoFar = tdata.getAt(#sofar)
  pCastcount = tdata.getAt(#casts).count
  pCallBack = tdata.getAt(#callback)
  pCurrPercent = tdata.getAt(#Percent)
  pAllowindexing = tdata.getAt(#doindexing)
  pTempPercent = 0
  pLastPercent = 0
  pCurLoadCount = 0
  pTmpLoadCount = 0
  pCastList = [:]
  repeat while tdata.getAt(#casts) <= undefined
    tCast = getAt(undefined, tdata)
    pCastList.setAt(tCast, 0)
  end repeat
  return(1)
end

on OneCastDone me, tFile 
  pLoadedSoFar = pLoadedSoFar + 1
  if integer(pLoadedSoFar) = pCastcount then
    pStatus = #ready
  end if
  pCastList.setAt(tFile, 1)
  repeat while 1
    if count(pCastList) = 0 then
    else
      if pCastList.getAt(1) = 1 then
        tCastName = pCastList.getPropAt(1)
        if getCastLoadManager().exists(tCastName) then
          getThreadManager().initThread(castLib(tCastName).number)
        end if
        pCastList.deleteProp(tCastName)
        next repeat
      end if
    end if
  end repeat
  return(1)
end

on changeLoadingCount me, tPosOrNeg 
  pCurLoadCount = pCurLoadCount + tPosOrNeg
end

on resetPercentCounter me 
  pTempPercent = 0
  pTmpLoadCount = 0
  return(1)
end

on UpdateTaskPercent me, tInstancePercent, tFile 
  pTmpLoadCount = pTmpLoadCount + 1
  pTempPercent = pTempPercent + tInstancePercent
  if pTmpLoadCount = pCurLoadCount then
    tTemp = 1 * pTempPercent + pLoadedSoFar / pCastcount
    if tTemp <= 1 and pLastPercent <= tTemp then
      pCurrPercent = tTemp
    else
      pCurrPercent = pLastPercent
    end if
  end if
end

on getTaskState me 
  return(pStatus)
end

on getTaskPercent me 
  return(pCurrPercent)
end

on getIndexingAllowed me 
  return(pAllowindexing)
end

on DoCallBack me 
  if pStatus = #ready then
    if listp(pCallBack) then
      repeat while pCallBack <= undefined
        tCall = getAt(undefined, undefined)
        if objectExists(tCall.getAt(#client)) then
          call(tCall.getAt(#method), getObject(tCall.getAt(#client)), tCall.getAt(#argument))
        end if
      end repeat
    end if
  end if
end

on addCallBack me, tID, tMethod, tClientID, tArgument 
  if not symbolp(tMethod) then
    return(error(me, "Symbol referring to handler expected:" && tMethod, #addCallBack, #major))
  end if
  if not objectExists(tClientID) then
    return(error(me, "Object not found:" && tClientID, #addCallBack, #major))
  end if
  if not getObject(tClientID).handler(tMethod) then
    return(error(me, "Handler not found in object:" && tMethod & "/" & tClientID, #addCallBack, #major))
  end if
  if pStatus = #ready then
    call(tMethod, getObject(tClientID), tArgument)
    getCastLoadManager().removeCastLoadTask(pGroupId)
  else
    if pStatus = #LOADING then
      if voidp(pCallBack) then
        pCallBack = list([#method:tMethod, #client:tClientID, #argument:tArgument])
      else
        pCallBack.add([#method:tMethod, #client:tClientID, #argument:tArgument])
      end if
    end if
  end if
  return(1)
end
