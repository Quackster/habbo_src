on construct(me)
  me.construct()
  me.pViewMode = #game_score
  pGameOverShown = 0
  me.setaProp(#game_score, [#modal, "Gameover", "GameScore", "ReplayQuery", "HighscoreButton"])
  me.setaProp(#alltime_score, [#modal, "AlltimeScore", "ReplayQuery", "GamescoreButton"])
  me.setaProp(#rejoin, [#modal, "Rejoin"])
  return(1)
  exit
end

on displayPlayerLeft(me, tTeamId, tPlayerPos)
  if me.pViewMode <> #game_score then
    return(1)
  end if
  tComponent = me.getSubComponent("GameScore")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.displayPlayerLeft(tTeamId, tPlayerPos))
  exit
end

on displayPlayerRejoined(me, tTeamId, tPlayerPos)
  if me.pViewMode = #game_score then
    tComponent = me.getSubComponent("GameScore")
    if tComponent = 0 then
      return(0)
    end if
    return(tComponent.displayPlayerRejoined(tTeamId, tPlayerPos))
  else
    if me.pViewMode = #rejoin then
      tComponent = me.getSubComponent("Rejoin")
      if tComponent = 0 then
        return(0)
      end if
      return(tComponent.render())
    end if
  end if
  exit
end

on displayTimeLeft(me, tTime)
  tComponent = me.getSubComponent("Rejoin")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.displayTimeLeft(tTime))
  exit
end

on update(me)
  tComponent = me.getSubComponent("Gameover")
  if tComponent <> 0 then
    tComponent.update()
  end if
  tComponent = me.getSubComponent("Rejoin")
  if tComponent <> 0 then
    tComponent.update()
  end if
  return(1)
  exit
end

on getSubComponentClass(me, tID)
  if tID = "Gameover" then
    if pGameOverShown then
      return([])
    end if
    pGameOverShown = 1
  end if
  return(["IG TeamUI Subcomponent Class", "IG AfterGameUI" && tID && "Class"])
  exit
end

on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  if me <> "playagain_no.button" then
    if me = "ig_link_leave_game" then
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return(0)
      end if
      tService.leaveJoinedGame(0)
      me.getComponent().setSystemState(#ready)
      return(me.getHandler().send_EXIT_GAME(1))
    else
      if me = "playagain_yes.button" then
        executeMessage(#sendTrackingPoint, "/game/joined/replay")
        return(me.getHandler().send_PLAY_AGAIN())
      else
        if me = "join.button" then
          tTeamIndex = integer(tWndID.getProp(#char, tWndID.length))
          if not integerp(tTeamIndex) then
            return(0)
          end if
          tService = me.getIGComponent("GameList")
          if tService = 0 then
            return(0)
          end if
          return(tService.setJoinedGameId(tService.getJoinedGameId(), tTeamIndex))
        else
          if me <> "ig_tip_title" then
            if me <> "ig_title_bg" then
              if me <> "ig_tip_close" then
                if me = "ig_title_bg_light" then
                  tFlagManager = me.getFlagManager()
                  if tFlagManager = 0 then
                    return(0)
                  end if
                  if tEvent = #mouseDown then
                    if tFlagManager.getFlagState(tWndID) then
                      return(tFlagManager.Remove(tWndID))
                    end if
                  end if
                  return(tFlagManager.toggle(tWndID))
                else
                  if me = "ig_link_highscores_show" then
                    return(me.setViewMode(#alltime_score))
                  else
                    if me = "ig_link_highscores_hide" then
                      return(me.setViewMode(#game_score))
                    end if
                  end if
                end if
                return(1)
                exit
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover(me, tEvent, tSprID, tParam, tWndID, tTargetID)
  if me <> "ig_tip_title" then
    if me <> "ig_title_bg" then
      if me <> "ig_tip_close" then
        if me = "ig_title_bg_light" then
          tFlagManager = me.getFlagManager()
          if tFlagManager = 0 then
            return(0)
          end if
          if tEvent = #mouseEnter then
            tFlagManager.open(tWndID)
          else
            tFlagManager.close(tWndID)
          end if
          return(1)
        end if
        return(0)
        exit
      end if
    end if
  end if
end