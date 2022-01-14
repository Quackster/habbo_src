on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_cryforhelp me, tMsg 
  tProps = [:]
  tConn = tMsg.getaProp(#connection)
  tProps = [#picker:""]
  tProps.setAt(#time, tConn.GetStrFrom())
  tProps.setAt(#sender, tConn.GetStrFrom())
  tValue = tConn.GetStrFrom()
  tProps.setAt(#msg, replaceChunks(tValue, "<br>", "\r"))
  tProps.setAt(#url, tConn.GetStrFrom())
  ttype = tConn.GetIntFrom()
  tMarker = tConn.GetStrFrom()
  tProps.setAt(#name, tConn.GetStrFrom())
  if (ttype = 0) then
    tProps.setAt(#type, #public)
    tProps.setAt(#casts, tMarker)
    tProps.setAt(#id, tConn.GetStrFrom())
    tProps.setAt(#port, tConn.GetIntFrom())
    tProps.setAt(#door, tConn.GetIntFrom())
  else
    if (ttype = 1) then
      tProps.setAt(#type, #private)
      tProps.setAt(#marker, tMarker)
      tProps.setAt(#id, string(tConn.GetIntFrom()))
      tProps.setAt(#owner, string(tConn.GetStrFrom()))
    end if
  end if
  if tProps.getAt(#sender) <> "[AUTOMATIC]" then
    me.getComponent().receive_cryforhelp(tProps)
  end if
end

on handle_picked_cry me, tMsg 
  tPicker = tMsg.content.getProp(#line, 1)
  tLogUrl = tMsg.content.getProp(#line, 2)
  tProps = [#picker:tPicker, #url:tLogUrl]
  me.getComponent().receive_pickedCry(tProps)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(148, #handle_cryforhelp)
  tMsgs.setaProp(149, #handle_picked_cry)
  tCmds = [:]
  tCmds.setaProp("PICK_CRYFORHELP", 48)
  tCmds.setaProp("CRYFORHELP", 86)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end
