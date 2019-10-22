property pTimeOutID, pTimerEndTime, pWindowID, pTimerDurationSec

on construct me 
  pCountdownObjId = "bb_game_countdown"
  pFinalScoresObjId = "bb_game_finalscores"
  pWindowID = "win_bb_score"
  pTimeOutID = "bb_score_updateGameTimeout"
  return TRUE
end

on deconstruct me 
  me.removeGameScores()
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gamestatus_scores) then
    return(me.renderScore(tdata))
  else
    if (tTopic = #gamestart) then
      me.startGameTimer(tdata)
      return(me.showGameScores())
    else
      if (tTopic = #gameend) then
        return(me.removeGameScores())
      else
        if (tTopic = #fullgamestatus_time) then
          if tdata.getAt(#state) <> #started then
            return TRUE
          end if
          me.resumeGameTimer(tdata)
          return(me.showGameScores())
        end if
      end if
    end if
  end if
  return TRUE
end

on resumeGameTimer me, tdata 
  if tdata.getAt(#time_to_next_state) <= 0 then
    return FALSE
  end if
  pTimerEndTime = (the milliSeconds + (tdata.getAt(#time_to_next_state) * 1000))
  pTimerDurationSec = tdata.getAt(#state_duration)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata.getAt(#time_until_game_end))
  return(me.renderGameTimer(pTimerEndTime))
end

on startGameTimer me, tdata 
  if tdata.getAt(#time_until_game_end) <= 0 then
    return FALSE
  end if
  pTimerEndTime = (the milliSeconds + (tdata.getAt(#time_until_game_end) * 1000))
  pTimerDurationSec = tdata.getAt(#time_until_game_end)
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderGameTimer, me.getID(), pTimerEndTime, tdata.getAt(#time_until_game_end))
  return(me.renderGameTimer(pTimerEndTime))
end

on convertToMinSec me, tTime 
  tMin = (tTime / 60000)
  tSec = ((tTime mod 60000) / 1000)
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return([tMin, tSec])
end

on renderGameTimer me, tEndTime 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb_info_remTime")
  if (tElem = 0) then
    return FALSE
  end if
  if tEndTime < the milliSeconds then
    return FALSE
  end if
  tTime = me.convertToMinSec((tEndTime - the milliSeconds))
  tTimeStr = tTime.getAt(1) & ":" & tTime.getAt(2)
  tElem.setText(replaceChunks(getText("gs_timeleft"), "\\x", tTimeStr))
  return TRUE
end

on renderScore me, tdata 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if (pTimerEndTime - the milliSeconds) >= 0 then
    tElapsedTimePct = (((pTimerDurationSec * 1000) - (pTimerEndTime - the milliSeconds)) / float((pTimerDurationSec * 1000)))
  end if
  tMaxWidth = (tElapsedTimePct * 159)
  tHighest = 0
  repeat while tdata <= undefined
    tTeamScore = getAt(undefined, tdata)
    if tTeamScore > tHighest then
      tHighest = float(tTeamScore)
    end if
  end repeat
  if (tHighest = 0) then
    return TRUE
  end if
  tTeamId = 1
  repeat while tTeamId <= tdata.count
    tPercent = (tdata.getAt(tTeamId) / tHighest)
    tElem = tWndObj.getElement("bb_bar_scores" & tTeamId)
    if tElem <> 0 then
      tOldSize = tElem.getProperty(#width)
      tNewSize = (tMaxWidth * tPercent)
      tElem.resizeBy((tNewSize - tOldSize), 0)
    end if
    tTeamId = (1 + tTeamId)
  end repeat
  return TRUE
end

on showGameScores me 
  if windowExists(pWindowID) then
    return TRUE
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
  return TRUE
end

on removeGameScores me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return TRUE
end
