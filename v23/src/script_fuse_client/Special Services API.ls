on constructSpecialServices()
  return(createManager(#special_services, getClassVariable("special.services.class")))
  exit
end

on deconstructSpecialServices()
  return(removeManager(#special_services))
  exit
end

on getSpecialServices()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#special_services) then
    return(constructSpecialServices())
  end if
  return(tMgr.getManager(#special_services))
  exit
end

on try()
  return(getSpecialServices().try())
  exit
end

on catch()
  return(getSpecialServices().catch())
  exit
end

on createToolTip(tText)
  return(getSpecialServices().createToolTip(tText))
  exit
end

on removeToolTip()
  return(getSpecialServices().removeToolTip())
  exit
end

on setcursor(ttype)
  return(getSpecialServices().setcursor(ttype))
  exit
end

on openNetPage(tURL_key, tTarget)
  return(getSpecialServices().openNetPage(tURL_key, tTarget))
  exit
end

on showLoadingBar(tLoadID, tProps)
  return(getSpecialServices().showLoadingBar(tLoadID, tProps))
  exit
end

on getUniqueID()
  return(getSpecialServices().getUniqueID())
  exit
end

on getMachineID()
  return(getSpecialServices().getMachineID())
  exit
end

on getPredefinedURL(tURL)
  return(getSpecialServices().getPredefinedURL(tURL))
  exit
end

on getDomainPart(tURL)
  return(getSpecialServices().getDomainPart(tURL))
  exit
end

on getMoviePath()
  return(getSpecialServices().getMoviePath())
  exit
end

on getExtVarPath(me)
  return(getSpecialServices().getExtVarPath())
  exit
end

on sendProcessTracking(tStepValue)
  return(getSpecialServices().sendProcessTracking(tStepValue))
  exit
end

on secretDecode(tKey)
  return(getSpecialServices().secretDecode(tKey))
  exit
end

on readValueFromField(tFieldName, tDelimiter, tSearchedKey)
  return(getSpecialServices().readValueFromField(tFieldName, tDelimiter, tSearchedKey))
  exit
end

on performance()
  if objectExists(#perfTester) then
    return(removeObject(#perfTester))
  else
    return(createObject(#perfTester, getClassVariable("perf.test.class")))
  end if
  exit
end

on printMsg(tObj, tMsg)
  getSpecialServices().print(tObj, tMsg)
  exit
end

on callJavascriptFunction(tCallString, tdata)
  getSpecialServices().callJavascriptFunction(tCallString, tdata)
  exit
end