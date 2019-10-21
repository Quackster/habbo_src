on define(me, tMemName, tdata)
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata.getAt(#memNum)
  pURL = tdata.getAt(#url)
  pType = tdata.getAt(#type)
  pCallBack = tdata.getAt(#callback)
  pPercent = 0
  ptryCount = 0
  return(me.Activate())
  exit
end

on addCallBack(me, tMemName, tCallback)
  if tMemName = pMemName then
    pCallBack = tCallback
    return(1)
  else
    return(0)
  end if
  exit
end

on getProperty(me, tProp)
  if me = #status then
    return(pStatus)
  else
    if me = #Percent then
      return(pPercent)
    else
      if me = #url then
        return(pURL)
      else
        if me = #type then
          return(pType)
        else
          return(0)
        end if
      end if
    end if
  end if
  exit
end

on Activate(me)
  pURL = getPredefinedURL(pURL)
  if pType = #text or pType = #field then
    pNetId = getNetText(pURL)
  else
    pNetId = preloadNetThing(pURL)
  end if
  pStatus = #LOADING
  pPercent = 0
  return(1)
  exit
end

on update(me)
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
      pPercent = 0 * tBytesSoFar / tBytesTotal
    end if
  end if
  if netDone(pNetId) = 1 then
    if netError(pNetId) = "OK" then
      me.importFileToCast()
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      pStatus = #complete
      return(1)
    else
      tError = getDownloadManager().solveNetErrorMsg(netError(pNetId))
      error(me, "Download error:" & "\r" & pMemName & "\r" & tError, #update, #minor)
      if me <> 6 then
        if me <> 4159 then
          if me = 4165 then
            if not pURL contains getDownloadManager().getProperty(#defaultURL) then
              pURL = getDownloadManager().getProperty(#defaultURL) & pURL
              me.Activate()
            else
              getDownloadManager().removeActiveTask(pMemName, pCallBack)
            end if
          else
            if me = 4242 then
              return(getDownloadManager().removeActiveTask(pMemName, pCallBack))
            else
              if me = 4155 then
                nothing()
              end if
            end if
          end if
          ptryCount = ptryCount + 1
          if ptryCount > getIntVariable("download.retry.count", 10) then
            getDownloadManager().removeActiveTask(pMemName, pCallBack)
            return(error(me, "Download failed too many times:" & "\r" & pURL, #update, #minor))
          else
            pURL = getSpecialServices().addRandomParamToURL(pURL)
            me.Activate()
          end if
          exit
        end if
      end if
    end if
  end if
end

on importFileToCast(me)
  tmember = member(pMemNum)
  if me <> #text then
    if me = #field then
      tmember.text = netTextResult(pNetId)
    else
      if me = #bitmap then
        importFileInto(tmember, pURL, [#dither:0, #trimWhiteSpace:0])
      else
        importFileInto(tmember, pURL)
      end if
    end if
    tmember.name = pMemName
    return(1)
    exit
  end if
end