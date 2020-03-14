property pBalloonMargins, pRenderObj, pMainWindowId, pWindowState, pTournamentLogoMemNum, pGameListPage, pGamesPerPage, pGameParameters, pWatchMode, pTournamentLogoClickURL

on construct me 
  pBalloonMargins = [#normal:[:], #special:[:]]
  pBalloonMargins.getAt(#normal).setAt(#left, getIntVariable("balloons.leftmargin"))
  pBalloonMargins.getAt(#normal).setAt(#right, getIntVariable("balloons.rightmargin"))
  pBalloonMargins.getAt(#special).setAt(#left, 215)
  pBalloonMargins.getAt(#special).setAt(#right, pBalloonMargins.getAt(#normal).getAt(#right))
  pWindowState = 0
  pWatchMode = 0
  pMainWindowId = getText("bb_title_bouncingBall")
  pGameListPage = 1
  pGamesPerPage = 6
  pGameParameterStructFormat = []
  pGameParameters = [:]
  pRenderObj = createObject(#temp, "BouncingLoungeMenu Renderer Class")
  pRenderObj.defineWindow(pMainWindowId)
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if (tVisual = 0) then
    return()
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    tsprite.registerProcedure(#eventProcTicketBox, me.getID(), #mouseUp)
  end if
  registerMessage(#alert, me.getID(), #delayedMenuToBack)
  me.delayedMenuToBack()
  return TRUE
end

on deconstruct me 
  if objectp(pRenderObj) then
    pRenderObj.deconstruct()
  end if
  pRenderObj = void()
  removeWindow(pMainWindowId)
  me.setNormalBalloonMargins()
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if (tVisual = 0) then
    return()
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    call(#removeProcedure, [tsprite], #eventProcTicketBox, me.getID(), #mouseUp)
  end if
  return TRUE
end

on getWindowState me 
  return(pWindowState)
end

on setWindowState me, tstate 
  pWindowState = tstate
  return TRUE
end

on setNumTickets me 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb_amount_tickets")
  if (tElem = 0) then
    return FALSE
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #setNumTickets))
  end if
  tNum = string(tGameSystemObj.getNumTickets())
  if (tNum.length = 1) then
    tNum = "00" & tNum
  end if
  if (tNum.length = 2) then
    tNum = "0" & tNum
  end if
  return(tElem.setText(tNum))
end

on setTournamentLogo me, tdata 
  tMemNum = tdata.getAt(#member_num)
  if (tMemNum = void()) then
    tMemNum = 0
  else
    pTournamentLogoMemNum = tMemNum
    pTournamentLogoClickURL = tdata.getAt(#click_url)
  end if
  if member(tMemNum).image.width > 100 then
    return(pRenderObj.renderTournamentLogo(pTournamentLogoMemNum))
  else
    me.delay(500, #setTournamentLogo, tdata)
    return()
  end if
end

on setInstanceList me 
  if (me.getWindowState() = 0) then
    return(me.ChangeWindowView(#gameList))
  end if
  if me.getWindowState() <> #gameList then
    return FALSE
  end if
  return(me.showInstanceList())
end

on showInstanceList me 
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #showInstanceList))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    tList = [:]
  end if
  tStartIndex = (((pGameListPage - 1) * pGamesPerPage) + 1)
  pRenderObj.renderInstanceList(tList, tStartIndex, pGamesPerPage)
  tNumPages = (integer(((tList.count - 1) / pGamesPerPage)) + 1)
  if pGameListPage > tNumPages then
    pGameListPage = 1
  end if
  pRenderObj.renderPageNumber(pGameListPage, tNumPages)
end

on showInstance me 
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #showInstance))
  end if
  tParams = tGameSystemObj.getObservedInstance()
  if (tParams.getAt(#numTeams) = 2) then
    me.ChangeWindowView(#gameDetails2t)
  else
    if (tParams.getAt(#numTeams) = 3) then
      me.ChangeWindowView(#gameDetails3t)
    else
      if (tParams.getAt(#numTeams) = 4) then
        me.ChangeWindowView(#gameDetails4t)
      else
        return FALSE
      end if
    end if
  end if
  tStateStr = getText("gs_state_" & tParams.getAt(#state))
  if (tParams.getAt(#state) = #created) then
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
  return TRUE
end

on showGameCreation me 
  me.ChangeWindowView(#createGame)
  tWndObj = getWindow(pMainWindowId)
  me.setGameCreationDefaults()
  tElem = tWndObj.getElement("bb_field_gameNaming")
  if (tElem = 0) then
    return FALSE
  end if
  updateStage()
  tElem.setEdit(1)
  return(tElem.setFocus(1))
  return TRUE
end

on ChangeWindowView me, tWindow 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = void()) then
    if me.getWindowState() <> 0 then
      return FALSE
    end if
    if not createWindow(pMainWindowId) then
      return FALSE
    end if
    tWndObj = getWindow(pMainWindowId)
    tWndObj.moveTo(8, 8)
    tWndObj.registerProcedure(#eventProcMainWindow, me.getID(), #mouseUp)
    me.setSpecialBalloonMargins()
  else
    tWndObj.unmerge()
  end if
  if (tWndObj = 0) then
    return FALSE
  end if
  me.setWindowState(0)
  if (tWindow = #gameList) then
    if not tWndObj.merge("bb_glist.window") then
      return FALSE
    end if
    me.showInstanceList()
    pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
  else
    if (tWindow = #gameDetails2t) then
      if not tWndObj.merge("bb_ginfo2t.window") then
        return FALSE
      end if
    else
      if (tWindow = #gameDetails3t) then
        if not tWndObj.merge("bb_ginfo3t.window") then
          return FALSE
        end if
      else
        if (tWindow = #gameDetails4t) then
          if not tWndObj.merge("bb_ginfo4t.window") then
            return FALSE
          end if
        else
          if (tWindow = #createGame) then
            if not tWndObj.merge("bb_gcreate.window") then
              return FALSE
            end if
            pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
          else
            return FALSE
          end if
        end if
      end if
    end if
  end if
  me.setNumTickets()
  me.setWindowState(tWindow)
  me.sendMenuToBack()
  return TRUE
end

on hideMainWindow me 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  return(tWndObj.hide())
end

on eventProcMainWindow me, tEvent, tSprID, tParam 
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #eventProcMainWindow))
  end if
  if (tSprID = "gs_button_buytickets") then
    me.delayedMenuToBack()
    return(executeMessage(#show_ticketWindow))
  else
    if (tSprID = "bb_area_gameList1") then
      tIndexOnPage = (1 + ((pGameListPage - 1) * pGamesPerPage))
      return(me.getComponent().observeInstance(tIndexOnPage))
    else
      if (tSprID = "bb_area_gameList2") then
        tIndexOnPage = (2 + ((pGameListPage - 1) * pGamesPerPage))
        return(me.getComponent().observeInstance(tIndexOnPage))
      else
        if (tSprID = "bb_area_gameList3") then
          tIndexOnPage = (3 + ((pGameListPage - 1) * pGamesPerPage))
          return(me.getComponent().observeInstance(tIndexOnPage))
        else
          if (tSprID = "bb_area_gameList4") then
            tIndexOnPage = (4 + ((pGameListPage - 1) * pGamesPerPage))
            return(me.getComponent().observeInstance(tIndexOnPage))
          else
            if (tSprID = "bb_area_gameList5") then
              tIndexOnPage = (5 + ((pGameListPage - 1) * pGamesPerPage))
              return(me.getComponent().observeInstance(tIndexOnPage))
            else
              if (tSprID = "bb_area_gameList6") then
                tIndexOnPage = (6 + ((pGameListPage - 1) * pGamesPerPage))
                return(me.getComponent().observeInstance(tIndexOnPage))
              else
                if (tSprID = "bb_arrow_pageFwd") then
                  return(me.changeInstanceListPage(1))
                else
                  if (tSprID = "bb_arrow_pageBack") then
                    return(me.changeInstanceListPage(-1))
                  else
                    if (tSprID = "bb_button_create") then
                      return(tGameSystemObj.initiateCreateGame())
                    else
                      if (tSprID = "bb_radio_teams2x") then
                        return(me.setNumberOfTeams(2))
                      else
                        if (tSprID = "bb_radio_teams3x") then
                          return(me.setNumberOfTeams(3))
                        else
                          if (tSprID = "bb_radio_teams4x") then
                            return(me.setNumberOfTeams(4))
                          else
                            if (tSprID = "bb_button_rdy") then
                              tWndObj = getWindow(pMainWindowId)
                              if (tWndObj = 0) then
                                return FALSE
                              end if
                              if (tWndObj.getElement("bb_field_gameNaming").getText() = "") then
                                return(me.showErrorMessage("game_checkname"))
                              end if
                              tText = tWndObj.getElement("bb_field_gameNaming").getText()
                              pGameParameters.setAt("name", convertSpecialChars(tText, 1))
                              me.hideMainWindow()
                              return(tGameSystemObj.createGame(pGameParameters, 1))
                            else
                              if (tSprID = "bb_button_cncl") then
                                tWndObj = getWindow(pMainWindowId)
                                if (tWndObj = 0) then
                                  return FALSE
                                end if
                                me.ChangeWindowView(#gameList)
                                return(tGameSystemObj.cancelCreateGame())
                              else
                                if (tSprID = "bb_button_leaveGam") then
                                  tParams = tGameSystemObj.getObservedInstance()
                                  if (tParams.getAt(#state) = #created) and me.getComponent().getUserTeamIndex() <> 0 or (pWatchMode = 1) then
                                    pWatchMode = 0
                                    me.getComponent().resetUserTeamIndex()
                                    tGameSystemObj.leaveGame()
                                  else
                                    tGameSystemObj.unobserveInstance()
                                    me.getComponent().resetUserTeamIndex()
                                    return(me.ChangeWindowView(#gameList))
                                  end if
                                else
                                  if (tSprID = "bb_link_gameInfo") then
                                    tParams = tGameSystemObj.getObservedInstance()
                                    tAction = me.getInstanceDetailButtonState(tParams.getAt(#state))
                                    if tAction <> #start then
                                      if (tAction = #start_dimmed) then
                                        return(tGameSystemObj.startGame())
                                      else
                                        if (tAction = #spectate) then
                                          return(tGameSystemObj.watchGame())
                                        else
                                          return TRUE
                                        end if
                                      end if
                                      if (tAction = "bb_link_team1") then
                                        me.getComponent().joinGame(1)
                                      else
                                        if (tAction = "bb_link_team2") then
                                          me.getComponent().joinGame(2)
                                        else
                                          if (tAction = "bb_link_team3") then
                                            me.getComponent().joinGame(3)
                                          else
                                            if (tAction = "bb_link_team4") then
                                              me.getComponent().joinGame(4)
                                            else
                                              if tAction <> "bb_kick1_1" then
                                                if tAction <> "bb_kick1_2" then
                                                  if tAction <> "bb_kick1_3" then
                                                    if tAction <> "bb_kick1_4" then
                                                      if tAction <> "bb_kick1_5" then
                                                        if tAction <> "bb_kick1_6" then
                                                          if tAction <> "bb_kick2_1" then
                                                            if tAction <> "bb_kick2_2" then
                                                              if tAction <> "bb_kick2_3" then
                                                                if tAction <> "bb_kick2_4" then
                                                                  if tAction <> "bb_kick2_5" then
                                                                    if tAction <> "bb_kick2_6" then
                                                                      if tAction <> "bb_kick3_1" then
                                                                        if tAction <> "bb_kick3_2" then
                                                                          if tAction <> "bb_kick3_3" then
                                                                            if tAction <> "bb_kick3_4" then
                                                                              if tAction <> "bb_kick4_1" then
                                                                                if tAction <> "bb_kick4_2" then
                                                                                  if (tAction = "bb_kick4_3") then
                                                                                    tTeamNum = integer(string(tSprID).getProp(#char, 8))
                                                                                    tPlayerNum = integer(string(tSprID).getProp(#char, 10))
                                                                                    tdata = tGameSystemObj.getObservedInstance()
                                                                                    if tTeamNum < 1 or tTeamNum > tdata.getAt(#teams).count then
                                                                                      return FALSE
                                                                                    end if
                                                                                    tTeam = tdata.getAt(#teams).getAt(tTeamNum).getAt(#players)
                                                                                    if tPlayerNum < 1 or tPlayerNum > tTeam.count then
                                                                                      return FALSE
                                                                                    end if
                                                                                    return(tGameSystemObj.kickPlayer(tTeam.getAt(tPlayerNum).getAt(#id)))
                                                                                  else
                                                                                    if (tAction = "bb_link_gameRul") then
                                                                                      openNetPage(getText("bb_link_gameRules_url"))
                                                                                    else
                                                                                      if (tAction = "bb_link_highScr") then
                                                                                        if tGameSystemObj.getTournamentFlag() then
                                                                                          openNetPage(getText("bb_link_tournament_highScores_url"))
                                                                                        else
                                                                                          openNetPage(getText("bb_link_highScores_url"))
                                                                                        end if
                                                                                      else
                                                                                        if (tAction = "bb_logo_tournament") then
                                                                                          if pTournamentLogoClickURL <> void() then
                                                                                            openNetPage(pTournamentLogoClickURL)
                                                                                          end if
                                                                                        end if
                                                                                      end if
                                                                                    end if
                                                                                  end if
                                                                                  return TRUE
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

on eventProcTicketBox me, tEvent, tSprID, tParam 
  return(executeMessage(#show_ticketWindow))
end

on changeInstanceListPage me, tOffset 
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #changeInstanceListPage))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    return FALSE
  end if
  tNumPages = (integer(((tList.count - 1) / pGamesPerPage)) + 1)
  if (tOffset = 1) then
    if pGameListPage >= tNumPages then
      return FALSE
    else
      pGameListPage = (pGameListPage + 1)
    end if
  else
    if (tOffset = -1) then
      if pGameListPage <= 1 then
        return FALSE
      else
        pGameListPage = (pGameListPage - 1)
      end if
    end if
  end if
  return(me.showInstanceList())
end

on setGameCreationDefaults me 
  pGameParameters = [#new:1]
  tGameSystemObj = me.getComponent().getGameSystem()
  if (tGameSystemObj = 0) then
    return(error(me, "Gamesystem not found.", #setGameCreationDefaults))
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return(error(me, "Invalid game parameters.", #setGameCreationDefaults))
  end if
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  repeat while tStruct <= 1
    tItem = getAt(1, count(tStruct))
    pGameParameters.addProp(tItem.getAt(#name), tItem.getAt(#default))
    if (tStruct = "name") then
      tWndObj.getElement("bb_field_gameNaming").setText(tItem.getAt(#default))
    else
      if (tStruct = "numTeams") then
        me.setNumberOfTeams(tItem.getAt(#default))
      end if
    end if
  end repeat
end

on setNumberOfTeams me, tNum 
  tOldElem = "bb_radio_teams" & pGameParameters.getAt("numTeams") & "x"
  tNewElem = "bb_radio_teams" & tNum & "x"
  pGameParameters.setAt("numTeams", tNum)
  tWndObj = getWindow(pMainWindowId)
  pRenderObj.updateRadioButton("", [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
end

on getInstanceDetailButtonState me, tGameState 
  tButton = #empty
  if (tGameState = #created) then
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
        if (me.getComponent().getUserTeamIndex() = 0) then
          tButton = #spectate
        end if
      end if
    end if
  else
    if (tGameState = #started) then
      if (me.getComponent().getUserTeamIndex() = 0) then
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
  return TRUE
end

on setNormalBalloonMargins me 
  setVariable("balloons.leftmargin", pBalloonMargins.getAt(#normal).getAt(#left))
  setVariable("balloons.rightmargin", pBalloonMargins.getAt(#normal).getAt(#right))
  return TRUE
end

on showErrorMessage me, tErrorType, tRequestStr, tExtra 
  if (tErrorType = 2) then
    executeMessage(#openOneClickGameBuyWindow)
    return TRUE
  else
    if (tErrorType = "game_deleted") then
      tAlertStr = "gs_error_game_deleted"
    else
      if (tErrorType = "idlewarning") then
        tAlertStr = "gs_idlewarning"
      else
        tAlertStr = "gs_error_" & tRequestStr & "_" & tErrorType
        if not textExists(tAlertStr) then
          tAlertStr = "gs_error_" & tErrorType
        end if
      end if
    end if
  end if
  if (tRequestStr = "create") then
    me.ChangeWindowView(#gameList)
  end if
  if (tErrorType = 6) then
    me.ChangeWindowView(#gameList)
  end if
  return(executeMessage(#alert, [#id:"gs_error", #Msg:tAlertStr]))
end

on delayedMenuToBack me 
  createTimeout(#temp, 3000, #sendMenuToBack, me.getID(), void(), 1)
end

on sendMenuToBack me 
  if not windowExists(pMainWindowId) then
    return FALSE
  end if
  tWndObj = getWindow(pMainWindowId)
  tWndObj.moveZ(-100000)
  tWndObj.lock()
end
