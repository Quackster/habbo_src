on construct(me)
  pFlagIdPrefix = "fg"
  return(me.construct())
  exit
end

on deconstruct(me)
  tFlagManager = me.getFlagManager()
  if tFlagManager <> 0 then
    tFlagManager.removeFlagSet(me.pID)
  end if
  return(me.deconstruct())
  exit
end

on setInfoFlag(me, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo)
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return(0)
  end if
  return(tFlagManager.setInfoFlag(me.pID, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo))
  exit
end

on existsFlagObject(me, tID)
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return(0)
  end if
  return(tFlagManager.exists(tID))
  exit
end

on removeFlagObject(me, tID)
  tFlagManager = me.getFlagManager()
  if tFlagManager = 0 then
    return(0)
  end if
  return(tFlagManager.Remove(tID))
  exit
end

on getFlagManager(me)
  if pFlagManagerId = void() then
    return(0)
  end if
  return(getObject(pFlagManagerId))
  exit
end

on getBasicFlagId(me)
  return(me.getWindowId() & "_" & pFlagIdPrefix)
  exit
end

on setTeamColorBackground(me, tWndID, tTeamIndex)
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return(0)
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
  return(1)
  exit
end

on getTeamColorDark(me, tTeamIndex)
  if me = 1 then
    return(rgb("#c64000"))
  else
    if me = 2 then
      return(rgb("#1971c3"))
    else
      if me = 3 then
        return(rgb("#659217"))
      else
        if me = 4 then
          return(rgb("#e19f00"))
        end if
      end if
    end if
  end if
  exit
end

on getTeamColorLight(me, tTeamIndex)
  if me = 1 then
    return(rgb("#e86a3c"))
  else
    if me = 2 then
      return(rgb("#4696e1"))
    else
      if me = 3 then
        return(rgb("#91b159"))
      else
        if me = 4 then
          return(rgb("#fcc02d"))
        end if
      end if
    end if
  end if
  exit
end