property pWindowID, pDisplayedGameId

on construct me 
  me.pWindowID = "pj"
  return TRUE
end

on deconstruct me 
  me.getMasterIGComponent().unregisterFromIGComponentUpdates("GameList")
  removeWindow(pWindowID)
  return(me.ancestor.deconstruct())
end

on displayEvent me, ttype, tParam 
  me.getMasterIGComponent().setActiveFlag(1)
  if ttype <> #show then
    return FALSE
  end if
  if voidp(tParam) then
    return FALSE
  end if
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  if tService.getActiveFlag() then
    tService.setObservedGameId(tParam)
  else
    tService.setObservedGameIdExplicit(tParam)
  end if
  me.getMasterIGComponent().registerForIGComponentUpdates("GameList")
  me.render()
  return TRUE
end

on render me 
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "ig_prejoin.window")
    tWndObj = getWindow(pWindowID)
    if (tWndObj = 0) then
      return FALSE
    end if
    tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseDown)
    tLocX = 400
    tLocY = 150
    tWndObj.lock()
    tWndObj.moveTo(tLocX, tLocY)
  else
    tWndObj = getWindow(pWindowID)
    if (tWndObj = 0) then
      return FALSE
    end if
  end if
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tGameRef = tService.getObservedGame()
  if (tGameRef = 0) then
    return TRUE
  end if
  pDisplayedGameId = tGameRef.getProperty(#id)
  tElem = tWndObj.getElement("ig_level_name")
  if tElem <> 0 then
    tElem.setText(tGameRef.getProperty(#level_name))
  end if
  tImage = tGameRef.getProperty(#game_type_icon)
  tElem = tWndObj.getElement("info_gamemode")
  if tElem <> 0 and (tImage.ilk = #image) then
    tElem.feedImage(tImage)
  end if
  tMemNum = getmemnum("ig_icon_teams_" & tGameRef.getProperty(#number_of_teams))
  if tMemNum > 0 then
    tImage = member(tMemNum).image
    tElem = tWndObj.getElement("info_team_amount")
    if tElem <> 0 and (tImage.ilk = #image) then
      tElem.feedImage(tImage)
    end if
  end if
  tElem = tWndObj.getElement("ig_players_joined")
  if (tElem = 0) then
    return FALSE
  end if
  tElem.setText(tGameRef.getProperty(#player_count) & "/" & tGameRef.getProperty(#player_max_count))
  return TRUE
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID 
  if (tSprID = "drag") then
    return TRUE
  else
    if tSprID <> "ig_close" then
      if (tSprID = "ig_prejoin_no.button") then
        tService = me.getIGComponent("GameList")
        if (tService = 0) then
          return FALSE
        end if
        tService.setObservedGameId(-1)
        return(me.Remove())
      else
        if (tSprID = "ig_prejoin_yes.button") then
          tService = me.getIGComponent("GameList")
          if (tService = 0) then
            return FALSE
          end if
          executeMessage(#sendTrackingPoint, "/game/joined/icon")
          return(tService.joinTeamWithLeastMembers(pDisplayedGameId))
        end if
      end if
      executeMessage(#show_ig, "GameList")
      return(me.Remove())
      return TRUE
    end if
  end if
end
