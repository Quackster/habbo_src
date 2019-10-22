on addWindows me 
  me.pWindowID = "jg_m"
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_jnd_minimized.window", me.pWindowSetId)
  return TRUE
end

on render me 
  tListService = me.getIGComponent("GameList")
  if (tListService = 0) then
    return FALSE
  end if
  tItemRef = tListService.getJoinedGame()
  if (tItemRef = 0) then
    return(me.ChangeWindowView("GameList"))
  end if
  me.renderPlayerCount(tItemRef.getPlayerCount(), tItemRef.getMaxPlayerCount())
  tPropList = tItemRef.dump()
  i = 1
  repeat while i <= tPropList.count
    tKey = tPropList.getPropAt(i)
    tValue = tPropList.getAt(i)
    me.renderProperty(tKey, tValue)
    i = (1 + i)
  end repeat
  return TRUE
end

on renderProperty me, tKey, tValue 
  if (tKey = #game_type_icon) then
    return(me.renderType(tValue))
  else
    if (tKey = #level_name) then
      return(me.renderName(tValue))
    else
      if (tKey = #number_of_teams) then
        return(me.renderNumberOfTeams(tValue))
      end if
    end if
  end if
  return FALSE
end

on renderType me, tValue 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("info_gamemode")
  if (tElem = 0) then
    return FALSE
  end if
  if (ilk(tValue) = #image) then
    tElem.feedImage(tValue)
  end if
  return TRUE
end

on renderName me, tValue 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("ig_level_name")
  if (tElem = 0) then
    return FALSE
  end if
  tElem.setText(tValue)
  return TRUE
end

on renderNumberOfTeams me, tValue 
  if (tValue = void()) then
    return FALSE
  end if
  if tValue > 4 then
    return FALSE
  end if
  tMemName = ["ig_icon_teams_1", "ig_icon_teams_2", "ig_icon_teams_3", "ig_icon_teams_4"].getAt(tValue)
  tMemNum = getmemnum(tMemName)
  if (tMemNum = 0) then
    return FALSE
  end if
  tTempImage = member(tMemNum).image
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("info_team_amount")
  if (tElem = 0) then
    return FALSE
  end if
  if (ilk(tTempImage) = #image) then
    tElem.feedImage(tTempImage)
  end if
end

on renderPlayerCount me, tPlayerCount, tMaxPlayerCount 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("ig_players_joined")
  if (tElem = 0) then
    return FALSE
  end if
  tElem.setText(tPlayerCount & "/" & tMaxPlayerCount)
  return TRUE
end
