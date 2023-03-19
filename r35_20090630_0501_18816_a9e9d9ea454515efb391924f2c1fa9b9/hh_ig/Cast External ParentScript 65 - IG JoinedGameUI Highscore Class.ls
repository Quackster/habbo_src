property pPreviousLayout

on addWindows me
  me.pWindowID = "jg"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), VOID, me.pWindowSetId)
  return 1
end

on render me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tItemRef = tService.getJoinedGame()
  if tItemRef = 0 then
    return 0
  end if
  me.pOwnerFlag = tItemRef.checkIfOwnerOfGame()
  if me.pOwnerFlag then
    tMode = "std"
  else
    tMode = "jnd"
  end if
  tLayout = "ig_" & tMode & "_highscores.window"
  if pPreviousLayout <> tLayout then
    tWndObj = getWindow(me.getWindowId())
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.unmerge()
    tWndObj.merge(tLayout)
    pPreviousLayout = tLayout
  end if
  me.renderScores(tItemRef)
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

on renderScores me, tItemRef
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
end
