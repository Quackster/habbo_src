on addWindows me
  me.pWindowID = "a"
  tService = me.getIGComponent("AfterGame")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getScoreData()
  if tGameRef = 0 then
    return 0
  end if
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamCount = tGameRef.getTeamCount()
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.moveTo(4, 2)
  tScrollStartOffset = -100
  repeat with tTeamPos = 1 to tTeamCount
    tWrapObjRef.addOneWindow(me.getWindowId(tTeamPos), "ig_ag_score_plrs_" & tTeamMaxSize & ".window", me.pWindowSetId, [#scrollFromLocX: tScrollStartOffset, #spaceBottom: 2])
    tScrollStartOffset = tScrollStartOffset - 50
  end repeat
  tWrapObjRef.render()
  tTeams = tGameRef.getAllTeamData()
  if not listp(tTeams) then
    return 0
  end if
  tTeamMaxSize = tGameRef.getTeamMaxSize()
  tTeamCount = tTeams.count
  repeat with tTeamPos = 1 to tTeamCount
    tWndID = me.getWindowId(tTeamPos)
    tTeam = tTeams[tTeamPos]
    tTeamId = tTeam.getaProp(#id)
    tTeamPlayers = tTeam.getaProp(#players)
    if tGameRef.hasTeamScores() then
      me.setScoreWindowIcon(tWndID, tTeamPos)
      me.setTeamColorBackground(tWndID, tTeamId)
      me.setTeamScore(tWndID, tTeamId, tTeam.getaProp(#score))
      me.setTeamFlags(tWndID, tTeam, tTeamId, tGameRef)
    end if
    repeat with tPlayerPos = 1 to tTeamPlayers.count
      tPlayer = tTeamPlayers[tPlayerPos]
      me.setScoreWindowPlayer(tTeamPos, tPlayerPos, tPlayer)
      me.setPlayerFlags(tWndID, tPlayerPos, tTeamId, tPlayer, tGameRef)
    end repeat
    repeat with tPlayerPos = tTeamPlayers.count + 1 to tTeamMaxSize
      me.setScoreWindowPlayer(tTeamPos, tPlayerPos, 0, 0)
      me.setPlayerFlags(tWndID, tPlayerPos, tTeamId, 0)
    end repeat
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
  tElem.moveBy((tElem.getProperty(#width) - tImage.width) / 2, (tElem.getProperty(#height) - tImage.height) / 2)
  tElem = tWndObj.getElement("info_rejoined_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  tElem.hide()
  return 1
end

on displayPlayerRejoined me, tTeamPos, tPlayerPos
  tWndObj = getWindow(me.getWindowId(tTeamPos))
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("info_rejoined_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  tMemNum = getmemnum("ig_icon_rejoined")
  if tMemNum = 0 then
    return 0
  end if
  tImage = member(tMemNum).image
  tElem.feedImage(tImage)
  tElem.moveBy((tElem.getProperty(#width) - tImage.width) / 2, (tElem.getProperty(#height) - tImage.height) / 2)
  return 1
end

on setPlayerFlags me, tWndID, tPlayerPos, tTeamId, tItemInfo, tGameRef
  tID = me.getBasicFlagId() & "_p_" & tTeamId & "_" & tPlayerPos
  if me.existsFlagObject(tID) then
    return 1
  end if
  if not listp(tItemInfo) then
    return 0
  end if
  if tItemInfo.getaProp(#disconnected) then
    return 1
  end if
  tElemID = "ig_score_player_" & tPlayerPos
  tColorDark = me.getTeamColorDark(tTeamId)
  if tGameRef <> 0 then
    tHiScore = tItemInfo.getaProp(#is_highscore)
    if tHiScore = 1 then
      tFlagType = "AfterGameHighscore"
      tItemInfo = tItemInfo.duplicate()
      tItemInfo.setaProp(#top_level_scores, tGameRef.getProperty(#top_level_scores))
    else
      if tItemInfo.getaProp(#name) = me.getOwnPlayerName() then
        tFlagType = "AfterGameXP"
      else
        return 1
      end if
    end if
  end if
  me.setInfoFlag(tID, tWndID, tElemID, tFlagType, tColorDark, tItemInfo)
end

on setTeamFlags me, tWndID, tItemInfo, tTeamId, tGameRef
  tID = me.getBasicFlagId() & "_t_" & tTeamId
  me.removeFlagObject(tID)
  tElemID = "ig_score_team"
  if tItemInfo <> 0 then
    tHiScore = tItemInfo.getaProp(#is_highscore)
    if tHiScore = 1 then
      tFlagType = "AfterGameTeamHighscore"
      tItemInfo.setaProp(#level_team_scores, tGameRef.getProperty(#level_team_scores))
      tItemInfo.setaProp(#this_team_id, tTeamId)
    else
      return 1
    end if
    tColorDark = me.getTeamColorDark(tTeamId)
    me.setInfoFlag(tID, tWndID, tElemID, tFlagType, tColorDark, tItemInfo)
  end if
end

on setTeamScore me, tWndID, tTeamIndex, tScore
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_name_team")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(getText("ig_teamname_" & tTeamIndex))
  tElem = tWndObj.getElement("ig_score_team")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(tScore)
  return 1
end

on setScoreWindowPlayer me, tTeamPos, tPlayerPos, tPlayerInfo, tPlayerActive
  tWndID = me.getWindowId(tTeamPos)
  if tPlayerInfo <> 0 then
    tOwnUser = tPlayerInfo.getaProp(#name) = me.getOwnPlayerName()
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
    if not tPlayerInfo.getaProp(#disconnected) and (tPlayerInfo.findPos(#figure) > 0) then
      tImage = me.getHeadImage(tPlayerInfo.getaProp(#figure), tPlayerInfo.getaProp(#sex), 18, 18)
    else
      me.displayPlayerLeft(tTeamPos, tPlayerPos)
    end if
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    if tPlayerInfo.getaProp(#rejoined) then
      me.displayPlayerRejoined(tTeamPos, tPlayerPos)
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
    if tOwnUser then
      tFontStruct = getStructVariable("struct.font.bold")
      tElem.setFont(tFontStruct)
    end if
  end if
  tElem = tWndObj.getElement("ig_score_player_" & tPlayerPos)
  if tElem = 0 then
    return 0
  end if
  if tPlayerInfo = 0 then
    tElem.hide()
  else
    tElem.show()
    tElem.setText(tPlayerInfo.getaProp(#score))
    if tOwnUser then
      tFontStruct = getStructVariable("struct.font.bold")
      tElem.setFont(tFontStruct)
    end if
  end if
  return 1
end

on setScoreWindowIcon me, tWndID, tTeamPosition
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_icon_medal")
  if tElem = 0 then
    return 0
  end if
  tMemNum = getmemnum("ig_icon_medal_" & tTeamPosition)
  if tMemNum = 0 then
    return 0
  end if
  tElem.setProperty(#image, member(tMemNum).image)
  return 1
end
