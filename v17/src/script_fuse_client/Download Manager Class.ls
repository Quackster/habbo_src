on construct(me)
  pTaskQueue = []
  pActiveTasks = []
  pReceivedTasks = []
  pCompleteTasks = []
  pTypeDefList = []
  me.emptyCookies()
  return(1)
  exit
end

on deconstruct(me)
  pTaskQueue = []
  pActiveTasks = []
  pReceivedTasks = []
  pCompleteTasks = []
  return(1)
  exit
end

on create(me, tURL, tMemName, ttype, tForceFlag)
  return(queue(me, tURL, tMemName, ttype, tForceFlag))
  exit
end

on Remove(me, tMemNameOrNum)
  return(me.abort(tMemNameOrNum))
  exit
end

on exists(me, tMemName)
  return(not voidp(pTaskQueue.getAt(tMemName)) or not voidp(pActiveTasks.getAt(tMemName)))
  exit
end

on queue(me, tURL, tMemName, ttype, tForceFlag, tDownloadMethod, tRedirectType)
  if not ilk(tURL, #string) then
    return(error(me, "Missing or invalid URL:" && tURL, #queue, #major))
  end if
  if not ilk(tMemName, #string) then
    tMemName = tURL
  end if
  if not ilk(ttype, #symbol) then
    ttype = me.recognizeMemberType(tURL)
  end if
  if not voidp(pTaskQueue.getAt(tMemName)) or not voidp(pActiveTasks.getAt(tMemName)) then
    return(error(me, "File already downloading:" && tMemName, #queue, #minor))
  end if
  if memberExists(tMemName) then
    if tForceFlag then
      tMemNum = getmemnum(tMemName)
    else
      return(getmemnum(tMemName))
    end if
  else
    tMemNum = createMember(tMemName, ttype)
  end if
  if tMemNum < 1 then
    return(error(me, "Failed to create member!", #queue, #major))
  else
    if member(tMemNum).type = #bitmap then
      member(tMemNum).image = image(1, 1, 8)
    end if
  end if
  pReceivedTasks.add(tMemName)
  tTempTask = [#url:tURL, #memNum:tMemNum, #type:ttype, #callback:void()]
  tTempTask.setAt(#downloadMethod, tDownloadMethod)
  tTempTask.setAt(#redirectType, tRedirectType)
  pTaskQueue.setAt(tMemName, tTempTask)
  me.updateQueue()
  return(tMemNum)
  exit
end

on registerCallback(me, tMemNameOrNum, tMethod, tClientID, tArgument)
  tTaskData = me.searchTask(tMemNameOrNum)
  if not tTaskData then
    if stringp(tMemNameOrNum) then
      if getmemnum(tMemNameOrNum) = 0 then
        return(error(me, "Task doesn't exist:" && tMemNameOrNum, #registerCallback, #major))
      end if
    else
      if integerp(tMemNameOrNum) then
        if member(tMemNameOrNum).type = #empty then
          return(error(me, "Task doesn't exist:" && tMemNameOrNum, #registerCallback, #major))
        end if
      else
        return(error(me, "Member's name or number expected:" && tMemNameOrNum, #registerCallback, #major))
      end if
    end if
    tTaskData = [#status:#complete]
  end if
  if not symbolp(tMethod) then
    return(error(me, "Symbol referring to a handler expected:" && tMethod, #registerCallback, #major))
  end if
  if not objectExists(tClientID) then
    return(error(me, "Object not found:" && tClientID, #registerCallback, #major))
  end if
  if not getObject(tClientID).handler(tMethod) then
    return(error(me, "Handler not found in object:" && tMethod, tClientID, #registerCallback, #major))
  end if
  if me = #complete then
    call(tMethod, getObject(tClientID), tArgument)
  else
    if me = #queue then
      pTaskQueue.getAt(tTaskData.getAt(#name)).setAt(#callback, [#method:tMethod, #client:tClientID, #argument:tArgument])
    else
      if me = #Active then
        call(#addCallBack, pActiveTasks, tTaskData.getAt(#name), [#method:tMethod, #client:tClientID, #argument:tArgument])
      end if
    end if
  end if
  return(1)
  exit
end

on getLoadPercent(me, tMemNameOrNum)
  if integerp(tMemNameOrNum) then
    tMemName = member(tMemNameOrNum).name
  else
    if stringp(tMemNameOrNum) then
      tMemName = tMemNameOrNum
    else
      return(error(me, "Member's name or number expected:" && tMemNameOrNum, #getLoadPercent, #minor))
    end if
  end if
  if pReceivedTasks.getOne(tMemName) = 0 then
    return(error(me, "Downloaded file not found:" && tMemName, #getLoadPercent, #minor))
  end if
  if not voidp(pActiveTasks.getAt(tMemName)) then
    return(pActiveTasks.getAt(tMemName).getProperty(#Percent))
  else
    if not voidp(pTaskQueue.getAt(tMemName)) then
      return(0)
    else
      if pCompleteTasks.getOne(tMemName) then
        return(0)
      end if
    end if
  end if
  return(0)
  exit
end

on getProperty(me, tPropID)
  if me = #curTaskCount then
    return(pTaskQueue.count + pActiveTasks.count)
  else
    if me = #actTaskCount then
      return(pActiveTasks.count)
    else
      if me = #maxTaskCount then
        return(getIntVariable("net.operation.count"))
      else
        if me = #defaultURL then
          return(getMoviePath())
        else
          return(0)
        end if
      end if
    end if
  end if
  exit
end

on setProperty(me, tPropID, tValue)
  return(0)
  exit
end

on solveNetErrorMsg(me, tErrorCode)
  if me = 4 then
    return("Bad MOA class. The required network or nonnetwork Xtras are improperly installed or not installed at all.")
  else
    if me = 5 then
      return("Bad MOA Interface. The required network or nonnetwork Xtras are improperly installed or not installed at all.")
    else
      if me = 6 then
        return("Bad URL or Bad MOA class. The required network or nonnetwork Xtras are improperly installed or not installed at all.")
      else
        if me = 20 then
          return("Internal error. Returned by netError() in the Netscape browser if the browser detected a network or internal error.")
        else
          if me = 4146 then
            return("Connection could not be established with the remote host.")
          else
            if me = 4149 then
              return("Data supplied by the server was in an unexpected format.")
            else
              if me = 4150 then
                return("Unexpected early closing of connection.")
              else
                if me = 4154 then
                  return("Operation could not be completed due to timeout.")
                else
                  if me = 4155 then
                    return("Not enough memory available to complete the transaction.")
                  else
                    if me = 4156 then
                      return("Protocol reply to request indicates an error in the reply.")
                    else
                      if me = 4157 then
                        return("Transaction failed to be authenticated.")
                      else
                        if me = 4159 then
                          return("Invalid URL.")
                        else
                          if me = 4164 then
                            return("Could not create a socket.")
                          else
                            if me = 4165 then
                              return("Requested object could not be found (URL may be incorrect).")
                            else
                              if me = 4166 then
                                return("Generic proxy failure.")
                              else
                                if me = 4167 then
                                  return("Transfer was intentionally interrupted by client.")
                                else
                                  if me = 4242 then
                                    return("Download stopped by netAbort(url).")
                                  else
                                    if me = 4836 then
                                      return("Download stopped for an unknown reason, possibly a network error, or the download was abandoned.")
                                    else
                                      return("Unknown error!")
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
  exit
end

on print(me)
  tListList = [pActiveTasks, pTaskQueue, pReceivedTasks]
  repeat while me <= undefined
    tList = getAt(undefined, undefined)
    tListMode = ilk(tList)
    i = 1
    repeat while i <= tList.count
      if tListMode = #list then
        tID = i
      else
        tID = tList.getPropAt(i)
      end if
      if symbolp(tID) then
        tID = "#" & tID
      end if
      put(tID && ":" && tList.getAt(i))
      i = 1 + i
    end repeat
  end repeat
  return(1)
  exit
end

on update(me)
  call(#update, pActiveTasks)
  exit
end

on searchTask(me, tMemNameOrNum)
  if stringp(tMemNameOrNum) then
    if pReceivedTasks.getPos(tMemNameOrNum) < 1 then
      return(0)
    end if
    tTaskData = [#name:tMemNameOrNum, #number:getmemnum(tMemNameOrNum), #status:void()]
    tResource = pTaskQueue.getAt(tMemNameOrNum)
    if not voidp(tResource) then
      tTaskData.setAt(#status, #queue)
    end if
    tResource = pActiveTasks.getAt(tMemNameOrNum)
    if not voidp(tResource) then
      tTaskData.setAt(#status, #Active)
    end if
    tResource = pCompleteTasks.getPos(tMemNameOrNum)
    if tResource > 0 then
      tTaskData.setAt(#status, #complete)
    end if
    if tTaskData.getAt(#status) <> void() then
      return(tTaskData)
    end if
    return(error(me, "Referred task not found:" && tMemNameOrNum, #searchTask, #minor))
  else
    if integerp(tMemNameOrNum) then
      return(searchTask(me, member(tMemNameOrNum).name))
    end if
  end if
  return(error(me, "Member's name or number expected:" && tMemNameOrNum, #searchTask, #minor))
  exit
end

on updateQueue(me)
  if pActiveTasks.count < getIntVariable("net.operation.count") then
    if pTaskQueue.count > 0 then
      tTaskName = pTaskQueue.getPropAt(1)
      tTaskData = pTaskQueue.getAt(tTaskName)
      pTaskQueue.deleteProp(tTaskName)
      if tTaskData.getAt(#downloadMethod) = #httpcookie then
        pActiveTasks.setAt(tTaskName, createObject(#temp, getClassVariable("httpcookie.instance.class")))
      else
        pActiveTasks.setAt(tTaskName, createObject(#temp, getClassVariable("download.instance.class")))
      end if
      pActiveTasks.getAt(tTaskName).define(tTaskName, tTaskData)
      receiveUpdate(me.getID())
    end if
  end if
  if pActiveTasks.count = 0 then
    removeUpdate(me.getID())
  end if
  return(1)
  exit
end

on removeActiveTask(me, tMemName, tCallback)
  i = 1
  repeat while i <= pActiveTasks.count
    if pActiveTasks.getAt(i).pMemName = tMemName then
      pActiveTasks.getAt(i).deconstruct()
      pActiveTasks.deleteAt(i)
      pCompleteTasks.add(tMemName)
      me.updateQueue()
    else
      i = 1 + i
    end if
  end repeat
  if not voidp(tCallback) then
    if objectExists(tCallback.getAt(#client)) then
      call(tCallback.getAt(#method), getObject(tCallback.getAt(#client)), tCallback.getAt(#argument))
    end if
  end if
  return(0)
  exit
end

on eraseDownloadedItems(me)
  i = 1
  repeat while i <= pReceivedTasks.count
    removeMember(pReceivedTasks.getAt(i))
    i = 1 + i
  end repeat
  return(1)
  exit
end

on recognizeMemberType(me, tURL)
  if pTypeDefList.count = 0 then
    me.fillTypeDefinitions()
  end if
  tFileType = tURL.getProp(#char, length(tURL) - 5, length(tURL))
  tFileType = tFileType.getProp(#char, offset(".", tFileType) + 1, length(tFileType))
  tFileType = pTypeDefList.getAt(tFileType)
  if not symbolp(tFileType) then
    error(me, "Couldn't recognize member's type:" && tURL, #recognizeMemberType, #minor)
    return(#field)
  else
    return(tFileType)
  end if
  exit
end

on emptyCookies(me)
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  setPref(tCookiePrefLoc, "")
  exit
end

on fillTypeDefinitions(me)
  pTypeDefList = []
  pTypeDefList.setAt("gif", #bitmap)
  pTypeDefList.setAt("jpg", #bitmap)
  pTypeDefList.setAt("bmp", #bitmap)
  pTypeDefList.setAt("png", #bitmap)
  pTypeDefList.setAt("tif", #bitmap)
  pTypeDefList.setAt("tiff", #bitmap)
  pTypeDefList.setAt("psd", #bitmap)
  pTypeDefList.setAt("txt", #field)
  pTypeDefList.setAt("html", #field)
  pTypeDefList.setAt("htm", #field)
  pTypeDefList.setAt("jsp", #field)
  pTypeDefList.setAt("xml", #field)
  pTypeDefList.setAt("nfo", #field)
  pTypeDefList.setAt("js", #field)
  pTypeDefList.setAt("css", #field)
  pTypeDefList.setAt("avi", #digitalVideo)
  pTypeDefList.setAt("mpg", #digitalVideo)
  pTypeDefList.setAt("mpeg", #digitalVideo)
  pTypeDefList.setAt("mp3", #sound)
  pTypeDefList.setAt("wav", #sound)
  pTypeDefList.setAt("snd", #sound)
  pTypeDefList.setAt("swa", #swa)
  pTypeDefList.setAt("fla", #flash)
  pTypeDefList.setAt("fnt", #font)
  pTypeDefList.setAt("ttf", #font)
  pTypeDefList.setAt("cur", #cursor)
  return(1)
  exit
end