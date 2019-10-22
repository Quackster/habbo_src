property pGameOverShown

on construct me 
  me.ancestor.construct()
  me.pViewMode = #game_score
  pGameOverShown = 0
  me.pViewModeComponents.setaProp(#game_score, [#modal, "Gameover", "GameScore", "ReplayQuery", "HighscoreButton"])
  me.pViewModeComponents.setaProp(#alltime_score, [#modal, "AlltimeScore", "ReplayQuery", "GamescoreButton"])
  me.pViewModeComponents.setaProp(#rejoin, [#modal, "Rejoin"])
  return TRUE
end

on displayPlayerLeft me, tTeamId, tPlayerPos 
  if me.pViewMode <> #game_score then
    return TRUE
  end if
  tComponent = me.getSubComponent("GameScore")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.displayPlayerLeft(tTeamId, tPlayerPos))
end

on displayPlayerRejoined me, tTeamId, tPlayerPos 
  if (me.pViewMode = #game_score) then
    tComponent = me.getSubComponent("GameScore")
    if (tComponent = 0) then
      return FALSE
    end if
    return(tComponent.displayPlayerRejoined(tTeamId, tPlayerPos))
  else
    if (me.pViewMode = #rejoin) then
      tComponent = me.getSubComponent("Rejoin")
      if (tComponent = 0) then
        return FALSE
      end if
      return(tComponent.render())
    end if
  end if
end

on displayTimeLeft me, tTime 
  tComponent = me.getSubComponent("Rejoin")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.displayTimeLeft(tTime))
end

on update me 
  tComponent = me.getSubComponent("Gameover")
  if tComponent <> 0 then
    tComponent.update()
  end if
  tComponent = me.getSubComponent("Rejoin")
  if tComponent <> 0 then
    tComponent.update()
  end if
  return TRUE
end

on getSubComponentClass me, tID 
  if (tID = "Gameover") then
    if pGameOverShown then
      return([])
    end if
    pGameOverShown = 1
  end if
  return(["IG TeamUI Subcomponent Class", "IG AfterGameUI" && tID && "Class"])
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID 
  if tSprID <> "playagain_no.button" then
    if (tSprID = "ig_link_leave_game") then
      tService = me.getIGComponent("GameList")
      if (tService = 0) then
        return FALSE
      end if
      tService.leaveJoinedGame(0)
      me.getComponent().setSystemState(#ready)
      return(me.getHandler().send_EXIT_GAME(1))
    else
      if (tSprID = "playagain_yes.button") then
        executeMessage(#sendTrackingPoint, "/game/joined/replay")
        return(me.getHandler().send_PLAY_AGAIN())
      else
        if (tSprID = "join.button") then
          tTeamIndex = integer(tWndID.getProp(#char, tWndID.length))
          if not integerp(tTeamIndex) then
            return FALSE
          end if
          tService = me.getIGComponent("GameList")
          if (tService = 0) then
            return FALSE
          end if
          return(tService.setJoinedGameId(tService.getJoinedGameId(), tTeamIndex))
        else
          if tSprID <> "ig_tip_title" then
            if tSprID <> "ig_title_bg" then
              if tSprID <> "ig_tip_close" then
                if (tSprID = "ig_title_bg_light") then
                  tFlagManager = me.getFlagManager()
                  if (tFlagManager = 0) then
                    return FALSE
                  end if
                  if (tEvent = #mouseDown) then
                    if tFlagManager.getFlagState(tWndID) then
                      return(tFlagManager.Remove(tWndID))
                    end if
                  end if
                  return(tFlagManager.toggle(tWndID))
                else
                  if (tSprID = "ig_link_highscores_show") then
                    return(me.setViewMode(#alltime_score))
                  else
                    if (tSprID = "ig_link_highscores_hide") then
                      return(me.setViewMode(#game_score))
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
  end if
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID, tTargetID 
  if tSprID <> "ig_tip_title" then
    if tSprID <> "ig_title_bg" then
      if tSprID <> "ig_tip_close" then
        if (tSprID = "ig_title_bg_light") then
          tFlagManager = me.getFlagManager()
          if (tFlagManager = 0) then
            return FALSE
          end if
          if (tEvent = #mouseEnter) then
            tFlagManager.open(tWndID)
          else
            tFlagManager.close(tWndID)
          end if
          return TRUE
        end if
        return FALSE
      end if
    end if
  end if
end
