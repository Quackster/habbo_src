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

on createVariable(tid, tValue)
  return(getVariableManager().create(tid, tValue))
  exit
end

on removeVariable(tid)
  return(getVariableManager().remove(tid))
  exit
end

on setVariable(tid, tValue)
  return(getVariableManager().create(tid, tValue))
  exit
end

on getVariable(tid, tDefault)
  return(getVariableManager().get(tid, tDefault))
  exit
end

on getIntVariable(tid, tDefault)
  return(getVariableManager().getInt(tid, tDefault))
  exit
end

on getStructVariable(tid, tDefault)
  return(getVariableManager().getValue(tid, tDefault))
  exit
end

on getClassVariable(tid, tDefault)
  return(getVariableManager().getValue(tid, tDefault))
  exit
end

on getVariableValue(tid, tDefault)
  return(getVariableManager().getValue(tid, tDefault))
  exit
end

on variableExists(tid)
  return(getVariableManager().exists(tid))
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