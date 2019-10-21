on render me 
  me.pWindowID = "list_det"
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tSetID = me.pWindowSetId & "_c"
  if not tWrapObjRef.existsSet(tSetID) then
    tWrapObjRef.initSet(tSetID, 2)
  end if
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tItemRef = tService.getObservedGame()
  tHasCompleteData = tItemRef <> 0
  if tHasCompleteData then
    tHasCompleteData = tItemRef.hasCompleteData()
  end if
  if not tHasCompleteData then
    tWrapObjRef.addOneWindow(me.getWindowId(), "ig_no_games.window", tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("btm"), void(), tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("spec"), void(), tSetID)
    tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV:1])
    tWrapObjRef.addOneWindow(me.getWindowId("btn_j"), "ig_frame_blank2_btm.window", tSetID)
    tWrapObjRef.render()
    return TRUE
  end if
  tTeamCount = tItemRef.getTeamCount()
  tTeamMaxSize = tItemRef.getTeamMaxSize()
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_tms_plrs_" & tTeamCount & "_" & tTeamMaxSize & ".window", tSetID)
  me.renderTeams(tItemRef)
  tWrapObjRef.addOneWindow(me.getWindowId("btm"), "ig_tms_btm.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("spec"), void(), tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV:1])
  tPropList = tItemRef.dump()
  i = 1
  repeat while i <= tPropList.count
    tKey = tPropList.getPropAt(i)
    tValue = tPropList.getAt(i)
    me.renderProperty(tKey, tValue)
    i = (1 + i)
  end repeat
  me.renderButtons()
  tWrapObjRef.render()
  return TRUE
end

on renderProperty me, tKey, tValue 
  if (tKey = #game_type_icon) then
    return(me.renderType(tValue))
  else
    if (tKey = #level_name) then
      return(me.renderName(tValue))
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

on renderButtons me 
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tSetID = me.pWindowSetId & "_c"
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tJoinedId = tService.getJoinedGameId()
  tGameId = tService.getObservedGameId()
  if (tGameId = tJoinedId) then
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
  return TRUE
end

on renderTeams me, tGameRef 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tTeams = tGameRef.getAllTeamData()
  tOwnerFlag = tGameRef.checkIfOwnerOfGame()
  tTeamCount = tGameRef.getTeamCount()
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamIndex = 1
  repeat while tTeamIndex <= tTeamCount
    tPlayerIndex = 1
    repeat while tPlayerIndex <= tTeamMaxSize
      tPlayerExists = tTeamIndex <= tTeams.count
      if tPlayerExists then
        tPlayerExists = tPlayerIndex <= tTeams.getAt(tTeamIndex).getAt(#players).count
      end if
      if not tPlayerExists then
        if tGameRef.checkPlayerRequiredForSlot(tTeamIndex, tPlayerIndex) then
          me.renderNoPlayer(1, tTeamIndex, tPlayerIndex)
        else
          me.renderNoPlayer(0, tTeamIndex, tPlayerIndex)
        end if
      else
        me.renderPlayer(tTeams.getAt(tTeamIndex).getAt(#players).getAt(tPlayerIndex), tTeamIndex, tPlayerIndex, tOwnerFlag)
      end if
      tPlayerIndex = (1 + tPlayerIndex)
    end repeat
    tTeamIndex = (1 + tTeamIndex)
  end repeat
  return TRUE
end

on renderNoPlayer me, tRequired, tTeamIndex, tPlayerIndex 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
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
  return TRUE
end

on renderPlayer me, tInfo, tTeamIndex, tPlayerIndex, tOwnerFlag 
  tWndObj = getWindow(me.getWindowId())
  if (tWndObj = 0) then
    return FALSE
  end if
  tSuffix = tTeamIndex & "_" & tPlayerIndex
  tElement = tWndObj.getElement("ig_icon_team_player_" & tSuffix)
  if (tElement = 0) then
    return TRUE
  end if
  tElement.show()
  tOwnPlayer = (tInfo.getaProp(#name) = me.getOwnPlayerName())
  tImage = me.getHeadImage(tInfo.getaProp(#figure), tInfo.getaProp(#sex), 18, 18)
  if (tImage.ilk = #image) then
    tElement.setProperty(#image, tImage)
  end if
  tElement = tWndObj.getElement("ig_name_team_player_" & tSuffix)
  if tElement <> 0 then
    if (tOwnPlayer = 1) then
      tFontStruct = tElement.getFont()
      tFontStruct.setaProp(#font, "vb")
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
  return TRUE
end
