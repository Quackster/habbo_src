property pOkToLogin, pLatencyTestID, pLatencyValueList, pLatencyTestTimeStampList, pLatencyTotalValue, pLatencyValueCount, pLatencyClearedValue, pLatencyClearedCount, pLatencyReportIndex, pLatencyReported, pLatencyReportDelta, pLatencyTestInterval, pLatencyTestTimeoutID, pDisconnectErrorState

on construct me
  pOkToLogin = 0
  pLatencyTestID = 1
  pLatencyValueList = []
  pLatencyTestTimeStampList = [:]
  pLatencyTotalValue = 0
  pLatencyValueCount = 0
  pLatencyClearedValue = 0
  pLatencyClearedCount = 0
  pLatencyTestTimeoutID = "latency.test.timeout"
  pLatencyTestInterval = 0
  pLatencyReportIndex = 0
  pLatencyReportDelta = 0
  if variableExists("latencytest.interval") then
    pLatencyTestInterval = getVariable("latencytest.interval")
  end if
  if variableExists("latencytest.report.index") then
    pLatencyReportIndex = getVariable("latencytest.report.index")
  end if
  if variableExists("latencytest.report.delta") then
    pLatencyReportDelta = getVariable("latencytest.report.delta")
  end if
  pLatencyReported = 0
  if variableExists("stats.tracking.javascript") then
    createObject(#statsBrokerJs, "Statistics Broker Javascript Class")
  end if
  if variableExists("stats.tracking.url") then
    createObject(#statsBroker, "Statistics Broker Class")
  end if
  if not objectExists(#dateFormatter) then
    createObject(#dateFormatter, ["Date Class"])
  end if
  if not objectExists("Figure_System") then
    if createObject("Figure_System", ["Figure System Class"]) <> 0 then
      tURL = getVariable("external.figurepartlist.txt")
      getObject("Figure_System").define(["type": "url", "source": tURL])
    end if
  end if
  if not objectExists("Figure_Preview") then
    createObject("Figure_Preview", ["Figure Preview Class"])
  end if
  getObject(#session).set("user_rights", [])
  registerMessage(#Initialize, me.getID(), #initA)
  if not objectExists("Help_Tooltip_Manager") then
    createObject("Help_Tooltip_Manager", "Help Tooltip Manager Class")
  end if
  if not objectExists("Oneclick_Buy_Window_Manager") then
    createObject("Oneclick_Buy_Window_Manager", "Game Oneclick Buy Window Manager Class")
  end if
  pDisconnectErrorState = "socket_init"
  registerMessage(#openConnection, me.getID(), #openConnection)
  registerMessage(#closeConnection, me.getID(), #disconnect)
  registerMessage(#performLogin, me.getID(), #sendLogin)
  registerMessage(#loginIsOk, me.getID(), #setLoginOk)
  return 1
end

on deconstruct me
  pOkToLogin = 0
  if objectExists("Figure_System") then
    removeObject("Figure_System")
  end if
  if objectExists("Figure_Preview") then
    removeObject("Figure_Preview")
  end if
  if objectExists("nav_problem_obj") then
    removeObject("nav_problem_obj")
  end if
  if objectExists(#statsBroker) then
    removeObject(#statsBroker)
  end if
  if objectExists(#statsBrokerJs) then
    removeObject(#statsBrokerJs)
  end if
  if objectExists(#getServerDate) then
    removeObject(#getServerDate)
  end if
  if objectExists("Help_Tooltip_Manager") then
    removeObject("Help_Tooltip_Manager")
  end if
  unregisterMessage(#openConnection, me.getID())
  unregisterMessage(#closeConnection, me.getID())
  if connectionExists(getVariable("connection.info.id", #Info)) then
    return me.disconnect()
  else
    return 1
  end if
end

on initA me
  if getIntVariable("figurepartlist.loaded", 1) = 0 then
    return me.delay(250, #initA)
  end if
  return me.delay(1000, #initB)
end

on initB me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tUseSSO = 0
  if variableExists("use.sso.ticket") then
    tUseSSO = getVariable("use.sso.ticket")
    if variableExists("sso.ticket") and tUseSSO then
      tSsoTicket = string(getVariable("sso.ticket"))
      if tSsoTicket.length > 1 then
        getObject(#session).set(#SSO_ticket, tSsoTicket)
        return me.openConnection()
      end if
    end if
  end if
  if tUseSSO = 0 then
    return me.getInterface().showLogin()
  else
    executeMessage(#alert, [#Msg: "Alert_generic_login_error"])
  end if
end

on sendLogin me, tConnection
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  me.SetDisconnectErrorState("login")
  if voidp(tConnection) then
    tConnection = getConnection(getVariable("connection.info.id"))
  end if
  if objectExists("nav_problem_obj") then
    removeObject("nav_problem_obj")
  end if
  if me.getComponent().isOkToLogin() then
    tSsoTicket = 0
    if getObject(#session).exists("SSO_ticket") then
      tSsoTicket = getObject(#session).GET("SSO_ticket")
    end if
    if tSsoTicket <> 0 then
      sendProcessTracking(15)
      return tConnection.send("SSO", [#string: tSsoTicket])
    else
      tUserName = getObject(#session).GET(#userName)
      tPassword = getObject(#session).GET(#Password)
      if not stringp(tUserName) or not stringp(tPassword) then
        return removeConnection(tConnection.getID())
      end if
      if (tUserName = EMPTY) or (tPassword = EMPTY) then
        return removeConnection(tConnection.getID())
      end if
      return tConnection.send("TRY_LOGIN", [#string: tUserName, #string: tPassword])
    end if
  end if
  return 1
end

on openConnection me
  me.setaProp(#pOkToLogin, 1)
  me.connect()
end

on connect me
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  _movie.traceScript = 0
  _player.traceScript = 0
  tHost = getVariable("connection.info.host")
  tPort = getIntVariable("connection.info.port")
  tConn = getVariable("connection.info.id", #Info)
  if voidp(tHost) or voidp(tPort) then
    return error(me, "Server port/host data not found!", #connect, #major)
  end if
  if not createConnection(tConn, tHost, tPort) then
    return error(me, "Failed to create connection!", #connect, #major)
  end if
  if not objectExists(#getServerDate) then
    createObject(#getServerDate, "Server Date Class")
  end if
  if not objectExists("nav_problem_obj") then
    createObject("nav_problem_obj", "Connection Problem Class")
  end if
  if not threadExists(#hobba) then
    initThread("thread.hobba")
  end if
  return 1
end

on disconnect me
  tConn = getVariable("connection.info.id", #Info)
  if connectionExists(tConn) then
    return removeConnection(tConn)
  else
    return error(me, "Connection not found!", #disconnect, #minor)
  end if
end

on setAllowLogin me
  pOkToLogin = 1
end

on isOkToLogin me
  return me.pOkToLogin
end

on initLatencyTest me
  if pLatencyTestInterval <= 0 then
    return 0
  end if
  if not timeoutExists(pLatencyTestTimeoutID) then
    createTimeout(pLatencyTestTimeoutID, pLatencyTestInterval, #sendLatencyTest, me.getID(), VOID, 0)
  end if
  return 1
end

on sendLatencyTest me
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tConnection = getConnection(getVariable("connection.info.id"))
  if tConnection.send("TEST_LATENCY", [#integer: pLatencyTestID]) then
    pLatencyTestTimeStampList.addProp(string(pLatencyTestID), the milliSeconds)
    pLatencyTestID = pLatencyTestID + 1
    return 1
  end if
  return 0
end

on sendGetBadges me
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tOwnUserId = getObject(#session).GET("user_user_id")
  tConnection = getConnection(getVariable("connection.info.id"))
  return tConnection.send("GETSELECTEDBADGES", [#integer: integer(tOwnUserId)])
end

on handleLatencyTest me, tID
  if voidp(pLatencyTestTimeStampList[string(tID)]) then
    return 0
  end if
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tConnection = getConnection(getVariable("connection.info.id"))
  tDelta = the milliSeconds - pLatencyTestTimeStampList[string(tID)]
  pLatencyTestTimeStampList.deleteProp(string(tID))
  pLatencyValueList.add(tDelta)
  pLatencyValueCount = pLatencyValueCount + 1
  if (pLatencyValueList.count = pLatencyReportIndex) and (pLatencyReportIndex > 0) then
    repeat with i = 1 to pLatencyValueList.count
      pLatencyTotalValue = pLatencyTotalValue + pLatencyValueList[i]
    end repeat
    tLatency = pLatencyTotalValue / pLatencyValueCount
    repeat with i = 1 to pLatencyValueList.count
      if pLatencyValueList[i] < (tLatency * 2) then
        pLatencyClearedValue = pLatencyClearedValue + pLatencyValueList[i]
        pLatencyClearedCount = pLatencyClearedCount + 1
      end if
    end repeat
    tLatencyCleared = pLatencyClearedValue / pLatencyClearedCount
    if (abs(tLatency - pLatencyReported) > pLatencyReportDelta) or (pLatencyReported = 0) then
      pLatencyReported = tLatency
      tConnection.send("REPORT_LATENCY", [#integer: tLatency, #integer: tLatencyCleared, #integer: pLatencyValueCount])
    end if
    pLatencyValueList = []
  end if
  return 1
end

on SetDisconnectErrorState me, tError
  pDisconnectErrorState = tError
end

on GetDisconnectErrorState me
  return pDisconnectErrorState
end
