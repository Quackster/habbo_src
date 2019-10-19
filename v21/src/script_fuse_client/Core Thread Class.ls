property pLogoSpr, pLogoStartTime, pFadingLogo

on construct me 
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("system.version"))
  tSession.set("client_url", getMoviePath())
  tSession.set("client_lastclick", "")
  createObject(#headers, getClassVariable("variable.manager.class"))
  createObject(#classes, getClassVariable("variable.manager.class"))
  createObject(#cache, getClassVariable("variable.manager.class"))
  createBroker(#Initialize)
  registerMessage(#requestHotelView, me.getID(), #initTransferToHotelView)
  pFadingLogo = 0
  pLogoStartTime = 0
  return(me.updateState("load_variables"))
end

on deconstruct me 
  return(me.hideLogo())
end

on showLogo me 
  if memberExists("Logo") then
    tmember = member(getmemnum("Logo"))
    pLogoSpr = sprite(reserveSprite(me.getID()))
    pLogoSpr.member = tmember
    pLogoSpr.ink = 0
    pLogoSpr.blend = 90
    pLogoSpr.locZ = -20000001
    pLogoSpr.loc = point((undefined.width / 2), (undefined.height / 2) - tmember.height)
    pLogoStartTime = the milliSeconds
  end if
  return(1)
end

on hideLogo me 
  if pLogoSpr.ilk = #sprite then
    releaseSprite(pLogoSpr.spriteNum)
    pLogoSpr = void()
  end if
  return(1)
end

on initTransferToHotelView me 
  tShowLogoForMs = 1000
  tLogoNowShownMs = the milliSeconds - pLogoStartTime
  if tLogoNowShownMs >= tShowLogoForMs then
    createTimeout("logo_timeout", 2000, #initUpdate, me.getID(), void(), 1)
  else
    createTimeout("init_timeout", tShowLogoForMs - tLogoNowShownMs + 1, #initTransferToHotelView, me.getID(), void(), 1)
  end if
end

on initUpdate me 
  pFadingLogo = 1
  receiveUpdate(me.getID())
end

on update me 
  if pFadingLogo then
    tBlend = 0
    if pLogoSpr <> void() then
      pLogoSpr.blend = pLogoSpr.blend - 10
      tBlend = pLogoSpr.blend
    end if
    if tBlend <= 0 then
      removeUpdate(me.getID())
      pFadingLogo = 0
      me.hideLogo()
      executeMessage(#showHotelView)
    end if
  end if
end

on assetDownloadCallbacks me, tAssetId, tSuccess 
  if tSuccess = 0 then
    if tAssetId <> "load_variables" then
      if tAssetId <> "load_texts" then
        if tAssetId = "load_casts" then
          fatalError(["error":tAssetId])
        end if
        return(0)
        if tAssetId = "load_variables" then
          me.updateState("load_params")
        else
          if tAssetId = "load_texts" then
            me.updateState("load_casts")
          else
            if tAssetId = "load_casts" then
              me.updateState("validate_resources")
            else
              if tAssetId = "validate_resources" then
                me.updateState("validate_resources")
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on updateState me, tstate 
  if tstate = "load_variables" then
    pState = tstate
    me.showLogo()
    cursor(4)
    if the runMode contains "Plugin" then
      tDelim = the itemDelimiter
      i = 1
      repeat while i <= 9
        tParamBundle = externalParamValue("sw" & i)
        if not voidp(tParamBundle) then
          the itemDelimiter = ";"
          j = 1
          repeat while j <= tParamBundle.count(#item)
            tParam = tParamBundle.getProp(#item, j)
            the itemDelimiter = "="
            if tParam.count(#item) > 1 then
              tKey = tParam.getProp(#item, 1)
              tValue = tParam.getProp(#item, 2, tParam.count(#item))
              if tKey = "client.fatal.error.url" then
                getVariableManager().set(tKey, tValue)
              else
                if tKey = "client.allow.cross.domain" then
                  getVariableManager().set(tKey, tValue)
                else
                  if tKey = "client.notify.cross.domain" then
                    getVariableManager().set(tKey, tValue)
                  else
                    if tKey = "external.variables.txt" then
                      getSpecialServices().setExtVarPath(tValue)
                    else
                      if tKey = "processlog.enabled" then
                        getVariableManager().set(tKey, tValue)
                      end if
                    end if
                  end if
                end if
              end if
            end if
            the itemDelimiter = ";"
            j = 1 + j
          end repeat
        end if
        i = 1 + i
      end repeat
      the itemDelimiter = tDelim
    end if
    tURL = getExtVarPath()
    tMemName = tURL
    if tURL contains "?" then
      tParamDelim = "&"
    else
      tParamDelim = "?"
    end if
    if the moviePath contains "http://" then
      tURL = tURL & tParamDelim & the milliSeconds
    else
      if tURL contains "http://" then
        tURL = tURL & tParamDelim & the milliSeconds
      end if
    end if
    sendProcessTracking(9)
    tMemNum = queueDownload(tURL, tMemName, #field, 1)
    if tMemNum = 0 then
      fatalError(["error":tstate])
      return(0)
    else
      return(registerDownloadCallback(tMemNum, #assetDownloadCallbacks, me.getID(), tstate))
    end if
  else
    if tstate = "load_params" then
      pState = tstate
      dumpVariableField(getExtVarPath())
      removeMember(getExtVarPath())
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        i = 1
        repeat while i <= 9
          tParamBundle = externalParamValue("sw" & i)
          if not voidp(tParamBundle) then
            the itemDelimiter = ";"
            j = 1
            repeat while j <= tParamBundle.count(#item)
              tParam = tParamBundle.getProp(#item, j)
              the itemDelimiter = "="
              if tParam.count(#item) > 1 then
                getVariableManager().set(tParam.getProp(#item, 1), tParam.getProp(#item, 2, tParam.count(#item)))
              end if
              the itemDelimiter = ";"
              j = 1 + j
            end repeat
          end if
          i = 1 + i
        end repeat
        the itemDelimiter = tDelim
      end if
      setDebugLevel(0)
      getStringServices().initConvList()
      puppetTempo(getIntVariable("system.tempo", 30))
      if variableExists("client.reload.url") then
        getObject(#session).set("client_url", obfuscate(getVariable("client.reload.url")))
      end if
      return(me.updateState("load_texts"))
    else
      if tstate = "load_texts" then
        pState = tstate
        tURL = getVariable("external.texts.txt")
        tMemName = tURL
        if tMemName = "" then
          return(me.updateState("load_casts"))
        end if
        if tURL contains "?" then
          tParamDelim = "&"
        else
          tParamDelim = "?"
        end if
        if the moviePath contains "http://" then
          tURL = tURL & tParamDelim & the milliSeconds
        else
          if tURL contains "http://" then
            tURL = tURL & tParamDelim & the milliSeconds
          end if
        end if
        sendProcessTracking(12)
        tMemNum = queueDownload(tURL, tMemName, #field)
        if tMemNum = 0 then
          fatalError(["error":tstate])
          return(0)
        else
          return(registerDownloadCallback(tMemNum, #assetDownloadCallbacks, me.getID(), tstate))
        end if
      else
        if tstate = "load_casts" then
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
            else
              tFileName = getVariable("cast.entry." & i)
              tCastList.add(tFileName)
              i = i + 1
            end if
          end repeat
          if count(tCastList) > 0 then
            tLoadID = startCastLoad(tCastList, 1, void(), void(), 1)
            if getVariable("loading.bar.active") then
              showLoadingBar(tLoadID, [#buffer:#window, #locY:500, #width:300])
            end if
            return(registerCastloadCallback(tLoadID, #assetDownloadCallbacks, me.getID(), tstate))
          else
            return(me.updateState("init_threads"))
          end if
        else
          if tstate = "validate_resources" then
            pState = tstate
            tCastList = []
            tNewList = []
            tVarMngr = getVariableManager()
            i = 1
            repeat while 1
              if not tVarMngr.exists("cast.entry." & i) then
              else
                tFileName = tVarMngr.GET("cast.entry." & i)
                tCastList.add(tFileName)
                i = i + 1
              end if
            end repeat
            if count(tCastList) > 0 then
              repeat while tstate <= undefined
                tCast = getAt(undefined, tstate)
                if not castExists(tCast) then
                  tNewList.add(tCast)
                end if
              end repeat
            end if
            if count(tNewList) > 0 then
              tLoadID = startCastLoad(tNewList, 1, void(), void(), 1)
              if getVariable("loading.bar.active") then
                showLoadingBar(tLoadID, [#buffer:#window, #locY:500, #width:300])
              end if
              return(registerCastloadCallback(tLoadID, #assetDownloadCallbacks, me.getID(), tstate))
            else
              return(me.updateState("init_threads"))
            end if
          else
            if tstate = "init_threads" then
              pState = tstate
              cursor(0)
              the stage.title = getVariable("client.window.title")
              me.hideLogo()
              getThreadManager().initAll()
              return(executeMessage(#Initialize, "initialize"))
            else
              return(error(me, "Unknown state:" && tstate, #updateState, #major))
            end if
          end if
        end if
      end if
    end if
  end if
end
