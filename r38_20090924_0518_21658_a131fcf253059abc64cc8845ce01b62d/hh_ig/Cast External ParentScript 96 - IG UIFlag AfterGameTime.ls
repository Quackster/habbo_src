property pEndTime, pUpdateCounter, pWindowHidden

on update me
  me.ancestor.update()
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < 4 then
    return 1
  end if
  pUpdateCounter = 0
  tTimeLeft = me.getTimeLeft()
  if tTimeLeft <= 0 then
    return 1
  end if
  if tTimeLeft > 30 then
    return 1
  else
    if pWindowHidden then
      pWindowHidden = 0
      return me.ancestor.createWindows()
    end if
  end if
  if me.pWindowList.count < 1 then
    return 0
  end if
  tWndObj = getWindow(me.pWindowList[1])
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_tip_title")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(me.getTitleText())
  return 1
end

on setTitleField me, tWindowID, tMode
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tLocY = tLocY + tWndObj.getProperty(#height)
  tElem = tWndObj.getElement("ig_tip_title")
  tTitleText = me.getTitleText()
  if tMode then
    tWndObj.resizeTo((tTitleText.length * 8) + 19 + 15 + 6, tWndObj.getProperty(#height))
  else
    tWndObj.resizeTo((tTitleText.length * 8) + 19 + 15 + 6, tWndObj.getProperty(#height))
  end if
  if tElem <> 0 then
    tElem.setText(tTitleText)
  end if
  return 1
end

on showInfo me, tWindowList, tdata, tMode
  if tWindowList.count < 1 then
    return 1
  end if
  pWindowID = tWindowList[1]
  pEndTime = tdata
  return 1
end

on getTitleText me
  return replaceChunks(getText("ig_tip_time_to_join_x"), "\x", me.getFormatTime())
end

on createWindows me
  pEndTime = me.pData
  if me.getTimeLeft() > 30 then
    pWindowHidden = 1
    return 1
  else
    return me.ancestor.createWindows()
  end if
end

on getLayout me, tMode
  if tMode then
    tLayout = ["ig_ag_tip_jointime_close.window"]
  else
    tLayout = ["ig_ag_tip_jointime.window"]
  end if
  return tLayout
end

on getFormatTime me
  tTimeLeft = integer((pEndTime - the milliSeconds) / 1000.0)
  if tTimeLeft < 0 then
    return "0:00"
  end if
  tMinutes = tTimeLeft / 60
  tSeconds = tTimeLeft mod 60
  if tSeconds < 10 then
    tSeconds = "0" & tSeconds
  end if
  return tMinutes & ":" & tSeconds
end

on getTimeLeft me
  tTimeLeft = (pEndTime - the milliSeconds) / 1000.0
  if tTimeLeft < 0 then
    return 0
  end if
  return tTimeLeft
end
