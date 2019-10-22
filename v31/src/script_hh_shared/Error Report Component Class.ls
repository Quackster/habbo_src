property pErrorLists

on construct me 
  pErrorLists = []
  registerMessage(#showErrorMessage, me.getID(), #showErrorMessage)
  registerMessage("crossDomainDownload", me.getID(), #registerCrossDomainError)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#showErrorMessage, me.getID())
  pErrorLists = []
  return TRUE
end

on registerCrossDomainError me, tURL 
  tShowAlert = 1
  tSessionObj = getObject(#session)
  if not voidp(tSessionObj) then
    tRights = tSessionObj.GET("user_rights")
    if listp(tRights) then
      tAlertRight = tRights.getOne("fuse_alert")
      if not tAlertRight then
        tShowAlert = 0
      end if
    end if
  end if
  if tShowAlert then
    tMessage = getText("alert_cross_domain_download") & "\r" & tURL
    me.showErrorMessage("client", tMessage)
  end if
end

on showErrorMessage me, tErrorID, tErrorMessage 
  tErrorList = [:]
  tErrorList.setAt(#errorId, tErrorID)
  tErrorList.setAt(#errorMsg, tErrorMessage)
  me.storeErrorReport(tErrorList)
  me.getInterface().showErrors()
end

on storeErrorReport me, tErrorList 
  pErrorLists.add(tErrorList)
end

on getErrorLists me 
  return(pErrorLists)
end

on clearErrorLists me, tIndex 
  tIndex = min(tIndex, pErrorLists.count)
  i = 1
  repeat while i <= tIndex
    pErrorLists.deleteAt(1)
    i = (1 + i)
  end repeat
end
