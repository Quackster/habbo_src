on construct(me)
  pBalloonMargins = [#normal:[], #special:[]]
  pBalloonMargins.getAt(#normal).setAt(#left, getIntVariable("balloons.leftmargin"))
  pBalloonMargins.getAt(#normal).setAt(#right, getIntVariable("balloons.rightmargin"))
  pBalloonMargins.getAt(#special).setAt(#left, 215)
  pBalloonMargins.getAt(#special).setAt(#right, pBalloonMargins.getAt(#normal).getAt(#right))
  pWindowState = 0
  pWatchMode = 0
  pMainWindowId = getText("bb_title_bouncingBall")
  pGameListPage = 1
  pGamesPerPage = 5
  pGameParameters = []
  pEditableParameters = []
  pRenderObj = createObject(#temp, "BouncingLoungeMenu Renderer Class")
  pRenderObj.defineWindow(pMainWindowId)
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if tVisual = 0 then
    return()
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    tsprite.registerProcedure(#eventProcTicketBox, me.getID(), #mouseUp)
  end if
  registerMessage(#alert, me.getID(), #delayedMenuToBack)
  me.delayedMenuToBack()
  return(1)
  exit
end

on deconstruct(me)
  if objectp(pRenderObj) then
    pRenderObj.deconstruct()
  end if
  pRenderObj = void()
  removeWindow(pMainWindowId)
  me.setNormalBalloonMargins()
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if tVisual = 0 then
    return()
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    call(#removeProcedure, [tsprite], #eventProcTicketBox, me.getID(), #mouseUp)
  end if
  return(1)
  exit
end

on getWindowState(me)
  return(pWindowState)
  exit
end

on setWindowState(me, tstate)
  pWindowState = tstate
  return(1)
  exit
end

on setNumTickets(me)
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("bb_amount_tickets")
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
  exit
end

on setTournamentLogo(me, tdata)
  tMemNum = tdata.getAt(#member_num)
  if tMemNum = void() then
    tMemNum = 0
  else
    pTournamentLogoMemNum = tMemNum
    pTournamentLogoClickURL = tdata.getAt(#click_url)
  end if
  if image.width > 100 then
    return(pRenderObj.renderTournamentLogo(pTournamentLogoMemNum))
  else
    me.delay(500, #setTournamentLogo, tdata)
    return()
  end if
  exit
end

on setInstanceList(me)
  if me.getWindowState() = 0 then
    return(me.ChangeWindowView(#gameList))
  end if
  if me.getWindowState() <> #gameList then
    return(0)
  end if
  return(me.showInstanceList())
  exit
end

on showInstanceList(me)
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #showInstanceList))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    tList = []
  end if
  tStartIndex = pGameListPage - 1 * pGamesPerPage + 1
  pRenderObj.renderInstanceList(tList, tStartIndex, pGamesPerPage)
  tNumPages = integer(tList.count - 1 / pGamesPerPage) + 1
  if pGameListPage > tNumPages then
    pGameListPage = 1
  end if
  pRenderObj.renderPageNumber(pGameListPage, tNumPages)
  exit
end

on showInstance(me, tMode)
  if tMode = void() then
    tMode = me.getWindowState()
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #showInstance))
  end if
  tParams = tGameSystemObj.getObservedInstance()
  if tMode = #gameDetails then
    me.ChangeWindowView(#gameDetails)
    pRenderObj.renderInstanceDetailField(tParams.getAt(#fieldType))
    if tParams.getAt(#fieldType) = 5 then
      tParams.setAt(#allowedPowerups, "")
    end if
    if stringp(tParams.getAt(#allowedPowerups)) then
      pRenderObj.renderInstanceDetailPowerups(tParams.getAt(#allowedPowerups))
    end if
  else
    if me = 2 then
      me.ChangeWindowView(#gameTeams2t)
    else
      if me = 3 then
        me.ChangeWindowView(#gameTeams3t)
      else
        if me = 4 then
          me.ChangeWindowView(#gameTeams4t)
        else
          return(0)
        end if
      end if
    end if
    tHost = me.getComponent().isUserHost()
    tOwnTeam = me.getComponent().getUserTeamIndex()
    pRenderObj.renderInstanceDetailTeams(tParams, me.getComponent().getUserName(), tHost, tOwnTeam)
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
  return(1)
  exit
end

on showGameCreation(me)
  me.ChangeWindowView(#createGame)
  tWndObj = getWindow(pMainWindowId)
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #setGameCreationDefaults))
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return(error(me, "Invalid game parameters.", #setGameCreationDefaults))
  end if
  pGameParameters = [#new:1]
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    pGameParameters.addProp(tItem.getAt(#name), tItem.getAt(#default))
    if tItem.getAt(#editable) = 2 then
      pEditableParameters.add(tItem.getAt(#name))
    end if
  end repeat
  me.setGameCreationDefaults()
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("bb_field_gameNaming")
  if tElem = 0 then
    return(0)
  end if
  updateStage()
  tElem.setEdit(1)
  return(tElem.setFocus(1))
  return(1)
  exit
end

on ChangeWindowView(me, tWindow)
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
  if me = #gameList then
    if not tWndObj.merge("bb_glist.window") then
      return(0)
    end if
    me.showInstanceList()
    pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
  else
    if me = #gameDetails then
      if not tWndObj.merge("bb_ginfo_more.window") then
        return(0)
      end if
    else
      if me = #gameTeams2t then
        if not tWndObj.merge("bb_ginfo2t.window") then
          return(0)
        end if
      else
        if me = #gameTeams3t then
          if not tWndObj.merge("bb_ginfo3t.window") then
            return(0)
          end if
        else
          if me = #gameTeams4t then
            if not tWndObj.merge("bb_ginfo4t.window") then
              return(0)
            end if
          else
            if me = #createGame then
              if not tWndObj.merge("bb_gcreate.window") then
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
  exit
end

on hideMainWindow(me)
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  return(tWndObj.hide())
  exit
end

on eventProcMainWindow(me, tEvent, tSprID, tParam)
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #eventProcMainWindow))
  end if
  if me = "gs_button_buytickets" then
    me.delayedMenuToBack()
    return(executeMessage(#show_ticketWindow))
  else
    if me = "bb_area_gameList1" then
      tIndexOnPage = 1 + pGameListPage - 1 * pGamesPerPage
      return(me.getComponent().observeInstance(tIndexOnPage))
    else
      if me = "bb_area_gameList2" then
        tIndexOnPage = 2 + pGameListPage - 1 * pGamesPerPage
        return(me.getComponent().observeInstance(tIndexOnPage))
      else
        if me = "bb_area_gameList3" then
          tIndexOnPage = 3 + pGameListPage - 1 * pGamesPerPage
          return(me.getComponent().observeInstance(tIndexOnPage))
        else
          if me = "bb_area_gameList4" then
            tIndexOnPage = 4 + pGameListPage - 1 * pGamesPerPage
            return(me.getComponent().observeInstance(tIndexOnPage))
          else
            if me = "bb_area_gameList5" then
              tIndexOnPage = 5 + pGameListPage - 1 * pGamesPerPage
              return(me.getComponent().observeInstance(tIndexOnPage))
            else
              if me = "bb_area_gameList6" then
                tIndexOnPage = 6 + pGameListPage - 1 * pGamesPerPage
                return(me.getComponent().observeInstance(tIndexOnPage))
              else
                if me = "bb_tab_gameInfo" then
                  return(me.showInstance(#gameDetails))
                else
                  if me = "bb_tab_teams" then
                    return(me.showInstance(#gameTeams))
                  else
                    if me = "bb_arrow_pageFwd" then
                      return(me.changeInstanceListPage(1))
                    else
                      if me = "bb_arrow_pageBack" then
                        return(me.changeInstanceListPage(-1))
                      else
                        if me = "bb_button_create" then
                          return(tGameSystemObj.initiateCreateGame())
                        else
                          if me = "bb_radio_teams2x" then
                            return(me.setNumberOfTeams(2))
                          else
                            if me = "bb_radio_teams3x" then
                              return(me.setNumberOfTeams(3))
                            else
                              if me = "bb_radio_teams4x" then
                                return(me.setNumberOfTeams(4))
                              else
                                if me = "gs_dropmenu_gamefield" then
                                  return(me.setFieldType(tParam))
                                else
                                  if me <> "bb2_slot_pwrup_1" then
                                    if me <> "bb2_slot_pwrup_2" then
                                      if me <> "bb2_slot_pwrup_3" then
                                        if me <> "bb2_slot_pwrup_4" then
                                          if me <> "bb2_slot_pwrup_5" then
                                            if me <> "bb2_slot_pwrup_6" then
                                              if me <> "bb2_slot_pwrup_7" then
                                                if me = "bb2_slot_pwrup_8" then
                                                  tSelection = integer(tSprID.getProp(#char, tSprID.length))
                                                  if not integerp(tSelection) then
                                                    return(0)
                                                  end if
                                                  return(me.togglePowerup(tSelection))
                                                else
                                                  if me = "bb_button_rdy" then
                                                    tWndObj = getWindow(pMainWindowId)
                                                    if tWndObj = 0 then
                                                      return(0)
                                                    end if
                                                    if tWndObj.getElement("bb_field_gameNaming").getText() = "" then
                                                      return(me.showErrorMessage("game_checkname"))
                                                    end if
                                                    tText = tWndObj.getElement("bb_field_gameNaming").getText()
                                                    pGameParameters.setAt("name", convertSpecialChars(tText, 1))
                                                    me.hideMainWindow()
                                                    if tGameSystemObj.createGame(pGameParameters, 1) then
                                                      return(1)
                                                    end if
                                                    me.ChangeWindowView(#gameList)
                                                    return(tGameSystemObj.cancelCreateGame())
                                                  else
                                                    if me = "bb_button_cncl" then
                                                      tWndObj = getWindow(pMainWindowId)
                                                      if tWndObj = 0 then
                                                        return(0)
                                                      end if
                                                      me.ChangeWindowView(#gameList)
                                                      return(tGameSystemObj.cancelCreateGame())
                                                    else
                                                      if me = "bb_button_leaveGam" then
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
                                                        if me = "bb_link_gameInfo" then
                                                          tParams = tGameSystemObj.getObservedInstance()
                                                          tAction = me.getInstanceDetailButtonState(tParams.getAt(#state))
                                                          if me <> #start then
                                                            if me = #start_dimmed then
                                                              return(tGameSystemObj.startGame())
                                                            else
                                                              if me = #spectate then
                                                                return(tGameSystemObj.watchGame())
                                                              else
                                                                return(1)
                                                              end if
                                                            end if
                                                            if me = "bb_link_team1" then
                                                              me.getComponent().joinGame(1)
                                                            else
                                                              if me = "bb_link_team2" then
                                                                me.getComponent().joinGame(2)
                                                              else
                                                                if me = "bb_link_team3" then
                                                                  me.getComponent().joinGame(3)
                                                                else
                                                                  if me = "bb_link_team4" then
                                                                    me.getComponent().joinGame(4)
                                                                  else
                                                                    if me <> "bb_kick1_1" then
                                                                      if me <> "bb_kick1_2" then
                                                                        if me <> "bb_kick1_3" then
                                                                          if me <> "bb_kick1_4" then
                                                                            if me <> "bb_kick1_5" then
                                                                              if me <> "bb_kick1_6" then
                                                                                if me <> "bb_kick2_1" then
                                                                                  if me <> "bb_kick2_2" then
                                                                                    if me <> "bb_kick2_3" then
                                                                                      if me <> "bb_kick2_4" then
                                                                                        if me <> "bb_kick2_5" then
                                                                                          if me <> "bb_kick2_6" then
                                                                                            if me <> "bb_kick3_1" then
                                                                                              if me <> "bb_kick3_2" then
                                                                                                if me <> "bb_kick3_3" then
                                                                                                  if me <> "bb_kick3_4" then
                                                                                                    if me <> "bb_kick4_1" then
                                                                                                      if me <> "bb_kick4_2" then
                                                                                                        if me = "bb_kick4_3" then
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
                                                                                                          if me = "bb_link_gameRul" then
                                                                                                            openNetPage(getText("bb_link_gameRules_url"))
                                                                                                          else
                                                                                                            if me = "bb_link_highScr" then
                                                                                                              if tGameSystemObj.getTournamentFlag() then
                                                                                                                openNetPage(getText("bb_link_tournament_highScores_url"))
                                                                                                              else
                                                                                                                openNetPage(getText("bb_link_highScores_url"))
                                                                                                              end if
                                                                                                            else
                                                                                                              if me = "bb_logo_tournament" then
                                                                                                                if pTournamentLogoClickURL <> void() then
                                                                                                                  openNetPage(pTournamentLogoClickURL)
                                                                                                                end if
                                                                                                              else
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
  end if
end

on eventProcTicketBox(me, tEvent, tSprID, tParam)
  return(executeMessage(#show_ticketWindow))
  exit
end

on changeInstanceListPage(me, tOffset)
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #changeInstanceListPage))
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    return(0)
  end if
  tNumPages = integer(tList.count - 1 / pGamesPerPage) + 1
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
  exit
end

on setGameCreationDefaults(me)
  if not listp(pGameParameters) then
    return(0)
  end if
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= pGameParameters.count
    tKey = pGameParameters.getPropAt(i)
    tValue = pGameParameters.getAt(i)
    tActive = pEditableParameters.getPos(tKey) > 0
    if me = #new then
      nothing()
    else
      if me = "name" then
        tWndObj.getElement("bb_field_gameNaming").setText(tValue)
      else
        if me = "numTeams" then
          me.setNumberOfTeams(tValue)
        else
          if me = "fieldType" then
            me.setFieldType(tValue)
          else
            if me = "allowedPowerups" then
              tList = value("[" & tValue & "]")
              if not listp(tList) then
                return(error(me, "Cannot parse default powerup list"))
              end if
              tPos = 1
              repeat while me <= undefined
                tTypeCount = getAt(undefined, undefined)
                if tList.getPos(tTypeCount) > 0 then
                  setPowerupButtonState(me, tPos, tTypeCount, 0, tActive)
                else
                  setPowerupButtonState(me, tPos, tTypeCount, -1, tActive)
                end if
                tPos = tPos + 1
              end repeat
            end if
          end if
        end if
      end if
    end if
    i = 1 + i
  end repeat
  exit
end

on setNumberOfTeams(me, tNum)
  tOldElem = "bb_radio_teams" & pGameParameters.getAt("numTeams") & "x"
  tNewElem = "bb_radio_teams" & tNum & "x"
  pGameParameters.setAt("numTeams", tNum)
  tWndObj = getWindow(pMainWindowId)
  pRenderObj.updateRadioButton("", [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
  exit
end

on setFieldType(me, tValue)
  if integer(tValue) = 5 or pGameParameters.getAt("fieldType") = 5 then
    tUpdateButtons = 1
  end if
  pGameParameters.setAt("fieldType", integer(tValue))
  tWndObj = getWindow(pMainWindowId)
  tDropDown = tWndObj.getElement("gs_dropmenu_gamefield")
  if not ilk(tDropDown, #instance) then
    return(error(me, "Unable to retrieve dropdown:" && tDropDown, #setFieldType))
  end if
  tFieldTxtItems = []
  tFieldKeyItems = []
  i = 1
  repeat while i <= 5
    tFieldTxtItems.setAt(i, getText("bb_fieldname_" & i))
    tFieldKeyItems.setAt(i, string(i))
    i = 1 + i
  end repeat
  tDropDown.updateData(tFieldTxtItems, tFieldKeyItems, void(), tValue)
  if tUpdateButtons then
    tWndObj = getWindow(pMainWindowId)
    if tWndObj = 0 then
      return(0)
    end if
    tVisible = not pGameParameters.getAt("fieldType") = 5
    tNum = 1
    repeat while tNum <= 8
      tElement = tWndObj.getElement("bb2_slot_pwrup_" & tNum)
      if tElement <> 0 then
        tElement.setProperty(#visible, tVisible)
      end if
      tNum = 1 + tNum
    end repeat
  end if
  return(1)
  exit
end

on togglePowerup(me, tNum)
  if pEditableParameters.getPos("allowedPowerups") = 0 then
    return(1)
  end if
  tSelected = pGameParameters.getAt("allowedPowerups")
  tSelectedList = value("[" & tSelected & "]")
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return(error(me, "Gamesystem not found.", #togglePowerup))
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return(error(me, "Invalid game parameters.", #togglePowerup))
  end if
  repeat while me <= undefined
    tItem = getAt(undefined, tNum)
    if tItem.getAt(#name) = "allowedPowerups" then
      tAvailableList = value("[" & tItem.getAt(#default) & "]")
    else
    end if
  end repeat
  if not listp(tAvailableList) then
    return(error(me, "Invalid powerup type index", #togglePowerup))
  end if
  if tNum > tAvailableList.count then
    return(error(me, "Invalid powerup type for index", #togglePowerup))
  end if
  ttype = tAvailableList.getAt(tNum)
  if tAvailableList.getPos(ttype) = 0 then
    return(error(me, "Invalid powerup type num", #togglePowerup))
  end if
  if tSelectedList.getPos(ttype) > 0 then
    tSelectedList.deleteOne(ttype)
    me.setPowerupButtonState(tNum, ttype, 1)
  else
    tSelectedList.add(ttype)
    me.setPowerupButtonState(tNum, ttype, 0)
  end if
  tSelectedList.sort()
  tSelected = string(tSelectedList)
  tSelected = tSelected.getProp(#char, 2, tSelected.length - 1)
  tSelected = replaceChars(tSelected, space(), "")
  pGameParameters.setAt("allowedPowerups", tSelected)
  return(1)
  exit
end

on setPowerupButtonState(me, tNum, ttype, tValue, tActive)
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tElement = tWndObj.getElement("bb2_slot_pwrup_" & tNum)
  if tElement = 0 then
    return(error(me, "Cannot locate powerup button element #" & tNum))
  end if
  if tValue > -1 then
    tMemNum = getmemnum("bb2_pwrupbutton_" & ttype & "_" & tValue)
  else
    tMemNum = getmemnum("bb2_pwrupbttn_bg")
  end if
  if tActive = 0 or tValue = -1 then
    tElement.setProperty(#cursor, 0)
  else
    tElement.setProperty(#cursor, "cursor.finger")
  end if
  if tMemNum > 0 then
    return(tElement.setProperty(#image, member(tMemNum).image))
  end if
  return(0)
  exit
end

on getInstanceDetailButtonState(me, tGameState)
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
  exit
end

on setWatchMode(me, tBoolean)
  pWatchMode = tBoolean
  exit
end

on setSpecialBalloonMargins(me)
  setVariable("balloons.leftmargin", pBalloonMargins.getAt(#special).getAt(#left))
  setVariable("balloons.rightmargin", pBalloonMargins.getAt(#special).getAt(#right))
  return(1)
  exit
end

on setNormalBalloonMargins(me)
  setVariable("balloons.leftmargin", pBalloonMargins.getAt(#normal).getAt(#left))
  setVariable("balloons.rightmargin", pBalloonMargins.getAt(#normal).getAt(#right))
  return(1)
  exit
end

on showErrorMessage(me, tErrorType, tRequestStr, tExtra)
  if me = 2 then
    return(executeMessage(#openOneClickGameBuyWindow))
  else
    if me = "game_deleted" then
      tAlertStr = "gs_error_game_deleted"
    else
      if me = "idlewarning" then
        tAlertStr = "gs_idlewarning"
      else
        tAlertStr = "gs_error_" & tRequestStr & "_" & tErrorType
        if not textExists(tAlertStr) then
          tAlertStr = "gs_error_" & tErrorType
        end if
      end if
    end if
  end if
  if me = "create" then
    me.ChangeWindowView(#gameList)
  end if
  if me = 6 then
    me.ChangeWindowView(#gameList)
  end if
  return(executeMessage(#alert, [#id:"gs_error", #Msg:tAlertStr]))
  exit
end

on delayedMenuToBack(me)
  createTimeout(#temp, 3000, #sendMenuToBack, me.getID(), void(), 1)
  exit
end

on sendMenuToBack(me)
  if not windowExists(pMainWindowId) then
    return(0)
  end if
  tWndObj = getWindow(pMainWindowId)
  the undefined = tWndObj.eventProc
  -- UNK_2
  tWndObj.lock()
  exit
end