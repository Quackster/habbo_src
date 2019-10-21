on construct me 
  registerListener(getVariable("connection.info.id"), me.getID(), [59:#handle_flatcreated, 33:#handle_error])
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return TRUE
end

on deconstruct me 
  unregisterListener(getVariable("connection.info.id"), me.getID(), [59:#handle_flatcreated, 33:#handle_error])
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return TRUE
end

on handle_flatcreated me, tMsg 
  tID = tMsg.content.getPropRef(#line, 1).getProp(#word, 1)
  tName = tMsg.content.getProp(#line, 2)
  me.getInterface().flatcreated(tName, tID)
end

on handle_error me, tMsg 
  tErr = tMsg.content
  if (tErr = "Error creating a private room") then
    executeMessage(#alert, [#Msg:getText("roomatic_create_error")])
    return(me.getInterface().showHideRoomKiosk())
  end if
  return TRUE
end
