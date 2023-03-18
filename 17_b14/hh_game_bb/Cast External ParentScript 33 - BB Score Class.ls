property pWindowID, pTimeOutID, pBuffer, pTimerEndTime, pTimerDurationSec, pCountdownObjId

on construct me
  pCountdownObjId = "bb_game_countdown"
  pFinalScoresObjId = "bb_game_finalscores"
  pWindowID = "win_bb_score"
  pTimeOutID = "bb_score_updateGameTimeout"
  return 1
end

on deconstruct me
  me.removeGameScores()
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gamestatus_scores:
      return me.renderScore(tdata)
    #gamestart:
      me.startGameTimer(tdata)
      return me.showGameScores()
    #gameend:
      return me.removeGameScores()
    #fullgamestatus_time:
      if tdata[#state] <> #game_started then
        return 1
      end if
      me.resumeGameTimer(tdata)
      return me.showGameScores()
  end case
  return 1
end

on resumeGameTimer me, tdata
  if tdata[#time_to_next_state] <= 0 then
    return 0
  end if
  pTimerEndTime = the milliSeconds + (tdata[#time_to_next_state] * 1000)
  pTimerDurationSec = tdata[#state_duration]
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata[#time_until_game_end])
  return me.renderGameTimer(pTimerEndTime)
end

on startGameTimer me, tdata
  if tdata[#time_until_game_end] <= 0 then
    return 0
  end if
  pTimerEndTime = the milliSeconds + (tdata[#time_until_game_end] * 1000)
  pTimerDurationSec = tdata[#time_until_game_end]
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata[#time_until_game_end])
  return me.renderGameTimer(pTimerEndTime)
end

on convertToMinSec me, tTime
  tMin = tTime / 60000
  tSec = tTime mod 60000 / 1000
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return [tMin, tSec]
end

on renderGameTimer me, tEndTime
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("bb_info_remTime")
  if tElem = 0 then
    return 0
  end if
  if tEndTime < the milliSeconds then
    return 0
  end if
  tTime = me.convertToMinSec(tEndTime - the milliSeconds)
  tTimeStr = tTime[1] & ":" & tTime[2]
  tElem.setText(replaceChunks(getText("gs_timeleft"), "\x", tTimeStr))
  return 1
end

on renderScore me, tdata
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  if (pTimerEndTime - the milliSeconds) >= 0 then
    tElapsedTimePct = ((pTimerDurationSec * 1000) - (pTimerEndTime - the milliSeconds)) / float(pTimerDurationSec * 1000)
  end if
  tMaxWidth = tElapsedTimePct * 159
  tHighest = 0
  repeat with tTeamScore in tdata
    if tTeamScore > tHighest then
      tHighest = float(tTeamScore)
    end if
  end repeat
  if tHighest = 0 then
    return 1
  end if
  repeat with tTeamId = 1 to tdata.count
    tPercent = tdata[tTeamId] / tHighest
    tElem = tWndObj.getElement("bb_bar_scores" & tTeamId)
    if tElem <> 0 then
      tOldSize = tElem.getProperty(#width)
      tNewSize = tMaxWidth * tPercent
      tElem.resizeBy(tNewSize - tOldSize, 0)
    end if
  end repeat
  return 1
end

on showGameScores me
  if windowExists(pWindowID) then
    return 1
  end if
  if createWindow(pWindowID, "bb_scores.window") then
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(41, 50)
    else
      tWndObj.moveTo(25, 26)
    end if
    tWndObj.lock()
    tWndObj.getElement("bb_bar_scores1").resizeTo(0, 5)
    tWndObj.getElement("bb_bar_scores2").resizeTo(0, 5)
    tWndObj.getElement("bb_bar_scores3").resizeTo(0, 5)
    tWndObj.getElement("bb_bar_scores4").resizeTo(0, 5)
  else
    return error(me, "Cannot open score window.", #showGameScores)
  end if
  return 1
end

on removeGameScores me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return 1
end
