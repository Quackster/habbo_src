on construct(me)
  pGameId = "JoinedGame!"
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG GameInstanceData Class"]
  pState = 0
  return(1)
  exit
end

on deconstruct(me)
  pState = 0
  return(me.deconstruct())
  exit
end

on displayEvent(me, ttype, tParam)
  if me = #pre_game then
    return(me.displayPreGame(tParam))
  else
    if me = #user_left_game then
      return(me.displayPlayerLeft(tParam))
    else
      if me = #arena_entered then
        return(me.displayArenaEntered(tParam))
      else
        if me = #still_loading then
          return(me.displayStillLoading(tParam))
        else
          if me = #stage_starting then
            return(me.displayStageStarting(tParam))
          end if
        end if
      end if
    end if
  end if
  return(0)
  exit
end

on getJoinedGame(me)
  return(me.getListEntry(pGameId))
  exit
end

on getMsecAtNextState(me)
  return(pMsecAtNextState)
  exit
end

on displayPreGame(me, tdata)
  pState = 1
  if not listp(tdata) then
    return(0)
  end if
  tdata.setaProp(#id, pGameId)
  me.updateEntry(tdata)
  executeMessage(#show_ig, "PreGame")
  executeMessage(#startChatDisplay)
  return(1)
  exit
end

on displayPlayerLeft(me, tID)
  put("* PreGame.displayPlayerLeft" && tID)
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return(0)
  end if
  tGameRef.removeUserFromGame([#id:tID])
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.displayPlayerLeft(tID)
  return(1)
  exit
end

on displayArenaEntered(me, tdata)
  pMsecAtNextState = -1
  if not listp(tdata) then
    return(0)
  end if
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return(0)
  end if
  tGameRef.addUserToGame(tdata)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.displayPlayer(tdata)
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return(0)
  end if
  tdata = tdata.duplicate()
  tFigureObj = getObject("Figure_System")
  if tFigureObj = 0 then
    return(0)
  end if
  tdata.setaProp(#figure, tFigureObj.parseFigure(tdata.getaProp(#figure), tdata.getaProp(#sex), "user"))
  tdata.setaProp(#class, "user")
  tdata.setaProp(#id, string(tdata.getAt(#id)))
  tdata.setaProp(#direction, [0, 0])
  tRoomComponent.createUserObject(tdata)
  return(1)
  exit
end

on displayStillLoading(me, tdata)
  if not listp(tdata) then
    return(0)
  end if
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.displayProgress(tdata.getaProp(#progress))
  tFinished = tdata.getaProp(#finished_players)
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return(0)
  end if
  repeat while me <= undefined
    tID = getAt(undefined, tdata)
    tPlayerInfo = tGameRef.getPlayerById(tID)
    if listp(tPlayerInfo) then
      tRenderObj.displayPlayerDone(tID, tPlayerInfo.getaProp(#figure), tPlayerInfo.getaProp(#sex))
    else
      error(me, "Player left, not handled correctly..FIX!", #displayStillLoading)
    end if
  end repeat
  return(1)
  exit
end

on displayStageStarting(me, tdata)
  tTimeLeftSec = tdata.getaProp(#time_to_stage_running)
  pMsecAtNextState = the milliSeconds + tTimeLeftSec * 1000
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.displayCountdown()
  return(1)
  exit
end