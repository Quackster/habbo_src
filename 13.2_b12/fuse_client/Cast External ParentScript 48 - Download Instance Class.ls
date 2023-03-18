property pStatus, pMemName, pMemNum, pURL, pType, pCallBack, pNetId, pPercent, ptryCount

on define me, tMemName, tdata
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata[#memNum]
  pURL = tdata[#url]
  pType = tdata[#type]
  pCallBack = tdata[#callback]
  pPercent = 0.0
  ptryCount = 0
  return me.Activate()
end

on addCallBack me, tMemName, tCallback
  if tMemName = pMemName then
    pCallBack = tCallback
    return 1
  else
    return 0
  end if
end

on getProperty me, tProp
  case tProp of
    #status:
      return pStatus
    #Percent:
      return pPercent
    #url:
      return pURL
    #type:
      return pType
    otherwise:
      return 0
  end case
end

on Activate me
  pURL = getPredefinedURL(pURL)
  if (pType = #text) or (pType = #field) then
    pNetId = getNetText(pURL)
  else
    pNetId = preloadNetThing(pURL)
  end if
  pStatus = #LOADING
  pPercent = 0.0
  return 1
end

on update me
  if pStatus <> #LOADING then
    return 0
  end if
  tStreamStatus = getStreamStatus(pNetId)
  if listp(tStreamStatus) then
    tBytesSoFar = tStreamStatus[#bytesSoFar]
    tBytesTotal = tStreamStatus[#bytesTotal]
    if tBytesTotal = 0 then
      tBytesTotal = tBytesSoFar
    end if
    if tStreamStatus[#bytesSoFar] > 0 then
      pPercent = 1.0 * tBytesSoFar / tBytesTotal
    end if
  end if
  if netDone(pNetId) = 1 then
    if (netError(pNetId) = "OK") and (tStreamStatus[#bytesSoFar] > 0) then
      me.importFileToCast()
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      pStatus = #complete
      return 1
    else
      tError = getDownloadManager().solveNetErrorMsg(netError(pNetId))
      error(me, "Download error:" & RETURN & pMemName & RETURN & tError, #update)
      case netError(pNetId) of
        6, 4159, 4165:
          if not (pURL contains getDownloadManager().getProperty(#defaultURL)) then
            pURL = getDownloadManager().getProperty(#defaultURL) & pURL
            me.Activate()
          else
            getDownloadManager().removeActiveTask(pMemName, pCallBack)
          end if
        4242:
          return getDownloadManager().removeActiveTask(pMemName, pCallBack)
        4155:
          nothing()
      end case
      ptryCount = ptryCount + 1
      if ptryCount > getIntVariable("download.retry.count", 10) then
        getDownloadManager().removeActiveTask(pMemName, pCallBack)
        return error(me, "Download failed too many times:" & RETURN & pURL, #update)
      else
        pURL = getSpecialServices().addRandomParamToURL(pURL)
        me.Activate()
      end if
    end if
  end if
end

on importFileToCast me
  tmember = member(pMemNum)
  case pType of
    #text, #field:
      tmember.text = netTextResult(pNetId)
    #bitmap:
      importFileInto(tmember, pURL, [#dither: 0, #trimWhiteSpace: 0])
    otherwise:
      importFileInto(tmember, pURL)
  end case
  tmember.name = pMemName
  return 1
end
