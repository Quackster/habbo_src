on addWindows me
  me.pWindowID = "cr"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tSetID = me.pWindowSetId & "_c"
  tWrapObjRef.initSet(tSetID, 3)
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_choose_teams_ss.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("spec"), VOID, tSetID)
  if getObject(#session).GET("lastroom") <> "Entry" then
    tWrapObjRef.addOneWindow(me.getWindowId("invite"), "ig_choose_availability.window", tSetID)
  else
    tWrapObjRef.addOneWindow(me.getWindowId("horo"), "ig_tms_btm_drk.window", tSetID)
  end if
  tWrapObjRef.addOneWindow(me.getWindowId("hor"), "ig_divider_hor.window", tSetID, [#scaleV: 1])
  tWrapObjRef.addOneWindow(me.getWindowId("btn_j"), "ig_frame_create_btm.window", tSetID)
  return 1
end

on render me
  tService = me.getIGComponent("LevelList")
  if tService = 0 then
    return 0
  end if
  tItemRef = tService.getSelectedLevel()
  if tItemRef = 0 then
    return 0
  end if
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
    #private:
      return me.renderPrivateFlag(tValue)
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
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to 4
    tElement = tWndObj.getElement("ig_icon_team_amount_" & i)
    if tElement <> 0 then
      if i = tValue then
        tMemNum = getmemnum("ig_ui_icon_tms_" & i & "_0")
      else
        tMemNum = getmemnum("ig_ui_icon_tms_" & i & "_1")
      end if
      if tMemNum <> 0 then
        tElement.setProperty(#image, member(tMemNum).image)
      end if
    end if
  end repeat
  return 1
end

on renderPrivateFlag me, tValue
  tWndObj = getWindow(me.getWindowId("invite"))
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_game_availability_0")
  if tElem <> 0 then
    tElem.setProperty(#blend, 0 + (not tValue * 100))
  end if
  tElem = tWndObj.getElement("ig_game_availability_1")
  if tElem <> 0 then
    tElem.setProperty(#blend, 0 + (tValue * 100))
  end if
  return 1
end
