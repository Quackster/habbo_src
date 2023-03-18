on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_cryforhelp me, tMsg
  tProps = [:]
  tConn = tMsg.getaProp(#connection)
  tProps = [#picker: EMPTY]
  tProps[#cry_id] = tConn.GetStrFrom()
  tProps[#category] = tConn.GetIntFrom()
  tProps[#time] = tConn.GetStrFrom()
  tProps[#sender] = tConn.GetStrFrom()
  tProps[#Msg] = replaceChunks(tConn.GetStrFrom(), "<br>", RETURN)
  tProps[#url_id] = tConn.GetStrFrom()
  tProps[#roomname] = tConn.GetStrFrom()
  ttype = tConn.GetIntFrom()
  tMarker = tConn.GetStrFrom()
  if ttype = 0 then
    tProps[#type] = #public
    tProps[#casts] = tMarker
    tProps[#port] = tConn.GetIntFrom()
    tProps[#door] = tConn.GetIntFrom()
    tProps[#room_id] = tProps[#door]
  else
    if ttype = 1 then
      tProps[#type] = #private
      tProps[#marker] = tMarker
      tProps[#room_id] = string(tConn.GetIntFrom())
      tProps[#owner] = string(tConn.GetStrFrom())
    else
      if ttype = 2 then
        tProps[#type] = #game
        tProps[#casts] = tMarker
        tProps[#port] = tConn.GetIntFrom()
        tProps[#door] = tConn.GetIntFrom()
        tProps[#room_id] = tProps[#door]
      end if
    end if
  end if
  if tProps[#sender] <> "[AUTOMATIC]" then
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
  tProps = [#picker: tPicker, #cry_id: tid]
  me.getComponent().receive_pickedCry(tProps)
end

on handle_cry_reply me, tMsg
  tConn = tMsg.getaProp(#connection)
  tText = convertSpecialChars(tConn.GetStrFrom(), 0)
  tText = replaceChunks(tText, "<br>", RETURN)
  executeMessage(#alert, [#title: "hobba_message_from", #Msg: tText])
  return 1
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
  return 1
end
