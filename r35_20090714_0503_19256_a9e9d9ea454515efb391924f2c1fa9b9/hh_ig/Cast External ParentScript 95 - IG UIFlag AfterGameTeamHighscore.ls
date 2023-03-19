on showInfo me, tWindowList, tdata, tMode
  if not tMode then
    return 1
  end if
  if tWindowList.count < 2 then
    return 1
  end if
  tWndObj = getWindow(tWindowList[2])
  tThisTeamId = tdata.getaProp(#this_team_id)
  tdata = tdata.getaProp(#level_team_scores)
  if not listp(tdata) then
    return 0
  end if
  if tdata.count < 3 then
    tCount = tdata.count
  else
    tCount = 3
  end if
  repeat with i = 1 to tCount
    tWndObj = getWindow(tWindowList[i * 2])
    if tWndObj = 0 then
      return 0
    end if
    tItem = tdata[i]
    tPlayers = tItem.getaProp(#players)
    tHighlight = tItem.getaProp(#id) = tThisTeamId
    tElem = tWndObj.getElement("ig_teamhigh_rank")
    if tElem = 0 then
      return 0
    end if
    if tHighlight then
      tFontStruct = getStructVariable("struct.font.bold")
      tElem.setFont(tFontStruct)
    end if
    tElem.setText(i & ".")
    tElem = tWndObj.getElement("ig_teamhigh_score")
    if tElem = 0 then
      return 0
    end if
    if tHighlight then
      tElem.setFont(tFontStruct)
    end if
    tElem.setText(tItem.getaProp(#score))
    if tHighlight then
      tElem = tWndObj.getElement("ig_teamhigh_teamscore")
      if tElem = 0 then
        return 0
      end if
      tElem.setFont(tFontStruct)
    end if
    tText = EMPTY
    tBreak = 0
    repeat with j = 1 to tPlayers.count
      if tPlayers[j].length > 14 then
        tText = tText & tPlayers[j].char[1..12] & "..."
      else
        tText = tText & tPlayers[j]
      end if
      if tBreak then
        tText = tText & RETURN
      else
        if j < tPlayers.count then
          tText = tText & ", "
        end if
      end if
      tBreak = not tBreak
    end repeat
    tElem = tWndObj.getElement("ig_teamhigh_team")
    if tElem = 0 then
      return 0
    end if
    tElem.setText(tText)
    tFont = tElem.getFont()
    tLineHeight = tFont.getaProp(#lineHeight)
    tHeight = ((tPlayers.count + 1) / 2 * tLineHeight) + 14
    tWndObj.resizeTo(tWndObj.getProperty(#width), tHeight)
  end repeat
  tY = -1
  repeat with i = 1 to tWindowList.count
    tWndObj = getWindow(tWindowList[i])
    if tWndObj = 0 then
      return 0
    end if
    if tY > 0 then
      tWndObj.moveTo(tWndObj.getProperty(#locX), tY)
    end if
    tY = tWndObj.getProperty(#locY) + tWndObj.getProperty(#height)
  end repeat
  return 1
end

on getTitleText me
  return getText("ig_ag_flag_teamhigh_title")
end

on getLayout me, tMode
  if tMode then
    tLayout = ["ig_ag_tip_title_exp.window", "ig_ag_teamhigh_mid.window", "ig_ag_teamhigh_brk.window", "ig_ag_teamhigh_mid.window", "ig_ag_teamhigh_brk.window", "ig_ag_teamhigh_mid.window", "ig_ag_teamhigh_btm.window"]
  else
    tLayout = ["ig_ag_tip_title.window"]
  end if
  return tLayout
end
