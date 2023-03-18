property pOkToLogin

on construct me
  pOkToLogin = 0
  if variableExists("stats.tracking.javascript") then
    createObject(#statsBroker, "Statistics Broker Javascript Class")
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
  if not variableExists("quickLogin") then
    setVariable("quickLogin", 0)
  end if
  if getIntVariable("quickLogin", 0) and (the runMode contains "Author") then
    if not voidp(getPref(getVariable("fuse.project.id", "fusepref"))) then
      tTemp = value(getPref(getVariable("fuse.project.id", "fusepref")))
      getObject(#session).set(#userName, tTemp[1])
      getObject(#session).set(#password, tTemp[2])
      pOkToLogin = 1
      return me.connect()
    end if
  end if
  registerMessage(#Initialize, me.getID(), #initA)
  if not objectExists("Help_Tooltip_Manager") then
    createObject("Help_Tooltip_Manager", "Help Tooltip Manager Class")
  end if
  if not objectExists("Ticket_Window_Manager") then
    createObject("Ticket_Window_Manager", "Ticket Window Manager Class")
  end if
  if not objectExists("Oneclick_Buy_Window_Manager") then
    createObject("Oneclick_Buy_Window_Manager", "Game Oneclick Buy Window Manager Class")
  end if
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
  if objectExists(#getServerDate) then
    removeObject(#getServerDate)
  end if
  if objectExists("Help_Tooltip_Manager") then
    removeObject("Help_Tooltip_Manager")
  end if
  unregisterMessage(#openConnection, me.getID())
  unregisterMessage(#closeConnection, me.getID())
  if connectionExists(getVariable("connection.info.id", #info)) then
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
      return tConnection.send("SSO", [#string: tSsoTicket])
    else
      tUserName = getObject(#session).GET(#userName)
      tPassword = getObject(#session).GET(#password)
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
  tHost = getVariable("connection.info.host")
  tPort = getIntVariable("connection.info.port")
  tConn = getVariable("connection.info.id", #info)
  if voidp(tHost) or voidp(tPort) then
    return error(me, "Server port/host data not found!", #connect)
  end if
  if not createConnection(tConn, tHost, tPort) then
    return error(me, "Failed to create connection!", #connect)
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
  tConn = getVariable("connection.info.id", #info)
  if connectionExists(tConn) then
    return removeConnection(tConn)
  else
    return error(me, "Connection not found!", #disconnect)
  end if
end

on setAllowLogin me
  pOkToLogin = 1
end

on isOkToLogin me
  return me.pOkToLogin
end
