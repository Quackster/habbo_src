property pWindowID, pTimeOutID, pOpenWindow, pScoreData, pCountdownEndTime, pJoinedPlayers, pWriterPlainNormLeft, pWriterPlainBoldLeft, pWriterLinkRight

on construct me
  pJoinedPlayers = []
  pWindowID = getText("gs_title_finalscores")
  pTimeOutID = "bb_endgame_resetGameTimeout"
  createWriter("bb_plain_norm_left", getStructVariable("struct.font.plain"))
  pWriterPlainNormLeft = getWriter("bb_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap: 0, #fixedLineSpace: 16])
  createWriter("bb_plain_bold_left", getStructVariable("struct.font.bold"))
  pWriterPlainBoldLeft = getWriter("bb_plain_bold_left")
  createWriter("bb_link_right", getStructVariable("struct.font.link"))
  pWriterLinkRight = getWriter("bb_link_right")
  pWriterLinkRight.setProperty(#alignment, #right)
  registerMessage(#remove_user, me.getID(), #showRemovedPlayer)
  return 1
end

on deconstruct me
  me.removeFinalScores()
  removeWriter("bb_plain_norm_left")
  pWriterPlainNormLeft = VOID
  removeWriter("bb_plain_bold_left")
  pWriterPlainBoldLeft = VOID
  removeWriter("bb_link_right")
  pWriterLinkRight = VOID
  unregisterMessage(#remove_user, me.getID())
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gameend:
      pJoinedPlayers = []
      me.saveSortedScores(tdata)
      me.startResetCountdown(tdata[#time_until_game_reset])
      me.toggleWindowMode()
    #gamereset:
      me.removeFinalScores()
    #playerrejoined:
      me.showJoinedPlayer(tdata)
    #numtickets:
      me.renderNumTickets()
  end case
  return 1
end

on toggleWindowMode me
  if (pOpenWindow = VOID) or (pOpenWindow = "bb_score_tiny.window") then
    if not listp(pScoreData) then
      return 0
    end if
    tTeamNum = pScoreData.count
    pOpenWindow = "bb_score_big_" & tTeamNum & "t.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return error(me, "Cannot open score window.", #toggleWindowMode)
    end if
    me.renderFinalScoresText()
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(124, 74)
    else
      tWndObj.moveTo(124, 50)
    end if
  else
    pOpenWindow = "bb_score_tiny.window"
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
  tElem = tWndObj.getElement("bb_ticketAmount_text")
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
        repeat while tSortedPlayers[tPos] > tdata[#players][tPlayerNum]
          tPos = tPos + 1
          if tPos > tSortedPlayers.count then
            exit repeat
          end if
        end repeat
      end if
      tSortedPlayers.addAt(tPos, [#id: tdata[#players].getPropAt(tPlayerNum), #score: tdata[#players][tPlayerNum][#score]])
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
    tSortedTeams.addAt(tPos, [#score: tdata[#score], #id: tTeamId, #players: tSortedPlayers])
  end repeat
  pScoreData = tSortedTeams
  return 1
end

on renderFinalScoresText me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if me.getGameSystem().getSpectatorModeFlag() then
    repeat with tButtonID in ["bb_button_playAgn", "bb_button_leaveGam2", "gs_button_buytickets"]
      tWndObj.getElement(tButtonID).hide()
    end repeat
  end if
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tTeamNum = pScoreData.count
  tBestPlayer = [#id: 0, #score: 0]
  repeat with tTeamId = 1 to tTeamNum
    tdata = pScoreData[tTeamId]
    tElem = tWndObj.getElement("bb_win_bigScores_ball" & tTeamId)
    tImage = member(getmemnum("bb_ico_ball" & tdata[#id])).image
    if (tElem <> 0) and (tImage <> VOID) then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("bb_score_team" & tTeamId)
    if tElem <> 0 then
      tElem.setText(tdata[#score])
    end if
    tImage = me.renderFinalScoreItem(tdata)
    tElem = tWndObj.getElement("bb_area_scores" & tTeamId)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    repeat with tPlayerNum = 1 to tdata[#players].count
      if tdata[#players][tPlayerNum][#score] > tBestPlayer[#score] then
        tTie = 0
        tBestPlayer[#id] = tdata[#players][tPlayerNum][#id]
        tBestPlayer[#score] = tdata[#players][tPlayerNum][#score]
        next repeat
      end if
      if tdata[#players][tPlayerNum][#score] = tBestPlayer[#score] then
        tTie = 1
      end if
    end repeat
  end repeat
  if not tTie then
    tElem = tWndObj.getElement("gs_bestplayer_name")
    if tElem <> 0 then
      tUserObj = tRoomComponent.getUserObject(tBestPlayer[#id])
      if tUserObj <> 0 then
        tTempImage = tUserObj.getPicture()
        tPlayerImage = image(32, 62, 32)
        if ilk(tTempImage) = #image then
          tPlayerImage.copyPixels(tTempImage, tTempImage.rect + rect(7, -7, 7, -7), tTempImage.rect)
        end if
        tElem.setText(tUserObj.getName())
        tElem = tWndObj.getElement("gs_bestplayer_score")
        tElem.setText(tBestPlayer[#score])
      end if
    end if
  else
    tElem = tWndObj.getElement("gs_bestplayer_title")
    if tElem <> 0 then
      tElem.setText(getText("gs_score_tie"))
    end if
  end if
  tElem = tWndObj.getElement("bb_icon_winner")
  if tElem <> 0 then
    if not (ilk(tPlayerImage) = #image) then
      tPlayerImage = member(getmemnum("guide_tie")).image
      tElem.moveBy(0, 6)
    end if
    tElem.feedImage(tPlayerImage)
  end if
  return 1
end

on renderFinalScoreItem me, tTeam
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tNameTxt = EMPTY
  tScoreTxt = EMPTY
  tImage = image(165, tTeam[#players].count * 16, 32)
  repeat with tPlayerNum = 1 to tTeam[#players].count
    tScoreTxt = tScoreTxt & tTeam[#players][tPlayerNum][#score] & RETURN
    tPlayerObj = tRoomComponent.getUserObject(tTeam[#players][tPlayerNum][#id])
    if tPlayerObj <> 0 then
      tNameTxt = tNameTxt & tPlayerObj.getName() & RETURN
    end if
  end repeat
  tOffset = 0
  if variableExists("bb_menu_nameandscore_voffset") then
    tOffset = getVariable("bb_menu_nameandscore_voffset")
  end if
  tNameImage = pWriterPlainNormLeft.render(tNameTxt)
  tImage.copyPixels(tNameImage, tNameImage.rect + rect(6, -5 + tOffset, 6, -5 + tOffset), tNameImage.rect)
  tScoreImage = pWriterPlainNormLeft.render(tScoreTxt)
  tImage.copyPixels(tScoreImage, tScoreImage.rect + rect(130, -5 + tOffset, 130, -5 + tOffset), tScoreImage.rect)
  return tImage
end

on showJoinedPlayer me, tdata
  tStrId = string(tdata[#id])
  if pJoinedPlayers.findPos(tStrId) = 0 then
    pJoinedPlayers.add(tStrId)
  end if
  me.showPlayerIcon(#joined, tdata)
  me.showJoinedPlayersNum()
  return 1
end

on showRemovedPlayer me, tStrId
  if pJoinedPlayers.findPos(tStrId) = 0 then
    return 0
  end if
  pJoinedPlayers.deleteOne(tStrId)
  me.showPlayerIcon(0, [#id: tStrId])
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
    tStarImg = member(getmemnum("bb_ico_star_lt")).image
  else
    tStarImg = image(11, 9, 8)
  end if
  tImage.copyPixels(tStarImg, tStarImg.rect + rect(109, 1 + (16 * (tMyPlayerNum - 1)), 109, 1 + (16 * (tMyPlayerNum - 1))), tStarImg.rect)
  tElem.feedImage(tImage)
  return 1
end

on showJoinedPlayersNum me
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("bb_info_joinedPlrs")
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
  tElem = tWndObj.getElement("bb_info_tmToJoin")
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

on eventProc me, tEvent, tSprID, tParam
  case tSprID of
    "bb_button_playAgn":
      if me.getGameSystem() = 0 then
        return 0
      end if
      me.getGameSystem().rejoinGame()
    "bb_button_leaveGam2":
      if me.getGameSystem() = 0 then
        return 0
      end if
      me.getGameSystem().enterLounge()
    "bb_link_shrink", "bb_link_expand":
      me.toggleWindowMode()
    "gs_button_buytickets":
      executeMessage(#show_ticketWindow)
  end case
end
