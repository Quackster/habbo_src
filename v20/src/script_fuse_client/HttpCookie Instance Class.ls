on define(me, tMemName, tdata)
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata.getAt(#memNum)
  pType = tdata.getAt(#type)
  pCallBack = tdata.getAt(#callback)
  if voidp(tdata.getAt(#redirectType)) then
    pRedirectType = #follow
  else
    pRedirectType = tdata.getAt(#redirectType)
  end if
  tSeparatedURL = me.separateURL(tdata.getAt(#url))
  pServer = tSeparatedURL.getAt(#server)
  pDestination = tSeparatedURL.getAt(#destination)
  pPort = tSeparatedURL.getAt(#port)
  if voidp(pDestination) then
    pDestination = "/"
  end if
  if not pDestination starts "/" then
  end if
  if voidp(pPort) then
    pPort = 80
  end if
  pCRLF = numToChar(13) & numToChar(10)
  pVERSION = "0.1"
  pUserAgent = "HTTP-CLASS/" & pVERSION
  pHttpVersion = "1.1"
  pMaxBytes = 16 * 1024
  pData = []
  pNetDone = 0
  if pCookies = void() then
    pCookies = []
  end if
  pRedirectNetID = void()
  return(me.sendRequest())
  exit
end

on separateURL(me, tURL)
  tUrlParts = []
  tURL = replaceChunks(tURL, "http://", "")
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
  return([#server:tServer, #destination:tDestination, #port:tPort])
  exit
end

on addCallBack(me, tMemName, tCallback)
  if tMemName = pMemName then
    pCallBack = tCallback
    return(1)
  else
    return(0)
  end if
  exit
end

on getProperty(me, tProp)
  if me = #status then
    return(pStatus)
  else
    if me = #url then
      return(pServer & pDestination)
    else
      if me = #type then
        return(pType)
      else
        if me = #Percent then
          if pNetDone then
            return(100)
          else
            return(0)
          end if
        else
          return(0)
        end if
      end if
    end if
  end if
  exit
end

on update(me)
  if pNetDone then
    if pStatus = #error or pStatus = #LOADING then
      pStatus = #complete
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      return(1)
    end if
  end if
  if not voidp(pRedirectNetID) then
    if netDone(pRedirectNetID) then
      if not memberExists(pMemName) then
        createMember(pMemName, #bitmap)
      end if
      importFileInto(member(pMemName), pRedirectUrl, [#dither:0, #trimWhiteSpace:0])
      pNetDone = 1
      pRedirectNetID = void()
    end if
  end if
  return(0)
  exit
end

on sendRequest(me)
  pNetResult = void()
  pNetDone = 0
  pNetError = 0
  pStatus = #LOADING
  pMUXtra = xtra("multiuser").new()
  pMUXtra.setNetBufferLimits(16 * 1024 * 2, pMaxBytes, 100)
  tErrCode = pMUXtra.setNetMessageHandler(#messageHandler, me)
  if tErrCode <> 0 then
    error(me, "Error with setNetMessageHandler", #sendRequest, #major)
  end if
  tErrCode = pMUXtra.connectToNetServer("*", "*", pServer, pPort, "HTTP_CLASS", 1)
  if tErrCode <> 0 then
    error(me, "Error sending ConnectToNetServer to server", #sendRequest, #major)
    pStatus = #error
    pNetDone = 1
    return(0)
  end if
  exit
end

on getStoredCookies(tDomain)
  if voidp(tDomain) then
    tDomain = pServer
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "."
  tDomainItemCount = tDomain.count(#item)
  tDomain = tDomain.getProp(#item, tDomainItemCount - 1) & tDomain.getProp(#item, tDomainItemCount)
  the itemDelimiter = tDelim
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  tAllCookies = value(getPref(tCookiePrefLoc))
  if ilk(tAllCookies) <> #propList then
    tAllCookies = []
  end if
  tThisDomainCookies = tAllCookies.getAt(tDomain)
  if ilk(tThisDomainCookies) <> #propList then
    tThisDomainCookies = []
  end if
  tFlatCookieList = []
  repeat while tDomain <= undefined
    tUniqueCookie = getAt(undefined, undefined)
    tFlatCookieList.add(tUniqueCookie)
  end repeat
  return(tFlatCookieList)
  exit
end

on setStoredCookies(tDomain, tNewCookies)
  if voidp(tDomain) or voidp(tNewCookies) then
    return(0)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "."
  tDomainItemCount = tDomain.count(#item)
  tDomain = tDomain.getProp(#item, tDomainItemCount - 1) & tDomain.getProp(#item, tDomainItemCount)
  the itemDelimiter = tDelim
  tCookiePrefLoc = getVariable("httpcookie.pref.name")
  tAllCookies = value(getPref(tCookiePrefLoc))
  if ilk(tAllCookies) <> #propList then
    tAllCookies = []
  end if
  tThisDomainCookies = tAllCookies.getAt(tDomain)
  if ilk(tThisDomainCookies) <> #propList then
    tThisDomainCookies = []
  end if
  repeat while tDomain <= undefined
    tNewCookie = getAt(undefined, tNewCookies)
    tNewCookieID = tNewCookie.getAt(1)
    tThisDomainCookies.setAt(tNewCookieID, tNewCookie)
  end repeat
  tAllCookies.setAt(tDomain, tThisDomainCookies)
  setPref(tCookiePrefLoc, tAllCookies & "")
  exit
end

on createNetRequest(me)
  tCmd = ""
  tHeaders = []
  tBody = ""
  tPort = ":" & pPort
  if tPort = ":80" then
    tPort = ""
  end if
  tHeaders.add("Host: " & pServer & tPort)
  tHeaders.add("User-Agent:" && pUserAgent)
  tHeaders.add("Accept: text/*")
  tHeaders.add("Accept-Charset: ISO-8859-1")
  pCookies = getStoredCookies(pServer)
  tCookieString = ""
  repeat while me <= undefined
    tCookie = getAt(undefined, undefined)
    if pDestination starts tCookie.getAt("path") then
      if tCookieString <> "" then
      end if
    end if
  end repeat
  if tCookieString <> "" then
    tHeaders.add("Cookie:" && tCookieString)
  end if
  tDestination = pDestination
  if count(pData) then
  end if
  tMethod = "GET"
  tCmd = tMethod && tDestination && "HTTP/" & pHttpVersion
  return(["cmd":tCmd, "headers":tHeaders, "body":tBody])
  exit
end

on messageHandler(me)
  tMsg = pMUXtra.getNetMessage()
  pNetError = tMsg.errorCode
  tSenderId = tMsg.senderID
  tSubject = tMsg.subject
  tContent = tMsg.content
  if not pNetError = 0 then
    if tSenderId = "System" and tSubject = "ConnectionProblem" then
      nothing()
    else
      tErrStr = pMUXtra.getNetErrorString(pNetError)
      pNetDone = 1
      pStatus = #error
      me.clearMU()
    end if
    return(1)
  end if
  if tSenderId = "System" and tSubject = "ConnectToNetServer" then
    me.handleHelloResponse(tMsg)
  else
    me.handleContentResponse(tMsg, tContent)
  end if
  exit
end

on handleHelloResponse(me, tMsg)
  pNetRequest = me.createNetRequest()
  tHttpStr = pNetRequest.getAt("cmd") & pCRLF
  repeat while me <= undefined
    tHeader = getAt(undefined, tMsg)
  end repeat
  pMUXtra.sendNetMessage("system", "", tHttpStr)
  exit
end

on handleContentResponse(me, tMsg, tContent)
  tFinished = 0
  if tContent starts "HTTP/" then
    pNetResult = me.parseResponse(tContent)
    tBody = pNetResult.getAt("body")
    tNotChunkedResult = pNetResult.getAt("headers").getAt("Transfer-Encoding") <> "chunked"
    tEndOfResult = tBody.getProp(#char, tBody.length - 4, tBody.length) = "0" & pCRLF & pCRLF
    if tNotChunkedResult or tEndOfResult then
      tFinished = 1
    end if
    pNetResult.setAt("body", tBody)
    tPos = pNetResult.findPos("Set-Cookie")
    if not voidp(tPos) then
      repeat while 1
        pCookies.add(me.parseCookieString(pNetResult.getProp(#headers, tPos)))
        tPos = tPos + 1
        if tPos > pNetResult.count(#headers) then
        else
          if pNetResult.getPropAt(tPos) <> "Set-Cookie" then
          else
          end if
        end if
      end repeat
      setStoredCookies(pServer, pCookies)
    end if
  else
    if tContent.getProp(#char, tContent.length - 4, tContent.length) = "0" & pCRLF & pCRLF then
      tContent = tContent.getProp(#char, 1, tContent.length - 7)
      tFinished = 1
    end if
    pNetResult.setAt("body", pNetResult.getAt("body") & tContent)
  end if
  if tFinished then
    if pNetResult.getAt("headers").getAt("Transfer-Encoding") = "chunked" then
      pNetResult.setAt("body", me.parseRawBody(pNetResult.getAt("body")))
    end if
    tRedirectUrl = pNetResult.getAt("headers").getAt("Location")
    if voidp(tRedirectUrl) then
      tmember = member(pMemName)
      if tmember.type <> #text then
        error(me, "Incompatible download type. Maybe not redirected.", #handleContentResponse, #minor)
      else
        member(pMemName).text = pNetResult.getAt("body")
        pNetDone = 1
      end if
    else
      tCompleteUrl = tRedirectUrl
      if not tRedirectUrl contains "http://" then
        if not tRedirectUrl starts "/" then
        end if
        tCompleteUrl = "http://" & pServer & tRedirectUrl
      end if
      if pRedirectType = #follow then
        tOwnDomain = getDomainPart(getMoviePath())
        tDownloadDomain = getDomainPart(tCompleteUrl)
        if tOwnDomain <> tDownloadDomain and tCompleteUrl contains "http://" or tCompleteUrl contains "https://" and not tCompleteUrl contains "://localhost" then
          tAllowCrossDomain = 0
          if variableExists("client.allow.cross.domain") then
            tAllowCrossDomain = getVariable("client.allow.cross.domain")
          end if
          tNotifyCrossDomain = 1
          if variableExists("client.notify.cross.domain") then
            tNotifyCrossDomain = value(getVariable("client.notify.cross.domain"))
          end if
          if tNotifyCrossDomain then
            executeMessage("crossDomainDownload", tCompleteUrl)
          end if
          if not tAllowCrossDomain then
            pNetDone = 1
            return(error(me, "Cross domain download not allowed:" && tCompleteUrl, #handleContentResponse, #minor))
          end if
        end if
        if pType = #bitmap then
          pRedirectUrl = tCompleteUrl
          pRedirectNetID = preloadNetThing(tCompleteUrl)
        else
          if pType = #text then
            me.define(pMemName, [#url:tCompleteUrl, #memNum:pMemNum, #type:pType, #callback:pCallBack])
          end if
        end if
      else
        openNetPage(tCompleteUrl, "_new")
        pNetDone = 1
      end if
    end if
  end if
  exit
end

on clearMU(me)
  if objectp(pMUXtra) then
    tErrCode = pMUXtra.setNetMessageHandler(0, me)
    tErrCode = pMUXtra.setNetMessageHandler(0, me, "ConnectToNetServer")
  end if
  pMUXtra = void()
  exit
end

on parseResponse(me, tResponse)
  tTemp = explode(tResponse, pCRLF & pCRLF, 2)
  tResponseHeaders = tTemp.getAt(1)
  tResponseBody = tTemp.getAt(2)
  tResponseHeaderLines = explode(tResponseHeaders, pCRLF)
  tHttpResponseLine = tResponseHeaderLines.getAt(1)
  tResponseCode = tHttpResponseLine
  tResponseCodeNum = integer(tResponseCode.getProp(#word, 2))
  tResponseHeaderArray = []
  i = 2
  repeat while i <= tResponseHeaderLines.count
    tHeaderLine = tResponseHeaderLines.getAt(i)
    tTemp = explode(tHeaderLine, ": ", 2)
    tHeader = tTemp.getAt(1)
    tValue = tTemp.getAt(2)
    tResponseHeaderArray.addProp(tHeader, tValue)
    i = 1 + i
  end repeat
  tResponseHeaderArray.sort()
  tReturnArr = []
  tReturnArr.setAt("status_code", tResponseCode)
  tReturnArr.setAt("status_num", tResponseCodeNum)
  tReturnArr.setAt("headers", tResponseHeaderArray)
  tReturnArr.setAt("body", tResponseBody)
  return(tReturnArr)
  exit
end

on parseRawBody(me, tRawbody)
  tBody = ""
  repeat while 1
    tTemp = explode(tRawbody, pCRLF, 2)
    if tTemp.count < 2 then
    else
      tLen = me.hex2dec(tTemp.getAt(1))
      tRawbody = tTemp.getAt(2)
    end if
  end repeat
  return(tBody)
  exit
end

on parseCookieString(me, tStr)
  tCookie = []
  tParts = explode(tStr, "; ")
  tTemp = explode(tParts.getAt(1), "=")
  tCookie.setAt("name", tTemp.getAt(1))
  tCookie.setAt("value", tTemp.getAt(2))
  i = 2
  repeat while i <= tParts.count
    tTemp = explode(tParts.getAt(i), "=")
    if tTemp.getAt(1) = "path" then
      tCookie.setAt("path", tTemp.getAt(2))
    end if
    i = 1 + i
  end repeat
  if voidp(tCookie.getAt("path")) then
    tCookie.setAt("path", "/")
  end if
  return(tCookie)
  exit
end

on getDataString(me, tdata)
  tDataStr = ""
  i = 1
  repeat while i <= tdata.count
    if i < tdata.count then
    end if
    i = 1 + i
  end repeat
  return(tDataStr)
  exit
end

on hex2dec(me, tHex)
  tCol = rgb(tHex)
  return(ERROR * 0 + tCol.green * 256 + tCol.blue)
  exit
end