on construct(me)
  pCatchFlag = 0
  pSavedHook = 0
  pToolTipAct = getIntVariable("tooltip.active", 0)
  pToolTipMem = void()
  pToolTipSpr = void()
  pCurrCursor = 0
  pLastCursor = 0
  pUniqueSeed = 0
  pProcessList = []
  pSessionHash = ""
  if _player <> void() then
    if _player.traceScript or _player.traceScript then
      return(0)
    end if
  end if
  _player.traceScript = 0
  _player.traceScript = 0
  return(1)
  exit
end

on deconstruct(me)
  if not voidp(pToolTipSpr) then
    releaseSprite(pToolTipSpr.spriteNum)
  end if
  if not voidp(pToolTipMem) then
    removeMember(pToolTipMem.name)
  end if
  return(1)
  exit
end

on try(me)
  pCatchFlag = 0
  pSavedHook = the alertHook
  the alertHook = me
  return(1)
  exit
end

on catch(me)
  the alertHook = pSavedHook
  return(pCatchFlag)
  return(0)
  exit
end

on callJavaScriptFunction(me, tCallString, tdata)
  startProfilingTask("Special Services::callJavascriptFunction")
  if the runMode = "Author" then
    return(0)
  end if
  script("JavaScript Proxy").callJavaScript("\"" & tCallString & "\"", "\"" & tdata & "\"")
  finishProfilingTask("Special Services::callJavascriptFunction")
  exit
end

on createToolTip(me, tText)
  if pToolTipAct then
    if voidp(pToolTipMem) then
      me.prepareToolTip()
    end if
    if voidp(pToolTipSpr) then
      me.prepareToolTip()
    end if
    if voidp(tText) then
      tText = "..."
    end if
    pToolTipSpr.visible = 0
    pToolTipMem.rect = rect(0, 0, length(tText.getProp(#line, 1)) * 8, 20)
    pToolTipMem.text = tText
    pToolTipID = the milliSeconds
    return(me.delay(pToolTipDel, #renderToolTip, pToolTipID))
  end if
  exit
end

on removeToolTip(me, tNextID)
  if pToolTipAct then
    if voidp(tNextID) or pToolTipID = tNextID then
      pToolTipID = void()
      pToolTipSpr.visible = 0
      return(1)
    end if
  end if
  exit
end

on renderToolTip(me, tNextID)
  if pToolTipAct then
    if tNextID <> pToolTipID or voidp(pToolTipID) then
      return(0)
    end if
    pToolTipSpr.loc = the mouseLoc + [-2, 15]
    pToolTipSpr.visible = 1
    me.delay(pToolTipDel * 2, #removeToolTip, pToolTipID)
  end if
  exit
end

on setcursor(me, ttype)
  if me = void() then
    ttype = 0
  else
    if me = #arrow then
      ttype = 0
    else
      if me = #ibeam then
        ttype = 1
      else
        if me = #crosshair then
          ttype = 2
        else
          if me = #crossbar then
            ttype = 3
          else
            if me = #timer then
              ttype = 4
            else
              if me = #previous then
                ttype = pLastCursor
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  cursor(ttype)
  pLastCursor = pCurrCursor
  pCurrCursor = ttype
  return(1)
  exit
end

on openNetPage(me, tURL_key, tTarget)
  if not stringp(tURL_key) then
    return(0)
  end if
  if textExists(tURL_key) then
    tURL = getText(tURL_key, tURL_key)
  else
    tURL = tURL_key
  end if
  tURL = me.getPredefinedURL(tURL)
  tResolvedTarget = void()
  tTargetIsPArent = 0
  if voidp(tTarget) then
    if variableExists("default.url.open.target") then
      tResolvedTarget = getVariable("default.url.open.target")
      tTargetIsPArent = 1
    else
      tResolvedTarget = "_new"
    end if
  else
    if tTarget = "self" or tTarget = "_self" then
      tResolvedTarget = void()
    else
      if tTarget = "_new" or tTarget = "new" then
        tResolvedTarget = "_new"
      else
        tResolvedTarget = tTarget
      end if
    end if
  end if
  tURLStart = tURL
  tURLEnd = ""
  if tURL contains "#" then
    tURLStart = chars(tURL, 1, offset("#", tURL) - 1)
    tURLEnd = chars(tURL, offset("#", tURL), tURL.length)
  end if
  if variableExists("client.http.request.sourceid") and tTargetIsPArent then
    tSourceParamTxt = getVariable("client.http.request.sourceid") & "=1"
    if not tURLStart contains tSourceParamTxt then
      if tURLStart contains "?" then
        tURLStart = tURLStart & "&" & tSourceParamTxt
      else
        tURLStart = tURLStart & "?" & tSourceParamTxt
      end if
    end if
  end if
  tURL = tURLStart & tURLEnd
  tURL = replaceChunks(tURL, "%random%", random(9999999999))
  gotoNetPage(tURL, tResolvedTarget)
  put("Open page:" && tURL && "target:" && tResolvedTarget)
  return(1)
  exit
end

on showLoadingBar(me, tLoadID, tProps)
  tObj = createObject(#random, getClassVariable("loading.bar.class"))
  if tObj = 0 then
    return(error(me, "Couldn't create loading bar instance!", #showLoadingBar, #major))
  end if
  if not tObj.define(tLoadID, tProps) then
    removeObject(tObj.getID())
    return(error(me, "Couldn't initialize loading bar instance!", #showLoadingBar, #major))
  end if
  return(tObj.getID())
  exit
end

on getUniqueID(me)
  pUniqueSeed = pUniqueSeed + 1
  return("uid:" & pUniqueSeed & ":" & the milliSeconds)
  exit
end

on setMachineId(me, tString)
  setPref(getVariable("pref.value.id"), tString)
  exit
end

on getMachineID(me)
  tStoredMachineID = string(getPref(getVariable("pref.value.id")))
  return(tStoredMachineID)
  exit
end

on getMoviePath(me)
  tVariableID = "system.v1"
  if not variableExists(tVariableID) then
    setVariable(tVariableID, obfuscate(the moviePath))
  end if
  return(deobfuscate(getVariable(tVariableID)))
  exit
end

on getDomainPart(me, tPath)
  if voidp(tPath) then
    return("")
  end if
  if chars(tPath, 1, 8) = "https://" then
    tPath = chars(tPath, 9, tPath.length)
  else
    if chars(tPath, 1, 7) = "http://" then
      tPath = chars(tPath, 8, tPath.length)
    end if
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tPath = tPath.getProp(#item, 1)
  the itemDelimiter = "."
  tMaxItemCount = 2
  if tPath contains ".co." then
    tMaxItemCount = tMaxItemCount + 1
  end if
  tPath = tPath.getProp(#item, tPath.count(#item) - tMaxItemCount + 1, tPath.count(#item))
  the itemDelimiter = ":"
  tPath = tPath.getProp(#item, 1)
  the itemDelimiter = tDelim
  return(tPath)
  exit
end

on getPredefinedURL(me, tURL)
  if tURL contains "http://%predefined%/" then
    if variableExists("url.prefix") then
      tReplace = "http://%predefined%"
      tPrefix = getVariable("url.prefix")
      if chars(tPrefix, tPrefix.length, tPrefix.length) = "/" then
        tReplace = "http://%predefined%/"
      end if
      tURL = replaceChunks(tURL, tReplace, tPrefix)
    else
      return(error(me, "URL prefix not defined, invalid link.", #getPredefinedURL, #minor))
    end if
  end if
  return(tURL)
  exit
end

on getExtVarPath(me)
  tVariableID = "system.v2"
  if not variableExists(tVariableID) then
    return(getVariableManager().GET("external.variables.txt"))
  end if
  return(deobfuscate(getVariable(tVariableID)))
  exit
end

on sendProcessTracking(me, tStepValue)
  startProfilingTask("Special Services::sendProcessTracking")
  pProcessList.add(tStepValue)
  if pProcessList.count > 25 then
    pProcessList.deleteAt(1)
  end if
  if the runMode contains "Author" then
  end if
  if variableExists("processlog.url") then
    tReportURL = string(getVariable("processlog.url"))
    if tReportURL = "javascript" then
      if not memberExists("javascriptLog") then
        return(error("JavascriptLog script not found."))
      end if
      tJsHandler = script("javascriptLog").newJavaScriptLog()
      if objectp(tJsHandler) then
        tJsHandler.call(tStepValue)
      end if
    else
      if tReportURL <> "" and tReportURL <> void() then
        tParams = ["step":tStepValue, "account_id":getVariable("account_id")]
        postNetText(tReportURL, tParams)
      end if
    end if
  end if
  finishProfilingTask("Special Services::sendProcessTracking")
  exit
end

on getProcessTrackingList(me)
  return(pProcessList)
  exit
end

on secretDecode(me, tKey)
  tLength = tKey.length
  if tLength mod 2 = 1 then
    tLength = tLength - 1
  end if
  tTable = tKey.getProp(#char, 1, tKey.length / 2)
  tKey = tKey.getProp(#char, 1 + tKey.length / 2, tLength)
  tCheckSum = 0
  i = 1
  repeat while i <= tKey.length
    c = tKey.getProp(#char, i)
    a = offset(c, tTable) - 1
    if a mod 2 = 0 then
      a = a * 2
    end if
    if i - 1 mod 3 = 0 then
      a = a * 3
    end if
    if a < 0 then
      a = tKey.length mod 2
    end if
    tCheckSum = tCheckSum + a
    tCheckSum = bitXor(tCheckSum, a * power(2, i - 1 mod 3 * 8))
    i = 1 + i
  end repeat
  return(tCheckSum)
  exit
end

on readValueFromField(me, tField, tDelimiter, tSearchedKey)
  tStr = field(0)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      if tProp = tSearchedKey then
        if not tValue contains space() and integerp(integer(tValue)) then
          if length(string(integer(tValue))) = length(tValue) then
            tValue = integer(tValue)
          end if
        else
          if floatp(float(tValue)) then
            tValue = float(tValue)
          end if
        end if
        if stringp(tValue) then
          j = 1
          repeat while j <= length(tValue)
            j = 1 + j
          end repeat
        end if
        the itemDelimiter = tDelim
        return(tValue)
      end if
    end if
    the itemDelimiter = tDelimiter
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(0)
  exit
end

on addRandomParamToURL(me, tURL)
  tRandomParamName = "randp"
  tSeparator = "?"
  if tURL contains "?" then
    tSeparator = "&"
  end if
  tURL = tURL & tSeparator & tRandomParamName & random(999) & "=1"
  return(tURL)
  exit
end

on checkForXtra(me, tXtraName)
  tList = the xtraList
  repeat while me <= undefined
    tXtra = getAt(undefined, tXtraName)
    tXtraListName = ""
    if not voidp(tXtra.getAt(#name)) then
      tXtraListName = tXtra.getAt(#name)
    else
      if not voidp(tXtra.getAt(#fileName)) then
        tXtraListName = tXtra.getAt(#fileName)
      end if
    end if
    if tXtraListName <> "" then
      if tXtraListName contains tXtraName then
        return(1)
      end if
    end if
  end repeat
  return(0)
  exit
end

on print(me, tObj, tMsg)
  tObj = string(tObj)
  tObj = tObj.getProp(#word, 2, tObj.count(#word) - 2)
  tObj = tObj.getProp(#char, 2, length(tObj))
  put("Print:" & "\r" & "\t" && "Object: " && tObj & "\r" & "\t" && "Message:" && tMsg)
  exit
end

on generateMachineId(me, tMaxLength)
  tWhiteList = string(getVariable("machine.id.white.list"))
  tRawMachineId = string(the milliSeconds) & string(the time) & string(the date)
  tMachineID = ""
  tCharNo = 1
  repeat while tCharNo <= tRawMachineId.length
    tChar = chars(tRawMachineId, tCharNo, tCharNo)
    if tWhiteList contains tChar then
      tMachineID = tMachineID & tChar
    end if
    tCharNo = 1 + tCharNo
  end repeat
  tMachineID = replaceChunks(tMachineID, "AM", "")
  tMachineID = replaceChunks(tMachineID, "PM", "")
  tMachineID = replaceChunks(tMachineID, "am", "")
  tMachineID = replaceChunks(tMachineID, "pm", "")
  tMaxLength = getVariable("machine.id.max.length")
  tMachineID = chars(tMachineID, 1, tMaxLength)
  return(tMachineID)
  exit
end

on generateMachineId_(me, tMaxLength)
  tMachineID = string(the milliSeconds) & string(the time) & string(the date)
  tLocaleDelimiters = [".", ",", ":", ";", "/", "\\", "am", "pm", " ", "-", "AM", "PM", numToChar(10), numToChar(13)]
  repeat while me <= undefined
    tDelimiter = getAt(undefined, tMaxLength)
    tMachineID = replaceChunks(tMachineID, tDelimiter, "")
  end repeat
  tMachineID = chars(tMachineID, 1, tMaxLength)
  return(tMachineID)
  exit
end

on setExtVarPath(me, tURL)
  return(setVariable("system.v2", obfuscate(tURL & "&hash=" & pSessionHash)))
  exit
end

on setSessionHash(me, tHash)
  pSessionHash = tHash
  exit
end

on getSessionHash(me)
  return(pSessionHash)
  exit
end

on prepareToolTip(me)
  if pToolTipAct then
    tFontStruct = getStructVariable("struct.font.tooltip")
    pToolTipMem = member(createMember("ToolTip Text", #field))
    pToolTipMem.boxType = #adjust
    pToolTipMem.wordWrap = 0
    pToolTipMem.rect = rect(0, 0, 10, 20)
    pToolTipMem.border = 1
    pToolTipMem.margin = 4
    pToolTipMem.alignment = "center"
    pToolTipMem.font = tFontStruct.getaProp(#font)
    pToolTipMem.fontSize = tFontStruct.getaProp(#fontSize)
    pToolTipMem.color = tFontStruct.getaProp(#color)
    pToolTipSpr = sprite(reserveSprite(me.getID()))
    pToolTipSpr.member = pToolTipMem
    pToolTipSpr.visible = 0
    ERROR.locZ = 0
    pToolTipID = void()
    pToolTipDel = getIntVariable("tooltip.delay", 2000)
  end if
  exit
end

on alertHook(me)
  pCatchFlag = 1
  the alertHook = pSavedHook
  return(1)
  exit
end

on getReceipt(me, tStamp)
  tReceipt = []
  tCharNo = 1
  repeat while tCharNo <= tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tReceipt.setAt(tCharNo, tChar)
    tCharNo = 1 + tCharNo
  end repeat
  return(tReceipt)
  exit
end

on getClientUpTime(me)
  tTimeNow = the long time
  tDateNow = the date
  if not objectExists(#session) then
    return(0)
  end if
  tTimeStart = getObject(#session).GET("client_starttime")
  tDateStart = getObject(#session).GET("client_startdate")
  tSeconds = 0
  tTimeDelimiter = me.getDelimiter(tTimeNow)
  if tDateNow <> tDateStart then
    tDays = 1
    tSeconds = tDays * 24 * 60 * 60 + me.calculateTimeDifference(tTimeStart, tTimeNow, tTimeDelimiter)
  else
    tSeconds = me.calculateTimeDifference(tTimeStart, tTimeNow, tTimeDelimiter)
  end if
  return(tSeconds)
  exit
end

on calculateTimeDifference(me, a_from, a_to, a_delimiter)
  tItemDeLim = the itemDelimiter
  the itemDelimiter = a_delimiter
  tHours = integer(a_to.getProp(#item, 1)) - integer(a_from.getProp(#item, 1))
  tMinutes = integer(a_to.getProp(#item, 2)) - integer(a_from.getProp(#item, 2))
  tSeconds = integer(a_to.getProp(#item, 3)) - integer(a_from.getProp(#item, 3))
  tAmPmMod = 0
  if a_from contains "am" or a_from contains "pm" then
    if a_from contains "am" and a_to contains "pm" then
      tAmPmMod = 12 * 60 * 60
    end if
    if a_to contains "am" and a_from contains "pm" then
      tAmPmMod = 12 * 60 * 60
    end if
  end if
  the itemDelimiter = tItemDeLim
  return(tHours * 60 * 60 + tMinutes * 60 + tSeconds + tAmPmMod)
  exit
end

on getDelimiter(me, a_string)
  tLocaleDelimiters = [".", ",", ":", ";", "/", "\\", " ", "-", numToChar(10), numToChar(13)]
  i = 1
  repeat while i <= tLocaleDelimiters.count
    tOffset = offset(tLocaleDelimiters.getAt(i), a_string)
    if tOffset > 0 and tOffset < 5 then
      temp = tLocaleDelimiters.duplicate().getAt(i)
      return(temp)
    end if
    i = 1 + i
  end repeat
  return(":")
  exit
end

on getValueByType(me, tContent, tExpectedType)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tReturnValue = void()
  if me = #string then
    tReturnValue = string(tContent)
  else
    if me = #integer then
      tReturnValue = integer(tContent)
    else
      if me = #symbol then
        tReturnValue = symbol(string(tContent))
      else
        if me = #list then
          tContentStr = string(tContent)
          if chars(tContentStr, 1, 1) <> "[" then
            return([])
          end if
          if chars(tContentStr, tContentStr.length, tContentStr.length) <> "]" then
            return([])
          end if
          if offset("\r", tContentStr) > 1 then
            return([])
          end if
          tReturnValue = value(tContent)
        else
          if me = #propList then
            tContentStr = string(tContent)
            if chars(tContentStr, 1, 1) <> "[" then
              return([])
            end if
            if chars(tContentStr, tContentStr.length, tContentStr.length) <> "]" then
              return([])
            end if
            if offset("\r", tContentStr) > 1 then
              return([])
            end if
            if offset(":", tContentStr) = 0 then
              return([])
            end if
            tReturnValue = value(tContent)
          else
          end if
        end if
      end if
    end if
  end if
  return(tReturnValue)
  exit
end

on handlers()
  return([])
  exit
end