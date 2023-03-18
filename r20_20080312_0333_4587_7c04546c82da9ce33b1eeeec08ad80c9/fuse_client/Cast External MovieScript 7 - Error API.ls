global gError

on constructErrorManager
  if objectp(gError) then
    return gError
  end if
  tClass = value(convertToPropList(field("System Props"), RETURN)["error.manager.class"])[1]
  gError = script(tClass).new()
  gError.construct()
  try()
  createObject(#error_manager, gError)
  catch()
  return gError
end

on deconstructErrorManager
  if not objectp(gError) then
    return 0
  end if
  gError.deconstruct()
  gError = VOID
  return 1
end

on getErrorManager
  if not objectp(gError) then
    return constructErrorManager()
  end if
  return gError
end

on error tObject, tMsg, tMethod, tErrorLevel
  return getErrorManager().error(tObject, tMsg, tMethod, tErrorLevel)
end

on fatalError tErrorData
  return getErrorManager().fatalError(tErrorData)
end

on SystemAlert tObject, tMsg, tMethod
  return getErrorManager().SystemAlert(tObject, tMsg, tMethod)
end

on setDebugLevel tLevel
  return getErrorManager().setDebugLevel(tLevel)
end

on printErrors
  return getErrorManager().print()
end
