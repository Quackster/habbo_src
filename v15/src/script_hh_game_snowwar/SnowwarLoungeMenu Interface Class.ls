property pBalloonMargins, pRenderObj, pMainWindowId, pWindowState, pTournamentLogoMemNum, pGameListPage, pGamesPerPage, pGameParameters, pWatchMode, pTournamentLogoClickURL

on construct me 
  pBalloonMargins = [#normal:[:], #special:[:]]
  pBalloonMargins.getAt(#normal).setAt(#left, getIntVariable("balloons.leftmargin"))
  pBalloonMargins.getAt(#normal).setAt(#right, getIntVariable("balloons.rightmargin"))
  pBalloonMargins.getAt(#special).setAt(#left, 215)
  pBalloonMargins.getAt(#special).setAt(#right, pBalloonMargins.getAt(#normal).getAt(#right))
  pWindowState = 0
  pWatchMode = 0
  pMainWindowId = getText("sw_title")
  pGameListPage = 1
  pGamesPerPage = 6
  pGameParameterStructFormat = []
  pGameParameters = [:]
  pRenderObj = createObject(#temp, "SnowwarLoungeMenu Renderer Class")
  pRenderObj.defineWindow(pMainWindowId)
  registerMessage(#alert, me.getID(), #delayedMenuToBack)
  me.delayedMenuToBack()
  return(1)
end

on deconstruct me 
  if objectp(pRenderObj) then
    pRenderObj.deconstruct()
  end if
  pRenderObj = void()
  removeWindow(pMainWindowId)
  me.setNormalBalloonMargins()
  return(1)
end

on getWindowState me 
  return(pWindowState)
end

on setWindowState me, tstate 
  pWindowState = tstate
  return(1)
end

on setNumTickets me 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("gs_numtickets")
  if tElem = 0 then
    return(0)
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #setNumTickets))
  end if
  tNum = string(tGameSystemObj.getNumTickets())
  if tNum.length = 1 then
    tNum = "00" & tNum
  end if
  if tNum.length = 2 then
    tNum = "0" & tNum
  end if
  return(tElem.setText(tNum))
end

on setTournamentLogo me, tdata 
  tMemNum = tdata.getAt(#member_num)
  if tMemNum = void() then
    tMemNum = 0
  else
    pTournamentLogoMemNum = tMemNum
    pTournamentLogoClickURL = tdata.getAt(#click_url)
  end if
  if undefined.width > 100 then
    return(pRenderObj.renderTournamentLogo(pTournamentLogoMemNum))
  else
    me.delay(500, #setTournamentLogo, tdata)
    return()
  end if
end

on setInstanceList me 
  if me.getWindowState() = 0 then
    return(me.ChangeWindowView(#gameList))
  end if
  if me.getWindowState() <> #gameList then
    return(0)
  end if
  return(me.showInstanceList())
end

on showInstanceList me 
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #showInstanceList))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    tList = [:]
  end if
  tStartIndex = (pGameListPage - 1 * pGamesPerPage) + 1
  pRenderObj.renderInstanceList(tList, tStartIndex, pGamesPerPage)
  tNumPages = integer((tList.count - 1 / pGamesPerPage)) + 1
  if pGameListPage > tNumPages then
    pGameListPage = 1
  end if
  pRenderObj.renderPageNumber(pGameListPage, tNumPages)
end

on showInstance me 
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #showInstance))
  end if
  tParams = tGameSystemObj.getObservedInstance()
  if tParams.getAt(#numTeams) = 2 then
    me.ChangeWindowView(#gameDetails2t)
  else
    if tParams.getAt(#numTeams) = 3 then
      me.ChangeWindowView(#gameDetails3t)
    else
      if tParams.getAt(#numTeams) = 4 then
        me.ChangeWindowView(#gameDetails4t)
      else
        me.ChangeWindowView(#gameDetails1t)
      end if
    end if
  end if
  tStateStr = getText("gs_state_" & tParams.getAt(#state))
  if tParams.getAt(#state) = #created then
    tSpecStr = replaceChunks(getText("gs_specnum"), "\\x", tParams.getAt(#numSpectators))
  else
    tSpecStr = ""
  end if
  pRenderObj.renderInstanceDetailTop(tParams.getAt(#name), tParams.getAt(#host).getAt(#name), tParams.getAt(#state), tStateStr, tSpecStr)
  tButtonState = me.getInstanceDetailButtonState(tParams.getAt(#state))
  pRenderObj.renderInstanceDetailButton(tButtonState, tParams.getAt(#state))
  tHost = me.getComponent().isUserHost()
  tOwnTeam = me.getComponent().getUserTeamIndex()
  pRenderObj.renderInstanceDetailTeams(tParams, me.getComponent().getUserName(), tHost, tOwnTeam)
  return(1)
end

on showGameCreation me 
  me.ChangeWindowView(#createGame)
  tWndObj = getWindow(pMainWindowId)
  me.setGameCreationDefaults()
  tElem = tWndObj.getElement("gs_field_gameNaming")
  if tElem = 0 then
    return(0)
  end if
  updateStage()
  me.setFieldType(1)
  return(tElem.setFocus(1))
end

on ChangeWindowView me, tWindow 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = void() then
    if me.getWindowState() <> 0 then
      return(0)
    end if
    if not createWindow(pMainWindowId) then
      return(0)
    end if
    tWndObj = getWindow(pMainWindowId)
    tWndObj.moveTo(8, 8)
    tWndObj.registerProcedure(#eventProcMainWindow, me.getID(), #mouseUp)
    me.setSpecialBalloonMargins()
  else
    tWndObj.unmerge()
  end if
  if tWndObj = 0 then
    return(0)
  end if
  me.setWindowState(0)
  if tWindow = #gameList then
    if not tWndObj.merge("sw_glist.window") then
      return(0)
    end if
    me.showInstanceList()
    pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
  else
    if tWindow = #gameDetails2t then
      if not tWndObj.merge("sw_ginfo2t.window") then
        return(0)
      end if
    else
      if tWindow = #gameDetails3t then
        if not tWndObj.merge("sw_ginfo3t.window") then
          return(0)
        end if
      else
        if tWindow = #gameDetails4t then
          if not tWndObj.merge("sw_ginfo4t.window") then
            return(0)
          end if
        else
          if tWindow = #gameDetails1t then
            if not tWndObj.merge("sw_ginfo1t.window") then
              return(0)
            end if
          else
            if tWindow = #createGame then
              if not tWndObj.merge("sw_gcreate.window") then
                return(0)
              end if
              pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
            else
              return(0)
            end if
          end if
        end if
      end if
    end if
  end if
  me.setNumTickets()
  me.setWindowState(tWindow)
  me.sendMenuToBack()
  return(1)
end

on hideMainWindow me 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  return(tWndObj.hide())
end

on eventProcMainWindow me, tEvent, tSprID, tParam 
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #eventProcMainWindow))
  end if
  if tSprID = "gs_area_gameList1" then
    tIndexOnPage = 1 + (pGameListPage - 1 * pGamesPerPage)
    return(me.getComponent().observeInstance(tIndexOnPage))
  else
    if tSprID = "gs_area_gameList2" then
      tIndexOnPage = 2 + (pGameListPage - 1 * pGamesPerPage)
      return(me.getComponent().observeInstance(tIndexOnPage))
    else
      if tSprID = "gs_area_gameList3" then
        tIndexOnPage = 3 + (pGameListPage - 1 * pGamesPerPage)
        return(me.getComponent().observeInstance(tIndexOnPage))
      else
        if tSprID = "gs_area_gameList4" then
          tIndexOnPage = 4 + (pGameListPage - 1 * pGamesPerPage)
          return(me.getComponent().observeInstance(tIndexOnPage))
        else
          if tSprID = "gs_area_gameList5" then
            tIndexOnPage = 5 + (pGameListPage - 1 * pGamesPerPage)
            return(me.getComponent().observeInstance(tIndexOnPage))
          else
            if tSprID = "gs_area_gameList6" then
              tIndexOnPage = 6 + (pGameListPage - 1 * pGamesPerPage)
              return(me.getComponent().observeInstance(tIndexOnPage))
            else
              if tSprID = "gs_arrow_pageFwd" then
                return(me.changeInstanceListPage(1))
              else
                if tSprID = "gs_arrow_pageBack" then
                  return(me.changeInstanceListPage(-1))
                else
                  if tSprID = "gs_button_create" then
                    return(tGameSystemObj.initiateCreateGame())
                  else
                    if tSprID = "gs_radio_gamelength_1" then
                      return(me.setGameLength(1))
                    else
                      if tSprID = "gs_radio_gamelength_2" then
                        return(me.setGameLength(2))
                      else
                        if tSprID = "gs_radio_gamelength_3" then
                          return(me.setGameLength(3))
                        else
                          if tSprID = "gs_radio_2teams" then
                            return(me.setNumberOfTeams(2))
                          else
                            if tSprID = "gs_radio_3teams" then
                              return(me.setNumberOfTeams(3))
                            else
                              if tSprID = "gs_radio_4teams" then
                                return(me.setNumberOfTeams(4))
                              else
                                if tSprID = "gs_radio_1teams" then
                                  return(me.setNumberOfTeams(1))
                                else
                                  if tSprID = "gs_dropmenu_gamefield" then
                                    return(me.setFieldType(tParam))
                                  else
                                    if tSprID = "gs_button_rdy" then
                                      tWndObj = getWindow(pMainWindowId)
                                      if tWndObj = 0 then
                                        return(0)
                                      end if
                                      if tWndObj.getElement("gs_field_gameNaming").getText() = "" then
                                        return(me.showErrorMessage("game_checkname"))
                                      end if
                                      tText = tWndObj.getElement("gs_field_gameNaming").getText()
                                      pGameParameters.setAt("name", convertSpecialChars(tText, 1))
                                      me.hideMainWindow()
                                      return(tGameSystemObj.createGame(pGameParameters, 1))
                                    else
                                      if tSprID = "gs_button_cncl" then
                                        tWndObj = getWindow(pMainWindowId)
                                        if tWndObj = 0 then
                                          return(0)
                                        end if
                                        me.ChangeWindowView(#gameList)
                                        return(tGameSystemObj.cancelCreateGame())
                                      else
                                        if tSprID = "gs_button_leaveGame" then
                                          tParams = tGameSystemObj.getObservedInstance()
                                          if tParams.getAt(#state) = #created and me.getComponent().getUserTeamIndex() <> 0 or pWatchMode = 1 then
                                            pWatchMode = 0
                                            me.getComponent().resetUserTeamIndex()
                                            tGameSystemObj.leaveGame()
                                          else
                                            tGameSystemObj.unobserveInstance()
                                            me.getComponent().resetUserTeamIndex()
                                            return(me.ChangeWindowView(#gameList))
                                          end if
                                        else
                                          if tSprID = "gs_link_gameInfo" then
                                            tParams = tGameSystemObj.getObservedInstance()
                                            tAction = me.getInstanceDetailButtonState(tParams.getAt(#state))
                                            if tSprID <> #start then
                                              if tSprID = #start_dimmed then
                                                return(tGameSystemObj.startGame())
                                              else
                                                if tSprID = #spectate then
                                                  return(tGameSystemObj.watchGame())
                                                else
                                                  return(1)
                                                end if
                                              end if
                                              if tSprID = "gs_link_team1" then
                                                me.getComponent().joinGame(1)
                                              else
                                                if tSprID = "gs_link_team2" then
                                                  me.getComponent().joinGame(2)
                                                else
                                                  if tSprID = "gs_link_team3" then
                                                    me.getComponent().joinGame(3)
                                                  else
                                                    if tSprID = "gs_link_team4" then
                                                      me.getComponent().joinGame(4)
                                                    else
                                                      if tSprID <> "bb_kick1_1" then
                                                        if tSprID <> "bb_kick1_2" then
                                                          if tSprID <> "bb_kick1_3" then
                                                            if tSprID <> "bb_kick1_4" then
                                                              if tSprID <> "bb_kick1_5" then
                                                                if tSprID <> "bb_kick1_6" then
                                                                  if tSprID <> "bb_kick2_1" then
                                                                    if tSprID <> "bb_kick2_2" then
                                                                      if tSprID <> "bb_kick2_3" then
                                                                        if tSprID <> "bb_kick2_4" then
                                                                          if tSprID <> "bb_kick2_5" then
                                                                            if tSprID <> "bb_kick2_6" then
                                                                              if tSprID <> "bb_kick3_1" then
                                                                                if tSprID <> "bb_kick3_2" then
                                                                                  if tSprID <> "bb_kick3_3" then
                                                                                    if tSprID <> "bb_kick3_4" then
                                                                                      if tSprID <> "bb_kick4_1" then
                                                                                        if tSprID <> "bb_kick4_2" then
                                                                                          if tSprID = "bb_kick4_3" then
                                                                                            tTeamNum = integer(string(tSprID).getProp(#char, 8))
                                                                                            tPlayerNum = integer(string(tSprID).getProp(#char, 10))
                                                                                            tdata = tGameSystemObj.getObservedInstance()
                                                                                            if tTeamNum < 1 or tTeamNum > tdata.getAt(#teams).count then
                                                                                              return(0)
                                                                                            end if
                                                                                            tTeam = tdata.getAt(#teams).getAt(tTeamNum).getAt(#players)
                                                                                            if tPlayerNum < 1 or tPlayerNum > tTeam.count then
                                                                                              return(0)
                                                                                            end if
                                                                                            return(tGameSystemObj.kickPlayer(tTeam.getAt(tPlayerNum).getAt(#id)))
                                                                                          else
                                                                                            if tSprID = "gs_link_gameRul" then
                                                                                              openNetPage(getText("sw_link_gameRules_url"))
                                                                                            else
                                                                                              if tSprID = "gs_link_highScr" then
                                                                                                if tGameSystemObj.getTournamentFlag() then
                                                                                                  openNetPage(getText("sw_link_tournament_highScores_url"))
                                                                                                else
                                                                                                  openNetPage(getText("sw_link_highScores_url"))
                                                                                                end if
                                                                                              else
                                                                                                if tSprID = "gs_logo_tournament" then
                                                                                                  if pTournamentLogoClickURL <> void() then
                                                                                                    openNetPage(pTournamentLogoClickURL)
                                                                                                  end if
                                                                                                else
                                                                                                  if tSprID = "gs_button_buytickets" then
                                                                                                    return(executeMessage(#show_ticketWindow))
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
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on changeInstanceListPage me, tOffset 
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #changeInstanceListPage))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    return(0)
  end if
  tNumPages = integer((tList.count - 1 / pGamesPerPage)) + 1
  if tOffset = 1 then
    if pGameListPage >= tNumPages then
      return(0)
    else
      pGameListPage = pGameListPage + 1
    end if
  else
    if tOffset = -1 then
      if pGameListPage <= 1 then
        return(0)
      else
        pGameListPage = pGameListPage - 1
      end if
    end if
  end if
  return(me.showInstanceList())
end

on setGameCreationDefaults me 
  pGameParameters = [#new:1]
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #setGameCreationDefaults))
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return(error(me, "Invalid game parameters.", #setGameCreationDefaults))
  end if
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  repeat while tStruct <= undefined
    tItem = getAt(undefined, undefined)
    pGameParameters.addProp(tItem.getAt(#name), tItem.getAt(#default))
    if tStruct = "name" then
      tWndObj.getElement("gs_field_gameNaming").setText(tItem.getAt(#default))
    else
      if tStruct = "numTeams" then
        me.setNumberOfTeams(tItem.getAt(#default))
      else
        if tStruct = "gameLengthChoice" then
          me.setGameLength(tItem.getAt(#default))
        else
          if tStruct = "fieldType" then
            me.setFieldType(tItem.getAt(#default))
          end if
        end if
      end if
    end if
  end repeat
end

on setNumberOfTeams me, tValue 
  tOldElem = "gs_radio_" & pGameParameters.getAt("numTeams") & "teams"
  tNewElem = "gs_radio_" & tValue & "teams"
  pGameParameters.setAt("numTeams", tValue)
  pRenderObj.updateRadioButton("", [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
  return(1)
end

on setGameLength me, tValue 
  tOldElem = "gs_radio_gamelength_" & pGameParameters.getAt("gameLengthChoice")
  tNewElem = "gs_radio_gamelength_" & tValue
  pGameParameters.setAt("gameLengthChoice", tValue)
  pRenderObj.updateRadioButton("", [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
  return(1)
end

on setFieldType me, tValue 
  pGameParameters.setAt("fieldType", integer(tValue))
  tWndObj = getWindow(pMainWindowId)
  tDropDown = tWndObj.getElement("gs_dropmenu_gamefield")
  if not ilk(tDropDown, #instance) then
    return(error(me, "Unable to retrieve dropdown:" && tDropDown, #setFieldType))
  end if
  tFieldTxtItems = []
  tFieldKeyItems = []
  i = 1
  repeat while i <= 7
    tFieldTxtItems.setAt(i, getText("sw_fieldname_" & i))
    tFieldKeyItems.setAt(i, string(i))
    i = 1 + i
  end repeat
  tDropDown.updateData(tFieldTxtItems, tFieldKeyItems, void(), tValue)
  return(1)
end

on getInstanceDetailButtonState me, tGameState 
  tButton = #empty
  if tGameState = #created then
    if me.getComponent().isUserHost() then
      if me.getComponent().gameCanStart() then
        tButton = #start
      else
        tButton = #start_dimmed
      end if
    else
      if pWatchMode then
        tButton = #spectateInfo
      else
        if me.getComponent().getUserTeamIndex() = 0 then
          tButton = #spectate
        end if
      end if
    end if
  else
    if tGameState = #started then
      if me.getComponent().getUserTeamIndex() = 0 then
        tButton = #spectate
      end if
    end if
  end if
  return(tButton)
end

on setWatchMode me, tBoolean 
  pWatchMode = tBoolean
end

on setSpecialBalloonMargins me 
  setVariable("balloons.leftmargin", pBalloonMargins.getAt(#special).getAt(#left))
  setVariable("balloons.rightmargin", pBalloonMargins.getAt(#special).getAt(#right))
  return(1)
end

on setNormalBalloonMargins me 
  setVariable("balloons.leftmargin", pBalloonMargins.getAt(#normal).getAt(#left))
  setVariable("balloons.rightmargin", pBalloonMargins.getAt(#normal).getAt(#right))
  return(1)
end

on showErrorMessage me, tErrorType, tRequestStr, tExtra 
  if tErrorType = 2 then
    executeMessage(#openOneClickGameBuyWindow)
    return(1)
  else
    if tErrorType = "game_deleted" then
      tAlertStr = "gs_error_game_deleted"
    else
      if tErrorType = "idlewarning" then
        tAlertStr = "gs_idlewarning"
      else
        tAlertStr = "gs_error_" & tRequestStr & "_" & tErrorType
        if not textExists(tAlertStr) then
          tAlertStr = "gs_error_" & tErrorType
        end if
      end if
    end if
  end if
  if tErrorType = "create" then
    me.ChangeWindowView(#gameList)
  end if
  if tErrorType = 6 then
    me.ChangeWindowView(#gameList)
  end if
  return(executeMessage(#alert, [#id:"gs_error", #Msg:tAlertStr]))
end

on delayedMenuToBack me 
  createTimeout(#temp, 3000, #sendMenuToBack, me.getID(), void(), 1)
end

on sendMenuToBack me 
  if not windowExists(pMainWindowId) then
    return(0)
  end if
  tWndObj = getWindow(pMainWindowId)
  tWndObj.moveZ(-100000)
  tWndObj.lock()
end
