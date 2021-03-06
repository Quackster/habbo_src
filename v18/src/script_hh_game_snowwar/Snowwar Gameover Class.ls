property pWriterPlainNormLeft, pWriterLinkRight, pOpenWindow, pScoreData, pWindowID, pTimeOutID, pPlayerData, pBestPlayer, pJoinedPlayers, pCountdownEndTime

on construct me 
  pScoreData = [:]
  pPlayerData = [:]
  pJoinedPlayers = [:]
  pBestPlayer = [:]
  pWindowID = getText("gs_title_finalscores")
  pTimeOutID = "gs_endgame_resetGameTimeout"
  createWriter("gs_plain_norm_left", getStructVariable("struct.font.plain"))
  pWriterPlainNormLeft = getWriter("gs_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:16])
  createWriter("gs_plain_bold_left", getStructVariable("struct.font.bold"))
  pWriterPlainBoldLeft = getWriter("gs_plain_bold_left")
  createWriter("gs_link_right", getStructVariable("struct.font.link"))
  pWriterLinkRight = getWriter("gs_link_right")
  pWriterLinkRight.setProperty(#alignment, #right)
  registerMessage(#remove_user, me.getID(), #showRemovedPlayer)
  return TRUE
end

on deconstruct me 
  me.removeFinalScores()
  removeWriter("gs_plain_norm_left")
  pWriterPlainNormLeft = void()
  removeWriter("gs_plain_bold_left")
  pWriterPlainBoldLeft = void()
  removeWriter("gs_link_right")
  pWriterLinkRight = void()
  pBestPlayer = void()
  unregisterMessage(#remove_user, me.getID())
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gameend) then
    pJoinedPlayers = [:]
    me.saveSortedScores(tdata)
    me.startResetCountdown(tdata.getAt(#time_until_game_reset))
    me.toggleWindowMode()
  else
    if (tTopic = #gamereset) then
      me.removeFinalScores()
    else
      if (tTopic = #playerrejoined) then
        me.showJoinedPlayer(tdata)
      else
        if (tTopic = #numtickets) then
          return(me.renderNumTickets())
        end if
      end if
    end if
  end if
  return TRUE
end

on toggleWindowMode me 
  if (pOpenWindow = void()) or (pOpenWindow = "sw_score_tiny.window") then
    if not listp(pScoreData) then
      return FALSE
    end if
    tTeamNum = pScoreData.count
    pOpenWindow = "sw_score_big_" & tTeamNum & "t.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return(error(me, "Cannot open score window.", #toggleWindowMode))
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
      return(error(me, "Cannot open score window.", #toggleWindowMode))
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
  return TRUE
end

on removeFinalScores me 
  pCountdownEndTime = void()
  pOpenWindow = void()
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return TRUE
end

on renderNumTickets me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("gs_numtickets")
  if (tElem = 0) then
    return FALSE
  end if
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tNumTickets = string(me.getGameSystem().getNumTickets())
  if (tNumTickets.length = 1) then
    tNumTickets = "00" & tNumTickets
  end if
  if (tNumTickets.length = 2) then
    tNumTickets = "0" & tNumTickets
  end if
  tElem.setText(tNumTickets)
end

on saveSortedScores me, tdata 
  pScoreData = tdata.getAt(#gameend_scores)
  tSortedTeams = []
  tTeamNum = pScoreData.count
  tTeamId = 1
  repeat while tTeamId <= tTeamNum
    tdata = pScoreData.getAt(tTeamId)
    tSortedPlayers = []
    tPlayerNum = 1
    repeat while tPlayerNum <= tdata.getAt(#players).count
      tPos = 1
      if tSortedPlayers.count > 0 then
        repeat while tSortedPlayers.getAt(tPos).getAt(#score) > tdata.getAt(#players).getAt(tPlayerNum).getAt(#score)
          tPos = (tPos + 1)
          if tPos > tSortedPlayers.count then
          else
          end if
        end repeat
      end if
      tSortedPlayers.addAt(tPos, tdata.getAt(#players).getAt(tPlayerNum).duplicate())
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tPos = 1
    if tSortedTeams.count > 0 then
      repeat while tSortedTeams.getAt(tPos).getAt(#score) > tdata.getAt(#score)
        tPos = (tPos + 1)
        if tPos > tSortedTeams.count then
        else
        end if
      end repeat
    end if
    tSortedTeams.addAt(tPos, [#score:tdata.getAt(#score), #team_id:tTeamId, #players:tSortedPlayers])
    tTeamId = (1 + tTeamId)
  end repeat
  pScoreData = tSortedTeams
  if getObject(#session).exists("user_game_index") then
    tOwnId = getObject(#session).GET("user_game_index")
  end if
  tOwnPlayerWins = 0
  pPlayerData = [:]
  pBestPlayer = [:]
  tTeamInfoCount = 1
  repeat while tTeamInfoCount <= tTeamNum
    tdata = pScoreData.getAt(tTeamInfoCount)
    tPlayerNum = 1
    repeat while tPlayerNum <= tdata.getAt(#players).count
      tPlayerId = string(tdata.getAt(#players).getAt(tPlayerNum).getAt(#id))
      tPlayerName = tdata.getAt(#players).getAt(tPlayerNum).getAt(#name)
      pPlayerData.addProp(tPlayerId, tPlayerName)
      if (tPlayerId = tOwnId) and (tTeamInfoCount = 1) then
        tOwnPlayerWins = 1
      end if
      if tdata.getAt(#players).getAt(tPlayerNum).getAt(#score) > pBestPlayer.getAt(#score) then
        pBestPlayer.setAt(#tie, 0)
        pBestPlayer.setAt(#id, tPlayerId)
        pBestPlayer.setAt(#name, tPlayerName)
        pBestPlayer.setAt(#score, tdata.getAt(#players).getAt(tPlayerNum).getAt(#score))
      else
        if (tdata.getAt(#players).getAt(tPlayerNum).getAt(#score) = pBestPlayer.getAt(#score)) then
          pBestPlayer.setAt(#tie, 1)
        end if
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tTeamInfoCount = (1 + tTeamInfoCount)
  end repeat
  if pBestPlayer.getAt(#tie) then
    playSound("LS-C64-win-1")
  else
    pBestPlayer.setAt(#image, me.getBestPlayerImage(pBestPlayer.getAt(#id)))
    if tOwnPlayerWins then
      playSound("LS-C64-win-1")
    else
      playSound("LS-C64-loose-1")
    end if
  end if
  return TRUE
end

on renderFinalScoresText me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if me.getGameSystem().getSpectatorModeFlag() then
    repeat while ["gs_button_rejoin", "gs_button_leaveGame2"] <= undefined
      tButtonID = getAt(undefined, undefined)
      tWndObj.getElement(tButtonID).hide()
    end repeat
  end if
  tTeamNum = pScoreData.count
  tTeamInfoCount = 1
  repeat while tTeamInfoCount <= tTeamNum
    tdata = pScoreData.getAt(tTeamInfoCount)
    tTeamId = tdata.getAt(#team_id)
    tElem = tWndObj.getElement("gs_scores_icon_team" & tTeamInfoCount)
    tImage = member(getmemnum("sw_ico_team" & tTeamId)).image
    if tElem <> 0 and tImage <> void() then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("gs_scores_score_team" & tTeamInfoCount)
    if tElem <> 0 then
      tElem.setText(tdata.getAt(#score))
    end if
    tImage = me.renderFinalScoreItem(tdata)
    tElem = tWndObj.getElement("bb_area_scores" & tTeamInfoCount)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    tTeamInfoCount = (1 + tTeamInfoCount)
  end repeat
  if not pBestPlayer.getAt(#tie) then
    if (pBestPlayer.getAt(#image) = void()) then
      pBestPlayer.setAt(#image, member(getmemnum("guide_tie")).image)
    end if
    tElem = tWndObj.getElement("gs_bestplayer_name")
    tElem.setText(pBestPlayer.getAt(#name))
    tElem = tWndObj.getElement("gs_bestplayer_score")
    tElem.setText(pBestPlayer.getAt(#score))
    tElem = tWndObj.getElement("bb_icon_winner")
    if tElem <> 0 and (ilk(pBestPlayer.getAt(#image)) = #image) then
      tElem.feedImage(pBestPlayer.getAt(#image))
    end if
  else
    tPlayerImage = member(getmemnum("guide_tie")).image
    tElem = tWndObj.getElement("bb_icon_winner")
    if tElem <> 0 and (ilk(tPlayerImage) = #image) then
      tElem.feedImage(tPlayerImage)
    end if
    tElem = tWndObj.getElement("gs_bestplayer_title")
    if tElem <> 0 then
      tElem.setText(getText("gs_score_tie"))
    end if
  end if
  return TRUE
end

on renderFinalScoreItem me, tTeam 
  tNameTxt = ""
  tScoreTxt = ""
  tImage = image(165, (tTeam.getAt(#players).count * 16), 32)
  tPlayerNum = 1
  repeat while tPlayerNum <= tTeam.getAt(#players).count
    tScoreTxt = tScoreTxt & tTeam.getAt(#players).getAt(tPlayerNum).getAt(#score) & "\r"
    tNameTxt = tNameTxt & tTeam.getAt(#players).getAt(tPlayerNum).getAt(#name) & "\r"
    tPlayerNum = (1 + tPlayerNum)
  end repeat
  tOffset = 0
  tNameImage = pWriterPlainNormLeft.render(tNameTxt)
  tImage.copyPixels(tNameImage, (tNameImage.rect + rect(6, (-5 + tOffset), 6, (-5 + tOffset))), tNameImage.rect)
  tScoreImage = pWriterPlainNormLeft.render(tScoreTxt)
  tImage.copyPixels(tScoreImage, (tScoreImage.rect + rect(130, (-5 + tOffset), 130, (-5 + tOffset))), tScoreImage.rect)
  return(tImage)
end

on showJoinedPlayer me, tdata 
  tStrId = string(tdata.getAt(#id))
  tHumanId = string(me.getGameSystem().getGameObjectProperty(tStrId, "human_id"))
  tRoomIndex = string(me.getGameSystem().getGameObjectProperty(tStrId, "room_index"))
  if (pJoinedPlayers.findPos(tRoomIndex) = 0) then
    pJoinedPlayers.addProp(tRoomIndex, ["human_id":tHumanId])
  end if
  me.showPlayerIcon(#joined, [#id:tHumanId])
  me.showJoinedPlayersNum()
  return TRUE
end

on showRemovedPlayer me, tRoomIndex 
  if (pJoinedPlayers.findPos(tRoomIndex) = 0) then
    return FALSE
  end if
  tHumanId = pJoinedPlayers.getAt(tRoomIndex).getAt("human_id")
  pJoinedPlayers.deleteProp(tRoomIndex)
  me.showPlayerIcon(0, [#id:tHumanId])
  me.showJoinedPlayersNum()
  return TRUE
end

on showPlayerIcon me, tIcon, tdata 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tStrId = string(tdata.getAt(#id))
  if (pScoreData = void()) then
    return FALSE
  end if
  tTeamNum = 1
  repeat while tTeamNum <= pScoreData.count
    tPlayerNum = 1
    repeat while tPlayerNum <= pScoreData.getAt(tTeamNum).getAt(#players).count
      if (pScoreData.getAt(tTeamNum).getAt(#players).getAt(tPlayerNum).getAt(#id) = tdata.getAt(#id)) then
        tMyTeamNum = tTeamNum
        tMyPlayerNum = tPlayerNum
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tTeamNum = (1 + tTeamNum)
  end repeat
  tElem = tWndObj.getElement("bb_area_scores" & tMyTeamNum)
  if (tElem = 0) then
    return FALSE
  end if
  tImage = tElem.getProperty(#image)
  if (tIcon = #joined) then
    tStarImg = member(getmemnum("sw_ico_star_lt")).image
  else
    tStarImg = image(11, 9, 8)
  end if
  tImage.copyPixels(tStarImg, (tStarImg.rect + rect(109, (1 + (16 * (tMyPlayerNum - 1))), 109, (1 + (16 * (tMyPlayerNum - 1))))), tStarImg.rect)
  tElem.feedImage(tImage)
  return TRUE
end

on showJoinedPlayers me 
  if not listp(pJoinedPlayers) then
    return TRUE
  end if
  repeat while pJoinedPlayers <= undefined
    tPlayer = getAt(undefined, undefined)
    tHumanId = string(tPlayer.getAt("human_id"))
    me.showPlayerIcon(#joined, [#id:tHumanId])
  end repeat
  return TRUE
end

on showJoinedPlayersNum me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("gs_joinedplayers")
  if (tElem = 0) then
    return FALSE
  end if
  return(tElem.setText(replaceChunks(getText("gs_joinedplayers"), "\\x", pJoinedPlayers.count)))
end

on startResetCountdown me, tSecondsLeft 
  if tSecondsLeft <= 0 then
    return FALSE
  end if
  pCountdownEndTime = (the milliSeconds + (tSecondsLeft * 1000))
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderCountdownTimer, me.getID(), pCountdownEndTime, tSecondsLeft)
  me.renderCountdownTimer()
  return TRUE
end

on convertToMinSec me, tTime 
  tMin = (tTime / 60000)
  tSec = ((tTime mod 60000) / 1000)
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return([tMin, tSec])
end

on renderCountdownTimer me 
  if (pCountdownEndTime = 0) then
    return FALSE
  end if
  tEndTime = pCountdownEndTime
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("gs_timetojoin")
  if (tElem = 0) then
    return FALSE
  end if
  if tEndTime < the milliSeconds then
    return FALSE
  end if
  tTime = me.convertToMinSec((tEndTime - the milliSeconds))
  tTimeStr = tTime.getAt(1) & ":" & tTime.getAt(2)
  tElem.setText(replaceChunks(getText("gs_timetojoin"), "\\x", tTimeStr))
end

on getBestPlayerImage me, tUserID 
  tUserGameObj = me.getGameSystem().getGameObject(string(tUserID))
  if (tUserGameObj = 0) then
    return(error(me, "Winning player's userobject not found in room, id:" && tUserID, #getBestPlayerImage))
  end if
  tTempImage = tUserGameObj.getRoomObjectImage()
  tPlayerImage = image(tTempImage.width, tTempImage.height, 32)
  tPlayerImage.copyPixels(tTempImage, tTempImage.rect, (tTempImage.rect + rect(27, 45, 27, 45)))
  return(tPlayerImage)
end

on eventProc me, tEvent, tSprID, tParam 
  if (tSprID = "gs_button_rejoin") then
    if (me.getGameSystem() = 0) then
      return FALSE
    end if
    me.getGameSystem().rejoinGame()
  else
    if tSprID <> "gs_button_leavegame" then
      if (tSprID = "gs_button_leaveGame2") then
        if (me.getGameSystem() = 0) then
          return FALSE
        end if
        me.getGameSystem().enterLounge()
      else
        if tSprID <> "gs_link_shrink" then
          if (tSprID = "gs_link_expand") then
            return(me.toggleWindowMode())
          else
            if (tSprID = "gs_button_buytickets") then
              return(executeMessage(#show_ticketWindow))
            end if
          end if
        end if
      end if
    end if
  end if
end
