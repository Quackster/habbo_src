on constructSpecialServices
  return createManager(#special_services, getClassVariable("special.services.class"))
end

on deconstructSpecialServices
  return removeManager(#special_services)
end

on getSpecialServices
  tMgr = getObjectManager()
  if not tMgr.managerExists(#special_services) then
    return constructSpecialServices()
  end if
  return tMgr.getManager(#special_services)
end

on try
  return getSpecialServices().try()
end

on catch
  return getSpecialServices().catch()
end

on createToolTip tText
  return getSpecialServices().createToolTip(tText)
end

on removeToolTip
  return getSpecialServices().removeToolTip()
end

on setcursor ttype
  return getSpecialServices().setcursor(ttype)
end

on openNetPage tURL_key, tTarget
  return getSpecialServices().openNetPage(tURL_key, tTarget)
end

on showLoadingBar tLoadID, tProps
  return getSpecialServices().showLoadingBar(tLoadID, tProps)
end

on getUniqueID
  return getSpecialServices().getUniqueID()
end

on getMachineID
  return getSpecialServices().getMachineID()
end

on getPredefinedURL tURL
  return getSpecialServices().getPredefinedURL(tURL)
end

on getDomainPart tURL
  return getSpecialServices().getDomainPart(tURL)
end

on getMoviePath
  return getSpecialServices().getMoviePath()
end

on getExtVarPath me
  return getSpecialServices().getExtVarPath()
end

on sendProcessTracking tStepValue
  return getSpecialServices().sendProcessTracking(tStepValue)
end

on getProcessTrackingList
  tListStr = implode(getSpecialServices().getProcessTrackingList(), ",")
  return tListStr
end

on secretDecode tKey
  return getSpecialServices().secretDecode(tKey)
end

on readValueFromField tFieldName, tDelimiter, tSearchedKey
  return getSpecialServices().readValueFromField(tFieldName, tDelimiter, tSearchedKey)
end

on checkForXtra tXtraName
  return getSpecialServices().checkForXtra(tXtraName)
end

on performance
  if objectExists(#perfTester) then
    return removeObject(#perfTester)
  else
    return createObject(#perfTester, getClassVariable("perf.test.class"))
  end if
end

on printMsg tObj, tMsg
  getSpecialServices().print(tObj, tMsg)
end

on callJavaScriptFunction tCallString, tdata
  getSpecialServices().callJavaScriptFunction(tCallString, tdata)
end

on getClientUpTime
  return getSpecialServices().getClientUpTime()
end

on getValueByType tContent, tExpectedType
  return getSpecialServices().getValueByType(tContent, tExpectedType)
end

on handlers
  return []
end
