on construct me
  me.ancestor.construct()
  me.pViewMode = #Info
  me.pViewModeComponents = [#Info: ["List", "Details"], #highscore: ["List", "Highscore"]]
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on getGameTypeHandlerClass me, tGameType
  tGameTypeService = me.getIGComponent("GameTypes")
  if tGameTypeService = 0 then
    return 0
  end if
  tTypeStr = tGameTypeService.getGameTypeString(tGameType)
  tMemName = "IG GameListUI" && tTypeStr && "Class"
  if not memberExists(tMemName) then
    tClass = "IG GameListUI Details Class"
  else
    tClass = ["IG GameListUI Details Class", tMemName]
  end if
  return tClass
end

on getSubComponent me, tID, tAddIfMissing
  tObject = me.pSubComponentList.getaProp(tID)
  if tObject <> 0 then
    return tObject
  end if
  if not tAddIfMissing then
    return 0
  end if
  case tID of
    "Highscore":
      tClass = ["IG GameListUI Details Class", "IG GameListUI Highscore Class"]
    "Details":
      tService = me.getMasterIGComponent()
      if tService = 0 then
        return 0
      end if
      tItemRef = tService.getObservedGame()
      if tItemRef = 0 then
        tItemRef = tService.getJoinedGame()
      end if
      if tItemRef = 0 then
        tClass = me.getGameTypeHandlerClass()
      else
        tClass = me.getGameTypeHandlerClass(tItemRef.getProperty(#game_type))
      end if
    otherwise:
      tClass = "IG GameListUI" && tID && "Class"
  end case
  return me.initializeSubComponent(tID, tClass)
end

on getOwnPlayerName me
  tSession = getObject(#session)
  if tSession = 0 then
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
  tJoinedGameId = tListService.getJoinedGameId()
  tObservedGameId = tListService.getObservedGameId()
  case tSprID of
    "join_game.button":
      executeMessage(#sendTrackingPoint, "/game/joined/ui")
      return tListService.joinTeamWithLeastMembers(tObservedGameId)
    "leave_game.button":
      tListService.leaveJoinedGame(1)
      return executeMessage(#show_ig, "GameList")
    "ig_owngame_back.button":
      return me.ChangeWindowView("JoinedGame")
    "ig_tab_highscores":
      return me.setViewMode(#highscore)
    "ig_level_name", "ig_tab_gameinfo":
      return me.setViewMode(#Info)
  end case
  tComponent = me.getSubComponent("List", 0)
  if tComponent <> 0 then
    tComponent.eventProcMouseDown(tEvent, tSprID, tParam, tWndID)
  end if
  tComponent = me.getSubComponent("Details", 0)
  if tComponent <> 0 then
    tComponent.eventProcMouseDown(tEvent, tSprID, tParam, tWndID)
  end if
  return 1
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID
  tComponent = me.getSubComponent("Details", 0)
  if tComponent <> 0 then
    return call(#eventProcMouseHover, [tComponent], tEvent, tSprID, tParam, tWndID)
  end if
  return 0
end
