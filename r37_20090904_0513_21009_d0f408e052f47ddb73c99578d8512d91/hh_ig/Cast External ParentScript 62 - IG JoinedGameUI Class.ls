on construct me
  me.ancestor.construct()
  me.pViewModeComponents = [#Info: ["Details"], #change_team: ["ChangeTeam"], #highscore: ["Highscore"], #mini: ["Minimized"]]
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on setViewMode me, tMode
  tWrapObj = me.getWindowWrapper()
  if tWrapObj = 0 then
    return 0
  end if
  tRealLoc = tWrapObj.getRealLocation()
  me.ancestor.setViewMode(tMode)
  tWrapObj.moveTo(tRealLoc[1], tRealLoc[2])
end

on getSubComponentClass me, tID
  return ["IG JoinedGameUI Details Class", "IG JoinedGameUI" && tID && "Class"]
end

on getOwnPlayerName me
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  if not tSession.exists(#user_name) then
    return 0
  end if
  return tSession.GET(#user_name)
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  tListService = me.getIGComponent("GameList")
  if tListService = 0 then
    return 0
  end if
  tJoinedGameRef = tListService.getJoinedGame()
  if tJoinedGameRef = 0 then
    return 0
  end if
  tMainThreadRef = me.getMainThread()
  tIntParams = []
  repeat while integerp(integer(tSprID.char[tSprID.length]))
    tIntParam = 0
    tMultiplier = 1
    repeat while integerp(integer(tSprID.char[tSprID.length]))
      tIntParam = tIntParam + (tMultiplier * integer(tSprID.char[tSprID.length]))
      tSprID = tSprID.char[1..tSprID.length - 1]
      tMultiplier = tMultiplier * 10
    end repeat
    tIntParams.addAt(1, tIntParam)
    if tSprID.char[tSprID.length] = "_" then
      tSprID = tSprID.char[1..tSprID.length - 1]
    end if
  end repeat
  case tSprID of
    "ig_change_team.button":
      if tJoinedGameRef.getTeamCount() < 3 then
        return tListService.setNextTeamInJoinedGame()
      else
        return me.setViewMode(#change_team)
      end if
    "ig_icon_gamelist":
      return me.ChangeWindowView("GameList")
    "ig_minimize":
      return me.setViewMode(#mini)
    "ig_maximize", "ig_level_name", "ig_tab_gameinfo_bg", "info_gamemode":
      return me.setViewMode(#Info)
    "ig_tab_highscores":
      return me.setViewMode(#highscore)
    "ig_button_join_another_game":
      return me.ChangeWindowView("GameList")
    "ig_leave_game.button":
      return tListService.leaveJoinedGame(0)
    "ig_kick_team_player":
      if tIntParams.count <> 2 then
        return 0
      end if
      tTeamIndex = tIntParams[1]
      tPlayerIndex = tIntParams[2]
      tTeamData = tJoinedGameRef.getTeamPlayers(tTeamIndex)
      if tTeamData = 0 then
        return 0
      end if
      if tTeamData.count < tPlayerIndex then
        return 0
      end if
      tPlayerData = tTeamData[tPlayerIndex]
      if tPlayerData.getaProp(#name) = me.getOwnPlayerName() then
        return tListService.leaveJoinedGame(0)
      else
        return tMainThreadRef.getHandler().send_KICK_USER(tPlayerData.getaProp(#id))
      end if
    "join":
      me.setViewMode(#Info)
      if tIntParams.count <> 1 then
        return 0
      end if
      return tListService.setJoinedGameId(tListService.getJoinedGameId(), tIntParams[1])
  end case
  return 1
end
