on construct me 
  registerListener(getVariable("connection.info.id"), me.getID(), [59:#handleFlatCreated])
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return TRUE
end

on deconstuct me 
  unregisterListener(getVariable("connection.info.id"), me.getID(), [59:#handleFlatCreated])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return TRUE
end

on handleFlatCreated me, tMsg 
  tid = tMsg.content.getPropRef(#line, 1).getProp(#word, 1)
  tName = tMsg.content.getPropRef(#line, 2).getProp(#word, 1)
  me.getInterface().flatcreated(tName, tid)
end
