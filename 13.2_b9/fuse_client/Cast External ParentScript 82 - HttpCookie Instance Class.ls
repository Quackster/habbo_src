property pMUXtra, pServer, pPort, pDestination, pData, pMaxBytes, pCRLF, pNetDone, pNetResult, pNetError, pNetRequest, pUserAgent, pHttpVersion, pResponseCbHandler, pResponseCbObj, pCookies, pType, pStatus, pMemName, pMemNum, pCallBack, pRedirectNetID, pRedirectUrl, pRedirectType

on define me, tMemName, tdata
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata[#memNum]
  pType = tdata[#type]
  pCallBack = tdata[#callback]
  if voidp(tdata[#redirectType]) then
    pRedirectType = #follow
  else
    pRedirectType = tdata[#redirectType]
  end if
  tSeparatedURL = me.separateURL(tdata[#url])
  pServer = tSeparatedURL[#server]
  pDestination = tSeparatedURL[#destination]
  pPort = tSeparatedURL[#port]
  if voidp(pDestination) then
    pDestination = "/"
  end if
  if not (pDestination starts "/") then
    put "/" before pDestination
  end if
  if voidp(pPort) then
    pPort = 80
  end if
  pCRLF = numToChar(13) & numToChar(10)
  pVERSION = "0.1"
  pUserAgent = "HTTP-CLASS/" & pVERSION
  pHttpVersion = "1.1"
  pMaxBytes = 16 * 1024
  pData = [:]
  pNetDone = 0
  if pCookies = VOID then
    pCookies = [:]
  end if
  pRedirectNetID = VOID
  return me.sendRequest()
end

on separateURL me, tURL
  tUrlParts = [:]
  tURL = replaceChunks(tURL, "http://", EMPTY)
  tDestinationOffset = offset("/", tURL)
  tServerURL = chars(tURL, 1, tDestinationOffset - 1)
  tDestination = chars(tURL, tDestinationOffset, tURL.length)
  tPort = 80
  tServer = tServerURL
  if tServerURL contains ":" then
    tPortOffset = offset(":", tServerURL)
    tServer = chars(tServerURL, 1, tPortOffset - 1)
    tPort = value(chars(tServerURL, tPortOffset + 1, tServerURL.length))
  end if
  return [#server: tServer, #destination: tDestination, #port: tPort]
end

on addCallBack me, tMemName, tCallback
  if tMemName = pMemName then
    pCallBack = tCallback
    return 1
  else
    return 0
  end if
end

on getProperty me, tProp
  case tProp of
    #status:
      return pStatus
    #url:
      return pServer & pDestination
    #type:
      return pType
    #Percent:
      if pNetDone then
        return 100
      else
        return 0.0
      end if
    otherwise:
      return 0
  end case
end

on update me
  if pNetDone then
    if (pStatus = #error) or (pStatus = #LOADING) then
      pStatus = #complete
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      return 1
    end if
  end if
  if not voidp(pRedirectNetID) then
    if netDone(pRedirectNetID) then
      if not memberExists(pMemName) then
        createMember(pMemName, #bitmap)
      end if
      importFileInto(member(pMemName), pRedirectUrl, [#dither: 0, #trimWhiteSpace: 0])
      pNetDone = 1
      pRedirectNetID = VOID
    end if
  end if
  return 0
end

on sendRequest me
  pNetResult = VOID
  pNetDone = 0
  pNetError = 0
  pStatus = #LOADING
  pMUXtra = xtra("multiuser").new()
  pMUXtra.setNetBufferLimits(16 * 1024 * 2, pMaxBytes, 100)
  tErrCode = pMUXtra.setNetMessageHandler(#messageHandler, me)
  if tErrCode <> 0 then
    error(me, "Error with setNetMessageHandler", #sendRequest)
  end if
  tErrCode = pMUXtra.connectToNetServer("*", "*", pServer, pPort, "HTTP_CLASS", 1)
  if tErrCode <> 0 then
    error(me, "Error sending ConnectToNetServer to server", #sendRequest)
    pStatus = #error
    pNetDone = 1
    return 0
  end if
end

on getStoredCookies tDomain
  if voidp(tDomain) then
    tDomain = pServer
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "."
  tDomainItemCount = tDomain.item.count
  tDomain = tDomain.item[tDomainItemCount - 1] & tDomain.item[tDomainItemCount]
  the itemDelimiter = tDelim
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  tAllCookies = value(getPref(tCookiePrefLoc))
  if ilk(tAllCookies) <> #propList then
    tAllCookies = [:]
  end if
  tThisDomainCookies = tAllCookies[tDomain]
  if ilk(tThisDomainCookies) <> #propList then
    tThisDomainCookies = [:]
  end if
  tFlatCookieList = []
  repeat with tUniqueCookie in tThisDomainCookies
    tFlatCookieList.add(tUniqueCookie)
  end repeat
  return tFlatCookieList
end

on setStoredCookies tDomain, tNewCookies
  if voidp(tDomain) or voidp(tNewCookies) then
    return 0
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "."
  tDomainItemCount = tDomain.item.count
  tDomain = tDomain.item[tDomainItemCount - 1] & tDomain.item[tDomainItemCount]
  the itemDelimiter = tDelim
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  tAllCookies = value(getPref(tCookiePrefLoc))
  if ilk(tAllCookies) <> #propList then
    tAllCookies = [:]
  end if
  tThisDomainCookies = tAllCookies[tDomain]
  if ilk(tThisDomainCookies) <> #propList then
    tThisDomainCookies = [:]
  end if
  repeat with tNewCookie in tNewCookies
    tNewCookieID = tNewCookie[1]
    tThisDomainCookies[tNewCookieID] = tNewCookie
  end repeat
  tAllCookies[tDomain] = tThisDomainCookies
  setPref(tCookiePrefLoc, tAllCookies & EMPTY)
end

on createNetRequest me
  tCmd = EMPTY
  tHeaders = []
  tBody = EMPTY
  tHeaders.add("Host: " & pServer & ":" & pPort)
  tHeaders.add("User-Agent:" && pUserAgent)
  tHeaders.add("Accept: text/*")
  tHeaders.add("Accept-Charset: ISO-8859-1")
  pCookies = getStoredCookies(pServer)
  tCookieString = EMPTY
  repeat with tCookie in pCookies
    if pDestination starts tCookie["path"] then
      if tCookieString <> EMPTY then
        put "; " after tCookieString
      end if
      put tCookie["name"] & "=" & tCookie["value"] after tCookieString
    end if
  end repeat
  if tCookieString <> EMPTY then
    tHeaders.add("Cookie:" && tCookieString)
  end if
  tDestination = pDestination
  if count(pData) then
    put "?" & me.getDataString(pData) after tDestination
  end if
  tMethod = "GET"
  tCmd = tMethod && tDestination && "HTTP/" & pHttpVersion
  return ["cmd": tCmd, "headers": tHeaders, "body": tBody]
end

on messageHandler me
  tMsg = pMUXtra.getNetMessage()
  pNetError = tMsg.errorCode
  tSenderId = tMsg.senderID
  tSubject = tMsg.subject
  tContent = tMsg.content
  if not (pNetError = 0) then
    if (tSenderId = "System") and (tSubject = "ConnectionProblem") then
      nothing()
    else
      tErrStr = pMUXtra.getNetErrorString(pNetError)
      pNetDone = 1
      pStatus = #error
      me.clearMU()
    end if
    return 1
  end if
  if (tSenderId = "System") and (tSubject = "ConnectToNetServer") then
    me.handleHelloResponse(tMsg)
  else
    me.handleContentResponse(tMsg, tContent)
  end if
end

on handleHelloResponse me, tMsg
  pNetRequest = me.createNetRequest()
  tHttpStr = pNetRequest["cmd"] & pCRLF
  repeat with tHeader in pNetRequest["headers"]
    put tHeader & pCRLF after tHttpStr
  end repeat
  put pCRLF after tHttpStr
  put pNetRequest["body"] after tHttpStr
  pMUXtra.sendNetMessage("system", EMPTY, tHttpStr)
end

on handleContentResponse me, tMsg, tContent
  tFinished = 0
  if tContent starts "HTTP/" then
    pNetResult = me.parseResponse(tContent)
    tBody = pNetResult["body"]
    tNotChunkedResult = pNetResult["headers"]["Transfer-Encoding"] <> "chunked"
    tEndOfResult = tBody.char[tBody.length - 4..tBody.length] = ("0" & pCRLF & pCRLF)
    if tNotChunkedResult or tEndOfResult then
      tFinished = 1
    end if
    pNetResult["body"] = tBody
    tPos = pNetResult.headers.findPos("Set-Cookie")
    if not voidp(tPos) then
      repeat while 1
        pCookies.add(me.parseCookieString(pNetResult.headers[tPos]))
        tPos = tPos + 1
        if tPos > pNetResult.headers.count then
          exit repeat
        end if
        if pNetResult.headers.getPropAt(tPos) <> "Set-Cookie" then
          exit repeat
        end if
      end repeat
      setStoredCookies(pServer, pCookies)
    end if
  else
    if tContent.char[tContent.length - 4..tContent.length] = ("0" & pCRLF & pCRLF) then
      tContent = tContent.char[1..tContent.length - 7]
      tFinished = 1
    end if
    pNetResult["body"] = pNetResult["body"] & tContent
  end if
  if tFinished then
    if pNetResult["headers"]["Transfer-Encoding"] = "chunked" then
      pNetResult["body"] = me.parseRawBody(pNetResult["body"])
    end if
    tRedirectUrl = pNetResult["headers"]["Location"]
    if voidp(tRedirectUrl) then
      tmember = member(pMemName)
      if tmember.type <> #text then
        error(me, "Incompatible download type. Maybe not redirected.", #handleContentResponse)
      else
        member(pMemName).text = pNetResult["body"]
        pNetDone = 1
      end if
    else
      tCompleteUrl = tRedirectUrl
      if not (tRedirectUrl contains "http://") then
        if not (tRedirectUrl starts "/") then
          put "/" before tRedirectUrl
        end if
        tCompleteUrl = "http://" & pServer & tRedirectUrl
      end if
      if pRedirectType = #follow then
        if pType = #bitmap then
          pRedirectUrl = tCompleteUrl
          pRedirectNetID = preloadNetThing(tCompleteUrl)
        else
          if pType = #text then
            me.define(pMemName, [#url: tCompleteUrl, #memNum: pMemNum, #type: pType, #callback: pCallBack])
          end if
        end if
      else
        openNetPage(tCompleteUrl, "_new")
        pNetDone = 1
      end if
    end if
  end if
end

on clearMU me
  if objectp(pMUXtra) then
    tErrCode = pMUXtra.setNetMessageHandler(0, me)
    tErrCode = pMUXtra.setNetMessageHandler(0, me, "ConnectToNetServer")
  end if
  pMUXtra = VOID
end

on parseResponse me, tResponse
  tTemp = explode(tResponse, pCRLF & pCRLF, 2)
  tResponseHeaders = tTemp[1]
  tResponseBody = tTemp[2]
  tResponseHeaderLines = explode(tResponseHeaders, pCRLF)
  tHttpResponseLine = tResponseHeaderLines[1]
  tResponseCode = tHttpResponseLine
  tResponseCodeNum = integer(tResponseCode.word[2])
  tResponseHeaderArray = [:]
  repeat with i = 2 to tResponseHeaderLines.count
    tHeaderLine = tResponseHeaderLines[i]
    tTemp = explode(tHeaderLine, ": ", 2)
    tHeader = tTemp[1]
    tValue = tTemp[2]
    tResponseHeaderArray.addProp(tHeader, tValue)
  end repeat
  tResponseHeaderArray.sort()
  tReturnArr = [:]
  tReturnArr["status_code"] = tResponseCode
  tReturnArr["status_num"] = tResponseCodeNum
  tReturnArr["headers"] = tResponseHeaderArray
  tReturnArr["body"] = tResponseBody
  return tReturnArr
end

on parseRawBody me, tRawbody
  tBody = EMPTY
  repeat while 1
    tTemp = explode(tRawbody, pCRLF, 2)
    if tTemp.count < 2 then
      put tRawbody after tBody
      exit repeat
    end if
    tLen = me.hex2dec(tTemp[1])
    tRawbody = tTemp[2]
    put tRawbody.char[1..tLen] after tBody
    delete char 1 to tLen + 2 of tRawbody
  end repeat
  return tBody
end

on parseCookieString me, tStr
  tCookie = [:]
  tParts = explode(tStr, "; ")
  tTemp = explode(tParts[1], "=")
  tCookie["name"] = tTemp[1]
  tCookie["value"] = tTemp[2]
  repeat with i = 2 to tParts.count
    tTemp = explode(tParts[i], "=")
    if tTemp[1] = "path" then
      tCookie["path"] = tTemp[2]
    end if
  end repeat
  if voidp(tCookie["path"]) then
    tCookie["path"] = "/"
  end if
  return tCookie
end

on urlEncode me, tStr
  tEncodedStr = EMPTY
  tOkChars = "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  repeat with i = 1 to tStr.length
    tChar = tStr.char[i]
    if offset(tChar, tOkChars) then
      put tChar after tEncodedStr
      next repeat
    end if
    if tChar = SPACE then
      put "+" after tEncodedStr
      next repeat
    end if
    put "%" & rgb(charToNum(tChar), 0, 0).hexString().char[2..3] after tEncodedStr
  end repeat
  return tEncodedStr
end

on getDataString me, tdata
  tDataStr = EMPTY
  repeat with i = 1 to tdata.count
    put me.urlEncode(tdata.getPropAt(i)) & "=" & me.urlEncode(tdata[i]) after tDataStr
    if i < tdata.count then
      put "&" after tDataStr
    end if
  end repeat
  return tDataStr
end

on hex2dec me, tHex
  tCol = rgb(tHex)
  return (tCol.red * 65536) + (tCol.green * 256) + tCol.blue
end
