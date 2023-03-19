on constructDownloadManager
  return createManager(#download_manager, getClassVariable("download.manager.class"))
end

on deconstructDownloadManager
  return removeManager(#download_manager)
end

on getDownloadManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#download_manager) then
    return constructDownloadManager()
  end if
  return tMgr.getManager(#download_manager)
end

on queueDownload tURL, tMemName, tFileType, tForceFlag, tDownloadType, tRedirectType, tTarget
  return getDownloadManager().queue(tURL, tMemName, tFileType, tForceFlag, tDownloadType, tRedirectType, tTarget)
end

on abortDownLoad tMemNameOrNum
end

on registerDownloadCallback tMemNameOrNum, tMethod, tClientID, tArgument
  return getDownloadManager().registerCallback(tMemNameOrNum, tMethod, tClientID, tArgument)
end

on getDownLoadPercent tID
  return getDownloadManager().getLoadPercent(tID)
end

on downloadExists tID
  return getDownloadManager().exists(tID)
end

on printDownloads
  return getDownloadManager().print()
end

on handlers
  return []
end
