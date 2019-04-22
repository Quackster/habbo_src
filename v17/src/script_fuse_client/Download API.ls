on constructDownloadManager()
  return(createManager(#download_manager, getClassVariable("download.manager.class")))
  exit
end

on deconstructDownloadManager()
  return(removeManager(#download_manager))
  exit
end

on getDownloadManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#download_manager) then
    return(constructDownloadManager())
  end if
  return(tMgr.getManager(#download_manager))
  exit
end

on queueDownload(tURL, tMemName, tFileType, tForceFlag, tDownloadType, tRedirectType)
  return(getDownloadManager().queue(tURL, tMemName, tFileType, tForceFlag, tDownloadType, tRedirectType))
  exit
end

on abortDownLoad(tMemNameOrNum)
  return(getDownloadManager().abort(tMemNameOrNum))
  exit
end

on registerDownloadCallback(tMemNameOrNum, tMethod, tClientID, tArgument)
  return(getDownloadManager().registerCallback(tMemNameOrNum, tMethod, tClientID, tArgument))
  exit
end

on getDownLoadPercent(tID)
  return(getDownloadManager().getLoadPercent(tID))
  exit
end

on downloadExists(tID)
  return(getDownloadManager().exists(tID))
  exit
end

on printDownloads()
  return(getDownloadManager().print())
  exit
end