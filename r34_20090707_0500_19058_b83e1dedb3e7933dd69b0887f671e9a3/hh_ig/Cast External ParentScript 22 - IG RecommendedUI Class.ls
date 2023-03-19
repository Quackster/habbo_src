property pWindowID, pTargetElementID

on construct me
  pWindowID = "IG Recommends"
  return 1
end

on deconstruct me
  me.hide()
  return 1
end

on renderSubComponents me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if tService.isUpdateTimestampExpired() then
    return tService.pollContentUpdate()
  end if
  if tService.getListCount() = 0 then
    return 1
  end if
  me.createMyWindow()
  return 1
end

on handleUpdate me, tUpdateId, tSenderId
  put "* IG RecommendedUI Class.handleUpdate" && tUpdateId && tSenderId && windowExists(pWindowID)
  return me.renderUI()
end

on hide me
  me.removeMyWindow()
  return 1
end

on setTarget me, tTargetID
  pTargetElementID = tTargetID
end

on createMyWindow me
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "ig_popup_bg.window")
    tWndObj = getWindow(pWindowID)
    if tWndObj = 0 then
      return error(me, "Cannot create window!", #createMyWindow)
    end if
    if not tWndObj.merge("ig_recommeded_popup.window") then
      return error(me, "Cannot merge in window!", #createMyWindow)
    end if
    tWndObj.lock()
    tWndObj.moveTo(471, 359)
    tWndObj.registerProcedure(#popupEntered, me.getID(), #mouseEnter)
    tWndObj.registerProcedure(#popupLeft, me.getID(), #mouseLeave)
    tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseUp)
  end if
  me.renderList()
  return 1
end

on renderList me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to 3
    me.renderListItem(i, tService.getGameEntry(tService.getListIdByIndex(i)), tWndObj)
  end repeat
  return 1
end

on renderListItem me, tIndex, tGameRef, tWndObj
  if tGameRef = 0 then
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tElem.hide()
  else
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tElem.show()
    tElem = tWndObj.getElement("info_gamemode" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tImage = tGameRef.getProperty(#game_type_icon)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("ig_level_name" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tElem.setText(tGameRef.getProperty(#level_name))
    tElem = tWndObj.getElement("info_team_amount" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tMemNum = getmemnum("ig_icon_teams_" & tGameRef.getTeamCount())
    if tMemNum = 0 then
      return 0
    end if
    tElem.feedImage(member(tMemNum).image)
    tElem = tWndObj.getElement("ig_players_joined" & tIndex)
    if tElem = 0 then
      return 0
    end if
    tElem.setText(tGameRef.getPlayerCount() & "/" & tGameRef.getMaxPlayerCount())
  end if
  return 1
end

on removeMyWindow me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return 1
end

on popupEntered me
  executeMessage(#popupEntered, pTargetElementID)
end

on popupLeft me
  executeMessage(#popupLeft, pTargetElementID)
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  if me.getMainThread() = 0 then
    return 0
  end if
  case tSprID of
    "ig_players_joined1", "ig_players_joined2", "ig_players_joined3", "info_team_amount1", "info_team_amount2", "info_team_amount3", "info_gamemode1", "info_gamemode2", "info_gamemode3", "ig_level_name1", "ig_level_name2", "ig_level_name3", "room_obj_disp_bg1", "room_obj_disp_bg2", "room_obj_disp_bg3", "nav_popup_link_go1", "nav_popup_link_go2", "nav_popup_link_go3":
      tIndex = integer(tSprID.char[tSprID.length])
      if tIndex = VOID then
        return 0
      end if
      tService = me.getIGComponent("GameList")
      if tService = 0 then
        return 0
      end if
      tID = tService.getListIdByIndex(tIndex)
      if tID = -1 then
        return 0
      end if
      executeMessage(#sendTrackingPoint, "/game/joined/recom")
      tService.joinTeamWithLeastMembers(tID)
    otherwise:
      executeMessage(#show_ig, "GameList")
  end case
  me.Remove()
  return 1
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID
  put "* IG RecommendedUI Class mousehover"
end
