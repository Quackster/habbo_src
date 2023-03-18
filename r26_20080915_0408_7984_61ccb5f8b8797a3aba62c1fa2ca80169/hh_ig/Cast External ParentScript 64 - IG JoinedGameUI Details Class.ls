property pOwnerFlag, pPreviousLayout, pCurrentText

on addWindows me, tView
  me.pWindowID = "jg"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.initSet(me.pWindowSetId, 1)
  tWrapObjRef.addOneWindow(me.getWindowId(), VOID, me.pWindowSetId)
  return 1
end

on render me, tView
  tListService = me.getIGComponent("GameList")
  if tListService = 0 then
    return 0
  end if
  tItemRef = tListService.getJoinedGame()
  if tItemRef = 0 then
    return 0
  end if
  me.pOwnerFlag = tItemRef.checkIfOwnerOfGame()
  tTeamCount = tItemRef.getTeamCount()
  tTeamMaxSize = tItemRef.getTeamMaxSize()
  if tTeamCount = 0 then
    return 0
  end if
  if pOwnerFlag then
    tMode = "std"
  else
    tMode = "jnd"
  end if
  if tView = #change then
    tLayout = "_change_"
  else
    tLayout = "_tms_plrs_"
  end if
  tLayout = "ig_" & tMode & tLayout & tTeamCount & "_" & tTeamMaxSize & ".window"
  if pPreviousLayout <> tLayout then
    tWndObj = getWindow(me.getWindowId())
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.unmerge()
    tWndObj.merge(tLayout)
    pPreviousLayout = tLayout
  end if
  me.renderTeams(tItemRef)
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
    #players_required:
      return me.renderCanStart(tValue)
    #game_type_icon:
      return me.renderType(tValue)
    #level_name:
      return me.renderName(tValue)
  end case
  return 0
end

on renderCanStart me, tValue
  if not listp(tValue) then
    tstate = 1
  end if
  if tValue.count = 0 then
    tstate = 1
  end if
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  if tstate then
    tText = getText("ig_info_can_start")
    me.setStartButtonState(pOwnerFlag, 1)
  else
    tText = getText("ig_info_waiting_for_players")
    me.setStartButtonState(pOwnerFlag, 0)
  end if
  if not me.pOwnerFlag then
    return 1
  end if
  tElem = tWndObj.getElement("ig_info_startable")
  if tElem = 0 then
    return 1
  end if
  if pCurrentText = tText then
    return 1
  end if
  pCurrentText = tText
  if not writerExists(me.pWriterIdBold) then
    tWriter = me.getBoldWriter()
    if tWriter = 0 then
      return 0
    end if
    tFont = tWriter.getFont()
    tFont.setaProp(#color, rgb(255, 255, 255))
    tFont.setaProp(#fontStyle, [])
    tWriter.setFont(tFont)
  else
    tWriter = me.getBoldWriter()
    if tWriter = 0 then
      return 0
    end if
  end if
  tTextImage = tWriter.render(tText)
  tBgImage = member(getmemnum("ig_frm_px_gray")).image
  tImage = image(tTextImage.width + 32, 20, 32)
  tImage.copyPixels(tBgImage, tImage.rect, tBgImage.rect)
  tImage.copyPixels(tTextImage, tTextImage.rect + rect(16, 5, 16, 5), tTextImage.rect)
  tElem.feedImage(tImage)
  tOffsetH = (tWndObj.getProperty(#width) - tImage.width) / 2
  tElem.moveTo(tOffsetH, tElem.getProperty(#locY))
  tElem.resizeTo(tImage.width, tImage.height)
  return 1
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

on renderTeams me, tGameRef
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tTeams = tGameRef.getAllTeamData()
  tOwnerFlag = tGameRef.checkIfOwnerOfGame()
  tTeamCount = tGameRef.getTeamCount()
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  repeat with tTeamIndex = 1 to tTeamCount
    tTeamSize = tTeams[tTeamIndex][#players].count
    repeat with tPlayerIndex = 1 to tTeamMaxSize
      if tTeamIndex > tTeams.count then
        me.renderNoPlayer(0, tTeamIndex, tPlayerIndex)
        next repeat
      end if
      if tPlayerIndex > tTeamSize then
        if tGameRef.checkPlayerRequiredForSlot(tTeamIndex, tPlayerIndex) then
          me.renderNoPlayer(1, tTeamIndex, tPlayerIndex)
        else
          me.renderNoPlayer(0, tTeamIndex, tPlayerIndex)
        end if
        next repeat
      end if
      me.renderPlayer(tTeams[tTeamIndex][#players][tPlayerIndex], tTeamIndex, tPlayerIndex, tOwnerFlag)
    end repeat
  end repeat
  return 1
end

on renderNoPlayer me, tRequired, tTeamIndex, tPlayerIndex
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
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
    tFontStruct = getStructVariable("struct.font.plain")
    tElement.setFont(tFontStruct)
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
  return 1
end

on renderPlayer me, tInfo, tTeamIndex, tPlayerIndex, tOwnerFlag
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tSuffix = tTeamIndex & "_" & tPlayerIndex
  tElement = tWndObj.getElement("ig_icon_team_player_" & tSuffix)
  if tElement = 0 then
    return 1
  end if
  tElement.show()
  tOwnPlayer = tInfo.getaProp(#name) = me.getOwnPlayerName()
  tImage = me.getHeadImage(tInfo.getaProp(#figure), tInfo.getaProp(#sex), 18, 18)
  if tImage.ilk = #image then
    tElement.setProperty(#image, tImage)
  end if
  tElement = tWndObj.getElement("ig_name_team_player_" & tSuffix)
  if tElement <> 0 then
    if tOwnPlayer then
      tFontStruct = getStructVariable("struct.font.bold")
    else
      tFontStruct = getStructVariable("struct.font.plain")
    end if
    tElement.setFont(tFontStruct)
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
  return 1
end

on setStartButtonState me, towner, tstate
  tWndObj = getWindow(me.getWindowId())
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("ig_startgame.button")
  if tElement = 0 then
    return 0
  end if
  if towner then
    tElement.show()
    if tstate then
      tElement.setProperty(#blend, 100)
      tElement.setProperty(#cursor, "cursor.finger")
    else
      tElement.setProperty(#blend, 40)
      tElement.setProperty(#cursor, 0)
    end if
  else
    tElement.hide()
  end if
  return 1
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  tListService = me.getIGComponent("GameList")
  if tListService = 0 then
    return 0
  end if
  case tSprID of
    "ig_change_team.button":
      return tListService.setNextTeamInJoinedGame()
    "ig_icon_gamelist":
      return me.ChangeWindowView("GameList")
  end case
  return 1
end
