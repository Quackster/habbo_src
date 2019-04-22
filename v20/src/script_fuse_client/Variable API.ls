on constructVariableManager()
  return(createManager("System Props", value(convertToPropList(field(0), "\r").getAt("variable.manager.class"))))
  exit
end

on deconstructVariableManager()
  return(removeManager(#variable_manager))
  exit
end

on getVariableManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#variable_manager) then
    return(constructVariableManager())
  end if
  return(tMgr.getManager(#variable_manager))
  exit
end

on createVariable(tID, tValue)
  return(getVariableManager().create(tID, tValue))
  exit
end

on removeVariable(tID)
  return(getVariableManager().Remove(tID))
  exit
end

on setVariable(tID, tValue)
  return(getVariableManager().create(tID, tValue))
  exit
end

on getVariable(tID, tDefault)
  return(getVariableManager().GET(tID, tDefault))
  exit
end

on getIntVariable(tID, tDefault)
  return(getVariableManager().getInt(tID, tDefault))
  exit
end

on getStructVariable(tID, tDefault)
  return(getVariableManager().GetValue(tID, tDefault))
  exit
end

on getClassVariable(tID, tDefault)
  return(getVariableManager().GetValue(tID, tDefault))
  exit
end

on getVariableValue(tID, tDefault)
  return(getVariableManager().GetValue(tID, tDefault))
  exit
end

on variableExists(tID)
  return(getVariableManager().exists(tID))
  exit
end

on printVariables()
  return(getVariableManager().print())
  exit
end

on dumpVariableField(tField, tDelimiter)
  return(getVariableManager().dump(tField, tDelimiter))
  exit
end