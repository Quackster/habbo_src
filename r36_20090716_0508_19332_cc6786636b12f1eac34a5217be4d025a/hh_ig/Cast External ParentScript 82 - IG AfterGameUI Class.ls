property pGameOverShown

on construct me
  me.ancestor.construct()
  me.pViewMode = #game_score
  pGameOverShown = 0
  me.pViewModeComponents.setaProp(#game_score, [#modal, "Gameover", "GameScore", "ReplayQuery", "HighscoreButton"])
  me.pViewModeComponents.setaProp(#alltime_score, [#modal, "AlltimeScore", "ReplayQuery", "GamescoreButton"])
  me.pViewModeComponents.setaProp(#rejoin, [#modal, "Rejoin"])
  return 1
end

on displayPlayerLeft me, tTeamId, tPlayerPos
  if me.pViewMode <> #game_score then
    return 1
  end if
  tComponent = me.getSubComponent("GameScore")
  if tComponent = 0 then
    return 0
  end if
  return tComponent.displayPlayerLeft(tTeamId, tPlayerPos)
end

on displayPlayerRejoined me, tTeamId, tPlayerPos
  if me.pViewMode = #game_score then
    tComponent = me.getSubComponent("GameScore")
    if tComponent = 0 then
      return 0
    end if
    return tComponent.displayPlayerRejoined(tTeamId, tPlayerPos)
  else
    if me.pViewMode = #rejoin then
      tComponent = me.getSubComponent("Rejoin")
      if tComponent = 0 then
        return 0
      end if
      return tComponent.render()
    end if
  end if
end

on displayTimeLeft me, tTime
  tComponent = me.getSubComponent("Rejoin")
  if tComponent = 0 then
    return 0
  end if
  return tComponent.displayTimeLeft(tTime)
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
  return 1
end

on getSubComponentClass me, tID
  if tID = "Gameover" then
    if pGameOverShown then
      return []
    end if
    pGameOverShown = 1
  end if
  return ["IG TeamUI Subcomponent Class", "IG AfterGameUI" && tID && "Class"]
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  case tSprID of
    "playagain_no.button", "ig_link_leave_game":
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      tService.leaveJoinedGame(0)
      me.getComponent().setSystemState(#ready)
      return me.getHandler().send_EXIT_GAME(1)
    "playagain_yes.button":
      executeMessage(#sendTrackingPoint, "/game/joined/replay")
      return me.getHandler().send_PLAY_AGAIN()
    "join.button":
      tTeamIndex = integer(tWndID.char[tWndID.length])
      if not integerp(tTeamIndex) then
        return 0
      end if
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      return tService.setJoinedGameId(tService.getJoinedGameId(), tTeamIndex)
    "ig_tip_title", "ig_title_bg", "ig_tip_close", "ig_title_bg_light":
      tFlagManager = me.getFlagManager()
      if tFlagManager = 0 then
        return 0
      end if
      if tEvent = #mouseDown then
        if tFlagManager.getFlagState(tWndID) then
          return tFlagManager.Remove(tWndID)
        end if
      end if
      return tFlagManager.toggle(tWndID)
    "ig_link_highscores_show":
      return me.setViewMode(#alltime_score)
    "ig_link_highscores_hide":
      return me.setViewMode(#game_score)
  end case
  return 1
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID, tTargetID
  case tSprID of
    "ig_tip_title", "ig_title_bg", "ig_tip_close", "ig_title_bg_light":
      tFlagManager = me.getFlagManager()
      if tFlagManager = 0 then
        return 0
      end if
      if tEvent = #mouseEnter then
        tFlagManager.open(tWndID)
      else
        tFlagManager.close(tWndID)
      end if
      return 1
  end case
  return 0
end
