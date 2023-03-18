property pCryptoParams, pClientSecret

on construct me
  pCryptoParams = [:]
  pMD5ChecksumArr = []
  pSecCastNum = 0
  registerMessage(#hideLogin, me.getID(), #hideLogin)
  return me.regMsgList(1)
end

on deconstruct me
  unregisterMessage(#performLogin, me.getID())
  unregisterMessage(#hideLogin, me.getID())
  return me.regMsgList(0)
end

on handleDisconnect me, tMsg
  tSession = getObject(#session)
  tUserLoggedIn = 0
  if objectp(tSession) then
    tUserLoggedIn = tSession.GET("userLoggedIn")
  end if
  error(me, "Connection was disconnected:" && tMsg.connection.getID(), #handleDisconnect, #dummy)
  if tUserLoggedIn then
    me.getInterface().showDisconnect()
    return fatalError(["error": "disconnect"])
  else
    tErrorList = [:]
    tErrorList["error"] = me.getComponent().GetDisconnectErrorState()
    tConnection = getConnection(getVariable("connection.info.id", #Info))
    if tConnection <> VOID then
      tErrorList["host"] = tConnection.getProperty(#host)
      tErrorList["port"] = tConnection.getProperty(#port)
    end if
    return fatalError(tErrorList)
  end if
end

on handleHello me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  sendProcessTracking(21)
  me.getComponent().SetDisconnectErrorState("init_crypto")
  return tMsg.connection.send("INIT_CRYPTO", [#integer: 0])
end

on handleSessionParameters me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tPairsCount = tMsg.connection.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      repeat with i = 1 to tPairsCount
        tID = tMsg.connection.GetIntFrom()
        tSession = getObject(#session)
        case tID of
          0:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_coppa", tValue > 0)
            tSession.set("conf_strong_coppa_required", tValue > 1)
          1:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_voucher", tValue > 0)
          2:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_parent_email_request", tValue > 0)
          3:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_parent_email_request_reregistration", tValue > 0)
          4:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_allow_direct_mail", tValue > 0)
          5:
            tValue = tMsg.connection.GetStrFrom()
            if not objectExists(#dateFormatter) then
              createObject(#dateFormatter, ["Date Class"])
            end if
            tDateForm = getObject(#dateFormatter)
            if not (tDateForm = 0) then
              tDateForm.define(tValue)
            end if
          6:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_partner_integration", tValue > 0)
          7:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("allow_profile_editing", tValue > 0)
          8:
            tValue = tMsg.connection.GetStrFrom()
            tSession.set("tracking_header", tValue)
          9:
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("tutorial_enabled", tValue)
        end case
      end repeat
    end if
  end if
  return me.getComponent().sendLogin(tMsg.connection)
end

on handlePing me, tMsg
  tMsg.connection.send("PONG")
end

on handleLoginOK me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  executeMessage(#loadingBarSetExtraTaskDone, #login)
  sendProcessTracking(41)
  tMsg.connection.send("GET_INFO")
  tMsg.connection.send("GET_CREDITS")
  tMsg.connection.send("GETAVAILABLEBADGES")
  tMsg.connection.send("GET_POSSIBLE_ACHIEVEMENTS")
  tMsg.connection.send("GET_SOUND_SETTING")
  me.getComponent().initLatencyTest()
  getCastLoadManager().ResetOneDynamicCast(getMember("SecurityCode").castLibNum)
  if objectExists(#session) then
    getObject(#session).set("userLoggedIn", 1)
  end if
  executeMessage(#userloggedin)
  executeMessage(#sendTrackingPoint, "/client/loggedin")
end

on handleUserObj me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tuser = [:]
  tConn = tMsg.connection
  tuser["user_id"] = tConn.GetStrFrom()
  tuser["name"] = tConn.GetStrFrom()
  tuser["figure"] = tConn.GetStrFrom()
  tuser["sex"] = tConn.GetStrFrom()
  tuser["customData"] = tConn.GetStrFrom()
  tuser["ph_tickets"] = tConn.GetIntFrom()
  tuser["ph_figure"] = tConn.GetStrFrom()
  tuser["photo_film"] = tConn.GetIntFrom()
  tuser["directMail"] = tConn.GetIntFrom()
  tuser["respect_ticket_total"] = tConn.GetIntFrom()
  tuser["respect_ticket_count"] = tConn.GetIntFrom()
  tuser["figure_string"] = tuser["figure"]
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  if not voidp(tuser["sex"]) then
    if (tuser["sex"] contains "F") or (tuser["sex"] contains "f") then
      tuser["sex"] = "F"
    else
      tuser["sex"] = "M"
    end if
  end if
  if objectExists("Figure_System") then
    tuser["figure"] = getObject("Figure_System").parseFigure(tuser["figure"], tuser["sex"], "user", "USEROBJECT")
  end if
  the itemDelimiter = tDelim
  tSession = getObject(#session)
  repeat with i = 1 to tuser.count
    tSession.set("user_" & tuser.getPropAt(i), tuser[i])
  end repeat
  tSession.set(#userName, tSession.GET("user_name"))
  executeMessage(#updateFigureData)
  executeMessage(#respectCountUpdated)
  if getObject(#session).exists("user_logged") then
    return 
  else
    getObject(#session).set("user_logged", 1)
  end if
  me.getInterface().hideLogin()
  executeMessage(#userlogin, "userLogin")
end

on handleUserBanned me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tBanID = tConn.GetIntFrom()
  tBanReason = tConn.GetStrFrom()
  tBanMsg = getText("Alert_YouAreBanned") & RETURN & tBanReason
  executeMessage(#openGeneralDialog, #ban, [#id: "BannWarning", #title: "Alert_YouAreBanned_T", #Msg: tBanMsg, #modal: 1])
  removeConnection(tConn.getID())
end

on handleNoLoginPermission me, tMsg
  return 1
end

on handleSystemBroadcast me, tMsg
  tStr = tMsg.connection.GetStrFrom()
  tStr = replaceChunks(tStr, "\r", RETURN)
  tStr = replaceChunks(tStr, "<br>", RETURN)
  executeMessage(#alert, [#Msg: tStr])
  the keyboardFocusSprite = 0
end

on handleCheckSum me, tMsg
  getObject(#session).set("user_checksum", tMsg.content)
end

on handleAvailableBadges me, tMsg
  if getObject(#session).exists("available_badges") then
    tOldBadgeList = getObject(#session).GET("available_badges")
  else
    tOldBadgeList = []
  end if
  tBadgeList = []
  tBadgeCount = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tBadgeCount
    tBadgeID = tMsg.connection.GetStrFrom()
    tBadgeList.add(tBadgeID)
    if listp(tOldBadgeList) then
      if tOldBadgeList.findPos(tBadgeID) = 0 then
      end if
    end if
  end repeat
  tChosenBadgeCount = tMsg.connection.GetIntFrom()
  tChosenBadges = [:]
  repeat with i = 1 to tChosenBadgeCount
    tBadgeIndex = tMsg.connection.GetIntFrom()
    tBadgeID = tMsg.connection.GetStrFrom()
    tChosenBadges.setaProp(tBadgeIndex, tBadgeID)
  end repeat
  getObject("session").set("available_badges", tBadgeList)
  getObject("session").set("chosen_badges", tChosenBadges)
end

on handleRights me, tMsg
  tSession = getObject(#session)
  tSession.set("user_rights", [])
  tRights = tSession.GET("user_rights")
  tPrivilegeFound = 1
  repeat while tPrivilegeFound = 1
    tPrivilege = tMsg.connection.GetStrFrom()
    if (tPrivilege = VOID) or (tPrivilege = EMPTY) then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return 1
end

on handleError me, tMsg
  tConn = tMsg.connection
  tErrorCode = tConn.GetIntFrom()
  case tErrorCode of
    (-3):
      removeConnection(tMsg.connection.getID())
      me.getComponent().setaProp(#pOkToLogin, 0)
      if getObject(#session).exists("failed_password") then
        openNetPage(getText("login_forgottenPassword_url"))
        me.getInterface().showLogin()
        executeMessage(#externalLinkClick, point((the stage).image.width / 2, (the stage).image.height / 2))
        return 0
      else
        getObject(#session).set("failed_password", 1)
        me.getInterface().showLogin()
        executeMessage(#alert, [#Msg: "Alert_WrongNameOrPassword"])
      end if
    (-400):
      executeMessage(#alert, [#Msg: "alert_old_client"])
  end case
  return 1
end

on handleModAlert me, tMsg
  tTest = tMsg.getaProp(#content)
  tConn = tMsg.connection
  if not tConn then
    error(me, "Error in moderation alert.", #handleModerationAlert, #minor)
    return 0
  end if
  tMessageText = tConn.GetStrFrom()
  tURL = tConn.GetStrFrom()
  if tURL = EMPTY then
    tURL = VOID
  end if
  executeMessage(#alert, [#title: "alert_warning", #Msg: tMessageText, #modal: 1, #url: tURL])
end

on handleCryptoParameters me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  sendProcessTracking(22)
  tSecurityCastToken = tMsg.connection.GetStrFrom()
  tConnection = getConnection(getVariable("connection.info.id"))
  tConnection.SetToken(tSecurityCastToken)
  tClientToServer = 1
  tServerToClient = tMsg.connection.GetIntFrom() <> 0
  pCryptoParams = [#ClientToServer: tClientToServer, #ServerToClient: tServerToClient]
  if not variableExists("security.cast.load.url") then
    return 0
  end if
  tSecUrl = replaceChunks(getVariable("security.cast.load.url"), "%token%", tSecurityCastToken)
  tLoadID = startCastLoad([tSecUrl], 1, VOID, VOID, 1)
  registerCastloadCallback(tLoadID, #securityCastDownloadCallback, me.getID(), tSecUrl)
  return 1
end

on responseWithPublicKey me, tConnection
  startProfilingTask("Login Handler Diffie-Hellman Handshake")
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("HugeInt15").castLibNum <> tCastLibNum then
    return 0
  end if
  if castLib(tCastLibNum).member["HugeInt15"].script <> script("HugeInt15") then
    return 0
  end if
  tHex = EMPTY
  tLength = 24
  tHexChars = "012345679"
  repeat with tNo = 1 to tLength * 2
    tRandPos = random(tHexChars.length)
    if (tRandPos = 1) and (tNo = 1) then
      tRandPos = 1 + random(tHexChars.length - 1)
    end if
    tHex = tHex & chars(tHexChars, tRandPos, tRandPos)
  end repeat
  clientG = new script("HugeInt15")
  clientP = new script("HugeInt15")
  tSecurityCastObj = new script("SecurityCode", castLib(getMember("SecurityCode").castLibNum).name)
  clientG.assign(tSecurityCastObj.getLoginParameter("testing", #g), VOID, 1)
  clientP.assign(tSecurityCastObj.getLoginParameter("testing", #p), VOID, 1)
  pClientSecret = new script("HugeInt15")
  pClientSecret.assign(tHex)
  tPublicKeyStr = clientG.powMod(pClientSecret, clientP).getString()
  if not (the platform contains "windows") and (tPublicKeyStr.length < 2) then
    return me.forwardToRosettaDisablePage()
  end if
  executeMessage(#loadingBarSetExtraTaskDone, #handshake1)
  tConnection = getConnection(getVariable("connection.info.id"))
  tConnection.send("GENERATEKEY", [#string: tPublicKeyStr])
end

on handleServerSecretKey me, tMsg
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("HugeInt15").castLibNum <> tCastLibNum then
    return 0
  end if
  if castLib(tCastLibNum).member["HugeInt15"].script <> script("HugeInt15") then
    return 0
  end if
  clientP = new script("HugeInt15")
  tSecurityCastObj = new script("SecurityCode", castLib(getMember("SecurityCode").castLibNum).name)
  clientP.assign(tSecurityCastObj.getLoginParameter("testing", #p), VOID, 1)
  t_sServerPublicKey = tMsg.content
  if t_sServerPublicKey.length < 64 then
    return 0
  end if
  tClientBig = new script("HugeInt15")
  tClientBig.assign(t_sServerPublicKey)
  tSharedKey = tClientBig.powMod(pClientSecret, clientP)
  tByteArray = tSharedKey.getByteArray()
  tCryptoClass = "Cryptography Class"
  tCastLibNum = 2
  if member(tCryptoClass).castLibNum <> tCastLibNum then
    return 0
  end if
  if castLib(tCastLibNum).member[tCryptoClass].script <> script(tCryptoClass) then
    return 0
  end if
  t_rDecoder = createObject(#temp, [tCryptoClass])
  t_rDecoder.WvUrP88jJ4snglkrhCh3u9vHu0ADDS(tByteArray, #initByteArray)
  t_rEncoder = createObject(#temp, [tCryptoClass])
  t_rEncoder.WvUrP88jJ4snglkrhCh3u9vHu0ADDS(tByteArray, #initByteArray)
  t_rHeaderDecoder = createObject(#temp, [tCryptoClass])
  t_rHeaderDecoder.WvUrP88jJ4snglkrhCh3u9vHu0ADDS(tByteArray, #initByteArray)
  t_rHeaderEncoder = createObject(#temp, [tCryptoClass])
  t_rHeaderEncoder.WvUrP88jJ4snglkrhCh3u9vHu0ADDS(tByteArray, #initByteArray)
  tConnection = getConnection(getVariable("connection.info.id"))
  tConnection.setDecoder(t_rDecoder)
  tConnection.setEncoder(t_rEncoder)
  tConnection.setHeaderDecoder(t_rHeaderDecoder)
  tConnection.setHeaderEncoder(t_rHeaderEncoder)
  tConnection.setEncryption(pCryptoParams.getaProp(#ClientToServer))
  if pCryptoParams.getaProp(#ServerToClient) = 1 then
    tConnection.setProperty(#deciphering, 1)
  end if
  sendProcessTracking(28)
  executeMessage(#loadingBarSetExtraTaskDone, #handshake2)
  me.startNewSession()
  finishProfilingTask("Login Handler Diffie-Hellman Handshake")
  return 1
end

on handleHotelLogout me, tMsg
  tLogoutMsgId = tMsg.connection.GetIntFrom()
  case tLogoutMsgId of
    (-1):
      me.getComponent().disconnect()
      me.getInterface().showDisconnect()
    0:
      openNetPage(getText("url_logged_out"), "self")
    1:
      openNetPage(getText("url_logged_out"), "self")
    2:
      openNetPage(getText("url_logout_concurrent"), "self")
    3:
      openNetPage(getText("url_logout_timeout"), "self")
    4:
      openNetPage(getText("url_logout_timeout"), "self")
    otherwise:
      openNetPage(getText("url_logout_timeout"), "self")
  end case
end

on handleSoundSetting me, tMsg
  tstate = tMsg.connection.GetIntFrom()
  setSoundState(tstate)
  executeMessage(#soundSettingChanged, tstate)
end

on handlePossibleAchievements me, tMsg
  tConn = tMsg.getaProp(#connection)
  tAchievements = [:]
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tTypeID = tConn.GetIntFrom()
    tLevel = tConn.GetIntFrom()
    tBadgeID = tConn.GetStrFrom()
    tAchievements.setaProp(tBadgeID, [#type: tTypeID, #level: tLevel, #badge: tBadgeID])
  end repeat
  if not objectExists(#session) then
    return error(me, "Session object not found.", #handlePossibleUserAchievements, #major)
  end if
  getObject(#session).set("possible_achievements", tAchievements)
  executeMessage(#achievementsUpdated)
end

on handleAchievementNotification me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  ttype = tConn.GetIntFrom()
  tLevel = tConn.GetIntFrom()
  tBadgeID = tConn.GetStrFrom()
  tRemovedBadgeID = tConn.GetStrFrom()
  if not objectExists(#session) then
    return error(me, "Session object not found.", #handleAchievementNotification, #major)
  end if
  tSession = getObject(#session)
  tConn.send("GET_POSSIBLE_ACHIEVEMENTS")
  tBadges = tSession.GET("available_badges")
  if listp(tBadges) then
    tBadges.add(tBadgeID)
    executeMessage(#badgeReceived, tBadgeID)
    tPos = tBadges.getPos(tRemovedBadgeID)
    if tPos > 0 then
      tBadges.deleteAt(tPos)
      executeMessage(#badgeRemoved, tRemovedBadgeID)
    end if
  end if
  me.getComponent().sendGetBadges()
end

on startNewSession me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  me.getComponent().SetDisconnectErrorState("start_session")
  tClientURL = getMoviePath()
  tExtVarsURL = getExtVarPath()
  tConnection = getConnection(getVariable("connection.info.id"))
  tHost = tConnection.getProperty(#host)
  if tHost contains deobfuscate(",y,?mf,BmylPl^nGoH") then
    tClientURL = EMPTY
  end if
  if tHost contains deobfuscate("FbgeGnd=&Ae]F@E}") then
    tClientURL = EMPTY
  end if
  if tHost contains deobfuscate("&bF2fee|&CFmGqd}") then
    tClientURL = EMPTY
  end if
  if tHost contains deobfuscate("G#f@d\fae<fa$]") then
    tClientURL = EMPTY
  end if
  if not (the runMode contains "Plugin") then
    tClientURL = EMPTY
    tExtVarsURL = EMPTY
  else
    if getMoviePath() <> the moviePath then
      tClientURL = "3"
    end if
  end if
  tConnection.send("VERSIONCHECK", [#integer: getIntVariable("client.version.id"), #string: tClientURL, #string: tExtVarsURL])
  tConnection.send("UNIQUEID", [#string: getMachineID()])
  tConnection.send("GET_SESSION_PARAMETERS")
end

on hideLogin me
  me.getInterface().hideLogin()
end

on handleLatencyTest me, tMsg
  tID = tMsg.connection.GetIntFrom()
  me.getComponent().handleLatencyTest(tID)
end

on handleMachineId me, tMsg
  getSpecialServices().setMachineId(tMsg.connection.GetStrFrom())
end

on forwardToRosettaDisablePage me
  openNetPage(getVariable("rosetta.warning.page.url"), "self")
end

on securityCastDownloadCallback me, tURL, tSuccess
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  if tSuccess then
    sendProcessTracking(27)
    me.responseWithPublicKey()
  else
    fatalError(["error": "security_cct"])
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(-1, #handleDisconnect)
  tMsgs.setaProp(0, #handleHello)
  tMsgs.setaProp(1, #handleServerSecretKey)
  tMsgs.setaProp(2, #handleRights)
  tMsgs.setaProp(3, #handleLoginOK)
  tMsgs.setaProp(5, #handleUserObj)
  tMsgs.setaProp(20, #handleNoLoginPermission)
  tMsgs.setaProp(33, #handleError)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(50, #handlePing)
  tMsgs.setaProp(139, #handleSystemBroadcast)
  tMsgs.setaProp(141, #handleCheckSum)
  tMsgs.setaProp(161, #handleModAlert)
  tMsgs.setaProp(229, #handleAvailableBadges)
  tMsgs.setaProp(257, #handleSessionParameters)
  tMsgs.setaProp(277, #handleCryptoParameters)
  tMsgs.setaProp(287, #handleHotelLogout)
  tMsgs.setaProp(308, #handleSoundSetting)
  tMsgs.setaProp(436, #handlePossibleAchievements)
  tMsgs.setaProp(437, #handleAchievementNotification)
  tMsgs.setaProp(439, #handleMachineId)
  tMsgs.setaProp(354, #handleLatencyTest)
  tCmds = [:]
  tCmds.setaProp("TRY_LOGIN", 756)
  tCmds.setaProp("VERSIONCHECK", 1170)
  tCmds.setaProp("UNIQUEID", 813)
  tCmds.setaProp("GET_INFO", 7)
  tCmds.setaProp("GET_CREDITS", 8)
  tCmds.setaProp("GET_PASSWORD", 47)
  tCmds.setaProp("LANGCHECK", 58)
  tCmds.setaProp("BTCKS", 105)
  tCmds.setaProp("GETAVAILABLEBADGES", 157)
  tCmds.setaProp("GETSELECTEDBADGES", 159)
  tCmds.setaProp("GET_SESSION_PARAMETERS", 1817)
  tCmds.setaProp("PONG", 196)
  tCmds.setaProp("GENERATEKEY", 2002)
  tCmds.setaProp("SSO", 204)
  tCmds.setaProp("INIT_CRYPTO", 206)
  tCmds.setaProp("GET_SOUND_SETTING", 228)
  tCmds.setaProp("SET_SOUND_SETTING", 229)
  tCmds.setaProp("GET_POSSIBLE_ACHIEVEMENTS", 370)
  tCmds.setaProp("TEST_LATENCY", 315)
  tCmds.setaProp("REPORT_LATENCY", 316)
  tConn = getVariable("connection.info.id", #Info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return 1
end

on handlers me
  return []
end
