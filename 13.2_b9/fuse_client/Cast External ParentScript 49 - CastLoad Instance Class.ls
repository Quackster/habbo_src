property pFile, pURL, pNetId, pGroupId, pLoadTime, pBytesSoFar, ptryCount, pPercent, pState, pRetryDelay, pCastLoadMaxRetryCount

on define me, tFile, tURL, tpreloadId
  pFile = tFile
  pURL = tURL
  pGroupId = tpreloadId
  ptryCount = 1
  pRetryDelay = getIntVariable("castload.retry.delay", 10000)
  pCastLoadMaxRetryCount = getIntVariable("castload.retry.count", 10)
  return me.Activate()
end

on Activate me
  if ptryCount > 3 then
    if pURL contains "http://" then
      if pURL contains "?" then
        pURL = pURL & "&" & the milliSeconds
      else
        pURL = pURL & "?" & the milliSeconds
      end if
    end if
  end if
  pNetId = preloadNetThing(pURL)
  pLoadTime = the milliSeconds
  pBytesSoFar = 0
  pPercent = 0.0
  pState = #LOADING
  return 1
end

on update me
  if (pState = #done) or (pState = #failed) then
    return 1
  end if
  tStreamStatus = getStreamStatus(pNetId)
  if not listp(tStreamStatus) then
    return error(me, "Invalid stream status:" && pFile && "/" && tStreamStatus, #update)
  end if
  if (tStreamStatus.bytesSoFar > 0) and (pState = #LOADING) then
    tBytesSoFar = tStreamStatus.bytesSoFar
    tBytesTotal = tStreamStatus.bytesTotal
    if tBytesTotal = 0 then
      tBytesTotal = tBytesSoFar
    end if
    pPercent = 1.0 * tBytesSoFar / tBytesTotal
    getCastLoadManager().TellStreamState(pFile, pState, pPercent, pGroupId)
  end if
  if tStreamStatus.bytesSoFar <> pBytesSoFar then
    pBytesSoFar = tStreamStatus.bytesSoFar
    pLoadTime = the milliSeconds
  else
    if ((the milliSeconds - pLoadTime) > pRetryDelay) or (pState = #error) then
      tErrorMsg = getCastLoadManager().solveNetErrorMsg(netError(pNetId))
      error(me, "Failed network operation:" & RETURN & pURL & RETURN & tErrorMsg, #update)
      ptryCount = ptryCount + 1
      if ptryCount >= pCastLoadMaxRetryCount then
        pPercent = 1.0
        pState = #error
        getCastLoadManager().DoneCurrentDownLoad(pFile, pURL, pGroupId, pState)
        pState = #failed
        return SystemAlert(me, "Failed download operation:" & RETURN & "Tried to load file" && QUOTE & pFile & QUOTE && ptryCount && "times.", #update)
      else
        pURL = getSpecialServices().addRandomParamToURL(pURL)
      end if
      getCastLoadManager().TellStreamState(pFile, pState, 0.0, pGroupId)
      me.Activate()
      return 0
    end if
  end if
  if (tStreamStatus.error <> EMPTY) and (tStreamStatus.error <> "OK") then
    pState = #error
  end if
  if netDone(pNetId) and (pState <> #error) then
    pPercent = 1.0
    pState = #done
    getCastLoadManager().DoneCurrentDownLoad(pFile, pURL, pGroupId, pState)
  end if
end
