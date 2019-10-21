on construct(me)
  pWindowID = "IG Recommends"
  return(1)
  exit
end

on deconstruct(me)
  me.hide()
  return(1)
  exit
end

on renderSubComponents(me)
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return(0)
  end if
  if tService.isUpdateTimestampExpired() then
    return(tService.pollContentUpdate())
  end if
  if tService.getListCount() = 0 then
    return(1)
  end if
  me.createMyWindow()
  return(1)
  exit
end

on handleUpdate(me, tUpdateId, tSenderId)
  put("* IG RecommendedUI Class.handleUpdate" && tUpdateId && tSenderId && windowExists(pWindowID))
  return(me.renderUI())
  exit
end

on hide(me)
  me.removeMyWindow()
  return(1)
  exit
end

on setTarget(me, tTargetID)
  pTargetElementID = tTargetID
  exit
end

on createMyWindow(me)
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "ig_popup_bg.window")
    tWndObj = getWindow(pWindowID)
    if tWndObj = 0 then
      return(error(me, "Cannot create window!", #createMyWindow))
    end if
    if not tWndObj.merge("ig_recommeded_popup.window") then
      return(error(me, "Cannot merge in window!", #createMyWindow))
    end if
    tWndObj.lock()
    tWndObj.moveTo(471, 359)
    tWndObj.registerProcedure(#popupEntered, me.getID(), #mouseEnter)
    tWndObj.registerProcedure(#popupLeft, me.getID(), #mouseLeave)
    tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseUp)
  end if
  me.renderList()
  return(1)
  exit
end

on renderList(me)
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 3
    me.renderListItem(i, tService.getGameEntry(tService.getListIdByIndex(i)), tWndObj)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on renderListItem(me, tIndex, tGameRef, tWndObj)
  if tGameRef = 0 then
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tElem.hide()
  else
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tElem.show()
    tElem = tWndObj.getElement("info_gamemode" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tImage = tGameRef.getProperty(#game_type_icon)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("ig_level_name" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tElem.setText(tGameRef.getProperty(#level_name))
    tElem = tWndObj.getElement("info_team_amount" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tMemNum = getmemnum("ig_icon_teams_" & tGameRef.getTeamCount())
    if tMemNum = 0 then
      return(0)
    end if
    tElem.feedImage(member(tMemNum).image)
    tElem = tWndObj.getElement("ig_players_joined" & tIndex)
    if tElem = 0 then
      return(0)
    end if
    tElem.setText(tGameRef.getPlayerCount() & "/" & tGameRef.getMaxPlayerCount())
  end if
  return(1)
  exit
end

on removeMyWindow(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return(1)
  exit
end

on popupEntered(me)
  executeMessage(#popupEntered, pTargetElementID)
  exit
end

on popupLeft(me)
  executeMessage(#popupLeft, pTargetElementID)
  exit
end

on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  if me.getMainThread() = 0 then
    return(0)
  end if
  if me <> "ig_players_joined1" then
    if me <> "ig_players_joined2" then
      if me <> "ig_players_joined3" then
        if me <> "info_team_amount1" then
          if me <> "info_team_amount2" then
            if me <> "info_team_amount3" then
              if me <> "info_gamemode1" then
                if me <> "info_gamemode2" then
                  if me <> "info_gamemode3" then
                    if me <> "ig_level_name1" then
                      if me <> "ig_level_name2" then
                        if me <> "ig_level_name3" then
                          if me <> "room_obj_disp_bg1" then
                            if me <> "room_obj_disp_bg2" then
                              if me <> "room_obj_disp_bg3" then
                                if me <> "nav_popup_link_go1" then
                                  if me <> "nav_popup_link_go2" then
                                    if me = "nav_popup_link_go3" then
                                      tIndex = integer(tSprID.getProp(#char, tSprID.length))
                                      if tIndex = void() then
                                        return(0)
                                      end if
                                      tService = me.getIGComponent("GameList")
                                      if tService = 0 then
                                        return(0)
                                      end if
                                      tID = tService.getListIdByIndex(tIndex)
                                      if tID = -1 then
                                        return(0)
                                      end if
                                      executeMessage(#sendTrackingPoint, "/game/joined/recom")
                                      tService.joinTeamWithLeastMembers(tID)
                                    else
                                      executeMessage(#show_ig, "GameList")
                                    end if
                                    me.Remove()
                                    return(1)
                                    exit
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover(me, tEvent, tSprID, tParam, tWndID)
  put("* IG RecommendedUI Class mousehover")
  exit
end