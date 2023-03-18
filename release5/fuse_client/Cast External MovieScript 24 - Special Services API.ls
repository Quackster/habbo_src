on constructSpecialServices
  return createManager(#special_services, getClassVariable("special.services.class"))
end

on deconstructSpecialServices
  return removeManager(#special_services)
end

on getSpecialServices
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#special_services) then
    return constructSpecialServices()
  end if
  return tObjMngr.getManager(#special_services)
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

on setCursor ttype
  return getSpecialServices().setCursor(ttype)
end

on openNetPage tURL_key
  return getSpecialServices().openNetPage(tURL_key)
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

on secretDecode tKey
  return getSpecialServices().secretDecode(tKey)
end

on readValueFromField tFieldName, tDelimiter, tSearchedKey
  return getSpecialServices().readValueFromField(tFieldName, tDelimiter, tSearchedKey)
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
