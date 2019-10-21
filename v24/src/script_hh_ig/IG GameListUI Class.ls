on construct(me)
  me.construct()
  me.pViewMode = #info
  me.pViewModeComponents = [#info:["List", "Details"], #highscore:["List", "Highscore"]]
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on getGameTypeHandlerClass(me, tGameType)
  tGameTypeService = me.getIGComponent("GameTypes")
  if tGameTypeService = 0 then
    return(0)
  end if
  tTypeStr = tGameTypeService.getGameTypeString(tGameType)
  tMemName = "IG GameListUI" && tTypeStr && "Class"
  if not memberExists(tMemName) then
    tClass = "IG GameListUI Details Class"
  else
    tClass = ["IG GameListUI Details Class", tMemName]
  end if
  return(tClass)
  exit
end

on getSubComponent(me, tID, tAddIfMissing)
  tObject = me.getaProp(tID)
  if tObject <> 0 then
    return(tObject)
  end if
  if not tAddIfMissing then
    return(0)
  end if
  if me = "Highscore" then
    tClass = ["IG GameListUI Details Class", "IG GameListUI Highscore Class"]
  else
    if me = "Details" then
      tService = me.getMasterIGComponent()
      if tService = 0 then
        return(0)
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
    else
      tClass = "IG GameListUI" && tID && "Class"
    end if
  end if
  return(me.initializeSubComponent(tID, tClass))
  exit
end

on getOwnPlayerName(me)
  tSession = getObject(#session)
  if tSession = 0 then
    return(0)
  end if
  return(tSession.GET(#user_name))
  exit
end

on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  tListService = me.getIGComponent("GameList")
  if tListService = 0 then
    return(0)
  end if
  tJoinedGameRef = tListService.getJoinedGame()
  tJoinedGameId = tListService.getJoinedGameId()
  tObservedGameId = tListService.getObservedGameId()
  if me = "join_game.button" then
    executeMessage(#sendTrackingPoint, "/game/joined/ui")
    return(tListService.joinTeamWithLeastMembers(tObservedGameId))
  else
    if me = "leave_game.button" then
      tListService.leaveJoinedGame(1)
      return(executeMessage(#show_ig, "GameList"))
    else
      if me = "ig_owngame_back.button" then
        return(me.ChangeWindowView("JoinedGame"))
      else
        if me = "ig_tab_highscores" then
          return(me.setViewMode(#highscore))
        else
          if me <> "ig_level_name" then
            if me = "ig_tab_gameinfo" then
              return(me.setViewMode(#info))
            end if
            tComponent = me.getSubComponent("List", 0)
            if tComponent <> 0 then
              tComponent.eventProcMouseDown(tEvent, tSprID, tParam, tWndID)
            end if
            tComponent = me.getSubComponent("Details", 0)
            if tComponent <> 0 then
              tComponent.eventProcMouseDown(tEvent, tSprID, tParam, tWndID)
            end if
            return(1)
            exit
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover(me, tEvent, tSprID, tParam, tWndID)
  tComponent = me.getSubComponent("Details", 0)
  if tComponent <> 0 then
    return(call(#eventProcMouseHover, [tComponent], tEvent, tSprID, tParam, tWndID))
  end if
  return(0)
  exit
end