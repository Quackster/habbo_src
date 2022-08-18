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

on queueDownload tURL, tMemName, tFileType, tForceFlag
  return getDownloadManager().queue(tURL, tMemName, tFileType, tForceFlag)
end

on abortDownLoad tMemNameOrNum
  return getDownloadManager().abort(tMemNameOrNum)
end

on registerDownloadCallback tMemNameOrNum, tMethod, tClientID, tArgument
  return getDownloadManager().registerCallback(tMemNameOrNum, tMethod, tClientID, tArgument)
end

on getDownLoadPercent tid
  return getDownloadManager().getLoadPercent(tid)
end

on downloadExists tid
  return getDownloadManager().exists(tid)
end

on printDownloads
  return getDownloadManager().print()
end
