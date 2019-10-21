on construct(me)
  pWindowID = "win_bb_score"
  pTimeOutID = "bb_score_updateGameTimeout"
  return(1)
  exit
end

on deconstruct(me)
  me.removeGameScores()
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if me = #gamestatus_scores then
    return(me.renderScore(tdata))
  else
    if me = #gamestart then
      me.startGameTimer(tdata)
      return(me.showGameScores())
    else
      if me = #gameend then
        return(me.removeGameScores())
      end if
    end if
  end if
  return(1)
  exit
end

on resumeGameTimer(me, tdata)
  if tdata.getAt(#time_to_next_state) <= 0 then
    return(0)
  end if
  pTimerEndTime = the milliSeconds + tdata.getAt(#time_to_next_state) * 1000
  pTimerDurationSec = tdata.getAt(#state_duration)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata.getAt(#time_until_game_end))
  return(me.renderGameTimer(pTimerEndTime))
  exit
end

on startGameTimer(me, tdata)
  if tdata.getAt(#time_until_game_end) <= 0 then
    return(0)
  end if
  pTimerEndTime = the milliSeconds + tdata.getAt(#time_until_game_end) * 1000
  pTimerDurationSec = tdata.getAt(#time_until_game_end)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata.getAt(#time_until_game_end))
  return(me.renderGameTimer(pTimerEndTime))
  exit
end

on convertToMinSec(me, tTime)
  the render = tTime.pSecondaryTaskList
  tMin = ERROR
  the setHumanSpriteLoc = tTime.pSecondaryTaskList
  tSec = ERROR / 1000
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return([tMin, tSec])
  exit
end

on renderGameTimer(me, tEndTime)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("bb_info_remTime")
  if tElem = 0 then
    return(0)
  end if
  if tEndTime < the milliSeconds then
    return(0)
  end if
  tTime = me.convertToMinSec(tEndTime - the milliSeconds)
  tTimeStr = tTime.getAt(1) & ":" & tTime.getAt(2)
  tElem.setText(replaceChunks(getText("gs_timeleft"), "\\x", tTimeStr))
  return(1)
  exit
end

on renderScore(me, tdata)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if pTimerEndTime - the milliSeconds >= 0 then
    tElapsedTimePct = pTimerDurationSec * 1000 - pTimerEndTime - the milliSeconds / float(pTimerDurationSec * 1000)
  end if
  tMaxWidth = tElapsedTimePct * 159
  tHighest = 0
  repeat while me <= undefined
    tTeamScore = getAt(undefined, tdata)
    if tTeamScore > tHighest then
      tHighest = float(tTeamScore)
    end if
  end repeat
  if tHighest = 0 then
    return(1)
  end if
  tTeamId = 1
  repeat while tTeamId <= tdata.count
    tPercent = tdata.getAt(tTeamId) / tHighest
    tElem = tWndObj.getElement("bb_bar_scores" & tTeamId)
    if tElem <> 0 then
      tOldSize = tElem.getProperty(#width)
      tNewSize = tMaxWidth * tPercent
      tElem.resizeBy(tNewSize - tOldSize, 0)
    end if
    tTeamId = 1 + tTeamId
  end repeat
  return(1)
  exit
end

on showGameScores(me)
  if windowExists(pWindowID) then
    return(1)
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
    return(error(me, "Cannot open score window.", #showGameScores))
  end if
  return(1)
  exit
end

on removeGameScores(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return(1)
  exit
end