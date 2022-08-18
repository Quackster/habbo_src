property pTaskQueue, pActiveTasks, pReceivedTasks, pCompleteTasks, pTypeDefList, pOwnDomain, pLastError, pDontProfile

on construct me
  pTaskQueue = [:]
  pActiveTasks = [:]
  pReceivedTasks = []
  pCompleteTasks = []
  pTypeDefList = [:]
  me.emptyCookies()
  pOwnDomain = getDomainPart(getMoviePath())
  pLastError = 0
  pDontProfile = 1
  return 1
end

on deconstruct me
  pTaskQueue = [:]
  pActiveTasks = [:]
  pReceivedTasks = []
  pCompleteTasks = []
  return 1
end

on create me, tURL, tMemName, ttype, tForceFlag
  return queue(me, tURL, tMemName, ttype, tForceFlag)
end

on Remove me, tMemNameOrNum
end

on exists me, tMemName
  return (not voidp(pTaskQueue[tMemName]) or not voidp(pActiveTasks[tMemName]))
end

on queue me, tURL, tMemName, ttype, tForceFlag, tDownloadMethod, tRedirectType, tTarget
  if not ilk(tURL, #string) then
    return error(me, ("Missing or invalid URL:" && tURL), #queue, #major)
  end if
  if not ilk(tMemName, #string) then
    tMemName = tURL
  end if
  if not ilk(ttype, #symbol) then
    ttype = me.recognizeMemberType(tURL)
  end if
  tURL = getPredefinedURL(tURL)
  tOwnDomain = getDomainAndTld(getMoviePath())
  tDownloadDomain = getDomainAndTld(tURL)
  if (tOwnDomain <> tDownloadDomain) then
    if (not the runMode contains "Author") then
      error(me, ("Cross domain not allowed:" && tURL), #queue, #critical)
      fatalError(["error": "cross_domain_download"])
      return 0
    end if
  end if
  if (not voidp(pTaskQueue[tMemName]) or not voidp(pActiveTasks[tMemName])) then
    return error(me, ("File already downloading:" && tMemName), #queue, #minor)
  end if
  if memberExists(tMemName) then
    if tForceFlag then
      tMemNum = getmemnum(tMemName)
    else
      return getmemnum(tMemName)
    end if
  else
    tMemNum = createMember(tMemName, ttype)
  end if
  if (tMemNum < 1) then
    return error(me, "Failed to create member!", #queue, #major)
  else
    if (member(tMemNum).type = #bitmap) then
      member(tMemNum).image = image(1, 1, 8)
    end if
  end if
  pReceivedTasks.add(tMemName)
  tTempTask = [#url: tURL, #memNum: tMemNum, #type: ttype, #callback: VOID]
  tTempTask[#downloadMethod] = tDownloadMethod
  tTempTask[#redirectType] = tRedirectType
  tTempTask[#target] = tTarget
  pTaskQueue[tMemName] = tTempTask
  me.updateQueue()
  return tMemNum
end

on registerCallback me, tMemNameOrNum, tMethod, tClientID, tArgument
  startProfilingTask("Download Manager::registerCallback")
  tTaskData = me.searchTask(tMemNameOrNum)
  if not tTaskData then
    if stringp(tMemNameOrNum) then
      if (getmemnum(tMemNameOrNum) = 0) then
        return error(me, ("Task doesn't exist:" && tMemNameOrNum), #registerCallback, #major)
      end if
    else
      if integerp(tMemNameOrNum) then
        if (member(tMemNameOrNum).type = #empty) then
          return error(me, ("Task doesn't exist:" && tMemNameOrNum), #registerCallback, #major)
        end if
      else
        return error(me, ("Member's name or number expected:" && tMemNameOrNum), #registerCallback, #major)
      end if
    end if
    tTaskData = [#status: #complete]
  end if
  if not symbolp(tMethod) then
    return error(me, ("Symbol referring to a handler expected:" && tMethod), #registerCallback, #major)
  end if
  if not objectExists(tClientID) then
    return error(me, ("Object not found:" && tClientID), #registerCallback, #major)
  end if
  if not getObject(tClientID).handler(tMethod) then
    return error(me, ("Handler not found in object:" && tMethod), tClientID, #registerCallback, #major)
  end if
  case tTaskData[#status] of
    #complete:
      call(tMethod, getObject(tClientID), tArgument)
    #queue:
      pTaskQueue[tTaskData[#name]][#callback] = [#method: tMethod, #client: tClientID, #argument: tArgument]
    #Active:
      call(#addCallBack, pActiveTasks, tTaskData[#name], [#method: tMethod, #client: tClientID, #argument: tArgument])
  end case
  finishProfilingTask("Download Manager::registerCallback")
  return 1
end

on getLoadPercent me, tMemNameOrNum
  if integerp(tMemNameOrNum) then
    tMemName = member(tMemNameOrNum).name
  else
    if stringp(tMemNameOrNum) then
      tMemName = tMemNameOrNum
    else
      return error(me, ("Member's name or number expected:" && tMemNameOrNum), #getLoadPercent, #minor)
    end if
  end if
  if (pReceivedTasks.getOne(tMemName) = 0) then
    return error(me, ("Downloaded file not found:" && tMemName), #getLoadPercent, #minor)
  end if
  if not voidp(pActiveTasks[tMemName]) then
    return pActiveTasks[tMemName].getProperty(#Percent)
  else
    if not voidp(pTaskQueue[tMemName]) then
      return 0.0
    else
      if pCompleteTasks.getOne(tMemName) then
        return 1.0
      end if
    end if
  end if
  return 1.0
end

on getProperty me, tPropID
  case tPropID of
    #curTaskCount:
      return (pTaskQueue.count + pActiveTasks.count)
    #actTaskCount:
      return pActiveTasks.count
    #maxTaskCount:
      return getIntVariable("net.operation.count")
    #defaultURL:
      return getMoviePath()
  end case
  return 0
end

on setProperty me, tPropID, tValue
  -- ERROR: Could not identify jmp
  return 0
end

on solveNetErrorMsg me, tErrorCode
  case tErrorCode of
    4:
      return "Bad MOA class. The required network or nonnetwork Xtras are improperly installed or not installed at all."
    5:
      return "Bad MOA Interface. The required network or nonnetwork Xtras are improperly installed or not installed at all."
    6:
      return "Bad URL or Bad MOA class. The required network or nonnetwork Xtras are improperly installed or not installed at all."
    20:
      return "Internal error. Returned by netError() in the Netscape browser if the browser detected a network or internal error."
    4146:
      return "Connection could not be established with the remote host."
    4149:
      return "Data supplied by the server was in an unexpected format."
    4150:
      return "Unexpected early closing of connection."
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
    4164:
      return "Could not create a socket."
    4165:
      return "Requested object could not be found (URL may be incorrect)."
    4166:
      return "Generic proxy failure."
    4167:
      return "Transfer was intentionally interrupted by client."
    4242:
      return "Download stopped by netAbort(url)."
    4836:
      return "Download stopped for an unknown reason, possibly a network error, or the download was abandoned."
  end case
  return "Unknown error!"
end

on print me
  tListList = [pActiveTasks, pTaskQueue, pReceivedTasks]
  repeat with tList in tListList
    tListMode = ilk(tList)
    repeat with i = 1 to tList.count
      if (tListMode = #list) then
        tID = i
      else
        tID = tList.getPropAt(i)
      end if
      if symbolp(tID) then
        tID = ("#" & tID)
      end if
      put ((tID && ":") && tList[i])
    end repeat
  end repeat
  return 1
end

on GetLastError me
  return pLastError
end

on update me
  if getObjectManager().managerExists(#variable_manager) then
    if variableExists("profile.core.enabled") then
      pDontProfile = 0
    end if
  end if
  if pDontProfile then
    call(#update, pActiveTasks)
  else
    repeat with i = 1 to pActiveTasks.count
      tTask = pActiveTasks[i]
      tTaskName = ("Update Download Task " & tTask.getProperty(#url))
      startProfilingTask(tTaskName)
      call(#update, [tTask])
      finishProfilingTask(tTaskName)
    end repeat
  end if
end

on searchTask me, tMemNameOrNum
  if stringp(tMemNameOrNum) then
    if (pReceivedTasks.getPos(tMemNameOrNum) < 1) then
      return 0
    end if
    tTaskData = [#name: tMemNameOrNum, #number: getmemnum(tMemNameOrNum), #status: VOID]
    tResource = pTaskQueue[tMemNameOrNum]
    if not voidp(tResource) then
      tTaskData[#status] = #queue
    end if
    tResource = pActiveTasks[tMemNameOrNum]
    if not voidp(tResource) then
      tTaskData[#status] = #Active
    end if
    tResource = pCompleteTasks.getPos(tMemNameOrNum)
    if (tResource > 0) then
      tTaskData[#status] = #complete
    end if
    if (tTaskData[#status] <> VOID) then
      return tTaskData
    end if
    return error(me, ("Referred task not found:" && tMemNameOrNum), #searchTask, #minor)
  else
    if integerp(tMemNameOrNum) then
      return searchTask(me, member(tMemNameOrNum).name)
    end if
  end if
  return error(me, ("Member's name or number expected:" && tMemNameOrNum), #searchTask, #minor)
end

on updateQueue me
  if (pActiveTasks.count < getIntVariable("net.operation.count")) then
    if (pTaskQueue.count > 0) then
      pLastError = 0
      tTaskName = pTaskQueue.getPropAt(1)
      tTaskData = pTaskQueue[tTaskName]
      pTaskQueue.deleteProp(tTaskName)
      if (tTaskData[#downloadMethod] = #httpcookie) then
        pActiveTasks[tTaskName] = createObject(getUniqueID(), getClassVariable("httpcookie.instance.class"))
      else
        pActiveTasks[tTaskName] = createObject(getUniqueID(), getClassVariable("download.instance.class"))
      end if
      pActiveTasks[tTaskName].define(tTaskName, tTaskData)
      receiveUpdate(me.getID())
    end if
  end if
  if (pActiveTasks.count = 0) then
    removeUpdate(me.getID())
  end if
  return 1
end

on removeActiveTask me, tMemName, tCallback, tSuccess
  if voidp(tSuccess) then
    tSuccess = 1
  end if
  repeat with i = 1 to pActiveTasks.count
    if (pActiveTasks[i].pMemName = tMemName) then
      if not tSuccess then
        pLastError = netError(pActiveTasks[i].pNetId)
      end if
      pActiveTasks[i].deconstruct()
      pActiveTasks.deleteAt(i)
      pCompleteTasks.add(tMemName)
      me.updateQueue()
      exit repeat
    end if
  end repeat
  if not voidp(tCallback) then
    if objectExists(tCallback[#client]) then
      call(tCallback[#method], getObject(tCallback[#client]), tCallback[#argument], tSuccess)
    end if
  end if
  return 0
end

on eraseDownloadedItems me
  repeat with i = 1 to pReceivedTasks.count
    removeMember(pReceivedTasks[i])
  end repeat
  return 1
end

on recognizeMemberType me, tURL
  if (pTypeDefList.count = 0) then
    me.fillTypeDefinitions()
  end if
  tFileType = tURL.char[(length(tURL) - 5)]
  tFileType = tFileType.char[(offset(".", tFileType) + 1)]
  tFileType = pTypeDefList[tFileType]
  if not symbolp(tFileType) then
    error(me, ("Couldn't recognize member's type:" && tURL), #recognizeMemberType, #minor)
    return #field
  else
    return tFileType
  end if
end

on emptyCookies me
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  setPref(tCookiePrefLoc, EMPTY)
end

on fillTypeDefinitions me
  pTypeDefList = [:]
  pTypeDefList["gif"] = #bitmap
  pTypeDefList["jpg"] = #bitmap
  pTypeDefList["bmp"] = #bitmap
  pTypeDefList["png"] = #bitmap
  pTypeDefList["tif"] = #bitmap
  pTypeDefList["tiff"] = #bitmap
  pTypeDefList["psd"] = #bitmap
  pTypeDefList["txt"] = #field
  pTypeDefList["html"] = #field
  pTypeDefList["htm"] = #field
  pTypeDefList["jsp"] = #field
  pTypeDefList["xml"] = #field
  pTypeDefList["nfo"] = #field
  pTypeDefList["js"] = #field
  pTypeDefList["css"] = #field
  pTypeDefList["avi"] = #digitalVideo
  pTypeDefList["mpg"] = #digitalVideo
  pTypeDefList["mpeg"] = #digitalVideo
  pTypeDefList["mp3"] = #sound
  pTypeDefList["wav"] = #sound
  pTypeDefList["snd"] = #sound
  pTypeDefList["swa"] = #swa
  pTypeDefList["fla"] = #flash
  pTypeDefList["fnt"] = #font
  pTypeDefList["ttf"] = #font
  pTypeDefList["cur"] = #cursor
  return 1
end

on getDomainAndTld me, tURL
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if (ilk(tURL) <> #string) then
    return tURL
  end if
  if (offset("?", tURL) > 0) then
    tURL = chars(tURL, 0, (offset("?", tURL) - 1))
  end if
  if (chars(tURL, tURL.length, tURL.length) = "/") then
    tURL = chars(tURL, 0, (tURL.length - 1))
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  if ((tURL contains "http://") or (tURL contains "https://")) then
    tURL = tURL.item[3]
  else
    tURL = tURL.item[1]
  end if
  the itemDelimiter = ":"
  tURL = tURL.item[1]
  the itemDelimiter = "."
  tTldItemCount = 1
  tDomainAndTld = EMPTY
  if (tURL.item.count > 2) then
    tExtTld = tURL.item[(tURL.item.count - 1)]
    if (((tExtTld = "co.uk") or (tExtTld = "com.br")) or (tExtTld = "com.au")) then
      tTldItemCount = 2
    end if
    tDomainAndTld = tURL.item[(tURL.item.count - tTldItemCount)]
  else
    tDomainAndTld = tURL
  end if
  the itemDelimiter = tDelim
  return tDomainAndTld
end

on handlers
  return []
end
