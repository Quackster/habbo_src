on constructTextManager
  return createManager(#text_manager, getClassVariable("text.manager.class"))
end

on deconstructTextManager
  return removeManager(#text_manager)
end

on getTextManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#text_manager) then
    return constructTextManager()
  end if
  return tMgr.getManager(#text_manager)
end

on createText tID, tValue
  return getTextManager().create(tID, tValue)
end

on removeText tID
  return getTextManager().Remove(tID)
end

on setText tID, tValue
  return getTextManager().create(tID, tValue)
end

on getText tID, tDefault
  return getTextManager().GET(tID, tDefault)
end

on textExists tID
  return getTextManager().exists(tID)
end

on printTexts
  return getTextManager().print()
end

on dumpTextField tField, tDelimiter
  return getTextManager().dump(tField, tDelimiter)
end

on handlers
  return []
end
