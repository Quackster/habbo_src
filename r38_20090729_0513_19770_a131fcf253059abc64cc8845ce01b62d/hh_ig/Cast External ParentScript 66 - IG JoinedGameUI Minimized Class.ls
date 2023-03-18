on addWindows me
  me.pWindowID = "jg_m"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_jnd_minimized.window", me.pWindowSetId)
  return 1
end

on render me
  tListService = me.getIGComponent("GameList")
  if tListService = 0 then
    return 0
  end if
  tItemRef = tListService.getJoinedGame()
  if tItemRef = 0 then
    return me.ChangeWindowView("GameList")
  end if
  me.renderPlayerCount(tItemRef.getPlayerCount(), tItemRef.getMaxPlayerCount())
  tPropList = tItemRef.dump()
  repeat with i = 1 to tPropList.count
    tKey = tPropList.getPropAt(i)
    tValue = tPropList[i]
    me.renderProperty(tKey, tValue)
  end repeat
  return 1
end

on renderProperty me, tKey, tValue
  case tKey of
    #game_type_icon:
      return me.renderType(tValue)
    #level_name:
      return me.renderName(tValue)
    #number_of_teams:
      return me.renderNumberOfTeams(tValue)
  end case
  return 0
end

on renderType me, tValue
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("info_gamemode")
  if tElem = 0 then
    return 0
  end if
  if ilk(tValue) = #image then
    tElem.feedImage(tValue)
  end if
  return 1
end

on renderName me, tValue
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_level_name")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(tValue)
  return 1
end

on renderNumberOfTeams me, tValue
  if tValue = VOID then
    return 0
  end if
  if tValue > 4 then
    return 0
  end if
  tMemName = ["ig_icon_teams_1", "ig_icon_teams_2", "ig_icon_teams_3", "ig_icon_teams_4"][tValue]
  tMemNum = getmemnum(tMemName)
  if tMemNum = 0 then
    return 0
  end if
  tTempImage = member(tMemNum).image
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("info_team_amount")
  if tElem = 0 then
    return 0
  end if
  if ilk(tTempImage) = #image then
    tElem.feedImage(tTempImage)
  end if
end

on renderPlayerCount me, tPlayerCount, tMaxPlayerCount
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_players_joined")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(tPlayerCount & "/" & tMaxPlayerCount)
  return 1
end
