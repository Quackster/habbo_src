on construct me 
  me.ancestor.construct()
  me.pViewModeComponents = [#info:["Details"], #change_team:["ChangeTeam"], #highscore:["Highscore"], #mini:["Minimized"]]
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on setViewMode me, tMode 
  tWrapObj = me.getWindowWrapper()
  if (tWrapObj = 0) then
    return FALSE
  end if
  tRealLoc = tWrapObj.getRealLocation()
  me.ancestor.setViewMode(tMode)
  tWrapObj.moveTo(tRealLoc.getAt(1), tRealLoc.getAt(2))
end

on getSubComponentClass me, tID 
  return(["IG JoinedGameUI Details Class", "IG JoinedGameUI" && tID && "Class"])
end

on getOwnPlayerName me 
  tSession = getObject(#session)
  if (tSession = 0) then
    return FALSE
  end if
  if not tSession.exists(#user_name) then
    return FALSE
  end if
  return(tSession.GET(#user_name))
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID 
  tListService = me.getIGComponent("GameList")
  if (tListService = 0) then
    return FALSE
  end if
  tJoinedGameRef = tListService.getJoinedGame()
  if (tJoinedGameRef = 0) then
    return FALSE
  end if
  tMainThreadRef = me.getMainThread()
  tIntParams = []
  repeat while integerp(integer(tSprID.getProp(#char, tSprID.length)))
    tIntParam = 0
    tMultiplier = 1
    repeat while integerp(integer(tSprID.getProp(#char, tSprID.length)))
      tIntParam = (tIntParam + (tMultiplier * integer(tSprID.getProp(#char, tSprID.length))))
      tSprID = tSprID.getProp(#char, 1, (tSprID.length - 1))
      tMultiplier = (tMultiplier * 10)
    end repeat
    tIntParams.addAt(1, tIntParam)
    if (tSprID.getProp(#char, tSprID.length) = "_") then
      tSprID = tSprID.getProp(#char, 1, (tSprID.length - 1))
    end if
  end repeat
  if (tSprID = "ig_change_team.button") then
    if tJoinedGameRef.getTeamCount() < 3 then
      return(tListService.setNextTeamInJoinedGame())
    else
      return(me.setViewMode(#change_team))
    end if
  else
    if (tSprID = "ig_icon_gamelist") then
      return(me.ChangeWindowView("GameList"))
    else
      if (tSprID = "ig_minimize") then
        return(me.setViewMode(#mini))
      else
        if tSprID <> "ig_maximize" then
          if tSprID <> "ig_level_name" then
            if tSprID <> "ig_tab_gameinfo_bg" then
              if (tSprID = "info_gamemode") then
                return(me.setViewMode(#info))
              else
                if (tSprID = "ig_tab_highscores") then
                  return(me.setViewMode(#highscore))
                else
                  if (tSprID = "ig_button_join_another_game") then
                    return(me.ChangeWindowView("GameList"))
                  else
                    if (tSprID = "ig_leave_game.button") then
                      return(tListService.leaveJoinedGame(0))
                    else
                      if (tSprID = "ig_kick_team_player") then
                        if tIntParams.count <> 2 then
                          return FALSE
                        end if
                        tTeamIndex = tIntParams.getAt(1)
                        tPlayerIndex = tIntParams.getAt(2)
                        tTeamData = tJoinedGameRef.getTeamPlayers(tTeamIndex)
                        if (tTeamData = 0) then
                          return FALSE
                        end if
                        if tTeamData.count < tPlayerIndex then
                          return FALSE
                        end if
                        tPlayerData = tTeamData.getAt(tPlayerIndex)
                        if (tPlayerData.getaProp(#name) = me.getOwnPlayerName()) then
                          return(tListService.leaveJoinedGame(0))
                        else
                          return(tMainThreadRef.getHandler().send_KICK_USER(tPlayerData.getaProp(#id)))
                        end if
                      else
                        if (tSprID = "join") then
                          me.setViewMode(#info)
                          if tIntParams.count <> 1 then
                            return FALSE
                          end if
                          return(tListService.setJoinedGameId(tListService.getJoinedGameId(), tIntParams.getAt(1)))
                        end if
                      end if
                    end if
                  end if
                end if
              end if
              return TRUE
            end if
          end if
        end if
      end if
    end if
  end if
end
