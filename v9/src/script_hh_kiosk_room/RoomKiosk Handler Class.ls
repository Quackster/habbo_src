on construct me
  registerListener(getVariable("connection.info.id"), me.getID(), [59: #handle_flatcreated, 33: #handle_error])
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on deconstruct me
  unregisterListener(getVariable("connection.info.id"), me.getID(), [59: #handle_flatcreated, 33: #handle_error])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on handle_flatcreated me, tMsg
  tid = tMsg.content.line[1].word[1]
  tName = tMsg.content.line[2]
  me.getInterface().flatcreated(tName, tid)
end

on handle_error me, tMsg
  tErr = tMsg.content
  case tErr of
    "Error creating a private room":
      executeMessage(#alert, [#Msg: getText("roomatic_create_error")])
      return me.getInterface().showHideRoomKiosk()
  end case
  return 1
end
