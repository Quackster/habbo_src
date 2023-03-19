on render me
  me.pWindowID = "list_det"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tSetID = me.pWindowSetId & "_c"
  if not tWrapObjRef.existsSet(tSetID) then
    tWrapObjRef.initSet(tSetID, 2)
  end if
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tItemRef = tService.getObservedGame()
  tHasCompleteData = tItemRef <> 0
  if tHasCompleteData then
    tHasCompleteData = tItemRef.hasCompleteData()
  end if
  if not tHasCompleteData then
    tWrapObjRef.addOneWindow(me.getWindowId(), "ig_no_games.window", tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("btm"), VOID, tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("spec"), VOID, tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV: 1])
    tWrapObjRef.addOneWindow(me.getWindowId("btn_j"), "ig_frame_blank2_btm.window", tSetID)
    tWrapObjRef.render()
    return 1
  end if
  tTeamCount = tItemRef.getTeamCount()
  tTeamMaxSize = tItemRef.getTeamMaxSize()
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_tms_plrs_" & tTeamCount & "_" & tTeamMaxSize & ".window", tSetID)
  me.renderTeams(tItemRef)
  tWrapObjRef.addOneWindow(me.getWindowId("btm"), "ig_tms_btm.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("spec"), VOID, tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV: 1])
  tPropList = tItemRef.dump()
  repeat with i = 1 to tPropList.count
    tKey = tPropList.getPropAt(i)
    tValue = tPropList[i]
    me.renderProperty(tKey, tValue)
  end repeat
  me.renderButtons()
  tWrapObjRef.render()
  return 1
end

on renderProperty me, tKey, tValue
  case tKey of
    #game_type_icon:
      return me.renderType(tValue)
    #level_name:
      return me.renderName(tValue)
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

on renderButtons me
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tSetID = me.pWindowSetId & "_c"
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tJoinedId = tService.getJoinedGameId()
  tGameId = tService.getObservedGameId()
  if tGameId = tJoinedId then
    tLayout = "ig_frame_swap_own.window"
  else
    if tJoinedId > -1 then
      tLayout = "ig_frame_swap.window"
    else
      tLayout = "ig_frame_join_btm.window"
    end if
  end if
  if not windowExists(me.getWindowId("btn_j")) then
    tWrapObjRef.addOneWindow(me.getWindowId("btn_j"), tLayout, tSetID)
  else
    tWrapObjRef.replaceOneWindow(me.getWindowId("btn_j"), tLayout, 1)
  end if
  return 1
end

on renderTeams me, tGameRef
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tTeams = tGameRef.getAllTeamData()
  tOwnerFlag = tGameRef.checkIfOwnerOfGame()
  tTeamCount = tGameRef.getTeamCount()
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  repeat with tTeamIndex = 1 to tTeamCount
    repeat with tPlayerIndex = 1 to tTeamMaxSize
      tPlayerExists = tTeamIndex <= tTeams.count
      if tPlayerExists then
        tPlayerExists = tPlayerIndex <= tTeams[tTeamIndex][#players].count
      end if
      if not tPlayerExists then
        if tGameRef.checkPlayerRequiredForSlot(tTeamIndex, tPlayerIndex) then
          me.renderNoPlayer(1, tTeamIndex, tPlayerIndex)
        else
          me.renderNoPlayer(0, tTeamIndex, tPlayerIndex)
        end if
        next repeat
      end if
      me.renderPlayer(tTeams[tTeamIndex][#players][tPlayerIndex], tTeamIndex, tPlayerIndex, tOwnerFlag)
    end repeat
  end repeat
  return 1
end

on renderNoPlayer me, tRequired, tTeamIndex, tPlayerIndex
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tSuffix = tTeamIndex & "_" & tPlayerIndex
  tElement = tWndObj.getElement("ig_icon_team_player_" & tSuffix)
  if tElement <> 0 then
    if tRequired then
      tElement.show()
      tMemNum = getmemnum("ig_icon_player_needed")
      if tMemNum <> 0 then
        tImage = member(tMemNum).image
        tImage = me.alignIconImage(tImage, 18, 18)
        tElement.feedImage(tImage)
      end if
    else
      tElement.hide()
    end if
  end if
  tElement = tWndObj.getElement("ig_name_team_player_" & tSuffix)
  if tElement <> 0 then
    if tRequired then
      tElement.setText(getText("ig_player_needed"))
    else
      tElement.setText("---")
    end if
  end if
  tElement = tWndObj.getElement("ig_kick_team_player_" & tSuffix)
  if tElement <> 0 then
    tElement.hide()
  end if
  return 1
end

on renderPlayer me, tInfo, tTeamIndex, tPlayerIndex, tOwnerFlag
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tSuffix = tTeamIndex & "_" & tPlayerIndex
  tElement = tWndObj.getElement("ig_icon_team_player_" & tSuffix)
  if tElement = 0 then
    return 1
  end if
  tElement.show()
  tOwnPlayer = tInfo.getaProp(#name) = me.getOwnPlayerName()
  tImage = me.getHeadImage(tInfo.getaProp(#figure), tInfo.getaProp(#sex), 18, 18)
  if tImage.ilk = #image then
    tElement.setProperty(#image, tImage)
  end if
  tElement = tWndObj.getElement("ig_name_team_player_" & tSuffix)
  if tElement <> 0 then
    if tOwnPlayer = 1 then
      tFontStruct = getStructVariable("struct.font.bold")
      tElement.setFont(tFontStruct)
    end if
    tElement.setText(tInfo.getProp(#name))
    tElement.show()
  end if
  tElement = tWndObj.getElement("ig_kick_team_player_" & tSuffix)
  if tElement <> 0 then
    if tOwnerFlag or tOwnPlayer then
      tElement.show()
    else
      tElement.hide()
    end if
  end if
  tElement = tWndObj.getElement("join_" & tTeamIndex)
  if tElement <> 0 then
    if tOwnPlayer then
      tElement.setProperty(#blend, 30)
    else
      tElement.setProperty(#blend, 100)
    end if
  end if
  return 1
end
