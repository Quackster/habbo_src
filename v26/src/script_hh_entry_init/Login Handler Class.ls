property pBigJob, pCryptoParams

on construct me 
  pCryptoParams = [:]
  pMD5ChecksumArr = []
  pClientPrivKey = ""
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
  error("Connection was disconnected:", tMsg && connection.getID(), #handleDisconnect, #dummy)
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
  me.getComponent().SetDisconnectErrorState("init_crypto")
  return(connection.send("INIT_CRYPTO"))
end

on handleSessionParameters me, tMsg 
  tPairsCount = connection.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      i = 1
      repeat while i <= tPairsCount
        tID = connection.GetIntFrom()
        tSession = getObject(#session)
        if tMsg = 0 then
          tValue = connection.GetIntFrom()
          tSession.set("conf_coppa", tValue > 0)
          tSession.set("conf_strong_coppa_required", tValue > 1)
        else
          if tMsg = 1 then
            tValue = connection.GetIntFrom()
            tSession.set("conf_voucher", tValue > 0)
          else
            if tMsg = 2 then
              tValue = connection.GetIntFrom()
              tSession.set("conf_parent_email_request", tValue > 0)
            else
              if tMsg = 3 then
                tValue = connection.GetIntFrom()
                tSession.set("conf_parent_email_request_reregistration", tValue > 0)
              else
                if tMsg = 4 then
                  tValue = connection.GetIntFrom()
                  tSession.set("conf_allow_direct_mail", tValue > 0)
                else
                  if tMsg = 5 then
                    tValue = connection.GetStrFrom()
                    if not objectExists(#dateFormatter) then
                      createObject(#dateFormatter, ["Date Class"])
                    end if
                    tDateForm = getObject(#dateFormatter)
                    if not tDateForm = 0 then
                      tDateForm.define(tValue)
                    end if
                  else
                    if tMsg = 6 then
                      tValue = connection.GetIntFrom()
                      tSession.set("conf_partner_integration", tValue > 0)
                    else
                      if tMsg = 7 then
                        tValue = connection.GetIntFrom()
                        tSession.set("allow_profile_editing", tValue > 0)
                      else
                        if tMsg = 8 then
                          tValue = connection.GetStrFrom()
                          tSession.set("tracking_header", tValue)
                        else
                          if tMsg = 9 then
                            tValue = connection.GetIntFrom()
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
  connection.send("PONG")
end

on handleLoginOK me, tMsg 
  sendProcessTracking(41)
  connection.send("GET_INFO")
  connection.send("GET_CREDITS")
  connection.send("GETAVAILABLEBADGES")
  connection.send("GET_POSSIBLE_ACHIEVEMENTS")
  connection.send("GET_SOUND_SETTING")
  me.getComponent().initLatencyTest()
  if objectExists(#session) then
    getObject(#session).set("userLoggedIn", 1)
  end if
  executeMessage(#userloggedin)
  executeMessage(#sendTrackingPoint, "/client/loggedin")
end

on handleUserObj me, tMsg 
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
  removeConnection(connection.getID())
end

on handleEPSnotify me, tMsg 
  ttype = ""
  tdata = ""
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  f = 1
  repeat while tMsg <= content.count(#line)
    tProp = content.getPropRef(#line, f).getProp(#item, 1)
    tDesc = content.getPropRef(#line, f).getProp(#item, 2)
    if f = "t" then
      ttype = integer(tDesc)
    else
      if f = "p" then
        tdata = tDesc
      end if
    end if
    f = 1 + f
  end repeat
  the itemDelimiter = tDelim
  if f = 580 then
    if not createObject("lang_test", "CLangTest") then
      return(error(me, "Failed to init lang tester!", #handleEPSnotify, #minor))
    else
      return(getObject("lang_test").setWord(tdata))
    end if
  end if
  executeMessage(ttype, tdata, tMsg, connection.getID())
end

on handleSystemBroadcast me, tMsg 
  tMsg = tMsg.getAt(#content)
  tMsg = replaceChunks(tMsg, "\\r", "\r")
  tMsg = replaceChunks(tMsg, "<br>", "\r")
  executeMessage(#alert, [#Msg:tMsg])
  the keyboardFocusSprite = 0
end

on handleCheckSum me, tMsg 
  getObject(#session).set("user_checksum", tMsg.content)
end

on handleAvailableBadges me, tMsg 
  tBadgeList = []
  tBadgeCount = connection.GetIntFrom()
  i = 1
  repeat while i <= tBadgeCount
    tBadgeID = connection.GetStrFrom()
    tBadgeList.add(tBadgeID)
    i = 1 + i
  end repeat
  tChosenBadgeCount = connection.GetIntFrom()
  tChosenBadges = [:]
  i = 1
  repeat while i <= tChosenBadgeCount
    tBadgeIndex = connection.GetIntFrom()
    tBadgeID = connection.GetStrFrom()
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
    tPrivilege = connection.GetStrFrom()
    if tPrivilege = void() or tPrivilege = "" then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return(1)
end

on handleErr me, tMsg 
  error(me, "Error from server:" && tMsg.content, #handleErr, #dummy)
  if 1 = tMsg.content contains "login incorrect" then
    removeConnection(connection.getID())
    me.getComponent().setaProp(#pOkToLogin, 0)
    if getObject(#session).exists("failed_password") then
      openNetPage(getText("login_forgottenPassword_url"))
      me.getInterface().showLogin()
      executeMessage((image.width / 2), point(the stage, (image.height / 2)))
      return(0)
    else
      getObject(#session).set("failed_password", 1)
      me.getInterface().showLogin()
      executeMessage(#alert, [#Msg:"Alert_WrongNameOrPassword"])
    end if
  else
    if 1 = tMsg.content contains "mod_warn" then
      tDelim = the itemDelimiter
      the itemDelimiter = "/"
      tTextStr = #item.getProp(2, tMsg, content.count(#item))
      the itemDelimiter = tDelim
      executeMessage(#alert, [#title:"alert_warning", #Msg:tTextStr, #modal:1])
    else
      if 1 = tMsg.content contains "Version not correct" then
        executeMessage(#alert, [#Msg:"alert_old_client"])
      else
        if 1 = tMsg.content contains "Duplicate session" then
          removeConnection(connection.getID())
          me.getComponent().setaProp(#pOkToLogin, 0)
          me.getInterface().showLogin()
          executeMessage(#alert, [#Msg:"alert_duplicatesession"])
        end if
      end if
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
  tClientToServer = 1
  tServerToClient = connection.GetIntFrom() <> 0
  pCryptoParams = [#ClientToServer:tClientToServer, #ServerToClient:tServerToClient]
  if tClientToServer then
    me.responseWithPublicKey()
  else
    if tServerToClient then
      error(me, "Server to client encryption only is not supported.", #handleCryptoParameters, #minor)
      return(connection.disconnect(1))
    end if
    me.startNewSession()
  end if
  return(1)
end

on responseWithPublicKey me, tConnection 
  if undefined <> void() then
    if undefined.traceScript or undefined.traceScript then
      return(0)
    end if
  end if
  undefined.traceScript = 0
  undefined.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("Login Subscript 2").castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, "Login Subscript 2").script <> script("Login Subscript 2") then
    return(0)
  end if
  tConnection = getConnection(getVariable("connection.info.id"))
  tBigInt = script("Login Subscript 2")
  tPublicKeyStr = ""
  tTries = 1
  repeat while tPublicKeyStr.length < 72 and tTries < 5
    tHex = ""
    tLength = 40
    tHexChars = "012345679abcdef"
    tNo = 1
    repeat while tNo <= (tLength * 2)
      tRandPos = random(tHexChars.length)
      tHex = tHex & chars(tHexChars, tRandPos, tRandPos)
      tNo = 1 + tNo
    end repeat
    tFakeBigJob = BigInt_str2bigInt(tHex, 16, tLength)
    pBigJob = tBigInt.str2bigInt(tHex, 16, tLength)
    _ob38729_p = BigInt_str2bigInt("A8EA077D4943CC98E53C21F5F7C7A0DB8BCE7506F8361A7C1690392F2B090C96EE8BC67BAA0DCB7183F16401F5CB838E3B6EE86B9EF2E5D0F3C49D4DC4EDC2B9", 16)
    _ob38729_g = BigInt_str2bigInt("5", 16)
    tJsPublicKey = script("Login Subscript").doPowmodMathCs(pBigJob)
    tPublicKeyStr = tBigInt.bigInt2str(tJsPublicKey, 16)
    tTries = tTries + 1
  end repeat
  if not the platform contains "windows" and tPublicKeyStr.length < 2 then
    return(me.forwardToRosettaDisablePage())
  end if
  tConnection.send("GENERATEKEY", [#string:tPublicKeyStr])
end

on handleServerSecretKey me, tMsg 
  if undefined <> void() then
    if undefined.traceScript or undefined.traceScript then
      return(0)
    end if
  end if
  undefined.traceScript = 0
  undefined.traceScript = 0
  tCastLibNum = member("Login Handler Class").castLibNum
  if member("Login Subscript 2").castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, "Login Subscript 2").script <> script("Login Subscript 2") then
    return(0)
  end if
  tConnection = tMsg.connection
  tBigInt = script("Login Subscript 2")
  _ob38729_p = BigInt_str2bigInt("A8EA077D4943CC98E53C21F5F7C7A0DB8BCE7506F8361A7C1690392F2B090C96EE8BC67BAA0DCB7183F16401F5CB838E3B6EE86B9EF2E5D0F3C49D4DC4EDC2B9", 16)
  _ob38729_g = BigInt_str2bigInt("5", 16)
  t_sServerPublicKey = tMsg.content
  tFakeServerPublic = BigInt_str2bigInt(t_sServerPublicKey, 16)
  serverPublic = tBigInt.str2bigInt(t_sServerPublicKey, 16)
  tShared = script("Login Subscript").doPowmodMathSc(pBigJob, serverPublic)
  t_sSharedKey = tBigInt.bigInt2str(tShared, 16)
  if (t_sSharedKey.length mod 2) <> 0 then
    t_sSharedKey = "0" & t_sSharedKey
  end if
  tSharedKeyString = ""
  tStrSrv = getStringServices()
  a = 1
  repeat while a <= length(t_sSharedKey)
    t = tStrSrv.convertHexToInt(t_sSharedKey.getProp(#char, a, a + 1))
    tSharedKeyString = tSharedKeyString & numToChar(t)
    a = a + 1
    a = 1 + a
  end repeat
  tCryptoClass = "tYy1rX5j7e4PLYJLER"
  tCastLibNum = 2
  if member(tCryptoClass).castLibNum <> tCastLibNum then
    return(0)
  end if
  if castLib(tCastLibNum).getPropRef(#member, tCryptoClass).script <> script(tCryptoClass) then
    return(0)
  end if
  t_rDecoder = createObject(#temp, [tCryptoClass])
  t_rDecoder.qe2AkKOGGKDTTnd1Nei(tSharedKeyString, #initMUS)
  tConnection.setDecoder(t_rDecoder)
  tConnection.setEncryption(1)
  connection.setEncoder(createObject(#temp, [tCryptoClass]))
  connection.getEncoder().qe2AkKOGGKDTTnd1Nei(tSharedKeyString, #initMUS)
  connection.setEncryption(1)
  if pCryptoParams.getaProp(#ServerToClient) = 1 then
    me.makeServerToClientKey()
  else
    me.startNewSession()
  end if
  return(1)
end

on handleEndOfCryptoParams me, tMsg 
  me.startNewSession()
end

on handleHotelLogout me, tMsg 
  tLogoutMsgId = connection.GetIntFrom()
  if tMsg = -1 then
    me.getComponent().disconnect()
    me.getInterface().showDisconnect()
  else
    if tMsg = 1 then
      openNetPage(getText("url_logged_out"), "self")
    else
      if tMsg = 2 then
        openNetPage(getText("url_logout_concurrent"), "self")
      else
        if tMsg = 3 then
          openNetPage(getText("url_logout_timeout"), "self")
        end if
      end if
    end if
  end if
end

on handleSoundSetting me, tMsg 
  tstate = connection.GetIntFrom()
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
end

on handleAchievementNotification me, tMsg 
  tConn = tMsg.getaProp(#connection)
  ttype = tConn.GetIntFrom()
  tLevel = tConn.GetIntFrom()
  tBadgeID = tConn.GetStrFrom()
  tRemovedBadgeID = tConn.GetStrFrom()
  if not objectExists(#session) then
    return(error(me, "Session object not found.", #handleAchievementNotification, #major))
  end if
  tSession = getObject(#session)
  tAchievements = tSession.GET("possible_achievements")
  tNotify = 0
  i = 1
  repeat while i <= tAchievements.count
    tAchievement = tAchievements.getAt(i)
    if tAchievement.ilk <> #propList then
    else
      if tAchievement.type = ttype and tAchievement.level <= tLevel then
        tAchievements.deleteAt(i)
        i = i - 1
        tNotify = 1
      end if
    end if
    i = 1 + i
  end repeat
  if tNotify then
    executeMessage(#achievementsUpdated)
  end if
  tBadges = tSession.GET("available_badges")
  tBadges.add(tBadgeID)
  executeMessage(#badgeReceived, tBadgeID)
  tPos = tBadges.getPos(tRemovedBadgeID)
  if tPos > 0 then
    tBadges.deleteAt(tPos)
    executeMessage(#badgeRemoved, tRemovedBadgeID)
  end if
  me.getComponent().sendGetBadges()
end

on makeServerToClientKey me 
  if undefined <> void() then
    if undefined.traceScript or undefined.traceScript then
      return(0)
    end if
  end if
  undefined.traceScript = 0
  undefined.traceScript = 0
  tConnection = getConnection(getVariable("connection.info.id"))
  tDecoder = createObject(#temp, ["x3hSfgRdzsh7CfHKUPwqjndo3bOVnl"])
  tPublicKey = tDecoder.o()
  tConnection.send("SECRETKEY", [#string:tPublicKey])
  tKey = secretDecode(tPublicKey)
  tConnection.setDecoder(tDecoder)
  tConnection.getDecoder().WvUrP88jJ4snglkrhCh3u9vHu0ADDS(tKey)
  tPremixChars = "eb11nmhdwbn733c2xjv1qln3ukpe0hvce0ylr02s12sv96rus2ohexr9cp8rufbmb1mdb732j1l3kehc0l0s2v6u2hx9prfmu"
  tConnection.getDecoder().prMixEValueBin(tPremixChars, 17)
  tConnection.setProperty(#deciphering, 1)
end

on startNewSession me 
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
  tID = connection.GetIntFrom()
  me.getComponent().handleLatencyTest(tID)
end

on forwardToRosettaDisablePage me 
  openNetPage(getVariable("rosetta.warning.page.url"), "self")
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(-1, #handleDisconnect)
  tMsgs.setaProp(0, #handleHello)
  tMsgs.setaProp(1, #handleServerSecretKey)
  tMsgs.setaProp(2, #handleRights)
  tMsgs.setaProp(3, #handleLoginOK)
  tMsgs.setaProp(5, #handleUserObj)
  tMsgs.setaProp(33, #handleErr)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(50, #handlePing)
  tMsgs.setaProp(52, #handleEPSnotify)
  tMsgs.setaProp(139, #handleSystemBroadcast)
  tMsgs.setaProp(141, #handleCheckSum)
  tMsgs.setaProp(161, #handleModAlert)
  tMsgs.setaProp(229, #handleAvailableBadges)
  tMsgs.setaProp(257, #handleSessionParameters)
  tMsgs.setaProp(277, #handleCryptoParameters)
  tMsgs.setaProp(278, #handleEndOfCryptoParams)
  tMsgs.setaProp(287, #handleHotelLogout)
  tMsgs.setaProp(308, #handleSoundSetting)
  tMsgs.setaProp(436, #handlePossibleAchievements)
  tMsgs.setaProp(437, #handleAchievementNotification)
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
  tCmds.setaProp("SECRETKEY", 207)
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
