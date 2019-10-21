on constructTextManager()
  return(createManager(#text_manager, getClassVariable("text.manager.class")))
  exit
end

on deconstructTextManager()
  return(removeManager(#text_manager))
  exit
end

on getTextManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#text_manager) then
    return(constructTextManager())
  end if
  return(tMgr.getManager(#text_manager))
  exit
end

on createText(tID, tValue)
  return(getTextManager().create(tID, tValue))
  exit
end

on removeText(tID)
  return(getTextManager().Remove(tID))
  exit
end

on setText(tID, tValue)
  return(getTextManager().create(tID, tValue))
  exit
end

on getText(tID, tDefault)
  return(getTextManager().GET(tID, tDefault))
  exit
end

on textExists(tID)
  return(getTextManager().exists(tID))
  exit
end

on printTexts()
  return(getTextManager().print())
  exit
end

on dumpTextField(tField, tDelimiter)
  return(getTextManager().dump(tField, tDelimiter))
  exit
end