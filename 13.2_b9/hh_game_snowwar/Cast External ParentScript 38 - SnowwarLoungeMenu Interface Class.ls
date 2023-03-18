property pWindowState, pMainWindowId, pBalloonMargins, pWatchMode, pTournamentLogoMemNum, pTournamentLogoClickURL, pGameListPage, pGamesPerPage, pGameParameters, pRenderObj

on construct me
  pBalloonMargins = [#normal: [:], #special: [:]]
  pBalloonMargins[#normal][#left] = getIntVariable("balloons.leftmargin")
  pBalloonMargins[#normal][#right] = getIntVariable("balloons.rightmargin")
  pBalloonMargins[#special][#left] = 215
  pBalloonMargins[#special][#right] = pBalloonMargins[#normal][#right]
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
  return 1
end

on deconstruct me
  if objectp(pRenderObj) then
    pRenderObj.deconstruct()
  end if
  pRenderObj = VOID
  removeWindow(pMainWindowId)
  me.setNormalBalloonMargins()
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
  tElem = tWndObj.getElement("gs_numtickets")
  if tElem = 0 then
    return 0
  end if
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #setNumTickets)
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

on showInstance me
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #showInstance)
  end if
  tParams = tGameSystemObj.getObservedInstance()
  case tParams[#numTeams] of
    2:
      me.ChangeWindowView(#gameDetails2t)
    3:
      me.ChangeWindowView(#gameDetails3t)
    4:
      me.ChangeWindowView(#gameDetails4t)
    otherwise:
      me.ChangeWindowView(#gameDetails1t)
  end case
  tStateStr = getText("gs_state_" & tParams[#state])
  if tParams[#state] = #created then
    tSpecStr = replaceChunks(getText("gs_specnum"), "\x", tParams[#numSpectators])
  else
    tSpecStr = EMPTY
  end if
  pRenderObj.renderInstanceDetailTop(tParams[#name], tParams[#host][#name], tParams[#state], tStateStr, tSpecStr)
  tButtonState = me.getInstanceDetailButtonState(tParams[#state])
  pRenderObj.renderInstanceDetailButton(tButtonState, tParams[#state])
  tHost = me.getComponent().isUserHost()
  tOwnTeam = me.getComponent().getUserTeamIndex()
  pRenderObj.renderInstanceDetailTeams(tParams, me.getComponent().getUserName(), tHost, tOwnTeam)
  return 1
end

on showGameCreation me
  me.ChangeWindowView(#createGame)
  tWndObj = getWindow(pMainWindowId)
  me.setGameCreationDefaults()
  tElem = tWndObj.getElement("gs_field_gameNaming")
  if tElem = 0 then
    return 0
  end if
  updateStage()
  me.setFieldType(1)
  return tElem.setFocus(1)
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
      if not tWndObj.merge("sw_glist.window") then
        return 0
      end if
      me.showInstanceList()
      pRenderObj.renderTournamentLogo(pTournamentLogoMemNum)
    #gameDetails2t:
      if not tWndObj.merge("sw_ginfo2t.window") then
        return 0
      end if
    #gameDetails3t:
      if not tWndObj.merge("sw_ginfo3t.window") then
        return 0
      end if
    #gameDetails4t:
      if not tWndObj.merge("sw_ginfo4t.window") then
        return 0
      end if
    #gameDetails1t:
      if not tWndObj.merge("sw_ginfo1t.window") then
        return 0
      end if
    #createGame:
      if not tWndObj.merge("sw_gcreate.window") then
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
    "gs_area_gameList1":
      tIndexOnPage = 1 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_area_gameList2":
      tIndexOnPage = 2 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_area_gameList3":
      tIndexOnPage = 3 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_area_gameList4":
      tIndexOnPage = 4 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_area_gameList5":
      tIndexOnPage = 5 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_area_gameList6":
      tIndexOnPage = 6 + ((pGameListPage - 1) * pGamesPerPage)
      return me.getComponent().observeInstance(tIndexOnPage)
    "gs_arrow_pageFwd":
      return me.changeInstanceListPage(1)
    "gs_arrow_pageBack":
      return me.changeInstanceListPage(-1)
    "gs_button_create":
      return tGameSystemObj.initiateCreateGame()
    "gs_radio_gamelength_1":
      return me.setGameLength(1)
    "gs_radio_gamelength_2":
      return me.setGameLength(2)
    "gs_radio_gamelength_3":
      return me.setGameLength(3)
    "gs_radio_2teams":
      return me.setNumberOfTeams(2)
    "gs_radio_3teams":
      return me.setNumberOfTeams(3)
    "gs_radio_4teams":
      return me.setNumberOfTeams(4)
    "gs_radio_1teams":
      return me.setNumberOfTeams(1)
    "gs_dropmenu_gamefield":
      return me.setFieldType(tParam)
    "gs_button_rdy":
      tWndObj = getWindow(pMainWindowId)
      if tWndObj = 0 then
        return 0
      end if
      if tWndObj.getElement("gs_field_gameNaming").getText() = EMPTY then
        return me.showErrorMessage("game_checkname")
      end if
      tText = tWndObj.getElement("gs_field_gameNaming").getText()
      pGameParameters["name"] = convertSpecialChars(tText, 1)
      me.hideMainWindow()
      return tGameSystemObj.createGame(pGameParameters, 1)
    "gs_button_cncl":
      tWndObj = getWindow(pMainWindowId)
      if tWndObj = 0 then
        return 0
      end if
      me.ChangeWindowView(#gameList)
      return tGameSystemObj.cancelCreateGame()
    "gs_button_leaveGame":
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
    "gs_link_gameInfo":
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
    "gs_link_team1":
      me.getComponent().joinGame(1)
    "gs_link_team2":
      me.getComponent().joinGame(2)
    "gs_link_team3":
      me.getComponent().joinGame(3)
    "gs_link_team4":
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
    "gs_link_gameRul":
      openNetPage(getText("sw_link_gameRules_url"))
    "gs_link_highScr":
      if tGameSystemObj.getTournamentFlag() then
        openNetPage(getText("sw_link_tournament_highScores_url"))
      else
        openNetPage(getText("sw_link_highScores_url"))
      end if
    "gs_logo_tournament":
      if pTournamentLogoClickURL <> VOID then
        openNetPage(pTournamentLogoClickURL)
      end if
    "gs_button_buytickets":
      return executeMessage(#show_ticketWindow)
  end case
  return 1
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
  pGameParameters = [#new: 1]
  tGameSystemObj = me.getComponent().getGameSystem()
  if tGameSystemObj = 0 then
    return error(me, "Gamesystem not found.", #setGameCreationDefaults)
  end if
  tStruct = tGameSystemObj.getGameParameters()
  if not listp(tStruct) then
    return error(me, "Invalid game parameters.", #setGameCreationDefaults)
  end if
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return 0
  end if
  repeat with tItem in tStruct
    pGameParameters.addProp(tItem[#name], tItem[#default])
    case tItem[#name] of
      "name":
        tWndObj.getElement("gs_field_gameNaming").setText(tItem[#default])
      "numTeams":
        me.setNumberOfTeams(tItem[#default])
      "gameLengthChoice":
        me.setGameLength(tItem[#default])
      "fieldType":
        me.setFieldType(tItem[#default])
    end case
  end repeat
end

on setNumberOfTeams me, tValue
  tOldElem = "gs_radio_" & pGameParameters["numTeams"] & "teams"
  tNewElem = "gs_radio_" & tValue & "teams"
  pGameParameters["numTeams"] = tValue
  pRenderObj.updateRadioButton(EMPTY, [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
  return 1
end

on setGameLength me, tValue
  tOldElem = "gs_radio_gamelength_" & pGameParameters["gameLengthChoice"]
  tNewElem = "gs_radio_gamelength_" & tValue
  pGameParameters["gameLengthChoice"] = tValue
  pRenderObj.updateRadioButton(EMPTY, [tOldElem])
  pRenderObj.updateRadioButton(tNewElem, [])
  return 1
end

on setFieldType me, tValue
  pGameParameters["fieldType"] = integer(tValue)
  tWndObj = getWindow(pMainWindowId)
  tDropDown = tWndObj.getElement("gs_dropmenu_gamefield")
  if not ilk(tDropDown, #instance) then
    return error(me, "Unable to retrieve dropdown:" && tDropDown, #setFieldType)
  end if
  tFieldTxtItems = []
  tFieldKeyItems = []
  repeat with i = 1 to 5
    tFieldTxtItems[i] = getText("sw_fieldname_" & i)
    tFieldKeyItems[i] = string(i)
  end repeat
  tDropDown.updateData(tFieldTxtItems, tFieldKeyItems, VOID, tValue)
  return 1
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
      executeMessage(#openOneClickGameBuyWindow)
      return 1
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
