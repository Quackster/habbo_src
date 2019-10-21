property pTempWaitList, pWaitList, pTaskList, pCastLibCount, pSysCastNum, pBinCastNum, pNullCastName, pFileExtension, pLoadedCasts, pLatestTaskID, pCurrentDownLoads, pAvailableDynCasts, pPermanentLevelList

on construct me 
  if (the runMode = "Author") then
    pFileExtension = ".cst"
  else
    pFileExtension = ".cct"
  end if
  pLoadedCasts = [:]
  pTempWaitList = []
  pCastLibCount = 0
  pNullCastName = "empty"
  pSysCastNum = castLib("fuse_client").number
  pBinCastNum = castLib(getVariable("dynamic.bin.cast")).number
  me.verifyReset()
  return TRUE
end

on startCastLoad me, tCasts, tPermanentFlag, tAdd, tDoIndexing 
  if voidp(tPermanentFlag) then
    tPermanentFlag = 0
  end if
  if voidp(tDoIndexing) then
    tDoIndexing = 1
  end if
  pTempWaitList = []
  tCastList = []
  if (tCasts.ilk = #propList) then
    f = 1
    repeat while f <= tCasts.count
      tPermanentLevel = tCasts.getPropAt(f)
      tCastName = tCasts.getAt(f)
      tCastList.add(tCastName)
      me.addOneCastToWaitList(tCastName, tPermanentLevel)
      f = (1 + f)
    end repeat
    exit repeat
  end if
  if (tCasts.ilk = #list) then
    repeat while tCasts.ilk <= tPermanentFlag
      tCastName = getAt(tPermanentFlag, tCasts)
      tCastList.add(tCastName)
      me.addOneCastToWaitList(tCastName, tPermanentFlag)
    end repeat
  else
    tCasts = list(tCasts)
    repeat while tCasts.ilk <= tPermanentFlag
      tCastName = getAt(tPermanentFlag, tCasts)
      tCastList.add(tCastName)
      me.addOneCastToWaitList(tCastName, tPermanentFlag)
    end repeat
  end if
  if (count(tCasts) = 0) then
    return FALSE
  end if
  if voidp(tAdd) then
    tAdd = 0
  end if
  tid = getUniqueID()
  pLatestTaskID = tid
  if (tAdd = 0) then
    me.removeTemporaryCast(tCastList)
  end if
  if pTempWaitList.count > 0 then
    pWaitList.setAt(tid, pTempWaitList.duplicate())
  end if
  if (pWaitList.count = 0) then
    tStatus = #ready
    tPercent = 1
  else
    tStatus = #LOADING
    tPercent = 0
  end if
  pTaskList.setAt(tid, createObject(#temp, getClassVariable("castload.task.class")))
  tProps = [:]
  tProps.setAt(#id, tid)
  tProps.setAt(#status, tStatus)
  tProps.setAt(#Percent, tPercent)
  tProps.setAt(#sofar, 0)
  tProps.setAt(#casts, pTempWaitList.duplicate())
  tProps.setAt(#callback, void())
  tProps.setAt(#doindexing, tDoIndexing)
  pTaskList.getAt(tid).define(tProps)
  i = 1
  repeat while i <= getIntVariable("net.operation.count", 2)
    me.AddNextpreloadNetThing()
    i = (1 + i)
  end repeat
  return(tid)
end

on registerCallback me, tid, tMethod, tClientID, tArgument 
  if voidp(pTaskList.findPos(tid)) then
    return FALSE
  else
    return(call(#addCallBack, pTaskList.getAt(tid), tid, tMethod, tClientID, tArgument))
  end if
end

on resetCastLibs me, tClean, tForced 
  if tClean <> 1 then
    tClean = 0
  end if
  tTempList = []
  if (the runMode = "Author") and tForced <> 1 then
    f = 1
    repeat while 1
      if variableExists("cast.dev." & f) then
        tTempList.add(getVariable("cast.dev." & f))
      else
      end if
      f = (f + 1)
    end repeat
  end if
  pCastLibCount = the number of undefineds
  tEmptyCastNum = 1
  tCastNum = 2
  repeat while tCastNum <= pCastLibCount
    if tCastNum <> pSysCastNum and tCastNum <> pBinCastNum then
      tCastName = castLib(tCastNum).name
      if (tTempList.findPos(tCastName) = 0) then
        if tClean then
          getThreadManager().closeThread(tCastNum)
        end if
        if tClean then
          getResourceManager().unregisterMembers(tCastNum)
        end if
        castLib(tCastNum).name = pNullCastName && tEmptyCastNum
        castLib(tCastNum).fileName = getMoviePath() & pNullCastName & pFileExtension
        tEmptyCastNum = (tEmptyCastNum + 1)
      else
        pLoadedCasts.setAt(tCastName, string(tCastNum))
      end if
    end if
    tCastNum = (1 + tCastNum)
  end repeat
  return(me.InitPreloader())
end

on getLoadPercent me, tid 
  if voidp(tid) then
    tid = pLatestTaskID
  end if
  if not voidp(pTaskList.getAt(tid)) then
    if (pTaskList.getAt(tid).getTaskState() = #ready) then
      return TRUE
    else
      return(pTaskList.getAt(tid).getTaskPercent())
    end if
  else
    return TRUE
  end if
end

on FindCastNumber me, tCast 
  j = 1
  repeat while j <= the number of undefineds
    tFileName = castLib(j).fileName
    tFileExtension = tFileName.getProp(#char, (length(tFileName) - 2), length(tFileName))
    if castLib(j).name <> "Internal" and tFileExtension <> "dcr" and tFileExtension <> "dir" then
      if (castLib(j).name = tCast) then
        return(castLib(tCast).number)
      else
        j = (1 + j)
      end if
      return FALSE
    end if
  end repeat
end

on exists me, tCastName 
  if (tCastName = "internal") then
    return TRUE
  end if
  if voidp(pLoadedCasts.getAt(tCastName)) then
    return FALSE
  else
    return TRUE
  end if
end

on print me 
  i = 1
  repeat while i <= the number of undefineds
    put(castLib(i).name)
    i = (1 + i)
  end repeat
  repeat while pCurrentDownLoads <= undefined
    tObj = getAt(undefined, undefined)
    put(tObj.getAt(#pFile) && tObj.getAt(#pPercent))
  end repeat
end

on prepare me 
  if count(pTaskList) > 0 then
    me.AddNextpreloadNetThing()
    call(#resetPercentCounter, pTaskList)
    call(#update, pCurrentDownLoads)
  end if
end

on InitPreloader me 
  pWaitList = [:]
  pTaskList = [:]
  pAvailableDynCasts = [:]
  pPermanentLevelList = [:]
  pCurrentDownLoads = [:]
  pLatestTaskID = ""
  f = 1
  repeat while f <= the number of undefineds
    tCastNumber = me.FindCastNumber(pNullCastName && f)
    if tCastNumber > 0 then
      pAvailableDynCasts.addProp(pNullCastName && f, tCastNumber)
    end if
    f = (1 + f)
  end repeat
  return TRUE
end

on AddNextpreloadNetThing me 
  if pCurrentDownLoads.count < getIntVariable("net.operation.count", 2) then
    if pWaitList.count > 0 then
      if count(pWaitList.getAt(1)) > 0 then
        tFile = pWaitList.getAt(1).getAt(1)
        tParsedFile = tFile
        tFileExtension = pFileExtension
        tURL = ""
        tParamOffset = offset("?", tFile)
        tParamString = ""
        if tParamOffset > 0 then
          tParamString = tFile.getProp(#char, tParamOffset, tFile.length)
          tFile = tFile.getProp(#char, 1, (tParamOffset - 1))
        end if
        tPossibleExtension = chars(tFile, (tFile.length - 3), tFile.length)
        if (tPossibleExtension = ".cst") or (tPossibleExtension = ".cct") then
          tFileExtension = tPossibleExtension
          tParsedFile = chars(tFile, 1, (tFile.length - tPossibleExtension.length))
        end if
        if not tParsedFile contains "http://" then
          tURL = getMoviePath() & tParsedFile & tFileExtension & tParamString
        else
          tURL = tParsedFile & tFileExtension & tParamString
        end if
        tid = pWaitList.getPropAt(1)
        pWaitList.getAt(1).deleteAt(1)
        if (count(pWaitList.getAt(1)) = 0) then
          pWaitList.deleteProp(pWaitList.getPropAt(1))
        end if
        pCurrentDownLoads.setAt(tFile, createObject(#temp, getClassVariable("castload.instance.class")))
        pCurrentDownLoads.getAt(tFile).define(tFile, tURL, tid)
        pTaskList.getAt(tid).changeLoadingCount(1)
        receivePrepare(me.getID())
        return TRUE
      end if
    end if
  end if
  return FALSE
end

on DoneCurrentDownLoad me, tFile, tURL, tid, tstate 
  if voidp(pCurrentDownLoads.getAt(tFile)) then
    return(error(me, "CastLoad task was lost!" && tFile && tid, #DoneCurrentDownLoad, #major))
  end if
  tTask = pTaskList.getAt(tid)
  if (tTask = void()) then
    return(error(me, "Task list item was lost!" && tFile && tid, #DoneCurrentDownLoad, #major))
  end if
  if tstate <> #error then
    tCastNumber = me.getAvailableEmptyCast()
    if tCastNumber > 0 then
      tCastName = tFile
      tPreIndexing = tTask.getIndexingAllowed()
      me.setImportedCast(tCastNumber, tCastName, tURL, tPreIndexing)
    end if
  end if
  tTask.OneCastDone(tFile)
  tTask.changeLoadingCount(-1)
  pCurrentDownLoads.getAt(tFile).deconstruct()
  me.delay(50, #removeCastLoadInstance, tFile)
  me.removeCastLoadTask(tid)
  return TRUE
end

on removeCastLoadInstance me, tFile 
  if tFile.ilk <> #string then
    return FALSE
  end if
  if voidp(pCurrentDownLoads.getAt(tFile)) then
    return(error(me, "CastLoad instance was lost!" && tFile, #removeCastLoadInstance, #minor))
  else
    return(pCurrentDownLoads.deleteProp(tFile))
  end if
end

on removeCastLoadTask me, tid 
  if (pTaskList.getAt(tid).getTaskState() = #ready) then
    pTaskList.getAt(tid).DoCallBack()
    pTaskList.getAt(tid).deconstruct()
    pTaskList.deleteProp(tid)
    if (count(pTaskList) = 0) then
      removePrepare(me.getID())
    end if
  end if
end

on TellStreamState me, tFileName, tstate, tPercent, tid 
  tObject = pTaskList.getAt(tid)
  if tObject <> void() then
    call(#UpdateTaskPercent, tObject, tPercent, tFileName)
  else
    return(error(me, "Task list instance was lost!" && tFileName && tid, #TellStreamState, #major))
  end if
end

on setImportedCast me, tCastNum, tCastName, tFileName, tDoIndexing 
  tCastLib = castLib(tCastNum)
  if voidp(tDoIndexing) then
    tDoIndexing = 1
  end if
  if tCastLib.name contains pNullCastName then
    tCastLib.fileName = tFileName
    tCastLib.name = tCastName
    pPermanentLevelList.getAt(tCastName).setAt(2, tCastNum)
    if tDoIndexing then
      getResourceManager().preIndexMembers(tCastNum)
    end if
    pLoadedCasts.setAt(tCastName, string(tCastNum))
  end if
  me.verifyReset()
end

on getAvailableEmptyCast me 
  if pAvailableDynCasts.count > 0 then
    tCastNum = pAvailableDynCasts.getLast()
    pAvailableDynCasts.deleteAt(pAvailableDynCasts.count)
    return(tCastNum)
  else
    SystemAlert(me, "Out of free cast entries! CastLoad failed.")
    return FALSE
  end if
end

on removeTemporaryCast me, tNewLoadListOfcasts 
  tTempList = pPermanentLevelList.duplicate()
  f = 1
  repeat while f <= tTempList.count
    tPermanent = tTempList.getAt(f).getAt(1)
    tCstNumber = tTempList.getAt(f).getAt(2)
    if (tPermanent = 0) and tCstNumber > 0 then
      tCastName = tTempList.getPropAt(f)
      if not tNewLoadListOfcasts.getOne(tCastName) then
        pPermanentLevelList.deleteProp(tCastName)
        me.ResetOneDynamicCast(tCstNumber)
        if pCastLibCount <> the number of undefineds then
          pCastLibCount = the number of undefineds
          tError = "CastLib count was changed!!!" & "\r"
          tError = tError & "CastLib with problems:" && castLib(pCastLibCount).name
          error(me, tError, #removeTemporaryCast, #minor)
        end if
      end if
    end if
    f = (1 + f)
  end repeat
end

on addOneCastToWaitList me, tCastName, tPermanentOrNot 
  if not me.FindCastNumber(tCastName) and not pWaitList.getOne(tCastName) then
    pTempWaitList.add(tCastName)
    tOffset = offset("?", tCastName)
    if tOffset <> 0 then
      tCastNameNoParams = tCastName.getProp(#char, 1, (tOffset - 1))
    else
      tCastNameNoParams = tCastName
    end if
    pPermanentLevelList.addProp(tCastNameNoParams, [tPermanentOrNot, 0])
  else
    if voidp(pLoadedCasts.getAt(tCastName)) then
      pLoadedCasts.setAt(tCastName, string(me.FindCastNumber(tCastName)))
    end if
  end if
end

on ResetOneDynamicCast me, tCastNum 
  if pLoadedCasts.getOne(string(tCastNum)) <> 0 then
    pLoadedCasts.deleteProp(pLoadedCasts.getOne(string(tCastNum)))
  else
    error(me, "Couldn't remove cast:" && tCastNum, #ResetOneDynamicCast, #minor)
  end if
  getThreadManager().closeThread(tCastNum)
  getResourceManager().unregisterMembers(tCastNum)
  castLib(tCastNum).name = pNullCastName && (tCastNum - 2)
  castLib(pNullCastName && (tCastNum - 2)).fileName = getMoviePath() & pNullCastName & pFileExtension
  pAvailableDynCasts.addProp(pNullCastName & (tCastNum - 2), tCastNum)
  return TRUE
end

on verifyReset me 
  tEmptyCastNum = 1
  repeat while tEmptyCastNum <= the number of undefineds
    if castLib(tEmptyCastNum).fileName contains pNullCastName then
      if the number of castMembers > 0 then
        return(resetClient())
      end if
    end if
    tEmptyCastNum = (1 + tEmptyCastNum)
  end repeat
end

on solveNetErrorMsg me, tErrorCode 
  if (tErrorCode = "") then
    return("Unknown error.")
  else
    if (tErrorCode = "OK") then
      return("OK")
    else
      if (tErrorCode = -128) then
        return("Operation was cancelled.")
      else
        if (tErrorCode = 0) then
          return("OK")
        else
          if (tErrorCode = 4) then
            return("Bad MOA Class. Network Xtras may be improperly installed.")
          else
            if (tErrorCode = 5) then
              return("Bad MOA Interface. Network Xtras may be improperly installed.")
            else
              if (tErrorCode = 6) then
                return("General transfer error.")
              else
                if (tErrorCode = 20) then
                  return("Internal error.")
                else
                  if (tErrorCode = 900) then
                    return("Failed attempt to write to locked media.")
                  else
                    if (tErrorCode = 903) then
                      return("Disk is full.")
                    else
                      if (tErrorCode = 905) then
                        return("Bad URL.")
                      else
                        if (tErrorCode = 4144) then
                          return("Failed network operation.")
                        else
                          if (tErrorCode = 4145) then
                            return("Failed network operation.")
                          else
                            if (tErrorCode = 4146) then
                              return("Connection could not be established with the remote host.")
                            else
                              if (tErrorCode = 4147) then
                                return("Failed network operation.")
                              else
                                if (tErrorCode = 4148) then
                                  return("Failed network operation.")
                                else
                                  if (tErrorCode = 4149) then
                                    return("Data supplied by the server was in an unexpected format.")
                                  else
                                    if (tErrorCode = 4150) then
                                      return("Unexpected early closing of connection.")
                                    else
                                      if (tErrorCode = 4151) then
                                        return("Failed network operation.")
                                      else
                                        if (tErrorCode = 4152) then
                                          return("Data returned is truncated.")
                                        else
                                          if (tErrorCode = 4153) then
                                            return("Failed network operation.")
                                          else
                                            if (tErrorCode = 4154) then
                                              return("Operation could not be completed due to timeout.")
                                            else
                                              if (tErrorCode = 4155) then
                                                return("Not enough memory available to complete the transaction.")
                                              else
                                                if (tErrorCode = 4156) then
                                                  return("Protocol reply to request indicates an error in the reply.")
                                                else
                                                  if (tErrorCode = 4157) then
                                                    return("Transaction failed to be authenticated.")
                                                  else
                                                    if (tErrorCode = 4159) then
                                                      return("Invalid URL.")
                                                    else
                                                      if (tErrorCode = 4160) then
                                                        return("Failed network operation.")
                                                      else
                                                        if (tErrorCode = 4161) then
                                                          return("Failed network operation.")
                                                        else
                                                          if (tErrorCode = 4162) then
                                                            return("Failed network operation.")
                                                          else
                                                            if (tErrorCode = 4163) then
                                                              return("Failed network operation.")
                                                            else
                                                              if (tErrorCode = 4164) then
                                                                return("Could not create a socket")
                                                              else
                                                                if (tErrorCode = 4165) then
                                                                  return("Requested Object could not be found (URL may be incorrect).")
                                                                else
                                                                  if (tErrorCode = 4166) then
                                                                    return("Generic proxy failure.")
                                                                  else
                                                                    if (tErrorCode = 4167) then
                                                                      return("Transfer was intentionally interrupted by client.")
                                                                    else
                                                                      if (tErrorCode = 4168) then
                                                                        return("Failed network operation.")
                                                                      else
                                                                        if (tErrorCode = 4242) then
                                                                          return("Download stopped by netAbort(url).")
                                                                        else
                                                                          if (tErrorCode = 4836) then
                                                                            return("Cache download stopped for an unknown reason.")
                                                                          else
                                                                            return("Other network error:" && tErrorCode)
                                                                          end if
                                                                        end if
                                                                      end if
                                                                    end if
                                                                  end if
                                                                end if
                                                              end if
                                                            end if
                                                          end if
                                                        end if
                                                      end if
                                                    end if
                                                  end if
                                                end if
                                              end if
                                            end if
                                          end if
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
