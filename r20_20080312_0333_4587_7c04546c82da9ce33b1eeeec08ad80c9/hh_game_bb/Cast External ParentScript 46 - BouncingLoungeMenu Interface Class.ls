property pWindowState, pMainWindowId, pBalloonMargins, pWatchMode, pTournamentLogoMemNum, pTournamentLogoClickURL, pGameListPage, pGamesPerPage, pGameParameters, pEditableParameters, pRenderObj

on construct me
  pBalloonMargins = [#normal: [:], #special: [:]]
  pBalloonMargins[#normal][#left] = getIntVariable("balloons.leftmargin")
  pBalloonMargins[#normal][#right] = getIntVariable("balloons.rightmargin")
  pBalloonMargins[#special][#left] = 215
  pBalloonMargins[#special][#right] = pBalloonMargins[#normal][#right]
  pWindowState = 0
  pWatchMode = 0
  pMainWindowId = getText("bb_title_bouncingBall")
  pGameListPage = 1
  pGamesPerPage = 5
  pGameParameters = [:]
  pEditableParameters = []
  pRenderObj = createObject(#temp, "BouncingLoungeMenu Renderer Class")
  pRenderObj.defineWindow(pMainWindowId)
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if tVisual = 0 then
    return 
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    tsprite.registerProcedure(#eventProcTicketBox, me.getID(), #mouseUp)
  end if
  registerMessage(#alert, me.getID(), #delayedMenuToBack)
  me.delayedMenuToBack()
  return 1
end

on deconstruct me
  if objectp(pRenderObj) then
    pRenderObj.deconstruct()
  end if
  pRenderObj = VOID
  removeWindow(pMainWindowId)
  me.setNormalBalloonMargins()
  tVisual = getObject(#room_interface).getRoomVisualizer()
  if tVisual = 0 then
    return 
  end if
  tsprite = tVisual.getSprById("bb_ticket_box")
  if ilk(tsprite, #sprite) then
    call(#removeProcedure, [tsprite], #eventProcTicketBox, me.getID(), #mouseUp)
  end if
  return 1
end

on getWindowState me
  return pWindowState
end

on setWindowState me, tstate
  pWindowState = tstate
  return 1
end

on setNumTickets me
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("bb_amount_tickets")
  if tElem = 0 then
    return 0
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #setNumTickets)
  end if
  if tGameSystemObj.getGameTicketsNotUsedFlag() then
    tElem.hide()
    tElem = tWndObj.getElement("gs_button_buytickets")
    if tElem <> 0 then
      tElem.hide()
    end if
    tElem = tWndObj.getElement("bb_amount_tickets_bg")
    if tElem <> 0 then
      tElem.hide()
    end if
    return 1
  end if
  tNum = string(tGameSystemObj.getNumTickets())
  if tNum.length = 1 then
    tNum = "00" & tNum
  end if
  if tNum.length = 2 then
    tNum = "0" & tNum
  end if
  return tElem.setText(tNum)
end

on setTournamentLogo me, tdata
  tMemNum = tdata[#member_num]
  if tMemNum = VOID then
    tMemNum = 0
  else
    pTournamentLogoMemNum = tMemNum
    pTournamentLogoClickURL = tdata[#click_url]
  end if
  if member(tMemNum).image.width > 100 then
    return pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
  else
    me.delay(500, #setTournamentLogo, tdata)
    return 
  end if
end

on setInstanceList me
  if me.getWindowState() = 0 then
    return me.ChangeWindowView(#gameList)
  end if
  if me.getWindowState() <> #gameList then
    return 0
  end if
  return me.showInstanceList()
end

on showInstanceList me
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #showInstanceList)
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    tList = [:]
  end if
  tStartIndex = ((pGameListPage - 1) * pGamesPerPage) + 1
  pRenderObj.renderInstanceList(tList, tStartIndex, pGamesPerPage)
  tNumPages = integer((tList.count - 1) / pGamesPerPage) + 1
  if pGameListPage > tNumPages then
    pGameListPage = 1
  end if
  pRenderObj.renderPageNumber(pGameListPage, tNumPages)
end

on showInstance me, tMode
  if tMode = VOID then
    tMode = me.getWindowState()
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #showInstance)
  end if
  tParams = tGameSystemObj.getObservedInstance()
  if tMode = #gameDetails then
    me.ChangeWindowView(#gameDetails)
    pRenderObj.renderInstanceDetailField(tParams[#fieldType])
    if tParams[#fieldType] = 5 then
      tParams[#allowedPowerups] = EMPTY
    end if
    if stringp(tParams[#allowedPowerups]) then
      pRenderObj.renderInstanceDetailPowerups(tParams[#allowedPowerups])
    end if
  else
    case tParams[#numTeams] of
      2:
        me.ChangeWindowView(#gameTeams2t)
      3:
        me.ChangeWindowView(#gameTeams3t)
      4:
        me.ChangeWindowView(#gameTeams4t)
      otherwise:
        return 0
    end case
    tHost = me.getComponent().isUserHost()
    tOwnTeam = me.getComponent().getUserTeamIndex()
    pRenderObj.renderInstanceDetailTeams(tParams, me.getComponent().getUserName(), tHost, tOwnTeam)
  end if
  tStateStr = getText("gs_state_" & tParams[#state])
  if tParams[#state] = #created then
    tSpecStr = replaceChunks(getText("gs_specnum"), "\x", tParams[#numSpectators])
  else
    tSpecStr = EMPTY
  end if
  pRenderObj.renderInstanceDetailTop(tParams[#name], tParams[#host][#name], tParams[#state], tStateStr, tSpecStr)
  tButtonState = me.getInstanceDetailButtonState(tParams[#state])
  pRenderObj.renderInstanceDetailButton(tButtonState, tParams[#state])
  return 1
end

on showGameCreation me
  me.ChangeWindowView(#createGame)
  tWndObj = getWindow(pMainWindowId)
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #setGameCreationDefaults)
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return error(me, "Invalid game parameters.", #setGameCreationDefaults)
  end if
  pGameParameters = [#new: 1]
  repeat with tItem in tStruct
    pGameParameters.addProp(tItem[#name], tItem[#default])
    if tItem[#editable] = 2 then
      pEditableParameters.add(tItem[#name])
    end if
  end repeat
  me.setGameCreationDefaults()
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("bb_field_gameNaming")
  if tElem = 0 then
    return 0
  end if
  updateStage()
  tElem.setEdit(1)
  return tElem.setFocus(1)
  return 1
end

on ChangeWindowView me, tWindow
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = VOID then
    if me.getWindowState() <> 0 then
      return 0
    end if
    if not createWindow(pMainWindowId) then
      return 0
    end if
    tWndObj = getWindow(pMainWindowId)
    tWndObj.moveTo(8, 8)
    tWndObj.registerProcedure(#eventProcMainWindow, me.getID(), #mouseUp)
    me.setSpecialBalloonMargins()
  else
    tWndObj.unmerge()
  end if
  if tWndObj = 0 then
    return 0
  end if
  me.setWindowState(0)
  case tWindow of
    #gameList:
      if not tWndObj.merge("bb_glist.window") then
        return 0
      end if
      me.showInstanceList()
      pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
    #gameDetails:
      if not tWndObj.merge("bb_ginfo_more.window") then
        return 0
      end if
    #gameTeams2t:
      if not tWndObj.merge("bb_ginfo2t.window") then
        return 0
      end if
    #gameTeams3t:
      if not tWndObj.merge("bb_ginfo3t.window") then
        return 0
      end if
    #gameTeams4t:
      if not tWndObj.merge("bb_ginfo4t.window") then
        return 0
      end if
    #createGame:
      if not tWndObj.merge("bb_gcreate.window") then
        return 0
      end if
      pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
    otherwise:
      return 0
  end case
  me.setNumTickets()
  me.setWindowState(tWindow)
  me.sendMenuToBack()
  return 1
end

on hideMainWindow me
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  return tWndObj.hide()
end

on eventProcMainWindow me, tEvent, tSprID, tParam
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #eventProcMainWindow)
  end if
  case tSprID of
    "gs_button_buytickets":
      me.delayedMenuToBack()
      return executeMessage(#show_ticketWindow)
    "bb_area_gameList1":
      tIndexOnPage = 1 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_area_gameList2":
      tIndexOnPage = 2 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_area_gameList3":
      tIndexOnPage = 3 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_area_gameList4":
      tIndexOnPage = 4 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_area_gameList5":
      tIndexOnPage = 5 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_area_gameList6":
      tIndexOnPage = 6 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "bb_tab_gameInfo":
      return me.showInstance(#gameDetails)
    "bb_tab_teams":
      return me.showInstance(#gameTeams)
    "bb_arrow_pageFwd":
      return me.changeInstanceListPage(1)
    "bb_arrow_pageBack":
      return me.changeInstanceListPage(-1)
    "bb_button_create":
      return tGameSystemObj.initiateCreateGame()
    "bb_radio_teams2x":
      return me.setNumberOfTeams(2)
    "bb_radio_teams3x":
      return me.setNumberOfTeams(3)
    "bb_radio_teams4x":
      return me.setNumberOfTeams(4)
    "gs_dropmenu_gamefield":
      return me.setFieldType(tParam)
    "bb2_slot_pwrup_1", "bb2_slot_pwrup_2", "bb2_slot_pwrup_3", "bb2_slot_pwrup_4", "bb2_slot_pwrup_5", "bb2_slot_pwrup_6", "bb2_slot_pwrup_7", "bb2_slot_pwrup_8":
      tSelection = integer(tSprID.char[tSprID.length])
      if not integerp(tSelection) then
        return 0
      end if
      return me.togglePowerup(tSelection)
    "bb_button_rdy":
      tWndObj = getWindow(pMainWindowId)
      if tWndObj = 0 then
        return 0
      end if
      if tWndObj.getElement("bb_field_gameNaming").getText() = EMPTY then
        return me.showErrorMessage("game_checkname")
      end if
      tText = tWndObj.getElement("bb_field_gameNaming").getText()
      pGameParameters["name"] = convertSpecialChars(tText, 1)
      me.hideMainWindow()
      if tGameSystemObj.createGame(pGameParameters, 1) then
        return 1
      end if
      me.ChangeWindowView(#gameList)
      return tGameSystemObj.cancelCreateGame()
    "bb_button_cncl":
      tWndObj = getWindow(pMainWindowId)
      if tWndObj = 0 then
        return 0
      end if
      me.ChangeWindowView(#gameList)
      return tGameSystemObj.cancelCreateGame()
    "bb_button_leaveGam":
      tParams = tGameSystemObj.getObservedInstance()
      if (tParams[#state] = #created) and ((me.getComponent().getUserTeamIndex() <> 0) or (pWatchMode = 1)) then
        pWatchMode = 0
        me.getComponent().resetUserTeamIndex()
        tGameSystemObj.leaveGame()
      else
        tGameSystemObj.unobserveInstance()
        me.getComponent().resetUserTeamIndex()
        return me.ChangeWindowView(#gameList)
      end if
    "bb_link_gameInfo":
      tParams = tGameSystemObj.getObservedInstance()
      tAction = me.getInstanceDetailButtonState(tParams[#state])
      case tAction of
        #start, #start_dimmed:
          return tGameSystemObj.startGame()
        #spectate:
          return tGameSystemObj.watchGame()
        otherwise:
          return 1
      end case
    "bb_link_team1":
      me.getComponent().joinGame(1)
    "bb_link_team2":
      me.getComponent().joinGame(2)
    "bb_link_team3":
      me.getComponent().joinGame(3)
    "bb_link_team4":
      me.getComponent().joinGame(4)
    "bb_kick1_1", "bb_kick1_2", "bb_kick1_3", "bb_kick1_4", "bb_kick1_5", "bb_kick1_6", "bb_kick2_1", "bb_kick2_2", "bb_kick2_3", "bb_kick2_4", "bb_kick2_5", "bb_kick2_6", "bb_kick3_1", "bb_kick3_2", "bb_kick3_3", "bb_kick3_4", "bb_kick4_1", "bb_kick4_2", "bb_kick4_3":
      tTeamNum = integer(string(tSprID).char[8])
      tPlayerNum = integer(string(tSprID).char[10])
      tdata = tGameSystemObj.getObservedInstance()
      if (tTeamNum < 1) or (tTeamNum > tdata[#teams].count) then
        return 0
      end if
      tTeam = tdata[#teams][tTeamNum][#players]
      if (tPlayerNum < 1) or (tPlayerNum > tTeam.count) then
        return 0
      end if
      return tGameSystemObj.kickPlayer(tTeam[tPlayerNum][#id])
    "bb_link_gameRul":
      openNetPage(getText("bb_link_gameRules_url"))
    "bb_link_highScr":
      if tGameSystemObj.getTournamentFlag() then
        openNetPage(getText("bb_link_tournament_highScores_url"))
      else
        openNetPage(getText("bb_link_highScores_url"))
      end if
    "bb_logo_tournament":
      if pTournamentLogoClickURL <> VOID then
        openNetPage(pTournamentLogoClickURL)
      end if
  end case
  return 1
end

on eventProcTicketBox me, tEvent, tSprID, tParam
  return executeMessage(#show_ticketWindow)
end

on changeInstanceListPage me, tOffset
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #changeInstanceListPage)
  end if
  tList = tGameSystemObj.getInstanceList()
  if not listp(tList) then
    return 0
  end if
  tNumPages = integer((tList.count - 1) / pGamesPerPage) + 1
  if tOffset = 1 then
    if pGameListPage >= tNumPages then
      return 0
    else
      pGameListPage = pGameListPage + 1
    end if
  else
    if tOffset = -1 then
      if pGameListPage <= 1 then
        return 0
      else
        pGameListPage = pGameListPage - 1
      end if
    end if
  end if
  return me.showInstanceList()
end

on setGameCreationDefaults me
  if not listp(pGameParameters) then
    return 0
  end if
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to pGameParameters.count
    tKey = pGameParameters.getPropAt(i)
    tValue = pGameParameters[i]
    tActive = pEditableParameters.getPos(tKey) > 0
    case tKey of
      #new:
        nothing()
      "name":
        tWndObj.getElement("bb_field_gameNaming").setText(tValue)
      "numTeams":
        me.setNumberOfTeams(tValue)
      "fieldType":
        me.setFieldType(tValue)
      "allowedPowerups":
        tList = value("[" & tValue & "]")
        if not listp(tList) then
          return error(me, "Cannot parse default powerup list")
        end if
        tPos = 1
        repeat with tTypeCount in tList
          if tList.getPos(tTypeCount) > 0 then
            setPowerupButtonState(me, tPos, tTypeCount, 0, tActive)
          else
            setPowerupButtonState(me, tPos, tTypeCount, -1, tActive)
          end if
          tPos = tPos + 1
        end repeat
    end case
  end repeat
end

on setNumberOfTeams me, tNum
  tOldElem = "bb_radio_teams" & pGameParameters["numTeams"] & "x"
  tNewElem = "bb_radio_teams" & tNum & "x"
  pGameParameters["numTeams"] = tNum
  tWndObj = getWindow(pMainWindowId)
  pRenderObj.updateRadioButton(EMPTY, [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
end

on setFieldType me, tValue
  if (integer(tValue) = 5) or (pGameParameters["fieldType"] = 5) then
    tUpdateButtons = 1
  end if
  pGameParameters["fieldType"] = integer(tValue)
  tWndObj = getWindow(pMainWindowId)
  tDropDown = tWndObj.getElement("gs_dropmenu_gamefield")
  if not ilk(tDropDown, #instance) then
    return error(me, "Unable to retrieve dropdown:" && tDropDown, #setFieldType)
  end if
  tFieldTxtItems = []
  tFieldKeyItems = []
  repeat with i = 1 to 5
    tFieldTxtItems[i] = getText("bb_fieldname_" & i)
    tFieldKeyItems[i] = string(i)
  end repeat
  tDropDown.updateData(tFieldTxtItems, tFieldKeyItems, VOID, tValue)
  if tUpdateButtons then
    tWndObj = getWindow(pMainWindowId)
    if tWndObj = 0 then
      return 0
    end if
    tVisible = not (pGameParameters["fieldType"] = 5)
    repeat with tNum = 1 to 8
      tElement = tWndObj.getElement("bb2_slot_pwrup_" & tNum)
      if tElement <> 0 then
        tElement.setProperty(#visible, tVisible)
      end if
    end repeat
  end if
  return 1
end

on togglePowerup me, tNum
  if pEditableParameters.getPos("allowedPowerups") = 0 then
    return 1
  end if
  tSelected = pGameParameters["allowedPowerups"]
  tSelectedList = value("[" & tSelected & "]")
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #togglePowerup)
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return error(me, "Invalid game parameters.", #togglePowerup)
  end if
  repeat with tItem in tStruct
    if tItem[#name] = "allowedPowerups" then
      tAvailableList = value("[" & tItem[#default] & "]")
      exit repeat
    end if
  end repeat
  if not listp(tAvailableList) then
    return error(me, "Invalid powerup type index", #togglePowerup)
  end if
  if tNum > tAvailableList.count then
    return error(me, "Invalid powerup type for index", #togglePowerup)
  end if
  ttype = tAvailableList[tNum]
  if tAvailableList.getPos(ttype) = 0 then
    return error(me, "Invalid powerup type num", #togglePowerup)
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
  tSelected = tSelected.char[2..tSelected.length - 1]
  tSelected = replaceChars(tSelected, SPACE, EMPTY)
  pGameParameters["allowedPowerups"] = tSelected
  return 1
end

on setPowerupButtonState me, tNum, ttype, tValue, tActive
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("bb2_slot_pwrup_" & tNum)
  if tElement = 0 then
    return error(me, "Cannot locate powerup button element #" & tNum)
  end if
  if tValue > -1 then
    tMemNum = getmemnum("bb2_pwrupbutton_" & ttype & "_" & tValue)
  else
    tMemNum = getmemnum("bb2_pwrupbttn_bg")
  end if
  if (tActive = 0) or (tValue = -1) then
    tElement.setProperty(#cursor, 0)
  else
    tElement.setProperty(#cursor, "cursor.finger")
  end if
  if tMemNum > 0 then
    return tElement.setProperty(#image, member(tMemNum).image)
  end if
  return 0
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
  return tButton
end

on setWatchMode me, tBoolean
  pWatchMode = tBoolean
end

on setSpecialBalloonMargins me
  setVariable("balloons.leftmargin", pBalloonMargins[#special][#left])
  setVariable("balloons.rightmargin", pBalloonMargins[#special][#right])
  return 1
end

on setNormalBalloonMargins me
  setVariable("balloons.leftmargin", pBalloonMargins[#normal][#left])
  setVariable("balloons.rightmargin", pBalloonMargins[#normal][#right])
  return 1
end

on showErrorMessage me, tErrorType, tRequestStr, tExtra
  case tErrorType of
    2:
      return executeMessage(#openOneClickGameBuyWindow)
    "game_deleted":
      tAlertStr = "gs_error_game_deleted"
    "idlewarning":
      tAlertStr = "gs_idlewarning"
    otherwise:
      tAlertStr = "gs_error_" & tRequestStr & "_" & tErrorType
      if not textExists(tAlertStr) then
        tAlertStr = "gs_error_" & tErrorType
      end if
  end case
  case tRequestStr of
    "create":
      me.ChangeWindowView(#gameList)
  end case
  case tErrorType of
    6:
      me.ChangeWindowView(#gameList)
  end case
  return executeMessage(#alert, [#id: "gs_error", #Msg: tAlertStr])
end

on delayedMenuToBack me
  createTimeout(#temp, 3000, #sendMenuToBack, me.getID(), VOID, 1)
end

on sendMenuToBack me
  if not windowExists(pMainWindowId) then
    return 0
  end if
  tWndObj = getWindow(pMainWindowId)
  tWndObj.moveZ(-100000)
  tWndObj.lock()
end
