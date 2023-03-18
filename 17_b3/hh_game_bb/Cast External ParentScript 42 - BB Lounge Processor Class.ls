property pSkillLevelWindowId

on construct me
  pSkillLevelWindowId = "bb_skillevelwindow"
  initThread("bouncingloungemenu.thread.index")
  return 1
end

on deconstruct me
  if windowExists(pSkillLevelWindowId) then
    removeWindow(pSkillLevelWindowId)
  end if
  closeThread(#loungemenu)
  return 1
end

on Refresh me, tTopic, tdata
  if getThread(#loungemenu) = 0 then
    return 0
  end if
  tIntObj = getThread(#loungemenu).getInterface()
  if tIntObj = 0 then
    return 0
  end if
  tComObj = getThread(#loungemenu).getComponent()
  if tComObj = 0 then
    return 0
  end if
  case tTopic of
    #loungeinfo:
      return me.createSkillLevelWindow(tdata)
    #tournamentlogo:
      return tIntObj.setTournamentLogo(tdata)
    #numtickets:
      return tIntObj.setNumTickets()
    #instancelist:
      return tIntObj.setInstanceList()
    #gameparameters:
      return tIntObj.showGameCreation()
    #createok, #gameinstance:
      if tComObj.checkUserWasKicked() then
        tIntObj.showErrorMessage(6)
      end if
      tComObj.saveUserTeamIndex()
      return tIntObj.showInstance()
    #gamedeleted:
      me.getGameSystem().unobserveInstance()
      tComObj.resetUserTeamIndex()
      return tIntObj.ChangeWindowView(#gameList)
    #joinparameters:
      return tComObj.joinGame()
    #watchok:
      return tIntObj.setWatchMode(1)
    #watchfailed:
      tIntObj.setWatchMode(0)
      return tIntObj.showErrorMessage(tdata[#reason], tdata[#request])
    #joinfailed:
      return tIntObj.showErrorMessage(tdata[#reason], tdata[#request])
    #createfailed:
      return tIntObj.showErrorMessage(tdata[#reason], tdata[#request], tdata[#key])
    #startfailed:
      return tIntObj.showErrorMessage(tdata[#reason], tdata[#request])
    #instancenotavailable:
      return tIntObj.showErrorMessage("game_deleted")
    #idlewarning:
      return tIntObj.showErrorMessage("idlewarning")
  end case
  return 1
end

on createSkillLevelWindow me, tdata
  tSkillLevel = tdata[#lounge_skill_name]
  tSkillMin = tdata[#lounge_skill_score_min]
  tSkillMax = tdata[#lounge_skill_score_max]
  if tSkillMin <= 0 then
    tSkillMin = getText("gs_lounge_skill_no_min")
  end if
  if tSkillMax <= 0 then
    tSkillMax = getText("gs_lounge_skill_no_max")
  end if
  createWindow(pSkillLevelWindowId, "bb_skillevel.window")
  tWndObj = getWindow(pSkillLevelWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.moveTo(224, 449)
  tSkillStr = replaceChunks(getText("gs_lounge_skill"), "\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\y", tSkillMin)
  tSkillStr = replaceChunks(tSkillStr, "\z", tSkillMax)
  tSkillStr = replaceChunks(tSkillStr, "\r", RETURN)
  tElem = tWndObj.getElement("skill_text")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(tSkillStr.line[1])
  if tSkillStr.line.count > 1 then
    tElem = tWndObj.getElement("skill_score")
    if tElem = 0 then
      return 0
    end if
    tElem.setText(tSkillStr.line[2])
  end if
  return 1
end
