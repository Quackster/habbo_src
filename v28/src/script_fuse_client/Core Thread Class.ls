property pCrapFixSpr, pFullScreenRefreshSpr, pLogoSpr, pLogoStartTime, pFadingLogo, pCrapFixing, pCrapFixRegionInvalidated

on construct me 
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("system.version"))
  tSession.set("client_url", getMoviePath())
  tSession.set("client_lastclick", "")
  tSession.set("client_lastclick_time", "")
  createObject(#headers, getClassVariable("variable.manager.class"))
  createObject(#classes, getClassVariable("variable.manager.class"))
  createObject(#cache, getClassVariable("variable.manager.class"))
  createBroker(#Initialize)
  registerMessage(#requestHotelView, me.getID(), #initTransferToHotelView)
  registerMessage(#invalidateCrapFixRegion, me.getID(), #invalidateCrapFixer)
  pFadingLogo = 0
  pLogoStartTime = 0
  pCrapFixSpr = sprite(reserveSprite())
  if ilk(pCrapFixSpr) = #sprite then
    pCrapFixSpr.member = member("crap.fixer")
    pCrapFixSpr.width = 560
    pCrapFixSpr.height = 75
    pCrapFixSpr.locZ = -2000000000
    pCrapFixSpr.loc = point(-1, 0)
    pCrapFixSpr.visible = 0
  end if
  pCrapFixing = 0
  pCrapFixRegionInvalidated = 1
  pFullScreenRefreshSpr = sprite(reserveSprite())
  if ilk(pFullScreenRefreshSpr) = #sprite then
    pFullScreenRefreshSpr.member = member("crap.fixer")
    pFullScreenRefreshSpr.width = undefined.width + 1
    pFullScreenRefreshSpr.height = undefined.height
    pFullScreenRefreshSpr.locZ = -2000000000
    pFullScreenRefreshSpr.loc = point(-1, 0)
    pFullScreenRefreshSpr.visible = 0
  end if
  return(me.updateState("load_variables"))
end

on deconstruct me 
  if timeoutExists("client.refresh.timeout") then
    removeTimeout("client.refresh.timeout")
  end if
  unregisterMessage(#invalidateCrapFixRegion, me.getID())
  releaseSprite(pCrapFixSpr.spriteNum)
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

on invalidateCrapFixer me 
  pCrapFixRegionInvalidated = 1
end

on update me 
  if pFadingLogo then
    tBlend = 0
    if pLogoSpr <> void() then
      pLogoSpr.blend = pLogoSpr.blend - 10
      tBlend = pLogoSpr.blend
    end if
    if tBlend <= 0 then
      if not pCrapFixing then
        removeUpdate(me.getID())
      end if
      pFadingLogo = 0
      me.hideLogo()
      executeMessage(#showHotelView)
      callJavaScriptFunction("clientReady")
    end if
  end if
  if pCrapFixing then
    if ilk(pCrapFixSpr) = #sprite then
      if pCrapFixRegionInvalidated then
        pCrapFixSpr.visible = 1
        if pCrapFixSpr.locH = 0 then
          pCrapFixSpr.loc = point(-1, 0)
        else
          if pCrapFixSpr.locH = -1 then
            pCrapFixSpr.loc = point(0, 0)
          else
            pCrapFixSpr.loc = point(0, 0)
          end if
        end if
        pCrapFixRegionInvalidated = 0
      end if
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
                      if tKey = "processlog.url" then
                        getVariableManager().set(tKey, tValue)
                      else
                        if tKey = "account_id" then
                          getVariableManager().set(tKey, tValue)
                        end if
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
    tMemNum = queueDownload(tURL, tMemName, #field, 1)
    sendProcessTracking(9)
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
      if variableExists("text.crap.fixing") then
        pCrapFixing = getVariableValue("text.crap.fixing")
      end if
      if variableExists("client.full.refresh.period") then
        createTimeout("client.refresh.timeout", getIntVariable("client.full.refresh.period"), #fullScreenRefresh, me.getID(), void(), 0)
      end if
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
        tMemNum = queueDownload(tURL, tMemName, #field)
        sendProcessTracking(12)
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
          sendProcessTracking(23)
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
              showLoadingBar(tLoadID, [#buffer:#window, #locY:500, #width:300, #extraTasks:[#handshake1, #handshake2, #login]])
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
                showLoadingBar(tLoadID, [#buffer:#window, #locY:500, #width:300, #extraTasks:[#handshake1, #handshake2, #login]])
              end if
              return(registerCastloadCallback(tLoadID, #assetDownloadCallbacks, me.getID(), tstate))
            else
              return(me.updateState("init_threads"))
            end if
          else
            if tstate = "init_threads" then
              sendProcessTracking(24)
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

on fullScreenRefresh me 
  if ilk(pFullScreenRefreshSpr) = #sprite then
    pFullScreenRefreshSpr.visible = 1
    if pFullScreenRefreshSpr.locH = 0 then
      pFullScreenRefreshSpr.loc = point(-1, 0)
    else
      if pFullScreenRefreshSpr.locH = -1 then
        pFullScreenRefreshSpr.loc = point(0, 0)
      else
        pFullScreenRefreshSpr.loc = point(0, 0)
      end if
    end if
  end if
end
