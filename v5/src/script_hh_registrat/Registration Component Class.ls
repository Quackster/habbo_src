on construct(me)
  pValidPartProps = []
  pValidPartGroups = []
  pFigurePartListLoadedFlag = 0
  pAvailableSetListLoadedFlag = 0
  setVariable("figurepartlist.loaded", 0)
  registerMessage(#enterRoom, me.getID(), #closeFigureCreator)
  registerMessage(#changeRoom, me.getID(), #closeFigureCreator)
  registerMessage(#leaveRoom, me.getID(), #closeFigureCreator)
  registerMessage(#show_registration, me.getID(), #openFigureCreator)
  registerMessage(#hide_registration, me.getID(), #closeFigureCreator)
  registerMessage(#userlogin, me.getID(), #getAvailableSetList)
  return(me.updateState("loadFigurePartList"))
  exit
end

on deconstruct(me)
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#show_registration, me.getID())
  unregisterMessage(#hide_registration, me.getID())
  unregisterMessage(#userlogin, me.getID())
  return(me.updateState("reset"))
  exit
end

on openFigureCreator(me)
  return(me.updateState("openFigureCreator"))
  exit
end

on openFigureUpdate(me)
  return(me.updateState("openFigureUpdate"))
  exit
end

on closeFigureCreator(me)
  return(me.getInterface().closeFigureCreator())
  exit
end

on checkUserName(me, tNameStr)
  if objectExists(#string_validator) then
    if not getObject(#string_validator).validateString(tNameStr) then
      tFailed = getObject(#string_validator).getFailedChar()
      setText("alert_InvalidChar", replaceChunks(getText("alert_InvalidUserName"), "\\x", tFailed))
      executeMessage(#alert, [#msg:"alert_InvalidChar", #id:"nameinvalid"])
      return(0)
    end if
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "FINDUSER" && tNameStr & "\t" & "REGNAME")
    getConnection(getVariable("connection.info.id")).send(#info, "APPROVENAME" && tNameStr)
  end if
  return(1)
  exit
end

on sendNewFigureDataToServer(me, tPropList)
  if not voidp(tPropList.getAt("figure")) then
    tFigure = me.GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if variableExists("user_isp") then
    if not voidp(getVariable("user_isp")) then
      tPropList.setAt("isp_id", getVariable("user_isp"))
    end if
  end if
  tMsg = ""
  f = 1
  repeat while f <= tPropList.count
    tProp = tPropList.getPropAt(f)
    tDesc = tPropList.getAt(tProp)
    if tProp = "sex" then
      if tDesc.getProp(#char, 1) = "f" or tDesc.getProp(#char, 1) = "F" then
        tDesc = "Female"
      else
        tDesc = "Male"
      end if
    end if
    tMsg = tMsg & tProp & "=" & tDesc & "\r"
    f = 1 + f
  end repeat
  if connectionExists(getVariable("connection.info.id")) then
    return(getConnection(getVariable("connection.info.id")).send(#info, "REGISTER" && tMsg))
  else
    return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendNewFigureDataToServer))
  end if
  exit
end

on sendFigureUpdateToServer(me, tPropList)
  if not voidp(tPropList.getAt("figure")) then
    tFigure = me.GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if not voidp(tPropList.getAt("password")) then
    if me <> "" then
      if me = void() then
        return(error(me, "Password was reseted, abort update!", #sendFigureUpdateToServer))
      end if
      tMsg = ""
      f = 1
      repeat while f <= tPropList.count
        tProp = tPropList.getPropAt(f)
        tDesc = tPropList.getAt(tProp)
        if tProp = "user_sex" then
          if tDesc.getProp(#char, 1) = "f" or tDesc.getProp(#char, 1) = "F" then
            tDesc = "Female"
          else
            tDesc = "Male"
          end if
        end if
        if tProp <> "user_figure" then
          getObject(#session).set(tProp, tDesc)
        end if
        tMsg = tMsg & tProp & "=" & tDesc & "\r"
        f = 1 + f
      end repeat
      if connectionExists(getVariable("connection.info.id")) then
        return(getConnection(getVariable("connection.info.id")).send(#info, "UPDATE" && tMsg))
      else
        return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendFigureUpdateToServer))
      end if
      exit
    end if
  end if
end

on newFigureReady(me)
  getObject(#session).set("user_new_registration", 1)
  me.closeFigureCreator()
  me.updateState("start")
  if threadExists(#navigator) then
    getThread(#navigator).getComponent().updateState("connectionOk")
  end if
  return(1)
  exit
end

on figureUpdateReady(me)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "INFORETRIEVE" && getObject(#session).get(#userName) && getObject(#session).get(#password))
  else
    error(me, "Connection not found:" && getVariable("connection.info.id"), #figureUpdateReady)
  end if
  me.closeFigureCreator()
  return(me.updateState("start"))
  exit
end

on setAvailableSetList(me, tList)
  if pFigurePartListLoadedFlag and not voidp(tList) then
    me.initializeSelectablePartList(tList)
    pAvailableSetListLoadedFlag = 1
    if me = "openFigureCreator" then
      return(me.updateState("openFigureCreator"))
    else
      if me = "openFigureUpdate" then
        return(me.updateState("openFigureUpdate"))
      end if
    end if
  end if
  exit
end

on getAvailableSetList(me)
  if pFigurePartListLoadedFlag = 1 and pAvailableSetListLoadedFlag = 0 then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send(#info, "GETAVAILABLESETS")
    end if
  end if
  exit
end

on getState(me)
  return(pState)
  exit
end

on updateState(me, tstate, tProps)
  if me = "reset" then
    pState = tstate
    me.construct()
    return(0)
  else
    if me = "loadFigurePartList" then
      pState = tstate
      tURL = getVariable("external.figurepartlist.txt")
      tMem = tURL
      if the moviePath contains "http://" then
        tURL = tURL & "?" & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & "?" & the milliSeconds
        end if
      end if
      tmember = queueDownload(tURL, tMem, #field, 1)
      return(registerDownloadCallback(tmember, #updateState, me.getID(), "initialize"))
    else
      if me = "initialize" then
        pState = tstate
        tMemName = getVariable("external.figurepartlist.txt")
        if tMemName = 0 then
          tMemName = ""
        end if
        if not memberExists(tMemName) then
          tValidpartList = void()
          error(me, "Failure while loading part list", #updateState)
        else
          try()
          tValidpartList = value(member(getmemnum(tMemName)).text)
          if catch() then
            tValidpartList = void()
          end if
        end if
        me.initializeValidPartLists(tValidpartList)
        pFigurePartListLoadedFlag = 1
        setVariable("figurepartlist.loaded", 1)
        if memberExists(tMemName) then
          removeMember(tMemName)
        end if
        return(me.updateState("start"))
      else
        if me = "start" then
          pState = tstate
          return(1)
        else
          if me = "openFigureCreator" then
            pState = tstate
            if threadExists(#navigator) and not connectionExists(getVariable("connection.info.id")) then
              getThread(#navigator).getComponent().updateState("connection")
              me.getInterface().showLoadingWindow()
            else
              if pAvailableSetListLoadedFlag = 0 then
                return(me.getAvailableSetList())
              else
                me.getInterface().openFigureCreator("newFigure")
              end if
            end if
            return(1)
          else
            if me = "openFigureUpdate" then
              pState = tstate
              if pAvailableSetListLoadedFlag = 0 then
                return(me.getAvailableSetList())
              end if
              tFigure = me.validateFigure(getObject(#session).get("user_figure"), getObject(#session).get("user_sex"))
              getObject(#session).set("user_figure", tFigure)
              me.getInterface().showHideFigureCreator("update")
              return(1)
            else
              return(error(me, "Unknown state:" && tstate, #updateState))
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end