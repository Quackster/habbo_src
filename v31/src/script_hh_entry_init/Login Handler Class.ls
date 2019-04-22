property pClientSecret, pCryptoParams

on construct me 
  pCryptoParams = [:]
  pMD5ChecksumArr = []
  pSecCastNum = 0
  registerMessage(#hideLogin, me.getID(), #hideLogin)
  return(me.regMsgList(1))
end

on deconstruct me 
  unregisterMessage(#performLogin, me.getID())
  unregisterMessage(#hideLogin, me.getID())
  return(me.regMsgList(0))
end

on handleDisconnect me, tMsg 
  tSession = getObject(#session)
  tUserLoggedIn = 0
  if objectp(tSession) then
    tUserLoggedIn = tSession.GET("userLoggedIn")
  end if
  error(me, "Connection was disconnected:" && tMsg.getID(), #handleDisconnect, #dummy)
  if tUserLoggedIn then
    me.getInterface().showDisconnect()
    return(fatalError(["error":"disconnect"]))
  else
    tErrorList = [:]
    tErrorList.setAt("error", me.getComponent().GetDisconnectErrorState())
    tConnection = getConnection(getVariable("connection.info.id", #info))
    if tConnection <> void() then
      tErrorList.setAt("host", tConnection.getProperty(#host))
      tErrorList.setAt("port", tConnection.getProperty(#port))
    end if
    return(fatalError(tErrorList))
  end if
end

on handleHello me, tMsg 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  sendProcessTracking(21)
  me.getComponent().SetDisconnectErrorState("init_crypto")
  return(tMsg.send("INIT_CRYPTO", [#integer:0]))
end

on handleSessionParameters me, tMsg 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tPairsCount = tMsg.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      i = 1
      repeat while i <= tPairsCount
        tID = tMsg.GetIntFrom()
        tSession = getObject(#session)
        if tID = 0 then
          tValue = tMsg.GetIntFrom()
          tSession.set("conf_coppa", tValue > 0)
          tSession.set("conf_strong_coppa_required", tValue > 1)
        else
          if tID = 1 then
            tValue = tMsg.GetIntFrom()
            tSession.set("conf_voucher", tValue > 0)
          else
            if tID = 2 then
              tValue = tMsg.GetIntFrom()
              tSession.set("conf_parent_email_request", tValue > 0)
            else
              if tID = 3 then
                tValue = tMsg.GetIntFrom()
                tSession.set("conf_parent_email_request_reregistration", tValue > 0)
              else
                if tID = 4 then
                  tValue = tMsg.GetIntFrom()
                  tSession.set("conf_allow_direct_mail", tValue > 0)
                else
                  if tID = 5 then
                    tValue = tMsg.GetStrFrom()
                    if not objectExists(#dateFormatter) then
                      createObject(#dateFormatter, ["Date Class"])
                    end if
                    tDateForm = getObject(#dateFormatter)
                    if not tDateForm = 0 then
                      tDateForm.define(tValue)
                    end if
                  else
                    if tID = 6 then
                      tValue = tMsg.GetIntFrom()
                      tSession.set("conf_partner_integration", tValue > 0)
                    else
                      if tID = 7 then
                        tValue = tMsg.GetIntFrom()
                        tSession.set("allow_profile_editing", tValue > 0)
                      else
                        if tID = 8 then
                          tValue = tMsg.GetStrFrom()
                          tSession.set("tracking_header", tValue)
                        else
                          if tID = 9 then
                            tValue = tMsg.GetIntFrom()
                            tSession.set("tutorial_enabled", tValue)
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
        i = 1 + i
      end repeat
    end if
  end if
  return(me.getComponent().sendLogin(tMsg.connection))
end

on handlePing me, tMsg 
  tMsg.send("PONG")
end

on handleLoginOK me, tMsg 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  executeMessage(#loadingBarSetExtraTaskDone, #login)
  sendProcessTracking(41)
  tMsg.send("GET_INFO")
  tMsg.send("GET_CREDITS")
  tMsg.send("GETAVAILABLEBADGES")
  tMsg.send("GET_POSSIBLE_ACHIEVEMENTS")
  tMsg.send("GET_SOUND_SETTING")
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
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tuser = [:]
  tConn = tMsg.connection
  tuser.setAt("user_id", tConn.GetStrFrom())
  tuser.setAt("name", tConn.GetStrFrom())
  tuser.setAt("figure", tConn.GetStrFrom())
  tuser.setAt("sex", tConn.GetStrFrom())
  tuser.setAt("customData", tConn.GetStrFrom())
  tuser.setAt("ph_tickets", tConn.GetIntFrom())
  tuser.setAt("ph_figure", tConn.GetStrFrom())
  tuser.setAt("photo_film", tConn.GetIntFrom())
  tuser.setAt("directMail", tConn.GetIntFrom())
  tuser.setAt("respect_ticket_total", tConn.GetIntFrom())
  tuser.setAt("respect_ticket_count", tConn.GetIntFrom())
  tuser.setAt("figure_string", tuser.getAt("figure"))
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  if not voidp(tuser.getAt("sex")) then
    if tuser.getAt("sex") contains "F" or tuser.getAt("sex") contains "f" then
      tuser.setAt("sex", "F")
    else
      tuser.setAt("sex", "M")
    end if
  end if
  if objectExists("Figure_System") then
    tuser.setAt("figure", getObject("Figure_System").parseFigure(tuser.getAt("figure"), tuser.getAt("sex"), "user", "USEROBJECT"))
  end if
  the itemDelimiter = tDelim
  tSession = getObject(#session)
  i = 1
  repeat while i <= tuser.count
    tSession.set("user_" & tuser.getPropAt(i), tuser.getAt(i))
    i = 1 + i
  end repeat
  tSession.set(#userName, tSession.GET("user_name"))
  executeMessage(#updateFigureData)
  executeMessage(#respectCountUpdated)
  if getObject(#session).exists("user_logged") then
    return()
  else
    getObject(#session).set("user_logged", 1)
  end if
  me.getInterface().hideLogin()
  executeMessage(#userlogin, "userLogin")
end

on handleUserBanned me, tMsg 
  tBanMsg = getText("Alert_YouAreBanned") & "\r" & tMsg.content
  executeMessage(#openGeneralDialog, #ban, [#id:"BannWarning", #title:"Alert_YouAreBanned_T", #Msg:tBanMsg, #modal:1])
  removeConnection(tMsg.getID())
end

on handleEPSnotify me, tMsg 
  ttype = ""
  tdata = ""
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  f = 1
  repeat while f <= tMsg.count(#line)
    tProp = tMsg.getPropRef(#line, f).getProp(#item, 1)
    tDesc = tMsg.getPropRef(#line, f).getProp(#item, 2)
    if tProp = "t" then
      ttype = integer(tDesc)
    else
      if tProp = "p" then
        tdata = tDesc
      end if
    end if
    f = 1 + f
  end repeat
  the itemDelimiter = tDelim
  if tProp = 580 then
    if not createObject("lang_test", "CLangTest") then
      return(error(me, "Failed to init lang tester!", #handleEPSnotify, #minor))
    else
      return(getObject("lang_test").setWord(tdata))
    end if
  end if
  executeMessage(#notify, ttype, tdata, tMsg.getID())
end

on handleSystemBroadcast me, tMsg 
  tStr = tMsg.GetStrFrom()
  tStr = replaceChunks(tStr, "\\r", "\r")
  tStr = replaceChunks(tStr, "<br>", "\r")
  executeMessage(#alert, [#Msg:tStr])
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
  tBadgeCount = tMsg.GetIntFrom()
  i = 1
  repeat while i <= tBadgeCount
    tBadgeID = tMsg.GetStrFrom()
    tBadgeList.add(tBadgeID)
    if listp(tOldBadgeList) then
      if tOldBadgeList.findPos(tBadgeID) = 0 then
      end if
    end if
    i = 1 + i
  end repeat
  tChosenBadgeCount = tMsg.GetIntFrom()
  tChosenBadges = [:]
  i = 1
  repeat while i <= tChosenBadgeCount
    tBadgeIndex = tMsg.GetIntFrom()
    tBadgeID = tMsg.GetStrFrom()
    tChosenBadges.setaProp(tBadgeIndex, tBadgeID)
    i = 1 + i
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
    tPrivilege = tMsg.GetStrFrom()
    if tPrivilege = void() or tPrivilege = "" then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return(1)
end

on handleError me, tMsg 
  tConn = tMsg.connection
  tErrorCode = tConn.GetIntFrom()
  if tErrorCode = -3 then
    removeConnection(tMsg.getID())
    me.getComponent().setaProp(#pOkToLogin, 0)
    if getObject(#session).exists("failed_password") then
      openNetPage(getText("login_forgottenPassword_url"))
      me.getInterface().showLogin()
      executeMessage(#externalLinkClick, point(undefined.width / 2, undefined.height / 2))
      return(0)
    else
      getObject(#session).set("failed_password", 1)
      me.getInterface().showLogin()
      executeMessage(#alert, [#Msg:"Alert_WrongNameOrPassword"])
    end if
  else
    if tErrorCode = -400 then
      executeMessage(#alert, [#Msg:"alert_old_client"])
    end if
  end if
  return(1)
end

on handleModAlert me, tMsg 
  tTest = tMsg.getaProp(#content)
  tConn = tMsg.connection
  if not tConn then
    error(me, "Error in moderation alert.", #handleModerationAlert, #minor)
    return(0)
  end if
  tMessageText = tConn.GetStrFrom()
  tURL = tConn.GetStrFrom()
  if tURL = "" then
    tURL = void()
  end if
  executeMessage(#alert, [#title:"alert_warning", #Msg:tMessageText, #modal:1, #url:tURL])
end

on handleCryptoParameters me, tMsg 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  sendProcessTracking(22)
  tSecurityCastToken = tMsg.GetStrFrom()
  tConnection = getConnection(getVariable("connection.info.id"))
  tConnection.SetToken(tSecurityCastToken)
  tClientToServer = 1
  tServerToClient = tMsg.GetIntFrom() <> 0
  pCryptoParams = [#ClientToServer:tClientToServer, #ServerToClient:tServerToClient]
  if not variableExists("security.cast.load.url") then
    return(0)
  end if
  tSecUrl = replaceChunks(getVariable("security.cast.load.url"), "%token%", tSecurityCastToken)
  tLoadID = startCastLoad([tSecUrl], 1, void(), void(), 1)
  registerCastloadCallback(tLoadID, #securityCastDownloadCallback, me.getID(), tSecUrl)
  return(1)
end

on responseWithPublicKey me, tConnection 
  startProfilingTask("Login Handler Diffie-Hellman Handshake")
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("HugeInt15").castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, "HugeInt15").script <> script("HugeInt15") then
    return(0)
  end if
  tHex = ""
  tLength = 24
  tHexChars = "012345679"
  tNo = 1
  repeat while tNo <= tLength * 2
    tRandPos = random(tHexChars.length)
    if tRandPos = 1 and tNo = 1 then
      tRandPos = 1 + random(tHexChars.length - 1)
    end if
    tHex = tHex & chars(tHexChars, tRandPos, tRandPos)
    tNo = 1 + tNo
  end repeat
  clientG = ["HugeInt15"]
  clientP = ["HugeInt15"]
  tSecurityCastObj = ["SecurityCode", castLib(getMember("SecurityCode").castLibNum).name]
  clientG.assign(tSecurityCastObj.getLoginParameter("testing", #g), void(), 1)
  clientP.assign(tSecurityCastObj.getLoginParameter("testing", #p), void(), 1)
  pClientSecret = ["HugeInt15"]
  pClientSecret.assign(tHex)
  tPublicKeyStr = clientG.powMod(pClientSecret, clientP).getString()
  if not the platform contains "windows" and tPublicKeyStr.length < 2 then
    return(me.forwardToRosettaDisablePage())
  end if
  executeMessage(#loadingBarSetExtraTaskDone, #handshake1)
  tConnection = getConnection(getVariable("connection.info.id"))
  tConnection.send("GENERATEKEY", [#string:tPublicKeyStr])
end

on handleServerSecretKey me, tMsg 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("HugeInt15").castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, "HugeInt15").script <> script("HugeInt15") then
    return(0)
  end if
  clientP = ["HugeInt15"]
  tSecurityCastObj = ["SecurityCode", castLib(getMember("SecurityCode").castLibNum).name]
  clientP.assign(tSecurityCastObj.getLoginParameter("testing", #p), void(), 1)
  t_sServerPublicKey = tMsg.content
  if t_sServerPublicKey.length < 64 then
    return(0)
  end if
  tClientBig = ["HugeInt15"]
  tClientBig.assign(t_sServerPublicKey)
  tSharedKey = tClientBig.powMod(pClientSecret, clientP)
  tByteArray = tSharedKey.getByteArray()
  tCryptoClass = "Cryptography Class"
  tCastLibNum = 2
  if member(tCryptoClass).castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, tCryptoClass).script <> script(tCryptoClass) then
    return(0)
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
  return(1)
end

on handleHotelLogout me, tMsg 
  tLogoutMsgId = tMsg.GetIntFrom()
  if tLogoutMsgId = -1 then
    me.getComponent().disconnect()
    me.getInterface().showDisconnect()
  else
    if tLogoutMsgId = 1 then
      openNetPage(getText("url_logged_out"), "self")
    else
      if tLogoutMsgId = 2 then
        openNetPage(getText("url_logout_concurrent"), "self")
      else
        if tLogoutMsgId = 3 then
          openNetPage(getText("url_logout_timeout"), "self")
        end if
      end if
    end if
  end if
end

on handleSoundSetting me, tMsg 
  tstate = tMsg.GetIntFrom()
  setSoundState(tstate)
  executeMessage(#soundSettingChanged, tstate)
end

on handlePossibleAchievements me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tAchievements = [:]
  tCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tTypeID = tConn.GetIntFrom()
    tLevel = tConn.GetIntFrom()
    tBadgeID = tConn.GetStrFrom()
    tAchievements.setaProp(tBadgeID, [#type:tTypeID, #level:tLevel, #badge:tBadgeID])
    i = 1 + i
  end repeat
  if not objectExists(#session) then
    return(error(me, "Session object not found.", #handlePossibleUserAchievements, #major))
  end if
  getObject(#session).set("possible_achievements", tAchievements)
  executeMessage(#achievementsUpdated)
end

on handleAchievementNotification me, tMsg 
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return(0)
  end if
  ttype = tConn.GetIntFrom()
  tLevel = tConn.GetIntFrom()
  tBadgeID = tConn.GetStrFrom()
  tRemovedBadgeID = tConn.GetStrFrom()
  if not objectExists(#session) then
    return(error(me, "Session object not found.", #handleAchievementNotification, #major))
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
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  me.getComponent().SetDisconnectErrorState("start_session")
  tClientURL = getMoviePath()
  tExtVarsURL = getExtVarPath()
  tConnection = getConnection(getVariable("connection.info.id"))
  tHost = tConnection.getProperty(#host)
  if tHost contains deobfuscate(",y,?mf,BmylPl^nGoH") then
    tClientURL = ""
  end if
  if tHost contains deobfuscate("FbgeGnd=&Ae]F@E}") then
    tClientURL = ""
  end if
  if tHost contains deobfuscate("&bF2fee|&CFmGqd}") then
    tClientURL = ""
  end if
  if tHost contains deobfuscate("G#f@d\\fae<fa$]") then
    tClientURL = ""
  end if
  if not the runMode contains "Plugin" then
    tClientURL = ""
    tExtVarsURL = ""
  else
    if getMoviePath() <> the moviePath then
      tClientURL = "3"
    end if
  end if
  tConnection.send("VERSIONCHECK", [#integer:getIntVariable("client.version.id"), #string:tClientURL, #string:tExtVarsURL])
  tConnection.send("UNIQUEID", [#string:getMachineID()])
  tConnection.send("GET_SESSION_PARAMETERS")
end

on hideLogin me 
  me.getInterface().hideLogin()
end

on handleLatencyTest me, tMsg 
  tID = tMsg.GetIntFrom()
  me.getComponent().handleLatencyTest(tID)
end

on handleMachineId me, tMsg 
  getSpecialServices().setMachineId(tMsg.GetStrFrom())
end

on forwardToRosettaDisablePage me 
  openNetPage(getVariable("rosetta.warning.page.url"), "self")
end

on securityCastDownloadCallback me, tURL, tSuccess 
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if tSuccess then
    sendProcessTracking(27)
    me.responseWithPublicKey()
  else
    fatalError(["error":"security_cct"])
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
  tMsgs.setaProp(33, #handleError)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(50, #handlePing)
  tMsgs.setaProp(52, #handleEPSnotify)
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
  tConn = getVariable("connection.info.id", #info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return(1)
end

on handlers me 
  return([])
end
