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
  tProps.setAt(#cry_id, tConn.GetStrFrom())
  tProps.setAt(#category, tConn.GetIntFrom())
  tProps.setAt(#time, tConn.GetStrFrom())
  tProps.setAt(#sender, tConn.GetStrFrom())
  tProps.setAt(#Msg, replaceChunks(tConn.GetStrFrom(), "<br>", "\r"))
  tProps.setAt(#url_id, tConn.GetStrFrom())
  tProps.setAt(#roomname, tConn.GetStrFrom())
  ttype = tConn.GetIntFrom()
  tMarker = tConn.GetStrFrom()
  if (ttype = 0) then
    tProps.setAt(#type, #public)
    tProps.setAt(#casts, tMarker)
    tProps.setAt(#port, tConn.GetIntFrom())
    tProps.setAt(#door, tConn.GetIntFrom())
    tProps.setAt(#room_id, #public)
  else
    if (ttype = 1) then
      tProps.setAt(#type, #private)
      tProps.setAt(#marker, tMarker)
      tProps.setAt(#room_id, string(tConn.GetIntFrom()))
      tProps.setAt(#owner, string(tConn.GetStrFrom()))
    else
      if (ttype = 2) then
        tProps.setAt(#type, #game)
        tProps.setAt(#casts, tMarker)
        tProps.setAt(#port, tConn.GetIntFrom())
        tProps.setAt(#door, tConn.GetIntFrom())
        tProps.setAt(#room_id, #public)
      end if
    end if
  end if
  if tProps.getAt(#sender) <> "[AUTOMATIC]" then
    me.getComponent().receive_cryforhelp(tProps)
  end if
end

on handle_delete_cry me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tid = tConn.GetStrFrom()
  me.getComponent().deleteCry(tid)
end

on handle_picked_cry me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tid = tConn.GetStrFrom()
  tPicker = tConn.GetStrFrom()
  tProps = [#picker:tPicker, #cry_id:tid]
  me.getComponent().receive_pickedCry(tProps)
end

on handle_cry_reply me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tText = convertSpecialChars(tConn.GetStrFrom(), 0)
  tText = replaceChunks(tText, "<br>", "\r")
  executeMessage(#alert, [#title:"hobba_message_from", #Msg:tText])
  return TRUE
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(148, #handle_cryforhelp)
  tMsgs.setaProp(149, #handle_picked_cry)
  tMsgs.setaProp(273, #handle_delete_cry)
  tMsgs.setaProp(274, #handle_cry_reply)
  tCmds = [:]
  tCmds.setaProp("PICK_CRYFORHELP", 48)
  tCmds.setaProp("CRYFORHELP", 86)
  tCmds.setaProp("CHANGECALLCATEGORY", 198)
  tCmds.setaProp("MESSAGETOCALLER", 199)
  tCmds.setaProp("MODERATIONACTION", 200)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end
