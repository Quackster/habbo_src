on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on constructArena(me, tdata, tMsg)
  tConn = tMsg.connection
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return(0)
  end if
  tRoomThread = getThread(#room)
  if tRoomThread = 0 then
    return(0)
  end if
  tRoomComponent = tRoomThread.getComponent()
  executeMessage(#hide_navigator, #Remove)
  tMarker = tdata.getaProp(#room_marker)
  tRoomComponent.pRoomId = #game
  tSaveData = []
  tSaveData.setaProp(#type, #game)
  tSaveData.setaProp(#id, tMarker)
  tSaveData.setaProp(#marker, tMarker)
  tRoomComponent.pSaveData = tSaveData
  getObject(#session).set("lastroom", tSaveData.duplicate())
  me.roomConnected(tdata.getaProp(#room_program_class), tMarker)
  executeMessage(#gamesystem_sendevent, #msgstruct_gamereset, tMsg)
  me.updateProcess()
  return(1)
  exit
end

on exitArena(me)
  tRoomThread = getThread(#room)
  if tRoomThread = 0 then
    return(0)
  end if
  tComponent = tRoomThread.getComponent()
  tComponent.roomDisconnected()
  return(1)
  exit
end

on roomConnected(me, tClass, tMarker, tstate)
  tRoomThread = getThread(#room)
  if tRoomThread = 0 then
    return(0)
  end if
  tComponent = tRoomThread.getComponent()
  if voidp(tMarker) then
    error(me, "Missing room marker!!!", #roomConnected, #major)
  end if
  tComponent.setProp(#pSaveData, #marker, tMarker)
  tComponent.leaveRoom(1)
  if not tComponent.getInterface().showRoom(tMarker) then
    error(me, "Cannot showRoom:" && tMarker, #roomConnected)
    return(executeMessage(#leaveRoom))
  end if
  if memberExists(tClass) then
    createObject(tComponent.pRoomPrgID, tClass)
  end if
  tShadowManager = tComponent.getShadowManager()
  tShadowManager.define("roomShadow")
  return(1)
  exit
end

on updateProcess(me, tKey, tValue)
  tRoomThread = getThread(#room)
  if tRoomThread = 0 then
    return(0)
  end if
  tComponent = tRoomThread.getComponent()
  tComponent.getInterface().hideLoaderBar()
  tComponent.getInterface().hideTrashCover()
  tComponent.pActiveFlag = 1
  tComponent.setProp(#pChatProps, "mode", "CHAT")
  setcursor(#arrow)
  call(#prepare, [tComponent.getRoomPrg()])
  executeMessage(#roomReady)
  return(receivePrepare(tComponent.getID()))
  exit
end