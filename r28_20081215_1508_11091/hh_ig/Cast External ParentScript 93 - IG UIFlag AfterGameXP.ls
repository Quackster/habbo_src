property pXP

on showInfo me, tWindowList, tdata, tMode
  if not listp(tdata) then
    return 0
  end if
  pXP = tdata.getaProp(#xp_gained)
  if tWindowList.count < 1 then
    return 0
  end if
  tWndObj = getWindow(tWindowList[1])
  if tWndObj = 0 then
    return 0
  end if
  me.ancestor.setTitleField(tWindowList[1])
  if not tMode then
    return 1
  end if
  if tWindowList.count < 2 then
    return 1
  end if
  tWndObj = getWindow(tWindowList[2])
  tElem = tWndObj.getElement("ig_tip_xp_today_amount")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("ig_tip_xp_value"), "\xp", string(tdata.getaProp(#xp_today))))
  tElem = tWndObj.getElement("ig_tip_xp_month_amount")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("ig_tip_xp_value"), "\xp", string(tdata.getaProp(#xp_month))))
  tElem = tWndObj.getElement("ig_tip_xp_alltime_amount")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("ig_tip_xp_value"), "\xp", string(tdata.getaProp(#xp_total))))
  return 1
end

on getTitleText me
  if pXP = VOID then
    pXP = 0
  end if
  return replaceChunks(getText("ig_ag_flag_xp_title"), "\xp", pXP)
end

on getLayout me, tMode
  if tMode then
    tLayout = ["ig_ag_tip_title_exp.window", "ig_ag_tip_xp.window"]
  else
    tLayout = ["ig_ag_tip_title.window"]
  end if
  return tLayout
end
