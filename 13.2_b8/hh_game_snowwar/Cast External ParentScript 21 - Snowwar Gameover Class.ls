property pWindowID, pTimeOutID, pOpenWindow, pScoreData, pPlayerData, pCountdownEndTime, pJoinedPlayers, pBestPlayer, pWriterPlainNormLeft, pWriterPlainBoldLeft, pWriterLinkRight

on construct me
  pScoreData = [:]
  pPlayerData = [:]
  pJoinedPlayers = [:]
  pBestPlayer = [:]
  pWindowID = getText("gs_title_finalscores")
  pTimeOutID = "gs_endgame_resetGameTimeout"
  createWriter("gs_plain_norm_left", getStructVariable("struct.font.plain"))
  pWriterPlainNormLeft = getWriter("gs_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap: 0, #fixedLineSpace: 16])
  createWriter("gs_plain_bold_left", getStructVariable("struct.font.bold"))
  pWriterPlainBoldLeft = getWriter("gs_plain_bold_left")
  createWriter("gs_link_right", getStructVariable("struct.font.link"))
  pWriterLinkRight = getWriter("gs_link_right")
  pWriterLinkRight.setProperty(#alignment, #right)
  registerMessage(#remove_user, me.getID(), #showRemovedPlayer)
  return 1
end

on deconstruct me
  me.removeFinalScores()
  removeWriter("gs_plain_norm_left")
  pWriterPlainNormLeft = VOID
  removeWriter("gs_plain_bold_left")
  pWriterPlainBoldLeft = VOID
  removeWriter("gs_link_right")
  pWriterLinkRight = VOID
  pBestPlayer = VOID
  unregisterMessage(#remove_user, me.getID())
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gameend:
      pJoinedPlayers = [:]
      me.saveSortedScores(tdata)
      me.startResetCountdown(tdata[#time_until_game_reset])
      me.toggleWindowMode()
    #gamereset:
      me.removeFinalScores()
    #playerrejoined:
      me.showJoinedPlayer(tdata)
    #numtickets:
      return me.renderNumTickets()
  end case
  return 1
end

on toggleWindowMode me
  if (pOpenWindow = VOID) or (pOpenWindow = "sw_score_tiny.window") then
    if not listp(pScoreData) then
      return 0
    end if
    tTeamNum = pScoreData.count
    pOpenWindow = "sw_score_big_" & tTeamNum & "t.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return error(me, "Cannot open score window.", #toggleWindowMode)
    end if
    me.renderFinalScoresText()
    me.showJoinedPlayers()
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(124, 74)
    else
      tWndObj.moveTo(124, 50)
    end if
  else
    pOpenWindow = "sw_score_tiny.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return error(me, "Cannot open score window.", #toggleWindowMode)
    end if
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(41, 50)
    else
      tWndObj.moveTo(25, 26)
    end if
  end if
  tWndObj.lock()
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  me.showJoinedPlayersNum()
  me.renderCountdownTimer()
  me.renderNumTickets()
  return 1
end

on removeFinalScores me
  pCountdownEndTime = VOID
  pOpenWindow = VOID
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return 1
end

on renderNumTickets me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_numtickets")
  if tElem = 0 then
    return 0
  end if
  if me.getGameSystem() = 0 then
    return 0
  end if
  tNumTickets = string(me.getGameSystem().getNumTickets())
  if tNumTickets.length = 1 then
    tNumTickets = "00" & tNumTickets
  end if
  if tNumTickets.length = 2 then
    tNumTickets = "0" & tNumTickets
  end if
  tElem.setText(tNumTickets)
end

on saveSortedScores me, tdata
  pScoreData = tdata[#gameend_scores]
  tSortedTeams = []
  tTeamNum = pScoreData.count
  repeat with tTeamId = 1 to tTeamNum
    tdata = pScoreData[tTeamId]
    tSortedPlayers = []
    repeat with tPlayerNum = 1 to tdata[#players].count
      tPos = 1
      if tSortedPlayers.count > 0 then
        repeat while tSortedPlayers[tPos][#score] > tdata[#players][tPlayerNum][#score]
          tPos = tPos + 1
          if tPos > tSortedPlayers.count then
            exit repeat
          end if
        end repeat
      end if
      tSortedPlayers.addAt(tPos, tdata[#players][tPlayerNum].duplicate())
    end repeat
    tPos = 1
    if tSortedTeams.count > 0 then
      repeat while tSortedTeams[tPos][#score] > tdata[#score]
        tPos = tPos + 1
        if tPos > tSortedTeams.count then
          exit repeat
        end if
      end repeat
    end if
    tSortedTeams.addAt(tPos, [#score: tdata[#score], #team_id: tTeamId, #players: tSortedPlayers])
  end repeat
  pScoreData = tSortedTeams
  if getObject(#session).exists("user_game_index") then
    tOwnId = getObject(#session).GET("user_game_index")
  end if
  tOwnPlayerWins = 0
  pPlayerData = [:]
  pBestPlayer = [:]
  repeat with tTeamInfoCount = 1 to tTeamNum
    tdata = pScoreData[tTeamInfoCount]
    repeat with tPlayerNum = 1 to tdata[#players].count
      tPlayerId = string(tdata[#players][tPlayerNum][#id])
      tPlayerName = tdata[#players][tPlayerNum][#name]
      pPlayerData.addProp(tPlayerId, tPlayerName)
      if (tPlayerId = tOwnId) and (tTeamInfoCount = 1) then
        tOwnPlayerWins = 1
      end if
      if tdata[#players][tPlayerNum][#score] > pBestPlayer[#score] then
        pBestPlayer[#tie] = 0
        pBestPlayer[#id] = tPlayerId
        pBestPlayer[#name] = tPlayerName
        pBestPlayer[#score] = tdata[#players][tPlayerNum][#score]
        next repeat
      end if
      if tdata[#players][tPlayerNum][#score] = pBestPlayer[#score] then
        pBestPlayer[#tie] = 1
      end if
    end repeat
  end repeat
  if pBestPlayer[#tie] then
    playSound("LS-C64-win-1")
  else
    pBestPlayer[#image] = me.getBestPlayerImage(pBestPlayer[#id])
    if tOwnPlayerWins then
      playSound("LS-C64-win-1")
    else
      playSound("LS-C64-loose-1")
    end if
  end if
  return 1
end

on renderFinalScoresText me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if me.getGameSystem().getSpectatorModeFlag() then
    repeat with tButtonID in ["gs_button_rejoin", "gs_button_leaveGame2"]
      tWndObj.getElement(tButtonID).hide()
    end repeat
  end if
  tTeamNum = pScoreData.count
  repeat with tTeamInfoCount = 1 to tTeamNum
    tdata = pScoreData[tTeamInfoCount]
    tTeamId = tdata[#team_id]
    tElem = tWndObj.getElement("gs_scores_icon_team" & tTeamInfoCount)
    tImage = member(getmemnum("sw_ico_team" & tTeamId)).image
    if (tElem <> 0) and (tImage <> VOID) then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("gs_scores_score_team" & tTeamInfoCount)
    if tElem <> 0 then
      tElem.setText(tdata[#score])
    end if
    tImage = me.renderFinalScoreItem(tdata)
    tElem = tWndObj.getElement("bb_area_scores" & tTeamInfoCount)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
  end repeat
  if not pBestPlayer[#tie] then
    if pBestPlayer[#image] = VOID then
      pBestPlayer[#image] = member(getmemnum("guide_tie")).image
    end if
    tElem = tWndObj.getElement("gs_bestplayer_name")
    tElem.setText(pBestPlayer[#name])
    tElem = tWndObj.getElement("gs_bestplayer_score")
    tElem.setText(pBestPlayer[#score])
    tElem = tWndObj.getElement("bb_icon_winner")
    if (tElem <> 0) and (ilk(pBestPlayer[#image]) = #image) then
      tElem.feedImage(pBestPlayer[#image])
    end if
  else
    tPlayerImage = member(getmemnum("guide_tie")).image
    tElem = tWndObj.getElement("bb_icon_winner")
    if (tElem <> 0) and (ilk(tPlayerImage) = #image) then
      tElem.feedImage(tPlayerImage)
    end if
    tElem = tWndObj.getElement("gs_bestplayer_title")
    if tElem <> 0 then
      tElem.setText(getText("gs_score_tie"))
    end if
  end if
  return 1
end

on renderFinalScoreItem me, tTeam
  tNameTxt = EMPTY
  tScoreTxt = EMPTY
  tImage = image(165, tTeam[#players].count * 16, 32)
  repeat with tPlayerNum = 1 to tTeam[#players].count
    tScoreTxt = tScoreTxt & tTeam[#players][tPlayerNum][#score] & RETURN
    tNameTxt = tNameTxt & tTeam[#players][tPlayerNum][#name] & RETURN
  end repeat
  tOffset = 0
  tNameImage = pWriterPlainNormLeft.render(tNameTxt)
  tImage.copyPixels(tNameImage, tNameImage.rect + rect(6, -5 + tOffset, 6, -5 + tOffset), tNameImage.rect)
  tScoreImage = pWriterPlainNormLeft.render(tScoreTxt)
  tImage.copyPixels(tScoreImage, tScoreImage.rect + rect(130, -5 + tOffset, 130, -5 + tOffset), tScoreImage.rect)
  return tImage
end

on showJoinedPlayer me, tdata
  tStrId = string(tdata[#id])
  tHumanId = string(me.getGameSystem().getGameObjectProperty(tStrId, "human_id"))
  tRoomIndex = string(me.getGameSystem().getGameObjectProperty(tStrId, "room_index"))
  if pJoinedPlayers.findPos(tRoomIndex) = 0 then
    pJoinedPlayers.addProp(tRoomIndex, ["human_id": tHumanId])
  end if
  me.showPlayerIcon(#joined, [#id: tHumanId])
  me.showJoinedPlayersNum()
  return 1
end

on showRemovedPlayer me, tRoomIndex
  if pJoinedPlayers.findPos(tRoomIndex) = 0 then
    return 0
  end if
  tHumanId = pJoinedPlayers[tRoomIndex]["human_id"]
  pJoinedPlayers.deleteProp(tRoomIndex)
  me.showPlayerIcon(0, [#id: tHumanId])
  me.showJoinedPlayersNum()
  return 1
end

on showPlayerIcon me, tIcon, tdata
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tStrId = string(tdata[#id])
  if pScoreData = VOID then
    return 0
  end if
  repeat with tTeamNum = 1 to pScoreData.count
    repeat with tPlayerNum = 1 to pScoreData[tTeamNum][#players].count
      if pScoreData[tTeamNum][#players][tPlayerNum][#id] = tdata[#id] then
        tMyTeamNum = tTeamNum
        tMyPlayerNum = tPlayerNum
      end if
    end repeat
  end repeat
  tElem = tWndObj.getElement("bb_area_scores" & tMyTeamNum)
  if tElem = 0 then
    return 0
  end if
  tImage = tElem.getProperty(#image)
  if tIcon = #joined then
    tStarImg = member(getmemnum("sw_ico_star_lt")).image
  else
    tStarImg = image(11, 9, 8)
  end if
  tImage.copyPixels(tStarImg, tStarImg.rect + rect(109, 1 + (16 * (tMyPlayerNum - 1)), 109, 1 + (16 * (tMyPlayerNum - 1))), tStarImg.rect)
  tElem.feedImage(tImage)
  return 1
end

on showJoinedPlayers me
  if not listp(pJoinedPlayers) then
    return 1
  end if
  repeat with tPlayer in pJoinedPlayers
    tHumanId = string(tPlayer["human_id"])
    me.showPlayerIcon(#joined, [#id: tHumanId])
  end repeat
  return 1
end

on showJoinedPlayersNum me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_joinedplayers")
  if tElem = 0 then
    return 0
  end if
  return tElem.setText(replaceChunks(getText("gs_joinedplayers"), "\x", pJoinedPlayers.count))
end

on startResetCountdown me, tSecondsLeft
  if tSecondsLeft <= 0 then
    return 0
  end if
  pCountdownEndTime = the milliSeconds + (tSecondsLeft * 1000)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderCountdownTimer, me.getID(), pCountdownEndTime, tSecondsLeft)
  me.renderCountdownTimer()
  return 1
end

on convertToMinSec me, tTime
  tMin = tTime / 60000
  tSec = tTime mod 60000 / 1000
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return [tMin, tSec]
end

on renderCountdownTimer me
  if pCountdownEndTime = 0 then
    return 0
  end if
  tEndTime = pCountdownEndTime
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("gs_timetojoin")
  if tElem = 0 then
    return 0
  end if
  if tEndTime < the milliSeconds then
    return 0
  end if
  tTime = me.convertToMinSec(tEndTime - the milliSeconds)
  tTimeStr = tTime[1] & ":" & tTime[2]
  tElem.setText(replaceChunks(getText("gs_timetojoin"), "\x", tTimeStr))
end

on getBestPlayerImage me, tUserID
  tUserGameObj = me.getGameSystem().getGameObject(string(tUserID))
  if tUserGameObj = 0 then
    return error(me, "Winning player's userobject not found in room, id:" && tUserID, #getBestPlayerImage)
  end if
  tTempImage = tUserGameObj.getRoomObjectImage()
  tPlayerImage = image(tTempImage.width, tTempImage.height, 32)
  tPlayerImage.copyPixels(tTempImage, tTempImage.rect, tTempImage.rect + rect(27, 45, 27, 45))
  return tPlayerImage
end

on eventProc me, tEvent, tSprID, tParam
  case tSprID of
    "gs_button_rejoin":
      if me.getGameSystem() = 0 then
        return 0
      end if
      me.getGameSystem().rejoinGame()
    "gs_button_leavegame", "gs_button_leaveGame2":
      if me.getGameSystem() = 0 then
        return 0
      end if
      me.getGameSystem().enterLounge()
    "gs_link_shrink", "gs_link_expand":
      return me.toggleWindowMode()
    "gs_button_buytickets":
      return executeMessage(#show_ticketWindow)
  end case
end
