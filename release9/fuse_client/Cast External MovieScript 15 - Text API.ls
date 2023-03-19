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

on createText tid, tValue
  return getTextManager().create(tid, tValue)
end

on removeText tid
  return getTextManager().Remove(tid)
end

on setText tid, tValue
  return getTextManager().create(tid, tValue)
end

on getText tid, tDefault
  return getTextManager().get(tid, tDefault)
end

on textExists tid
  return getTextManager().exists(tid)
end

on printTexts
  return getTextManager().print()
end

on dumpTextField tField, tDelimiter
  return getTextManager().dump(tField, tDelimiter)
end
