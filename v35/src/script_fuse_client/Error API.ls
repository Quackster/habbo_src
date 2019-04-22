on constructErrorManager()
  if objectp(gError) then
    return(gError)
  end if
  tClass = value(convertToPropList(field(0), "\r").getAt("error.manager.class")).getAt(1)
  gError = script(tClass).new()
  gError.construct()
  try()
  createObject(#error_manager, gError)
  catch()
  return(gError)
  exit
end

on deconstructErrorManager()
  if not objectp(gError) then
    return(0)
  end if
  gError.deconstruct()
  gError = void()
  return(1)
  exit
end

on getErrorManager()
  if not objectp(gError) then
    return(constructErrorManager())
  end if
  return(gError)
  exit
end

on error(tObject, tMsg, tMethod, tErrorLevel)
  return(getErrorManager().error(tObject, tMsg, tMethod, tErrorLevel))
  exit
end

on serverError(tErrorList)
  return(getErrorManager().serverError(tErrorList))
  exit
end

on getClientErrors()
  return(getErrorManager().getClientErrors())
  exit
end

on getServerErrors()
  return(getErrorManager().getServerErrors())
  exit
end

on fatalError(tErrorData)
  return(getErrorManager().fatalError(tErrorData))
  exit
end

on SystemAlert(tObject, tMsg, tMethod)
  return(getErrorManager().SystemAlert(tObject, tMsg, tMethod))
  exit
end

on setDebugLevel(tLevel)
  return(getErrorManager().setDebugLevel(tLevel))
  exit
end

on printErrors()
  return(getErrorManager().print())
  exit
end

on handlers()
  return([])
  exit
end