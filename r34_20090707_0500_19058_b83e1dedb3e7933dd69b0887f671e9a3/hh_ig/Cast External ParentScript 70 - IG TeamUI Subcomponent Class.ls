property pFlagIdPrefix, pFlagManagerId

on construct me
  pFlagIdPrefix = "fg"
  return me.ancestor.construct()
end

on deconstruct me
  tFlagManager = me.getFlagManager()
  if tFlagManager <> 0 then
    tFlagManager.removeFlagSet(me.pID)
  end if
  return me.ancestor.deconstruct()
end

on setInfoFlag me, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return 0
  end if
  return tFlagManager.setInfoFlag(me.pID, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo)
end

on existsFlagObject me, tID
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return 0
  end if
  return tFlagManager.exists(tID)
end

on removeFlagObject me, tID
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return 0
  end if
  return tFlagManager.Remove(tID)
end

on getFlagManager me
  if pFlagManagerId = VOID then
    return 0
  end if
  return getObject(pFlagManagerId)
end

on getBasicFlagId me
  return me.getWindowId() & "_" & pFlagIdPrefix
end

on setTeamColorBackground me, tWndID, tTeamIndex
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_title_bg_dark")
  if tElem <> 0 then
    tColor = me.getTeamColorDark(tTeamIndex)
    if tColor.ilk = #color then
      tElem.setProperty(#bgColor, tColor)
    end if
  end if
  tElem = tWndObj.getElement("ig_title_bg_light")
  if tElem <> 0 then
    tColor = me.getTeamColorLight(tTeamIndex)
    if tColor.ilk = #color then
      tElem.setProperty(#bgColor, tColor)
    end if
  end if
  return 1
end

on getTeamColorDark me, tTeamIndex
  case tTeamIndex of
    1:
      return rgb("#c64000")
    2:
      return rgb("#1971c3")
    3:
      return rgb("#659217")
    4:
      return rgb("#e19f00")
  end case
end

on getTeamColorLight me, tTeamIndex
  case tTeamIndex of
    1:
      return rgb("#e86a3c")
    2:
      return rgb("#4696e1")
    3:
      return rgb("#91b159")
    4:
      return rgb("#fcc02d")
  end case
end
