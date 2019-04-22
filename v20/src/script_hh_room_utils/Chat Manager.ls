on construct(me)
  me.regMsgList(1)
  pDisplayObjName = "chat_display_object"
  createObject(pDisplayObjName, "Chat Display")
  registerMessage(#leaveRoom, me.getID(), #clearChat)
  exit
end

on deconstruct(me)
  me.regMsgList(0)
  me.clearChat()
  if objectExists(pDisplayObjName) then
    removeObject(pDisplayObjName)
  end if
  exit
end

on clearChat(me)
  if objectExists(pDisplayObjName) then
    tObj = getObject(pDisplayObjName)
    tObj.clearAll()
  end if
  exit
end

on enterChatMessage(me, tChatMode, tRoomUserId, tChatMessage)
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.insertChatMessage(tChatMode, tRoomUserId, tChatMessage)
  exit
end

on showBalloons(me)
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.showBalloons(1)
  exit
end

on hideBalloons(me)
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.showBalloons(0)
  exit
end

on removeBalloons(me)
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.clearAll()
  exit
end

on handle_chat(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tuser = string(tConn.GetIntFrom())
  tChat = tConn.GetStrFrom()
  tRoomInterface = getThread(#room).getInterface()
  if tRoomInterface.getIgnoreStatus(tuser) then
    return(0)
  end if
  if me = 24 then
    tMode = "CHAT"
  else
    if me = 25 then
      tMode = "WHISPER"
    else
      if me = 26 then
        tMode = "SHOUT"
      end if
    end if
  end if
  if tChat = "" then
    tMode = "UNHEARD"
  end if
  me.enterChatMessage(tMode, tuser, tChat)
  getThread(#room).getComponent().setUserTypingStatus(tuser, 0)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(24, #handle_chat)
  tMsgs.setaProp(25, #handle_chat)
  tMsgs.setaProp(26, #handle_chat)
  tCmds = []
  tCmds.setaProp("CHAT", 52)
  tCmds.setaProp("SHOUT", 55)
  tCmds.setaProp("WHISPER", 56)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end