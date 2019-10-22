property pGameId, pMsecAtNextState

on construct me 
  pGameId = "JoinedGame!"
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG GameInstanceData Class"]
  pState = 0
  return TRUE
end

on deconstruct me 
  pState = 0
  return(me.ancestor.deconstruct())
end

on displayEvent me, ttype, tParam 
  if (ttype = #pre_game) then
    return(me.displayPreGame(tParam))
  else
    if (ttype = #user_left_game) then
      return(me.displayPlayerLeft(tParam))
    else
      if (ttype = #arena_entered) then
        return(me.displayArenaEntered(tParam))
      else
        if (ttype = #still_loading) then
          return(me.displayStillLoading(tParam))
        else
          if (ttype = #stage_starting) then
            return(me.displayStageStarting(tParam))
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on getJoinedGame me 
  return(me.getListEntry(pGameId))
end

on getMsecAtNextState me 
  return(pMsecAtNextState)
end

on displayPreGame me, tdata 
  pState = 1
  if not listp(tdata) then
    return FALSE
  end if
  tdata.setaProp(#id, pGameId)
  me.updateEntry(tdata)
  executeMessage(#show_ig, "PreGame")
  executeMessage(#startChatDisplay)
  return TRUE
end

on displayPlayerLeft me, tID 
  put("* PreGame.displayPlayerLeft" && tID)
  tGameRef = me.getJoinedGame()
  if (tGameRef = 0) then
    return FALSE
  end if
  tGameRef.removeUserFromGame([#id:tID])
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.displayPlayerLeft(tID)
  return TRUE
end

on displayArenaEntered me, tdata 
  pMsecAtNextState = -1
  if not listp(tdata) then
    return FALSE
  end if
  tGameRef = me.getJoinedGame()
  if (tGameRef = 0) then
    return FALSE
  end if
  tGameRef.addUserToGame(tdata)
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.displayPlayer(tdata)
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tdata = tdata.duplicate()
  tFigureObj = getObject("Figure_System")
  if (tFigureObj = 0) then
    return FALSE
  end if
  tdata.setaProp(#figure, tFigureObj.parseFigure(tdata.getaProp(#figure), tdata.getaProp(#sex), "user"))
  tdata.setaProp(#class, "user")
  tdata.setaProp(#id, string(tdata.getAt(#id)))
  tdata.setaProp(#direction, [0, 0])
  tRoomComponent.createUserObject(tdata)
  return TRUE
end

on displayStillLoading me, tdata 
  if not listp(tdata) then
    return FALSE
  end if
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.displayProgress(tdata.getaProp(#progress))
  tFinished = tdata.getaProp(#finished_players)
  tGameRef = me.getJoinedGame()
  if (tGameRef = 0) then
    return FALSE
  end if
  repeat while tFinished <= undefined
    tID = getAt(undefined, tdata)
    tPlayerInfo = tGameRef.getPlayerById(tID)
    if listp(tPlayerInfo) then
      tRenderObj.displayPlayerDone(tID, tPlayerInfo.getaProp(#figure), tPlayerInfo.getaProp(#sex))
    else
      error(me, "Player left, not handled correctly..FIX!", #displayStillLoading)
    end if
  end repeat
  return TRUE
end

on displayStageStarting me, tdata 
  tTimeLeftSec = tdata.getaProp(#time_to_stage_running)
  pMsecAtNextState = (the milliSeconds + (tTimeLeftSec * 1000))
  tRenderObj = me.getRenderer()
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.displayCountdown()
  return TRUE
end
