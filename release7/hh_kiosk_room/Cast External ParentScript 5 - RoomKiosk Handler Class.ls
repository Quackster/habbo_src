on construct me
  registerListener(getVariable("connection.info.id"), me.getID(), [59: #handleFlatCreated])
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on deconstruct me
  unregisterListener(getVariable("connection.info.id"), me.getID(), [59: #handleFlatCreated])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on handleFlatCreated me, tMsg
  tid = tMsg.content.line[1].word[1]
  tName = tMsg.content.line[2]
  me.getInterface().flatcreated(tName, tid)
end
