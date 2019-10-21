on construct(me)
  pSkillLevelWindowId = "bb_skillevelwindow"
  initThread("bouncingloungemenu.thread.index")
  return(1)
  exit
end

on deconstruct(me)
  if windowExists(pSkillLevelWindowId) then
    removeWindow(pSkillLevelWindowId)
  end if
  closeThread(#loungemenu)
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if getThread(#loungemenu) = 0 then
    return(0)
  end if
  tIntObj = getThread(#loungemenu).getInterface()
  if tIntObj = 0 then
    return(0)
  end if
  tComObj = getThread(#loungemenu).getComponent()
  if tComObj = 0 then
    return(0)
  end if
  if me = #loungeinfo then
    return(me.createSkillLevelWindow(tdata))
  else
    if me = #tournamentlogo then
      return(tIntObj.setTournamentLogo(tdata))
    else
      if me = #numtickets then
        return(tIntObj.setNumTickets())
      else
        if me = #instancelist then
          return(tIntObj.setInstanceList())
        else
          if me = #gameparameters then
            return(tIntObj.showGameCreation())
          else
            if me <> #createok then
              if me = #gameinstance then
                if tComObj.checkUserWasKicked() then
                  tIntObj.showErrorMessage(6)
                end if
                tComObj.saveUserTeamIndex()
                return(tIntObj.showInstance())
              else
                if me = #gamedeleted then
                  me.getGameSystem().unobserveInstance()
                  tComObj.resetUserTeamIndex()
                  return(tIntObj.ChangeWindowView(#gameList))
                else
                  if me = #joinparameters then
                    return(tComObj.joinGame())
                  else
                    if me = #watchok then
                      return(tIntObj.setWatchMode(1))
                    else
                      if me = #watchfailed then
                        tIntObj.setWatchMode(0)
                        return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                      else
                        if me = #joinfailed then
                          return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                        else
                          if me = #createfailed then
                            return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request), tdata.getAt(#key)))
                          else
                            if me = #startfailed then
                              return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                            else
                              if me = #instancenotavailable then
                                return(tIntObj.showErrorMessage("game_deleted"))
                              else
                                if me = #idlewarning then
                                  return(tIntObj.showErrorMessage("idlewarning"))
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
              return(1)
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end

on createSkillLevelWindow(me, tdata)
  tSkillLevel = tdata.getAt(#lounge_skill_name)
  tSkillMin = tdata.getAt(#lounge_skill_score_min)
  tSkillMax = tdata.getAt(#lounge_skill_score_max)
  if tSkillMin <= 0 then
    tSkillMin = getText("gs_lounge_skill_no_min")
  end if
  if tSkillMax <= 0 then
    tSkillMax = getText("gs_lounge_skill_no_max")
  end if
  createWindow(pSkillLevelWindowId, "bb_skillevel.window")
  tWndObj = getWindow(pSkillLevelWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.moveTo(224, 449)
  tSkillStr = replaceChunks(getText("gs_lounge_skill"), "\\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\\y", tSkillMin)
  tSkillStr = replaceChunks(tSkillStr, "\\z", tSkillMax)
  tSkillStr = replaceChunks(tSkillStr, "\\r", "\r")
  tElem = tWndObj.getElement("skill_text")
  if tElem = 0 then
    return(0)
  end if
  tElem.setText(tSkillStr.getProp(#line, 1))
  if tSkillStr.count(#line) > 1 then
    tElem = tWndObj.getElement("skill_score")
    if tElem = 0 then
      return(0)
    end if
    tElem.setText(tSkillStr.getProp(#line, 2))
  end if
  return(1)
  exit
end