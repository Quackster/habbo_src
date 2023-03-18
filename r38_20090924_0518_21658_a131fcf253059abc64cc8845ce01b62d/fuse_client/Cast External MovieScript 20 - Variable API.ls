on constructVariableManager
  return createManager(#variable_manager, value(convertToPropList(field("System Props"), RETURN)["variable.manager.class"]))
end

on deconstructVariableManager
  return removeManager(#variable_manager)
end

on getVariableManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#variable_manager) then
    return constructVariableManager()
  end if
  return tMgr.getManager(#variable_manager)
end

on createVariable tID, tValue
  return getVariableManager().create(tID, tValue)
end

on removeVariable tID
  return getVariableManager().Remove(tID)
end

on setVariable tID, tValue
  return getVariableManager().create(tID, tValue)
end

on getVariable tID, tDefault
  return getVariableManager().GET(tID, tDefault)
end

on getIntVariable tID, tDefault
  return getVariableManager().getInt(tID, tDefault)
end

on getStringVariable tID, tDefault
  return getVariableManager().getString(tID, tDefault)
end

on getSymbolVariable tID, tDefault
  return getVariableManager().getSymbol(tID, tDefault)
end

on getStructVariable tID, tDefault
  return getVariableManager().GetValue(tID, tDefault)
end

on getClassVariable tID, tDefault
  return getVariableManager().GetValue(tID, tDefault)
end

on getVariableValue tID, tDefault
  return getVariableManager().GetValue(tID, tDefault)
end

on variableExists tID
  return getVariableManager().exists(tID)
end

on printVariables
  return getVariableManager().print()
end

on dumpVariableField tField, tDelimiter
  return getVariableManager().dump(tField, tDelimiter)
end

on handlers
  return []
end
