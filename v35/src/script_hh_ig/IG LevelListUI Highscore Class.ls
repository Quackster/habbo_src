on addWindows me 
  me.pWindowID = "cr"
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tSetID = me.pWindowSetId & "_c"
  tWrapObjRef.initSet(tSetID, 3)
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_level_highscores.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV:1])
  tWrapObjRef.addOneWindow(me.getWindowId("btn_j"), "ig_frame_create_btm.window", tSetID)
  return TRUE
end

on render me 
  tService = me.getIGComponent("LevelList")
  if (tService = 0) then
    return FALSE
  end if
  tItemRef = tService.getSelectedLevel()
  if (tItemRef = 0) then
    return FALSE
  end if
  tLevelData = tItemRef.getLevelHighscore()
  if (tLevelData = 0) then
    return FALSE
  end if
  tTeamData = tItemRef.getLevelTeamHighscore()
  if (tTeamData = 0) then
    return FALSE
  end if
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  i = 1
  repeat while i <= tLevelData.count
    tItem = tLevelData.getAt(i)
    tElement = tWndObj.getElement("ig_highscore_player" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#name))
    end if
    tElement = tWndObj.getElement("ig_highscore_score" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#score))
    end if
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tTeamData.count
    tItem = tTeamData.getAt(i)
    tText = ""
    tPlayers = tItem.getaProp(#players)
    repeat while tPlayers <= undefined
      tName = getAt(undefined, undefined)
      tText = tText & tName & "\r"
    end repeat
    tElement = tWndObj.getElement("ig_teamhigh_team_" & i)
    if tElement <> 0 then
      tElement.setText(tText)
    end if
    tElement = tWndObj.getElement("ig_teamhigh_score_" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#score))
    end if
    i = (1 + i)
  end repeat
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
    return TRUE
  else
    if (tKey = #game_type) then
      return(me.renderType(tValue))
    end if
  end if
  return(me.ancestor.renderProperty(tKey, tValue))
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
  tMemNum = getmemnum("ig_icon_gamemode_" & tValue & "_b")
  if tMemNum > 0 then
    tElem.feedImage(member(tMemNum).image)
  end if
  return TRUE
end
