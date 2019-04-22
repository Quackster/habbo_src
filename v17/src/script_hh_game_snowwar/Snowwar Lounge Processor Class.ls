property pSkillLevelWindowId

on construct me 
  pSkillLevelWindowId = "snowwar_skillevelwindow"
  initThread("snowwar.loungemenu.thread.index")
  return(1)
end

on deconstruct me 
  if windowExists(pSkillLevelWindowId) then
    removeWindow(pSkillLevelWindowId)
  end if
  closeThread(#loungemenu)
  return(1)
end

on Refresh me, tTopic, tdata 
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
  if tTopic = #loungeinfo then
    return(me.createSkillLevelWindow(tdata))
  else
    if tTopic = #tournamentlogo then
      return(tIntObj.setTournamentLogo(tdata))
    else
      if tTopic = #numtickets then
        return(tIntObj.setNumTickets())
      else
        if tTopic = #instancelist then
          return(tIntObj.setInstanceList())
        else
          if tTopic = #gameparameters then
            return(tIntObj.showGameCreation())
          else
            if tTopic <> #createok then
              if tTopic = #gameinstance then
                tComObj.saveUserTeamIndex()
                return(tIntObj.showInstance())
              else
                if tTopic = #gamedeleted then
                  me.getGameSystem().unobserveInstance()
                  tComObj.resetUserTeamIndex()
                  return(tIntObj.ChangeWindowView(#gameList))
                else
                  if tTopic = #joinparameters then
                    return(tComObj.joinGame())
                  else
                    if tTopic = #watchok then
                      return(tIntObj.setWatchMode(1))
                    else
                      if tTopic = #watchfailed then
                        tIntObj.setWatchMode(0)
                        return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                      else
                        if tTopic = #joinfailed then
                          return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                        else
                          if tTopic = #createfailed then
                            return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request), tdata.getAt(#key)))
                          else
                            if tTopic = #startfailed then
                              return(tIntObj.showErrorMessage(tdata.getAt(#reason), tdata.getAt(#request)))
                            else
                              if tTopic = #instancenotavailable then
                                return(tIntObj.showErrorMessage("game_deleted"))
                              else
                                if tTopic = #idlewarning then
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
            end if
          end if
        end if
      end if
    end if
  end if
end

on createSkillLevelWindow me, tdata 
  tSkillLevel = tdata.getAt(#lounge_skill_name)
  tSkillMin = tdata.getAt(#lounge_skill_score_min)
  tSkillMax = tdata.getAt(#lounge_skill_score_max)
  if tSkillMin <= 0 then
    tSkillMin = getText("gs_lounge_skill_no_min")
  end if
  if tSkillMax <= 0 then
    tSkillMax = getText("gs_lounge_skill_no_max")
  end if
  createWindow(pSkillLevelWindowId, "sw_skillevel.window")
  tWndObj = getWindow(pSkillLevelWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.moveTo(228, 449)
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
end
