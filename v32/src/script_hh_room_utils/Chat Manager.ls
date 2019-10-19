property pDisplayObjName, pHumanTimeoutList

on construct me 
  me.regMsgList(1)
  pHumanTimeoutList = [:]
  pDisplayObjName = "chat_display_object"
  createObject(pDisplayObjName, "Chat Display")
  registerMessage(#leaveRoom, me.getID(), #clearChat)
end

on deconstruct me 
  me.regMsgList(0)
  me.clearChat()
  if objectExists(pDisplayObjName) then
    removeObject(pDisplayObjName)
  end if
  i = 1
  repeat while i <= pHumanTimeoutList.count
    timeout(pHumanTimeoutList.getPropAt(i)).forget()
    i = 1 + i
  end repeat
end

on clearChat me 
  if objectExists(pDisplayObjName) then
    tObj = getObject(pDisplayObjName)
    tObj.clearAll()
  end if
end

on enterChatMessage me, tChatMode, tRoomUserId, tChatMessage 
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.insertChatMessage(tChatMode, tRoomUserId, tChatMessage)
end

on setAvatarSpeakAndGesture me, tUserID, tSpeakTimeout, tGesture 
  tObj = getThread(#room).getComponent().getUserObject(tUserID)
  if tObj = 0 then
    return()
  end if
  tObj.action_talk("talk")
  tTimeoutID = getUniqueID()
  tParams = [#human:tUserID, #gest:tGesture]
  timeout(tTimeoutID).new(tSpeakTimeout, #stopAvatarSpeak, me)
  pHumanTimeoutList.setaProp(tTimeoutID, tParams)
end

on stopAvatarSpeak me, tTimeout 
  tUserID = pHumanTimeoutList.getAt(tTimeout.name).getAt(#human)
  tGest = pHumanTimeoutList.getAt(tTimeout.name).getAt(#gest)
  pHumanTimeoutList.deleteProp(tTimeout.name)
  timeout(tTimeout.name).forget()
  tObj = getThread(#room).getComponent().getUserObject(tUserID)
  if tObj = 0 then
    return()
  end if
  call(#stop_action_talk, [tObj], "talk")
  if tGest <> "" then
    tObj.action_gest(tGest)
    tTimeoutID = getUniqueID()
    tParams = [#human:tUserID]
    timeout(tTimeoutID).new(getIntVariable("avatar.gesture.time"), #stopAvatarGesture, me)
    pHumanTimeoutList.setaProp(tTimeoutID, tParams)
  end if
end

on stopAvatarGesture me, tTimeout 
  tUserID = pHumanTimeoutList.getAt(tTimeout.name).getAt(#human)
  pHumanTimeoutList.deleteProp(tTimeout.name)
  timeout(tTimeout.name).forget()
  tObj = getThread(#room).getComponent().getUserObject(tUserID)
  if tObj = 0 then
    return()
  end if
  tObj.stop_action_gest()
end

on showBalloons me 
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.showBalloons(1)
end

on hideBalloons me 
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.showBalloons(0)
end

on removeBalloons me 
  tDisplayObj = getObject(pDisplayObjName)
  tDisplayObj.clearAll()
end

on handle_chat me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tuser = string(tConn.GetIntFrom())
  tChat = tConn.GetStrFrom()
  tGest = tConn.GetIntFrom()
  if tMsg.getaProp(#subject) = 24 then
    tMode = "CHAT"
  else
    if tMsg.getaProp(#subject) = 25 then
      tMode = "WHISPER"
    else
      if tMsg.getaProp(#subject) = 26 then
        tMode = "SHOUT"
      end if
    end if
  end if
  if tChat = "" then
    tMode = "UNHEARD"
  end if
  me.enterChatMessage(tMode, tuser, tChat)
  tSpeakingLength = (tChat.length * 100)
  if tMsg.getaProp(#subject) = 1 then
    tGestStr = "gest sml"
  else
    if tMsg.getaProp(#subject) = 2 then
      tGestStr = "gest agr"
    else
      if tMsg.getaProp(#subject) = 3 then
        tGestStr = "gest srp"
      else
        if tMsg.getaProp(#subject) = 4 then
          tGestStr = "gest sad"
        else
          tGestStr = ""
        end if
      end if
    end if
  end if
  me.setAvatarSpeakAndGesture(tuser, tSpeakingLength, tGestStr)
  getThread(#room).getComponent().setUserTypingStatus(tuser, 0)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(24, #handle_chat)
  tMsgs.setaProp(25, #handle_chat)
  tMsgs.setaProp(26, #handle_chat)
  tCmds = [:]
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
end
