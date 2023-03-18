property pState, pGameId, pMsecAtNextState

on construct me
  pGameId = "JoinedGame!"
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG GameInstanceData Class"]
  pState = 0
  return 1
end

on deconstruct me
  pState = 0
  return me.ancestor.deconstruct()
end

on displayEvent me, ttype, tParam
  case ttype of
    #pre_game:
      return me.displayPreGame(tParam)
    #user_left_game:
      return me.displayPlayerLeft(tParam)
    #arena_entered:
      return me.displayArenaEntered(tParam)
    #still_loading:
      return me.displayStillLoading(tParam)
    #stage_starting:
      return me.displayStageStarting(tParam)
  end case
  return 0
end

on getJoinedGame me
  return me.getListEntry(pGameId)
end

on getMsecAtNextState me
  return pMsecAtNextState
end

on displayPreGame me, tdata
  pState = 1
  if not listp(tdata) then
    return 0
  end if
  tdata.setaProp(#id, pGameId)
  me.updateEntry(tdata)
  executeMessage(#show_ig, "PreGame")
  executeMessage(#startChatDisplay)
  return 1
end

on displayPlayerLeft me, tID
  put "* PreGame.displayPlayerLeft" && tID
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tGameRef.removeUserFromGame([#id: tID])
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayPlayerLeft(tID)
  return 1
end

on displayArenaEntered me, tdata
  pMsecAtNextState = -1
  if not listp(tdata) then
    return 0
  end if
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tGameRef.addUserToGame(tdata)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayPlayer(tdata)
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tdata = tdata.duplicate()
  tFigureObj = getObject("Figure_System")
  if tFigureObj = 0 then
    return 0
  end if
  tdata.setaProp(#figure, tFigureObj.parseFigure(tdata.getaProp(#figure), tdata.getaProp(#sex), "user"))
  tdata.setaProp(#class, "user")
  tdata.setaProp(#id, string(tdata[#id]))
  tdata.setaProp(#direction, [0, 0])
  tRoomComponent.createUserObject(tdata)
  return 1
end

on displayStillLoading me, tdata
  if not listp(tdata) then
    return 0
  end if
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayProgress(tdata.getaProp(#progress))
  tFinished = tdata.getaProp(#finished_players)
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  repeat with tID in tFinished
    tPlayerInfo = tGameRef.getPlayerById(tID)
    if listp(tPlayerInfo) then
      tRenderObj.displayPlayerDone(tID, tPlayerInfo.getaProp(#figure), tPlayerInfo.getaProp(#sex))
      next repeat
    end if
    error(me, "Player left, not handled correctly..FIX!", #displayStillLoading)
  end repeat
  return 1
end

on displayStageStarting me, tdata
  tTimeLeftSec = tdata.getaProp(#time_to_stage_running)
  pMsecAtNextState = the milliSeconds + (tTimeLeftSec * 1000)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayCountdown()
  return 1
end
