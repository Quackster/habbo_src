property pEndTime, pAnimFrame, pUpdateCounter, pCurrentLayout

on update me
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < 4 then
    return 1
  end if
  pUpdateCounter = 0
  tTimeLeft = me.getTimeLeft()
  if tTimeLeft <= 0 then
    return 1
  end if
  tWndObj = getWindow(me.getWindowId("top"))
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_info_status")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("ig_info_game_start_in_x"), "\x", me.getFormatTime()))
  tElem = tWndObj.getElement("ig_icon_getready")
  if tElem = 0 then
    return 0
  end if
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > 5 then
    pAnimFrame = 0
  end if
  tMemNum = getmemnum("ig_icon_loading_" & pAnimFrame)
  if tMemNum = 0 then
    return 0
  end if
  tElem.setProperty(#image, member(tMemNum).image)
end

on addWindows me
  me.pWindowID = "a"
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamCount = tGameRef.getTeamCount()
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId("top"), VOID, me.pWindowSetId, [#spaceBottom: 2])
  tScrollStartOffset = -100
  repeat with tTeamIndex = 1 to tTeamCount
    tWrapObjRef.addOneWindow(me.getWindowId(tTeamIndex), "ig_ag_join_plrs_" & tTeamMaxSize & ".window", me.pWindowSetId, [#scrollFromLocX: tScrollStartOffset, #spaceBottom: 2])
    me.setTeamColorBackground(me.getWindowId(tTeamIndex), tTeamIndex)
    tScrollStartOffset = tScrollStartOffset - 50
  end repeat
  tWrapObjRef.addOneWindow(me.getWindowId("btn"), "ig_ag_leave_game.window", me.pWindowSetId)
  tWrapObjRef.moveTo(4, 10)
  return 1
end

on render me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  if me.getTimeLeft() > 0 then
    tLayout = "ig_ag_game_starting.window"
  else
    tLayout = "ig_ag_waiting_players.window"
  end if
  if tLayout <> pCurrentLayout then
    pCurrentLayout = tLayout
    tWndObj = getWindow(me.getWindowId("top"))
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.unmerge()
    tWndObj.merge(pCurrentLayout)
    tWrapObjRef = me.getWindowWrapper()
    if tWrapObjRef = 0 then
      return 0
    end if
    tWrapObjRef.render()
  end if
  tTeams = tGameRef.getAllTeamData()
  if not listp(tTeams) then
    return 0
  end if
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamCount = tTeams.count
  tOwnTeamIndex = tGameRef.getOwnPlayerTeam()
  repeat with tTeamIndex = 1 to tTeamCount
    tWndID = me.getWindowId(tTeamIndex)
    tTeam = tTeams[tTeamIndex]
    tTeamPlayers = tTeam.getaProp(#players)
    repeat with tPlayerPos = 1 to tTeamPlayers.count
      tPlayer = tTeamPlayers[tPlayerPos]
      me.setScoreWindowPlayer(tWndID, tPlayerPos, tPlayer)
    end repeat
    repeat with tPlayerPos = tTeamPlayers.count + 1 to tTeamMaxSize
      me.setScoreWindowPlayer(tWndID, tPlayerPos, 0, 0)
    end repeat
    me.setJoinButtonState(tTeamIndex, (tTeamIndex <> tOwnTeamIndex) and (tTeamPlayers.count < tTeamMaxSize))
  end repeat
end

on displayPlayerLeft me, tTeamId, tPlayerPos
  me.setPlayerFlags(me.getWindowId(tTeamId), tPlayerPos, tTeamId)
  tWndObj = getWindow(me.getWindowId(tTeamId))
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_icon_player_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  tElem.show()
  tMemNum = getmemnum("ig_icon_gameleft")
  if tMemNum = 0 then
    return 0
  end if
  tImage = member(tMemNum).image
  tElem.feedImage(tImage)
  return 1
end

on displayTimeLeft me, tTime
  pEndTime = (tTime * 1000) + the milliSeconds
  me.render()
  return 1
end

on setScoreWindowPlayer me, tWndID, tPlayerPos, tPlayerInfo, tPlayerActive
  if tPlayerInfo <> 0 then
    tOwnPlayer = tPlayerInfo.getaProp(#name) = me.getOwnPlayerName()
  end if
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_icon_player_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  if tPlayerInfo = 0 then
    tElem.hide()
  else
    tElem.show()
    if not tPlayerInfo.getaProp(#disconnected) then
      tImage = me.getHeadImage(tPlayerInfo.getaProp(#figure), tPlayerInfo.getaProp(#sex), 18, 18)
    else
      tMemNum = getmemnum("ig_icon_gameleft")
      if tMemNum > 0 then
        tImage = member(tMemNum).image
      end if
    end if
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
  end if
  tElem = tWndObj.getElement("ig_name_player_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  if tPlayerInfo = 0 then
    tElem.setText("---")
  else
    tElem.setText(tPlayerInfo.getaProp(#name))
    if tOwnPlayer then
      tFontStruct = getStructVariable("struct.font.bold")
    else
      tFontStruct = getStructVariable("struct.font.plain")
    end if
    tElem.setFont(tFontStruct)
  end if
  return 1
end

on setJoinButtonState me, tTeamIndex, tstate
  tWndObj = getWindow(me.getWindowId(tTeamIndex))
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("join.button")
  if tElem = 0 then
    return 0
  end if
  tElem.setProperty(#blend, 20 + (tstate * 80))
  if tstate then
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#cursor, 0)
  end if
  return 1
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
