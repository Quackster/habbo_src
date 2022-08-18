property pWaitList, pTaskList, pAvailableDynCasts, pPermanentLevelList, pLatestTaskID, pCurrentDownLoads, pLoadedCasts, pTempWaitList, pCastLibCount, pSysCastNum, pBinCastNum, pNullCastName, pFileExtension, pLastError

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
  pLastError = 0
  me.verifyReset()
  return 1
end

on startCastLoad me, tCasts, tPermanentFlag, tAdd, tDoIndexing, tDoTracking
  if voidp(tPermanentFlag) then
    tPermanentFlag = 0
  end if
  if voidp(tAdd) then
    tAdd = 0
  end if
  if voidp(tDoIndexing) then
    tDoIndexing = 1
  end if
  if voidp(tDoTracking) then
    tDoTracking = 0
  end if
  pLastError = 0
  if tDoTracking then
    tCastsStr = (EMPTY & tCasts)
    tCastsStr = replaceChunks(tCastsStr, QUOTE, EMPTY)
    tCastsStr = replaceChunks(tCastsStr, " ", EMPTY)
    tCastsStr = replaceChunks(tCastsStr, "[", EMPTY)
    tCastsStr = replaceChunks(tCastsStr, "]", EMPTY)
    tCastsStr = replaceChunks(tCastsStr, RETURN, EMPTY)
  end if
  pTempWaitList = []
  tCastList = []
  case tCasts.ilk of
    #propList:
      repeat with f = 1 to tCasts.count
        tPermanentLevel = tCasts.getPropAt(f)
        tCastName = tCasts[f]
        tCastList.add(tCastName)
        me.addOneCastToWaitList(tCastName, tPermanentLevel)
      end repeat
    #list:
      repeat with tCastName in tCasts
        tCastList.add(tCastName)
        me.addOneCastToWaitList(tCastName, tPermanentFlag)
      end repeat
    otherwise:
      tCasts = list(tCasts)
      repeat with tCastName in tCasts
        tCastList.add(tCastName)
        me.addOneCastToWaitList(tCastName, tPermanentFlag)
      end repeat
  end case
  if (count(tCasts) = 0) then
    return 0
  end if
  tID = getUniqueID()
  pLatestTaskID = tID
  if (tAdd = 0) then
    me.removeTemporaryCast(tCastList)
  end if
  if (pTempWaitList.count > 0) then
    pWaitList[tID] = pTempWaitList.duplicate()
  end if
  if (pWaitList.count = 0) then
    tStatus = #ready
    tPercent = 1.0
  else
    tStatus = #LOADING
    tPercent = 0
  end if
  pTaskList[tID] = createObject(#temp, getClassVariable("castload.task.class"))
  tProps = [:]
  tProps[#id] = tID
  tProps[#status] = tStatus
  tProps[#Percent] = tPercent
  tProps[#sofar] = 0
  tProps[#casts] = pTempWaitList.duplicate()
  tProps[#callback] = VOID
  tProps[#doindexing] = tDoIndexing
  pTaskList[tID].define(tProps)
  pLastError = 0
  repeat with i = 1 to getIntVariable("net.operation.count", 2)
    me.AddNextpreloadNetThing()
  end repeat
  return tID
end

on registerCallback me, tID, tMethod, tClientID, tArgument
  if voidp(pTaskList.findPos(tID)) then
    return 0
  else
    return call(#addCallBack, pTaskList[tID], tID, tMethod, tClientID, tArgument)
  end if
end

on resetCastLibs me, tClean, tForced
  if (tClean <> 1) then
    tClean = 0
  end if
  tTempList = []
  if ((the runMode = "Author") and (tForced <> 1)) then
    f = 1
    repeat while 1
      if variableExists(("cast.dev." & f)) then
        tTempList.add(getVariable(("cast.dev." & f)))
      else
        exit repeat
      end if
      f = (f + 1)
    end repeat
  end if
  pCastLibCount = the number of castLibs
  tEmptyCastNum = 1
  repeat with tCastNum = 2 to pCastLibCount
    if ((tCastNum <> pSysCastNum) and (tCastNum <> pBinCastNum)) then
      tCastName = castLib(tCastNum).name
      if (tTempList.findPos(tCastName) = 0) then
        if tClean then
          getThreadManager().closeThread(tCastNum)
        end if
        if tClean then
          getResourceManager().unregisterMembers(tCastNum)
        end if
        castLib(tCastNum).name = (pNullCastName && tEmptyCastNum)
        castLib(tCastNum).fileName = ((getMoviePath() & pNullCastName) & pFileExtension)
        tEmptyCastNum = (tEmptyCastNum + 1)
        next repeat
      end if
      pLoadedCasts[tCastName] = string(tCastNum)
    end if
  end repeat
  return me.InitPreloader()
end

on getLoadPercent me, tID
  if voidp(tID) then
    tID = pLatestTaskID
  end if
  if not voidp(pTaskList[tID]) then
    if (pTaskList[tID].getTaskState() = #ready) then
      return 1.0
    else
      return pTaskList[tID].getTaskPercent()
    end if
  else
    return 1.0
  end if
end

on FindCastNumber me, tCast
  repeat with j = 1 to the number of castLibs
    tFileName = castLib(j).fileName
    tFileExtension = tFileName.char[(length(tFileName) - 2)]
    if (((castLib(j).name <> "Internal") and (tFileExtension <> "dcr")) and (tFileExtension <> "dir")) then
      if (castLib(j).name = tCast) then
        return castLib(tCast).number
        exit repeat
      end if
    end if
  end repeat
  return 0
end

on exists me, tCastName
  if (tCastName = "internal") then
    return 1
  end if
  if voidp(pLoadedCasts[tCastName]) then
    return 0
  else
    return 1
  end if
end

on print me
  repeat with i = 1 to the number of castLibs
    put castLib(i).name
  end repeat
  repeat with tObj in pCurrentDownLoads
    put (tObj[#pFile] && tObj[#pPercent])
  end repeat
end

on GetLastError me
  return pLastError
end

on prepare me
  if (count(pTaskList) > 0) then
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
  pLatestTaskID = EMPTY
  repeat with f = 1 to the number of castLibs
    tCastNumber = me.FindCastNumber((pNullCastName && f))
    if (tCastNumber > 0) then
      pAvailableDynCasts.addProp((pNullCastName && f), tCastNumber)
    end if
  end repeat
  return 1
end

on AddNextpreloadNetThing me
  if (pCurrentDownLoads.count < getIntVariable("net.operation.count", 2)) then
    if (pWaitList.count > 0) then
      if (count(pWaitList[1]) > 0) then
        tFile = pWaitList[1][1]
        tParsedFile = tFile
        tFileExtension = pFileExtension
        tURL = EMPTY
        tParamOffset = offset("?", tFile)
        tParamString = EMPTY
        if (tParamOffset > 0) then
          tParamString = tFile.char[tParamOffset]
          tFile = tFile.char[1]
        end if
        tPossibleExtension = chars(tFile, (tFile.length - 3), tFile.length)
        if ((tPossibleExtension = ".cst") or (tPossibleExtension = ".cct")) then
          tFileExtension = tPossibleExtension
          tParsedFile = chars(tFile, 1, (tFile.length - tPossibleExtension.length))
        end if
        if (not tParsedFile contains "http://") then
          tURL = (((getMoviePath() & tParsedFile) & tFileExtension) & tParamString)
        else
          tURL = ((tParsedFile & tFileExtension) & tParamString)
        end if
        tID = pWaitList.getPropAt(1)
        pWaitList[1].deleteAt(1)
        if (count(pWaitList[1]) = 0) then
          pWaitList.deleteProp(pWaitList.getPropAt(1))
        end if
        pCurrentDownLoads[tFile] = createObject(#temp, getClassVariable("castload.instance.class"))
        pCurrentDownLoads[tFile].define(tFile, tURL, tID)
        pTaskList[tID].changeLoadingCount(1)
        receivePrepare(me.getID())
        return 1
      end if
    end if
  end if
  return 0
end

on DoneCurrentDownLoad me, tFile, tURL, tID, tstate
  if voidp(pCurrentDownLoads[tFile]) then
    return error(me, (("CastLoad task was lost!" && tFile) && tID), #DoneCurrentDownLoad, #major)
  end if
  tTask = pTaskList[tID]
  if (tTask = VOID) then
    return error(me, (("Task list item was lost!" && tFile) && tID), #DoneCurrentDownLoad, #major)
  end if
  if (tstate <> #done) then
    pLastError = netError(pCurrentDownLoads[tFile].pNetId)
  end if
  if (tstate <> #error) then
    tCastNumber = me.getAvailableEmptyCast()
    if (tCastNumber > 0) then
      tCastName = tFile
      tPreIndexing = tTask.getIndexingAllowed()
      me.setImportedCast(tCastNumber, tCastName, tURL, tPreIndexing)
    end if
  end if
  tTask.OneCastDone(tFile)
  tTask.changeLoadingCount(-1)
  pCurrentDownLoads[tFile].deconstruct()
  me.delay(50, #removeCastLoadInstance, tFile)
  me.removeCastLoadTask(tID, tstate)
  return 1
end

on removeCastLoadInstance me, tFile
  if (tFile.ilk <> #string) then
    return 0
  end if
  if voidp(pCurrentDownLoads[tFile]) then
    return error(me, ("CastLoad instance was lost!" && tFile), #removeCastLoadInstance, #minor)
  else
    return pCurrentDownLoads.deleteProp(tFile)
  end if
end

on removeCastLoadTask me, tID, tstate
  tTask = pTaskList[tID]
  if (tstate = #failed) then
    tTask.setFailed()
  end if
  if (tTask.getTaskState() = #ready) then
    if tTask.getFailed() then
      tstate = #failed
    end if
    tTask.DoCallBack(tstate)
    tTask.deconstruct()
    pTaskList.deleteProp(tID)
    if (count(pTaskList) = 0) then
      removePrepare(me.getID())
    end if
  end if
end

on TellStreamState me, tFileName, tstate, tPercent, tID
  tObject = pTaskList[tID]
  if (tObject <> VOID) then
    call(#UpdateTaskPercent, tObject, tPercent, tFileName)
  else
    return error(me, (("Task list instance was lost!" && tFileName) && tID), #TellStreamState, #major)
  end if
end

on setImportedCast me, tCastNum, tCastName, tFileName, tDoIndexing
  tCastLib = castLib(tCastNum)
  if voidp(tDoIndexing) then
    tDoIndexing = 1
  end if
  if (tCastLib.name contains pNullCastName) then
    tCastLib.fileName = tFileName
    tCastLib.name = tCastName
    pPermanentLevelList[tCastName][2] = tCastNum
    if tDoIndexing then
      getResourceManager().preIndexMembers(tCastNum)
    end if
    pLoadedCasts[tCastName] = string(tCastNum)
  end if
  me.verifyReset()
end

on getAvailableEmptyCast me
  if (pAvailableDynCasts.count > 0) then
    tCastNum = pAvailableDynCasts.getLast()
    pAvailableDynCasts.deleteAt(pAvailableDynCasts.count)
    return tCastNum
  else
    SystemAlert(me, "Out of free cast entries! CastLoad failed.")
    return 0
  end if
end

on removeTemporaryCast me, tNewLoadListOfcasts
  tTempList = pPermanentLevelList.duplicate()
  repeat with f = 1 to tTempList.count
    tPermanent = tTempList[f][1]
    tCstNumber = tTempList[f][2]
    if ((tPermanent = 0) and (tCstNumber > 0)) then
      tCastName = tTempList.getPropAt(f)
      if not tNewLoadListOfcasts.getOne(tCastName) then
        pPermanentLevelList.deleteProp(tCastName)
        me.ResetOneDynamicCast(tCstNumber)
        if (pCastLibCount <> the number of castLibs) then
          pCastLibCount = the number of castLibs
          tError = ("CastLib count was changed!!!" & RETURN)
          tError = ((tError & "CastLib with problems:") && castLib(pCastLibCount).name)
          error(me, tError, #removeTemporaryCast, #minor)
        end if
      end if
    end if
  end repeat
end

on addOneCastToWaitList me, tCastName, tPermanentOrNot
  if (not me.FindCastNumber(tCastName) and not pWaitList.getOne(tCastName)) then
    pTempWaitList.add(tCastName)
    tOffset = offset("?", tCastName)
    if (tOffset <> 0) then
      tCastNameNoParams = tCastName.char[1]
    else
      tCastNameNoParams = tCastName
    end if
    pPermanentLevelList.addProp(tCastNameNoParams, [tPermanentOrNot, 0])
  else
    if voidp(pLoadedCasts[tCastName]) then
      pLoadedCasts[tCastName] = string(me.FindCastNumber(tCastName))
    end if
  end if
end

on ResetOneDynamicCast me, tCastNum
  if (pLoadedCasts.getOne(string(tCastNum)) <> 0) then
    pLoadedCasts.deleteProp(pLoadedCasts.getOne(string(tCastNum)))
  else
    error(me, ("Couldn't remove cast:" && tCastNum), #ResetOneDynamicCast, #minor)
  end if
  getThreadManager().closeThread(tCastNum)
  getResourceManager().unregisterMembers(tCastNum)
  castLib(tCastNum).name = (pNullCastName && (tCastNum - 2))
  castLib((pNullCastName && (tCastNum - 2))).fileName = ((getMoviePath() & pNullCastName) & pFileExtension)
  pAvailableDynCasts.addProp((pNullCastName & (tCastNum - 2)), tCastNum)
  return 1
end

on verifyReset me
  repeat with tEmptyCastNum = 1 to the number of castLibs
    if (castLib(tEmptyCastNum).fileName contains pNullCastName) then
      if (the number of castMembers > 0) then
        fatalError(["error": "empty_cast_failure"])
        return 0
      end if
    end if
  end repeat
end

on solveNetErrorMsg me, tErrorCode
  case tErrorCode of
    EMPTY:
      return "Unknown error."
    "OK":
      return "OK"
    -128:
      return "Operation was cancelled."
    0:
      return "OK"
    4:
      return "Bad MOA Class. Network Xtras may be improperly installed."
    5:
      return "Bad MOA Interface. Network Xtras may be improperly installed."
    6:
      return "General transfer error."
    20:
      return "Internal error."
    900:
      return "Failed attempt to write to locked media."
    903:
      return "Disk is full."
    905:
      return "Bad URL."
    4144:
      return "Failed network operation."
    4145:
      return "Failed network operation."
    4146:
      return "Connection could not be established with the remote host."
    4147:
      return "Failed network operation."
    4148:
      return "Failed network operation."
    4149:
      return "Data supplied by the server was in an unexpected format."
    4150:
      return "Unexpected early closing of connection."
    4151:
      return "Failed network operation."
    4152:
      return "Data returned is truncated."
    4153:
      return "Failed network operation."
    4154:
      return "Operation could not be completed due to timeout."
    4155:
      return "Not enough memory available to complete the transaction."
    4156:
      return "Protocol reply to request indicates an error in the reply."
    4157:
      return "Transaction failed to be authenticated."
    4159:
      return "Invalid URL."
    4160:
      return "Failed network operation."
    4161:
      return "Failed network operation."
    4162:
      return "Failed network operation."
    4163:
      return "Failed network operation."
    4164:
      return "Could not create a socket"
    4165:
      return "Requested Object could not be found (URL may be incorrect)."
    4166:
      return "Generic proxy failure."
    4167:
      return "Transfer was intentionally interrupted by client."
    4168:
      return "Failed network operation."
    4242:
      return "Download stopped by netAbort(url)."
    4836:
      return "Cache download stopped for an unknown reason."
  end case
  return ("Other network error:" && tErrorCode)
end
