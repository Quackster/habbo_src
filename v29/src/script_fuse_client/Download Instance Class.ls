property pNetId, pMemName, pStatus, pPercent, pURL, pType, pCallBack, ptryCount, pMemNum

on deconstruct me 
  if timeoutExists("dl_timeout_" & pNetId) then
    removeTimeout("dl_timeout_" & pNetId)
  end if
end

on define me, tMemName, tdata 
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata.getAt(#memNum)
  pURL = tdata.getAt(#url)
  pType = tdata.getAt(#type)
  pCallBack = tdata.getAt(#callback)
  pPercent = 0
  ptryCount = 0
  return(me.Activate())
end

on addCallBack me, tMemName, tCallback 
  if tMemName = pMemName then
    pCallBack = tCallback
    return(1)
  else
    return(0)
  end if
end

on getProperty me, tProp 
  if tProp = #status then
    return(pStatus)
  else
    if tProp = #Percent then
      return(pPercent)
    else
      if tProp = #url then
        return(pURL)
      else
        if tProp = #type then
          return(pType)
        else
          return(0)
        end if
      end if
    end if
  end if
end

on Activate me 
  startProfilingTask("Download Instance::activate")
  if pType = #text or pType = #field then
    pNetId = getNetText(pURL)
  else
    pNetId = preloadNetThing(pURL)
  end if
  pStatus = #LOADING
  pPercent = 0
  finishProfilingTask("Download Instance::activate")
  return(1)
end

on activateWithTimeout me 
  pStatus = #paused
  pPercent = 0
  if variableExists("download.retry.delay") then
    tRetryTimeout = getVariable("download.retry.delay")
  else
    tRetryTimeout = 2000
  end if
  createTimeout("dl_timeout_" & pNetId, tRetryTimeout, #Activate, me.getID(), void(), 1)
end

on update me 
  if pStatus = #paused then
    return(0)
  end if
  if pStatus <> #LOADING then
    return(0)
  end if
  tStreamStatus = getStreamStatus(pNetId)
  if listp(tStreamStatus) then
    tBytesSoFar = tStreamStatus.getAt(#bytesSoFar)
    tBytesTotal = tStreamStatus.getAt(#bytesTotal)
    if tBytesTotal = 0 then
      tBytesTotal = tBytesSoFar
    end if
    if tStreamStatus.getAt(#bytesSoFar) > 0 then
      pPercent = 1 * tBytesSoFar / tBytesTotal
    end if
    if tStreamStatus.getAt(#bytesSoFar) = 0 and tStreamStatus.getAt(#bytesTotal) = 0 and tStreamStatus.getAt(#error) = "OK" then
      pPercent = 1
    end if
  end if
  if netDone(pNetId) = 1 then
    if netError(pNetId) = "OK" and pPercent > 0 then
      me.importFileToCast()
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      pStatus = #complete
      return(1)
    else
      tErrorID = netError(pNetId)
      tError = getDownloadManager().solveNetErrorMsg(tErrorID)
      error(me, "Download error:" & "\r" & pMemName & "\r" & tErrorID & "-" & tError & "-" & pPercent & "percent", #update, #minor)
      if netError(pNetId) <> 6 then
        if netError(pNetId) <> 4159 then
          if netError(pNetId) = 4165 then
            if not pURL contains getDownloadManager().getProperty(#defaultURL) then
              pURL = getDownloadManager().getProperty(#defaultURL) & pURL
              me.activateWithTimeout()
              return(0)
            else
              getDownloadManager().removeActiveTask(pMemName, pCallBack, 0)
              return(0)
            end if
          else
            if netError(pNetId) = 4242 then
              return(getDownloadManager().removeActiveTask(pMemName, pCallBack))
            else
              if netError(pNetId) = 4155 then
                nothing()
              end if
            end if
          end if
          ptryCount = ptryCount + 1
          if ptryCount > getIntVariable("download.retry.count", 10) then
            getDownloadManager().removeActiveTask(pMemName, pCallBack, 0)
            return(error(me, "Download failed too many times:" & "\r" & pURL & "-" & tErrorID & "-" & pPercent & "percent", #update, #major))
          else
            tTriesBeforeRAndParams = 2
            if ptryCount > tTriesBeforeRAndParams then
              pURL = getSpecialServices().addRandomParamToURL(pURL)
            end if
            me.activateWithTimeout()
          end if
        end if
      end if
    end if
  end if
end

on importFileToCast me 
  startProfilingTask("Download Instance::importFileToCast")
  tmember = member(pMemNum)
  if pType <> #text then
    if pType = #field then
      tmember.text = netTextResult(pNetId)
    else
      if pType = #bitmap then
        importFileInto(tmember, pURL, [#dither:0, #trimWhiteSpace:0])
      else
        importFileInto(tmember, pURL)
      end if
    end if
    tmember.name = pMemName
    finishProfilingTask("Download Instance::importFileToCast")
    return(1)
  end if
end

on handlers  
  return([])
end
