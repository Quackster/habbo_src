on showInfo(me, tWindowList, tdata, tMode)
  if not tMode then
    return(1)
  end if
  if tWindowList.count < 2 then
    return(1)
  end if
  tWndObj = getWindow(tWindowList.getAt(2))
  tScoreData = tdata.getaProp(#top_level_scores)
  if not listp(tScoreData) then
    return(0)
  end if
  tRankText = ""
  tNameText = ""
  tScoreText = ""
  tOwnPos = 0
  tOwnId = tdata.getaProp(#room_index)
  tDataCount = tScoreData.count
  if tDataCount > 5 then
    tDataCount = 5
  end if
  i = 1
  repeat while i <= tDataCount
    tItem = tScoreData.getAt(i)
    tOwnUser = tOwnId > -1 and tItem.getaProp(#room_index) = tOwnId
    tElem = tWndObj.getElement("ig_highscore_rank" & i)
    if tElem = 0 then
      return(0)
    end if
    if tOwnUser then
      tFontStruct = tElem.getFont()
      tFontStruct.setaProp(#font, "vb")
      tElem.setFont(tFontStruct)
    end if
    tElem.setText(i & ".")
    tElem = tWndObj.getElement("ig_highscore_player" & i)
    if tElem = 0 then
      return(0)
    end if
    if tOwnUser then
      tFontStruct = tElem.getFont()
      tFontStruct.setaProp(#font, "vb")
      tElem.setFont(tFontStruct)
    end if
    tElem.setText(tItem.getaProp(#name))
    tElem = tWndObj.getElement("ig_highscore_score" & i)
    if tElem = 0 then
      return(0)
    end if
    if tOwnUser then
      tFontStruct = tElem.getFont()
      tFontStruct.setaProp(#font, "vb")
      tElem.setFont(tFontStruct)
    end if
    tElem.setText(tItem.getaProp(#score))
    i = 1 + i
  end repeat
  return(1)
  exit
end

on getTitleText(me)
  return(getText("ig_ag_flag_high_title"))
  exit
end

on getLayout(me, tMode)
  if tMode then
    tLayout = ["ig_ag_tip_title_exp.window", "ig_ag_highscores_btm.window"]
  else
    tLayout = ["ig_ag_tip_title.window"]
  end if
  return(tLayout)
  exit
end