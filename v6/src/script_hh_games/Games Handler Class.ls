on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_opengameboard me, tMsg 
  tDelim = the itemDelimiter
  tLine = tMsg.content.getProp(#line, 1)
  if tLine contains "\t" then
    the itemDelimiter = "\t"
  else
    the itemDelimiter = ";"
  end if
  tProps = [:]
  tProps.setAt(#id, tLine.getProp(#item, 1))
  tProps.setAt(#name, tLine.getProp(#item, 2))
  tProps.setAt(#data, tMsg.content.getProp(#line, 1, tMsg.content.count(#line)))
  the itemDelimiter = tDelim
  me.getComponent().openGameBoard(tProps)
end

on handle_closegameboard me, tMsg 
  tDelim = the itemDelimiter
  tLine = tMsg.content.getProp(#line, 1)
  if tLine contains "\t" then
    the itemDelimiter = "\t"
  else
    the itemDelimiter = ";"
  end if
  tProps = [:]
  tProps.setAt(#id, tLine.getProp(#item, 1))
  tProps.setAt(#name, tLine.getProp(#item, 2))
  tProps.setAt(#data, tMsg.content.getProp(#line, 1, tMsg.content.count(#line)))
  the itemDelimiter = tDelim
  me.getComponent().closeGameBoard(tProps)
end

on handle_itemmsg me, tMsg 
  tProps = [:]
  tProps.setAt(#id, tMsg.content.getProp(#line, 1))
  tProps.setAt(#command, tMsg.content.getProp(#line, 2))
  tProps.setAt(#data, tMsg.content.getProp(#line, 3, tMsg.content.count(#line)))
  me.getComponent().processItemMessage(tProps)
end

on regMsgList me, tBool 
  tList = [:]
  tList.setaProp(144, #handle_itemmsg)
  tList.setaProp(145, #handle_opengameboard)
  tList.setaProp(146, #handle_closegameboard)
  tCmds = [:]
  tCmds.setaProp("IIM", 117)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tList)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tList)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return TRUE
end
