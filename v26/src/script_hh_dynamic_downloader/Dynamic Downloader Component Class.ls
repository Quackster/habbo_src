property pBypassList, pCurrentDownLoads, pDownloadedAssets, pDownloadQueue, pPriorityDownloadQueue, pAliasListReceived, pAliasListLoading, pRevisionsReceived, pRevisionsLoading, pAliasList, pDynDownloadURL, pFurniCastNameTemplate, pFurniRevisionList, pBinCastName

on construct me 
  if variableExists("dynamic.download.url") then
    pDynDownloadURL = getVariable("dynamic.download.url")
  else
    pDynDownloadURL = "dynamic_content/"
  end if
  if variableExists("dynamic.download.name.template") then
    pFurniCastNameTemplate = getVariable("dynamic.download.name.template")
  else
    pFurniCastNameTemplate = "hh_furni_xx_%typeid%.cct"
  end if
  if variableExists("sound.download.url") then
    pSoundDownloadUrl = getVariable("sound.download.url")
  else
    pSoundDownloadUrl = "sound/%typeid%.cct"
  end if
  pDownloadQueue = [:]
  pPriorityDownloadQueue = [:]
  pCurrentDownLoads = [:]
  pDownloadedAssets = [:]
  pFurniRevisionList = [:]
  pRevisionsReceived = 0
  pRevisionsLoading = 0
  pAliasList = [:]
  pAliasListReceived = 0
  pAliasListLoading = 0
  pBinCastName = "bin"
  pBypassList = value(getVariable("dyn.download.bypass.list", []))
end

on isAssetDownloaded me, tAssetId 
  repeat while pBypassList <= undefined
    tBypassItem = getAt(undefined, tAssetId)
    tBypassWildLength = tBypassItem.length
    tBypassItem = replaceChunks(tBypassItem, "?", "")
    if tAssetId = tBypassItem then
      return(1)
    end if
    if tAssetId starts tBypassItem and tAssetId.length = tBypassWildLength then
      return(1)
    end if
  end repeat
  tStatus = me.checkDownloadStatus(tAssetId)
  if pBypassList <> #downloaded then
    if pBypassList = #failed then
      return(1)
    else
      return(0)
    end if
  end if
end

on downloadCastDynamically me, tAssetId, tAssetType, tCallbackObjectID, tCallBackHandler, tPriorityDownload, tCallbackParams, tParentId 
  if tAssetId = "" or voidp(tAssetId) then
    error(me, "tAssetId was empty, returning with true just to prevent download sequence!", #downloadCastDynamically, #minor)
    return(1)
  end if
  tStatus = me.checkDownloadStatus(tAssetId)
  if tStatus <> #nodata then
    if tStatus <> #downloading then
      if tStatus = #inqueue then
        me.addToDownloadQueue(tAssetId, tCallbackObjectID, tCallBackHandler, tPriorityDownload, 0, tCallbackParams, tAssetType, tParentId)
        me.tryNextDownload()
        return(1)
      else
        if tStatus <> #downloaded then
          if tStatus = #failed then
            return(0)
          end if
          return(error(me, "Invalid status type found:" && tStatus, #downloadCastDynamically, #major))
        end if
      end if
    end if
  end if
end

on handleCompletedCastDownload me, tAssetId 
  tDownloadObj = pCurrentDownLoads.getAt(tAssetId)
  tCastName = tDownloadObj.getDownloadName()
  tCastNum = FindCastNumber(tCastName)
  if tCastNum = 0 then
    tDownloadObj.purgeCallbacks(0)
    pDownloadedAssets.setAt(tAssetId, #failed)
    pCurrentDownLoads.deleteProp(tAssetId)
    me.tryNextDownload()
    return(error(me, "Cast " & tCastName & " was not available", #handleCompletedCastDownload, #minor))
  end if
  me.acquireAssetsFromCast(tCastNum, tAssetId)
  tResetOk = getCastLoadManager().ResetOneDynamicCast(tCastNum)
  if not tResetOk then
    error(me, "Cast reset failed:" && tCastNum, #handleCompletedCastDownload, #major)
  end if
  pCurrentDownLoads.deleteProp(tAssetId)
  pDownloadedAssets.setAt(tAssetId, #downloaded)
  tDownloadObj.purgeCallbacks(1)
  me.tryNextDownload()
end

on checkDownloadStatus me, tAssetId 
  tDownloadStatus = pDownloadedAssets.getaProp(tAssetId)
  if tDownloadStatus <> void() then
    return(tDownloadStatus)
  else
    if pDownloadQueue.getaProp(tAssetId) <> void() then
      return(#inqueue)
    else
      if pPriorityDownloadQueue.getaProp(tAssetId) <> void() then
        return(#inqueue)
      else
        if pCurrentDownLoads.getaProp(tAssetId) <> void() then
          return(#downloading)
        end if
      end if
    end if
  end if
  return(#nodata)
end

on addToDownloadQueue me, tAssetId, tCallbackObjectID, tCallBackHandler, tPriorityDownload, tAllowIndexing, tCallbackParams, tAssetType, tParentId 
  if voidp(tAllowIndexing) then
    tAllowIndexing = 0
  end if
  tDownloadObj = void()
  if pDownloadQueue.getaProp(tAssetId) <> void() then
    tDownloadObj = pDownloadQueue.getaProp(tAssetId)
  else
    if pPriorityDownloadQueue.getaProp(tAssetId) <> void() then
      tDownloadObj = pPriorityDownloadQueue.getaProp(tAssetId)
    else
      if pCurrentDownLoads.getaProp(tAssetId) <> void() then
        tDownloadObj = pCurrentDownLoads.getaProp(tAssetId)
      else
        tDownloadObj = createObject("dyndownload-" & tAssetId, getClassVariable("dyn.download.instance"))
        if not tDownloadObj then
          error(me, "Could not create download object. Could it be a duplicate:" && tAssetId, #addToDownloadQueue, #major)
          return(0)
        end if
        tDownloadObj.setAssetId(tAssetId)
        tDownloadObj.setAssetType(tAssetType)
        tDownloadObj.setIndexing(tAllowIndexing)
        tDownloadObj.setParentId(tParentId)
        if tPriorityDownload then
          pPriorityDownloadQueue.addProp(tAssetId, tDownloadObj)
        else
          pDownloadQueue.addProp(tAssetId, tDownloadObj)
        end if
      end if
    end if
  end if
  tDownloadObj.addCallbackListener(tCallbackObjectID, tCallBackHandler, tCallbackParams)
end

on tryNextDownload me 
  if not pAliasListReceived then
    if not pAliasListLoading then
      pAliasList = [:]
      pAliasListLoading = 1
      tConn = getConnection(getVariableValue("connection.info.id"))
      tConn.send("GET_ALIAS_LIST")
    end if
    return(0)
  end if
  if not pRevisionsReceived then
    if not pRevisionsLoading then
      pFurniRevisionList = [:]
      pRevisionsLoading = 1
      getConnection(getVariableValue("connection.room.id")).send("GET_FURNI_REVISIONS")
    end if
    return(0)
  end if
  tMaxItemsInProcess = 1
  tDownloadObj = void()
  if pCurrentDownLoads.count >= tMaxItemsInProcess then
    return(0)
  end if
  if pPriorityDownloadQueue.count > 0 then
    tDownloadObj = getAt(pPriorityDownloadQueue, 1)
    tAssetId = tDownloadObj.getAssetId()
    pPriorityDownloadQueue.deleteProp(tAssetId)
  else
    if pDownloadQueue.count > 0 then
      tDownloadObj = getAt(pDownloadQueue, 1)
      tAssetId = tDownloadObj.getAssetId()
      pDownloadQueue.deleteProp(tAssetId)
    else
      return(0)
    end if
  end if
  if me.checkDownloadStatus(tAssetId) = #downloaded then
    tDownloadObj.purgeCallbacks(1)
    return(me.tryNextDownload())
  end if
  pCurrentDownLoads.addProp(tAssetId, tDownloadObj)
  tAliasedAssetId = tAssetId
  if not voidp(pAliasList.getaProp(tAssetId)) then
    tAliasedAssetId = pAliasList.getAt(tAssetId)
  end if
  tDownloadURL = pDynDownloadURL & pFurniCastNameTemplate
  if tDownloadObj.getAssetType() = #sound then
    tParentId = tDownloadObj.getParentId()
    if not voidp(tParentId) then
      if variableExists("dynamic.download.samples.template") then
        tDownloadURL = pDynDownloadURL & getVariable("dynamic.download.samples.template")
      end if
    end if
  end if
  tFixedAssetId = replaceChunks(tAliasedAssetId, " ", "_")
  tDownloadURL = replaceChunks(tDownloadURL, "%typeid%", tFixedAssetId)
  tRawAssetId = tAssetId
  if chars(tAssetId, 1, 2) = "s_" then
    tRawAssetId = chars(tAssetId, 3, tAssetId.length)
  end if
  if not voidp(tParentId) then
    tRevision = string(pFurniRevisionList.getAt(tParentId))
  else
    if not voidp(pFurniRevisionList.findPos(tRawAssetId)) then
      tRevision = string(pFurniRevisionList.getAt(tRawAssetId))
    else
      if tAssetId contains "poster" then
        tRevision = string(pFurniRevisionList.getAt("poster"))
      else
        tRevision = ""
      end if
    end if
  end if
  tDownloadURL = replaceChunks(tDownloadURL, "%revision%", tRevision)
  tDownloadObj.setDownloadName(tDownloadURL)
  tAllowIndexing = tDownloadObj.getIndexing()
  if variableExists("dynamic.download.delay") then
    tTimeout = getVariable("dynamic.download.delay")
    createTimeout("dynamicdelay" & the milliSeconds, tTimeout, #executeDownloadRequest, me.getID(), [tAssetId, tDownloadURL, tAllowIndexing], 1)
  else
    me.executeDownloadRequest([tAssetId, tDownloadURL, tAllowIndexing])
  end if
end

on executeDownloadRequest me, tParams 
  tAssetId = tParams.getAt(1)
  tDownloadURL = tParams.getAt(2)
  tAllowIndexing = tParams.getAt(3)
  tDownloadRefId = startCastLoad(tDownloadURL, 1, 1, tAllowIndexing)
  registerCastloadCallback(tDownloadRefId, #handleCompletedCastDownload, me.getID(), tAssetId)
end

on acquireAssetsFromCast me, tCastNum, tAssetId 
  if voidp(tAssetId) then
    tAssetId = ""
  end if
  tCast = castLib(tCastNum)
  if ilk(tCast) <> #castLib then
    error(me, "Download seems invalid, item is not a cast!", #acquireAssetsFromCast, #minor)
    return(0)
  end if
  tSavedPaletteRefs = [:]
  tFirst = 1
  tLast = the number of castMembers
  tDone = 0
  repeat while not tDone
    tDone = 1
    tCurrentLast = tLast
    tMemNo = tFirst
    repeat while tMemNo <= tCurrentLast
      tmember = member(tMemNo, tCast.number)
      tMemType = tmember.type
      tMemName = tmember.name
      if tCast.number = #bitmap then
        if member(tMemName, pBinCastName).name <> tMemName then
          if ilk(tmember.paletteRef) <> #symbol then
            tSourceMemName = tmember.name
            tAliasedMemName = me.doAliasReplacing(tSourceMemName, tAssetId)
            tAliasedMemName.setAt(tmember, paletteRef.name)
            tmember.paletteRef = #systemMac
          end if
          me.copyMemberToBin(tmember, tAssetId)
        end if
      else
        if tCast.number = #palette then
          if member(tMemName, pBinCastName).name <> tMemName then
            me.copyMemberToBin(tmember, void())
          end if
        else
          if tCast.number = #field then
            tSourceText = tmember.text
            tAliasedText = me.doAliasReplacing(tSourceText, tAssetId)
            tmember.text = tAliasedText
            if tMemName = "asset.index" then
              tClassesContainer = getObject(getVariable("room.classes.container"))
              i = 1
              repeat while i <= tmember.lineCount
                tLine = tmember.getProp(#line, i)
                if stringp(tLine) then
                  if tLine.length > 3 then
                    tLineData = value(tLine)
                    tAssetId = tLineData.getAt(#id)
                    pDownloadedAssets.setAt(tAssetId, #downloaded)
                    if offset("s_", tAssetId) = 1 then
                      tAssetId = tAssetId.getProp(#char, 3, tAssetId.length)
                    end if
                    tAssetClasses = tLineData.getAt(#classes)
                    tClassesContainer.set(tAssetId, tAssetClasses)
                  end if
                end if
                i = 1 + i
              end repeat
              exit repeat
            end if
            if tMemName = "memberalias.index" then
              if tMemNo = tLast then
                getResourceManager().readAliasIndexesFromField(tMemName, tCastNum)
              else
                tDone = 0
                tFirst = tMemNo
                tLast = tMemNo
              end if
            else
              if tMemName contains ".props" or tMemName contains ".data" then
                me.copyMemberToBin(tmember, tAssetId)
              end if
            end if
          else
            if tCast.number = #script then
              me.copyMemberToBin(tmember)
            else
              if tCast.number = #sound then
                me.copyMemberToBin(tmember)
              end if
            end if
          end if
        end if
      end if
      tMemNo = 1 + tMemNo
    end repeat
  end repeat
  i = 1
  repeat while i <= tSavedPaletteRefs.count
    tMemberName = tSavedPaletteRefs.getPropAt(i)
    tPaletteName = tSavedPaletteRefs.getAt(tMemberName)
    member(getmemnum(tMemberName)).paletteRef = member(getmemnum(tPaletteName))
    i = 1 + i
  end repeat
end

on copyMemberToBin me, tSourceMember, tTargetAssetClass 
  if voidp(tTargetAssetClass) then
    tTargetAssetClass = ""
  end if
  tAllowCopy = 1
  if tSourceMember.type = #empty then
    tAllowCopy = 0
  else
    if tSourceMember.type = #script then
      if tSourceMember.scriptType = #movie then
        tAllowCopy = 0
      end if
    end if
  end if
  if tAllowCopy then
    if getmemnum(tSourceMember.name) = 0 then
      tSourceMemName = tSourceMember.name
      tTargetMemName = me.doAliasReplacing(tSourceMemName, tTargetAssetClass)
      tTargetMemberNum = getmemnum(tTargetMemName)
      if tTargetMemberNum = 0 then
        tTargetMemberNum = createMember(tTargetMemName, tSourceMember.type, 0)
        if tTargetMemberNum = 0 then
          return(error(me, "Could not create a new member for copying: " & tTargetMemName, #copyMemberToBin, #major))
        end if
      end if
      tTargetMember = member(tTargetMemberNum)
      tTargetMember.media = tSourceMember.media
      if tSourceMember.type = #bitmap then
        if image.width = 0 then
          tTargetMember.image = tSourceMember.image
        end if
      end if
    end if
  end if
end

on doAliasReplacing me, tSourceString, tTargetAssetClass 
  tAliasedSTring = tSourceString
  if chars(tTargetAssetClass, 1, 2) = "s_" then
    tTargetAssetClass = chars(tTargetAssetClass, 3, tTargetAssetClass.length)
  end if
  if not voidp(pAliasList.getAt(tTargetAssetClass)) then
    tSourceAssetClass = pAliasList.getaProp(tTargetAssetClass)
    if not voidp(tSourceAssetClass) then
      tAliasedSTring = replaceChunks(tAliasedSTring, tSourceAssetClass, tTargetAssetClass)
    end if
  end if
  return(tAliasedSTring)
end

on setAssetAlias me, tOriginalClass, tAliasClass 
  if voidp(tOriginalClass) and voidp(tAliasClass) then
    pAliasListLoading = 0
    pAliasListReceived = 1
    return(1)
  end if
  pAliasList.setAt(tOriginalClass, tAliasClass)
  pAliasList.setAt("s_" & tOriginalClass, "s_" & tAliasClass)
end

on setFurniRevision me, tClass, tRevision, tIsFurni 
  if voidp(tClass) then
    pRevisionsReceived = 1
    pRevisionsLoading = 0
    me.tryNextDownload()
    return(1)
  end if
  tOffset = offset("*", tClass)
  if tOffset then
    tClass = tClass.getProp(#char, 1, tOffset - 1)
  end if
  if not voidp(pFurniRevisionList.getAt(tClass)) then
    pFurniRevisionList.setAt(tClass, max(pFurniRevisionList.getAt(tClass), tRevision))
  else
    pFurniRevisionList.setAt(tClass, tRevision)
  end if
  return(1)
end
