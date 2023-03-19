property pState, pGameId, pNewGameId, pScoreIndex, pScoreIndexByRoomIndex, pScoreIndexByName, pOwnPlayerTeamId, pMsecAtNextState

on deconstruct me
  pState = 0
  return me.ancestor.deconstruct()
end

on Initialize me
  pGameId = "JoinedGame!"
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG GameInstanceData Class"]
  pState = 0
  pNewGameId = VOID
  return me.registerForIGComponentUpdates("GameList")
end

on handleUpdate me, tUpdateId, tSenderId
  case tSenderId of
    "GameList":
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      tGameRef = tService.getObservedGame()
      if tGameRef = 0 then
        return 0
      end if
      if voidp(pNewGameId) then
        pNewGameId = tService.getObservedGameId()
        tTeamData = tGameRef.getAllTeamData()
        repeat with tTeam in tTeamData
          tPlayers = tTeam.getaProp(#players)
          repeat with tPlayer in tPlayers
            me.displayPlayerRejoined(tPlayer)
          end repeat
        end repeat
      end if
  end case
  return 1
end

on displayEvent me, ttype, tParam
  case ttype of
    #after_game:
      return me.displayAfterGame(tParam)
    #user_left_game:
      return me.displayPlayerLeft(tParam)
    #user_joined_game:
      return me.displayPlayerRejoined(tParam)
    #time_to_next_state:
      return me.displayTimeLeft(tParam)
  end case
  return 0
end

on getMsecAtNextState me
  return pMsecAtNextState
end

on getScoreData me
  return me.getListEntry(pGameId)
end

on displayAfterGame me, tdata
  me.getComponent().setSystemState(#after_game)
  pNewGameId = VOID
  if not listp(tdata) then
    return 0
  end if
  me.storePlayerIndex(tdata)
  tdata.setaProp(#id, pGameId)
  me.updateEntry(tdata)
  pMsecAtNextState = the milliSeconds + (tdata.getaProp(#time_to_next_state) * 1000)
  pState = 1
  tRenderObj = me.getRenderer()
  if objectp(tRenderObj) then
    tRenderObj.pGameOverShown = 0
  end if
  executeMessage(#show_ig, "AfterGame")
  me.displayWinningTeam(tdata)
  return 1
end

on displayPlayerLeft me, tUserID
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if tUserID = -1 then
    return 0
  end if
  tPlayerInfo = me.getPlayerInfo(tUserID)
  if tPlayerInfo = 0 then
    return 0
  end if
  tPlayerInfo.setaProp(#disconnected, 1)
  tTeamId = tPlayerInfo.getaProp(#team_id)
  tName = tPlayerInfo.getaProp(#name)
  tText = replaceChunks(getText("ig_bubble_ag_userleft"), "\x", tName)
  executeMessage(#showCustomMessage, [#class: "IG Chat Bubble Info", #message: tText, #loc: point(450, 500), #color: me.getTeamColorDark(tTeamId)])
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayPlayerLeft(tPlayerInfo.getaProp(#team_pos), tPlayerInfo.getaProp(#pos))
  return 1
end

on displayPlayerRejoined me, tdata
  tUserID = tdata.getaProp(#id)
  tPlayerInfo = me.getPlayerInfoByName(tdata.getaProp(#name))
  if tPlayerInfo = 0 then
    return 0
  end if
  tPlayerInfo.setaProp(#rejoined, 1)
  tTeamId = tdata.getaProp(#team_id)
  tName = tdata.getaProp(#name)
  tText = replaceChunks(getText("ig_bubble_ag_userrejoined"), "\x", tName)
  executeMessage(#showCustomMessage, [#class: "IG Chat Bubble Info", #message: tText, #loc: point(450, 500), #color: me.getTeamColorDark(tTeamId)])
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.displayPlayerRejoined(tPlayerInfo.getaProp(#team_pos), tPlayerInfo.getaProp(#pos))
  return 1
end

on displayWinningTeam me, tdata
  tTeams = tdata.getaProp(#teams)
  if not listp(tTeams) then
    return 0
  end if
  tWinningTeam = tTeams[1]
  tTeamId = tWinningTeam.getaProp(#id)
  tText = getText("ig_bubble_ag_winner_" & tTeamId)
  executeMessage(#showCustomMessage, [#class: "IG Chat Bubble Info", #message: tText, #loc: point(450, 500), #color: me.getTeamColorDark(tTeamId)])
  if tTeamId = pOwnPlayerTeamId then
    playSound("ig-winning")
  else
    playSound("ig-losing")
  end if
  return 1
end

on displayTimeLeft me, tTime
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  return tRenderObj.displayTimeLeft(tTime)
end

on getTeamColorDark me, tTeamIndex
  case tTeamIndex of
    1:
      return rgb("#c64000")
    2:
      return rgb("#1971c3")
    3:
      return rgb("#659217")
    4:
      return rgb("#e19f00")
  end case
end

on storePlayerIndex me, tdata
  pScoreIndex = [:]
  pScoreIndexByRoomIndex = [:]
  pScoreIndexByName = [:]
  tTeams = tdata.getaProp(#teams)
  tOwnName = me.getOwnPlayerName()
  repeat with tTeam in tTeams
    tTeamPos = tTeam.getaProp(#pos)
    tPlayers = tTeam.getaProp(#players)
    repeat with tPlayer in tPlayers
      if tOwnName = tPlayer.getaProp(#name) then
        pOwnPlayerTeamId = tPlayer.getaProp(#team_id)
      end if
      tName = tPlayer.getaProp(#name)
      pScoreIndexByName.setaProp(tName, tPlayer)
      tID = tPlayer.getaProp(#id)
      pScoreIndex.setaProp(tID, tPlayer)
      tRoomIndex = tPlayer.getaProp(#room_index)
      pScoreIndexByRoomIndex.setaProp(tRoomIndex, tPlayer)
    end repeat
  end repeat
  return 1
end

on getPlayerInfoByRoomIndex me, tRoomIndex
  return pScoreIndexByRoomIndex.getaProp(tRoomIndex)
end

on getPlayerInfo me, tID
  return pScoreIndex.getaProp(tID)
end

on getPlayerInfoByName me, tName
  return pScoreIndexByName.getaProp(tName)
end
