property pDecoder, pToolTipSpr, pToolTipMem, pSavedHook, pCatchFlag, pToolTipAct, pToolTipDel, pToolTipID, pLastCursor, pCurrCursor, pUniqueSeed

on construct me 
  pCatchFlag = 0
  pSavedHook = 0
  pToolTipAct = getIntVariable("tooltip.active", 0)
  pToolTipMem = void()
  pToolTipSpr = void()
  pCurrCursor = 0
  pLastCursor = 0
  pUniqueSeed = 0
  pDecoder = createObject(#temp, getClassVariable("connection.decoder.class"))
  pDecoder.setKey("sulake1Unique2Key3Generator")
  return(1)
end

on deconstruct me 
  if not voidp(pToolTipSpr) then
    releaseSprite(pToolTipSpr.spriteNum)
  end if
  if not voidp(pToolTipMem) then
    removeMember(pToolTipMem.name)
  end if
  pDecoder = void()
  return(1)
end

on try me 
  pCatchFlag = 0
  pSavedHook = the alertHook
  the alertHook = me
  return(1)
end

on catch me 
  the alertHook = pSavedHook
  return(pCatchFlag)
  return(0)
end

on createToolTip me, tText 
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
end

on removeToolTip me, tNextID 
  if pToolTipAct then
    if voidp(tNextID) or pToolTipID = tNextID then
      pToolTipID = void()
      pToolTipSpr.visible = 0
      return(1)
    end if
  end if
end

on renderToolTip me, tNextID 
  if pToolTipAct then
    if tNextID <> pToolTipID or voidp(pToolTipID) then
      return(0)
    end if
    pToolTipSpr.loc = the mouseLoc + [-2, 15]
    pToolTipSpr.visible = 1
    me.delay(pToolTipDel * 2, #removeToolTip, pToolTipID)
  end if
end

on setcursor me, ttype 
  if ttype = void() then
    ttype = 0
  else
    if ttype = #arrow then
      ttype = 0
    else
      if ttype = #ibeam then
        ttype = 1
      else
        if ttype = #crosshair then
          ttype = 2
        else
          if ttype = #crossbar then
            ttype = 3
          else
            if ttype = #timer then
              ttype = 4
            else
              if ttype = #previous then
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
end

on openNetPage me, tURL_key, tTarget 
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
  if variableExists("client.http.request.sourceid") and tTargetIsPArent then
    tSourceParamTxt = getVariable("client.http.request.sourceid") & "=1"
    if not tURL contains tSourceParamTxt then
      if tURL contains "?" then
        tURL = tURL & "&" & tSourceParamTxt
      else
        tURL = tURL & "?" & tSourceParamTxt
      end if
    end if
  end if
  gotoNetPage(tURL, tResolvedTarget)
  put("Open page:" && tURL && "target:" && tResolvedTarget)
  return(1)
end

on showLoadingBar me, tLoadID, tProps 
  tObj = createObject(#random, getClassVariable("loading.bar.class"))
  if tObj = 0 then
    return(error(me, "Couldn't create loading bar instance!", #showLoadingBar, #major))
  end if
  if not tObj.define(tLoadID, tProps) then
    removeObject(tObj.getID())
    return(error(me, "Couldn't initialize loading bar instance!", #showLoadingBar, #major))
  end if
  return(tObj.getID())
end

on getUniqueID me 
  pUniqueSeed = pUniqueSeed + 1
  return("uid:" & pUniqueSeed & ":" & the milliSeconds)
end

on getMachineID me 
  tMachineID = string(getPref(getVariable("pref.value.id")))
  tMaxLength = 24
  tMinLength = 10
  if chars(tMachineID, 1, 1) = "#" then
    tMachineID = chars(tMachineID, 2, tMachineID.length)
  else
    tMachineID = me.generateMachineId(tMaxLength)
    setPref(getVariable("pref.value.id"), "#" & tMachineID)
  end if
  return(tMachineID)
end

on getMoviePath me 
  tVariableID = "system.v1"
  if not variableExists(tVariableID) then
    setVariable(tVariableID, obfuscate(the moviePath))
  end if
  return(deobfuscate(getVariable(tVariableID)))
end

on getPredefinedURL me, tURL 
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
end

on getExtVarPath me 
  tVariableID = "system.v2"
  if not variableExists(tVariableID) then
    return(getVariableManager().GET("external.variables.txt"))
  end if
  return(deobfuscate(getVariable(tVariableID)))
end

on secretDecode me, tKey 
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
end

on readValueFromField me, tField, tDelimiter, tSearchedKey 
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
            if tField = 228 then
            else
              if tField = 246 then
              end if
            end if
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
end

on addRandomParamToURL me, tURL 
  tRandomParamName = "randp"
  tSeparator = "?"
  if tURL contains "?" then
    tSeparator = "&"
  end if
  tURL = tURL & tSeparator & tRandomParamName & random(999) & "=1"
  return(tURL)
end

on print me, tObj, tMsg 
  tObj = string(tObj)
  tObj = tObj.getProp(#word, 2, tObj.count(#word) - 2)
  tObj = tObj.getProp(#char, 2, length(tObj))
  put("Print:" & "\r" & "\t" && "Object: " && tObj & "\r" & "\t" && "Message:" && tMsg)
end

on generateMachineId me, tMaxLength 
  tMachineID = string(the milliSeconds) & string(the time) & string(the date)
  tLocaleDelimiters = [".", ",", ":", ";", "/", "\\", "am", "pm", " ", "-", "AM", "PM"]
  repeat while tLocaleDelimiters <= undefined
    tDelimiter = getAt(undefined, tMaxLength)
    tMachineID = replaceChunks(tMachineID, tDelimiter, "")
  end repeat
  tMachineID = chars(tMachineID, 1, tMaxLength)
  return(tMachineID)
end

on setExtVarPath me, tURL 
  return(setVariable("system.v2", obfuscate(tURL)))
end

on prepareToolTip me 
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
    pToolTipSpr.locZ = 200000000
    pToolTipID = void()
    pToolTipDel = getIntVariable("tooltip.delay", 2000)
  end if
end

on alertHook me 
  pCatchFlag = 1
  the alertHook = pSavedHook
  return(1)
end

on getReceipt me, tStamp 
  tReceipt = []
  tCharNo = 1
  repeat while tCharNo <= tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = tChar * tCharNo + 309203
    tReceipt.setAt(tCharNo, tChar)
    tCharNo = 1 + tCharNo
  end repeat
  return(tReceipt)
end
