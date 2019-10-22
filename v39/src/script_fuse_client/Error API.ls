on constructErrorManager  
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
end

on deconstructErrorManager  
  if not objectp(gError) then
    return FALSE
  end if
  gError.deconstruct()
  gError = void()
  return TRUE
end

on getErrorManager  
  if not objectp(gError) then
    return(constructErrorManager())
  end if
  return(gError)
end

on error tObject, tMsg, tMethod, tErrorLevel 
  return(getErrorManager().error(tObject, tMsg, tMethod, tErrorLevel))
end

on serverError tErrorList 
  return(getErrorManager().serverError(tErrorList))
end

on getClientErrors  
  return(getErrorManager().getClientErrors())
end

on getServerErrors  
  return(getErrorManager().getServerErrors())
end

on fatalError tErrorData 
  return(getErrorManager().fatalError(tErrorData))
end

on SystemAlert tObject, tMsg, tMethod 
  return(getErrorManager().SystemAlert(tObject, tMsg, tMethod))
end

on setDebugLevel tLevel 
  return(getErrorManager().setDebugLevel(tLevel))
end

on printErrors  
  return(getErrorManager().print())
end

on handlers  
  return([])
end
