on addWindows me
  me.pWindowID = "list_det"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tSetID = me.pWindowSetId & "_c"
  tWrapObjRef.initSet(tSetID, 2)
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_level_highscores.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV: 1])
  me.renderButtons()
  return 1
end

on render me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tItemRef = tService.getObservedGame()
  if tItemRef = 0 then
    return 0
  end if
  tLevelData = tItemRef.getLevelHighscore()
  if tLevelData = 0 then
    return 0
  end if
  tTeamData = tItemRef.getLevelTeamHighscore()
  if tTeamData = 0 then
    return 0
  end if
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to tLevelData.count
    tItem = tLevelData[i]
    tElement = tWndObj.getElement("ig_highscore_player" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#name))
    end if
    tElement = tWndObj.getElement("ig_highscore_score" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#score))
    end if
  end repeat
  repeat with i = 1 to tTeamData.count
    tItem = tTeamData[i]
    tText = EMPTY
    tPlayers = tItem.getaProp(#players)
    repeat with tName in tPlayers
      tText = tText & tName & RETURN
    end repeat
    tElement = tWndObj.getElement("ig_teamhigh_team_" & i)
    if tElement <> 0 then
      tElement.setText(tText)
    end if
    tElement = tWndObj.getElement("ig_teamhigh_score_" & i)
    if tElement <> 0 then
      tElement.setText(tItem.getaProp(#score))
    end if
  end repeat
  tPropList = tItemRef.dump()
  repeat with i = 1 to tPropList.count
    tKey = tPropList.getPropAt(i)
    tValue = tPropList[i]
    me.renderProperty(tKey, tValue)
  end repeat
  me.renderButtons()
  return 1
end

on renderProperty me, tKey, tValue
  case tKey of
    #game_type_icon:
      return 1
    #game_type:
      return me.renderType(tValue)
  end case
  return me.ancestor.renderProperty(tKey, tValue)
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
  tMemNum = getmemnum("ig_icon_gamemode_" & tValue & "_b")
  if tMemNum > 0 then
    tElem.feedImage(member(tMemNum).image)
  end if
  return 1
end
