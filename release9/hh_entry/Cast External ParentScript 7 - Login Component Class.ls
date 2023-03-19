property pOkToLogin

on construct me
  pOkToLogin = 0
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
      getObject(#session).set(#Password, tTemp[2])
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
  return me.getInterface().showLogin()
end

on connect me
  tHost = getVariable("connection.info.host")
  tPort = getIntVariable("connection.info.port")
  tConn = getVariable("connection.info.id", #Info)
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
  tConn = getVariable("connection.info.id", #Info)
  if connectionExists(tConn) then
    return removeConnection(tConn)
  else
    return error(me, "Connection not found!", #disconnect)
  end if
end

on isOkToLogin me
  return me.pOkToLogin
end
