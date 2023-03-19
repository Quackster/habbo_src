property pState, pLogoSpr

on construct me
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("system.version"))
  tSession.set("client_url", the moviePath)
  tSession.set("client_lastclick", EMPTY)
  createObject(#headers, getClassVariable("variable.manager.class"))
  createObject(#cache, getClassVariable("variable.manager.class"))
  createBroker(#Initialize)
  return me.updateState("load_variables")
end

on deconstruct me
  return me.hideLogo()
end

on showLogo me
  if memberExists("Logo") then
    tmember = member(getmemnum("Logo"))
    pLogoSpr = sprite(reserveSprite(me.getID()))
    pLogoSpr.ink = 36
    pLogoSpr.blend = 60
    pLogoSpr.member = tmember
    pLogoSpr.locZ = -20000001
    pLogoSpr.loc = point((the stage).rect.width / 2, ((the stage).rect.height / 2) - tmember.height)
  end if
  return 1
end

on hideLogo me
  if pLogoSpr.ilk = #sprite then
    releaseSprite(pLogoSpr.spriteNum)
    pLogoSpr = VOID
  end if
  return 1
end

on updateState me, tstate
  case tstate of
    "load_variables":
      pState = tstate
      me.showLogo()
      cursor(4)
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        the itemDelimiter = "="
        repeat with i = 1 to 9
          tParam = externalParamValue("sw" & i)
          if not voidp(tParam) then
            if tParam.item.count = 2 then
              if tParam.item[1] = "external.variables.txt" then
                getVariableManager().set("external.variables.txt", tParam.item[2])
              end if
            end if
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      tURL = getVariable("external.variables.txt")
      tMemName = tURL
      if the moviePath contains "http://" then
        tURL = tURL & "?" & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & "?" & the milliSeconds
        end if
      end if
      tMemNum = queueDownload(tURL, tMemName, #field, 1)
      return registerDownloadCallback(tMemNum, #updateState, me.getID(), "load_params")
    "load_params":
      pState = tstate
      dumpVariableField(getVariable("external.variables.txt"))
      removeMember(getVariable("external.variables.txt"))
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        the itemDelimiter = "="
        repeat with i = 1 to 9
          tParam = externalParamValue("sw" & i)
          if not voidp(tParam) then
            if tParam.item.count = 2 then
              getVariableManager().set(tParam.item[1], tParam.item[2])
            end if
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      setDebugLevel(getIntVariable("system.debug", 0))
      getStringServices().initConvList()
      puppetTempo(getIntVariable("system.tempo", 30))
      if variableExists("client.reload.url") then
        getObject(#session).set("client_url", getVariable("client.reload.url"))
      end if
      return me.updateState("load_texts")
    "load_texts":
      pState = tstate
      tURL = getVariable("external.texts.txt")
      tMemName = tURL
      if tMemName = EMPTY then
        return me.updateState("load_casts")
      end if
      if the moviePath contains "http://" then
        tURL = tURL & "?" & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & "?" & the milliSeconds
        end if
      end if
      tMemNum = queueDownload(tURL, tMemName, #field)
      return registerDownloadCallback(tMemNum, #updateState, me.getID(), "load_casts")
    "load_casts":
      pState = tstate
      tTxtFile = getVariable("external.texts.txt")
      if tTxtFile <> 0 then
        if memberExists(tTxtFile) then
          dumpTextField(tTxtFile)
          removeMember(tTxtFile)
        end if
      end if
      tCastList = []
      i = 1
      repeat while 1
        if not variableExists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = getVariable("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if count(tCastList) > 0 then
        tLoadID = startCastLoad(tCastList, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tLoadID, [#buffer: #window])
        end if
        return registerCastloadCallback(tLoadID, #updateState, me.getID(), "validate_resources")
      else
        return me.updateState("init_threads")
      end if
    "validate_resources":
      pState = tstate
      tCastList = []
      tNewList = []
      tVarMngr = getVariableManager()
      i = 1
      repeat while 1
        if not tVarMngr.exists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = tVarMngr.get("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if count(tCastList) > 0 then
        repeat with tCast in tCastList
          if not castExists(tCast) then
            tNewList.add(tCast)
          end if
        end repeat
      end if
      if count(tNewList) > 0 then
        tLoadID = startCastLoad(tNewList, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tLoadID, [#buffer: #window])
        end if
        return registerCastloadCallback(tLoadID, #updateState, me.getID(), "validate_resources")
      else
        return me.updateState("init_threads")
      end if
    "init_threads":
      pState = tstate
      cursor(0)
      (the stage).title = getVariable("client.window.title")
      me.hideLogo()
      getThreadManager().initAll()
      return executeMessage(#Initialize, "initialize")
    otherwise:
      return error(me, "Unknown state:" && tstate, #updateState)
  end case
end