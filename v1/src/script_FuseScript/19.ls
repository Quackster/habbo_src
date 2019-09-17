on stopMovie  
  gmemnamedb = void()
end

on idle  
  if the ticks - gLastBalloon > 650 then
    gLastBalloon = the ticks
    balloonsUp()
  end if
end

on checkStatusOk  
  if the ticks - lastStatusOk > 60 then
    sendEPFuseMsg("STATUSOK")
  end if
end

on LogonEnterpriseServer  
  gConnectionsSecured = 0
  gConnectionShouldBeKilled = 0
  if objectp(gConnectionInstance) then
    errCode = setNetMessageHandler(gConnectionInstance, 0, 0)
  end if
  gConnectionInstance = 0
  gConnectionInstance = new(xtra("Multiuser"))
  errCode = setNetMessageHandler(gConnectionInstance, #EPDefaultMessageHandler, script("Main Script"))
  if errCode = 0 then
    gConnectionOk = 0
    hostname = NULL
    hostport = integer()
    put(hostname, hostport)
    connectToNetServer(gConnectionInstance, "*", "*", hostname, hostport, "*", 1)
    put("Message")
  else
    ShowAlert("Creation of callback failed" & errCode)
  end if
end

on Logon  
  gConnectionsSecured = 0
  gConnectionShouldBeKilled = 0
  if objectp(gConnectionInstance) then
    errCode = setNetMessageHandler(gConnectionInstance, 0, 0)
  end if
  gConnectionInstance = 0
  lastContent = void()
  gConnectionInstance = new(xtra("Multiuser"))
  put(gConnectionInstance)
  errCode = setNetMessageHandler(gConnectionInstance, #DefaultMessageHandler, script("Main Script"))
  if errCode = 0 then
    gConnectionOk = 0
    hostname = gChosenUnitIp
    hostport = gChosenUnitPort
    put("Hos:" && hostname, hostport)
    connectToNetServer(gConnectionInstance, "*", "*", hostname, hostport, "*", 1)
  else
    ShowAlert("Creation of callback failed" & errCode)
  end if
end

on sendFuseMsg s 
  if gConnectionOk = 1 and objectp(gConnectionInstance) then
    s = stringReplace(s, "�", "&auml;")
    s = stringReplace(s, "�", "&ouml;")
    len = "" & s.length
    repeat while len.length < 4
      len = len & " "
    end repeat
    if gKryptausOn = 1 and objectp(RC4) then
      tMsg = RC4.encipher(len & s)
    else
      tMsg = len & s
    end if
    sendNetMessage(gConnectionInstance, 0, 0, tMsg)
  else
    put("connection not ready!")
  end if
end

on fuseLogin user, password, noDoor 
  if voidp(gDoor) then
    gDoor = 0
  end if
  if noDoor <> 1 then
    sendFuseMsg("LOGIN" && user && password && gDoor)
  else
    sendFuseMsg("LOGIN" && user && password)
  end if
end

on fuseRegister update 
  if field(0).length = 0 then
    ShowAlert("NoNameSet")
    goToFrame("regist")
    return()
  end if
  phoneN = fieldOrEmpty("phonenumber")
  gPhonenumberOk = 0
  if phoneN > 7 then
    gPhonenumberOk = 1
  end if
  s = ""
  s = "charactername_field" & field(0) & "\r"
  s = s & "password=" & fieldOrEmpty("password_field") & "\r"
  s = s & "email=" & fieldOrEmpty("email_field") & "\r"
  s = s & "figure=" & toOneLine(fieldOrEmpty("figure_field")) & "\r"
  s = s & "directMail=" & fieldOrEmpty("can_spam_field") & "\r"
  s = s & "birthday=" & fieldOrEmpty("birthday_field") & "\r"
  s = s & "phonenumber=" & fieldOrEmpty("phonenumber") & "\r"
  s = s & "customData=" & fieldOrEmpty("persistantmessage_field") & "\r"
  s = s & "has_read_agreement=" & fieldOrEmpty("Agreement_field") & "\r"
  s = s & "sex=" & fieldOrEmpty("charactersex_field") & "\r"
  s = s & "country=" & fieldOrEmpty("countryname") & "\r"
  gMySex = member("charactersex_field").text
  if the movieName contains "cr_entry" then
    s = s & "crossroads=1" & "\r"
  end if
  if voidp(update) or update = 0 then
    sendEPFuseMsg("REGISTER" && s)
  else
    sendEPFuseMsg("UPDATE" && s)
  end if
end

on toOneLine fcont 
  put(fcont && "<-- FCONT ORIGINAL")
  tmp = ""
  put(the number of line in fcont && "<--- NUMBER OF LINES")
  c = 1
  repeat while c <= the number of line in fcont
    tmp = tmp & fcont.getProp(#line, c)
    c = 1 + c
  end repeat
  put(fcont && "<--- FCONT")
  put(tmp && "<--- TMP")
  return(tmp)
end

on fieldOrEmpty fname 
  if sprite(0).number < 1 then
    return("")
  else
    return(field(0))
  end if
end

on fuseRetrieveInfo user, password 
  sendEPFuseMsg("INFORETRIEVE" && user && password)
end

on EnterpriseMessagehandler  
  DefaultMessageHandler()
end

on DefaultMessageHandler  
  if gConnectionInstance = 0 then
    return()
  end if
  newMessage = getNetMessage(gConnectionInstance)
  errCode = getaProp(newMessage, #errorCode)
  content = getaProp(newMessage, #content)
  gConnectionOk = 1
  if errCode <> 0 then
    goToHotel()
    return()
  end if
  if stringp(content) then
    if not content contains "##" then
      if voidp(lastContent) then
        lastContent = ""
      end if
      lastContent = lastContent & content
      return()
    end if
    if not voidp(lastContent) then
      content = lastContent & content
    end if
    contentChunk = ""
    contentArray = []
    the itemDelimiter = "##"
    b = 0
    if not content.char[content.length - 2..content.length] contains "##" then
      b = 1
      put("last item not ##")
      put(content.char[content.length - 2..content.length])
    end if
    lastContent = ""
    n = the number of item in content
    i = 1
    repeat while i <= n
      if i < n or b = 0 then
        add(contentArray, content.item[i])
      else
        if b = 1 and i = n then
          lastContent = content.item[i]
        end if
      end if
      i = 1 + i
    end repeat
    the itemDelimiter = ","
    i = 1
    repeat while i <= count(contentArray)
      handleMessageContent(getAt(contentArray, i))
      if gConnectionShouldBeKilled = 1 then
        return()
      end if
      i = 1 + i
    end repeat
  end if
end

on moveUser user, currentMobilX, currentMobilY, moveToMobilX, moveToMobilY 
  sendSprite(getUserSprite(gAvatarManager, user), #updateposition, user, currentMobilX, currentMobilY, moveToMobilX, moveToMobilY)
end

on updateChatWindow user, Message 
  sendSprite(84, #addLine, user, Message)
  createBalloon(user, Message)
end

on createAvatar user, figure, locX, locY, locHeight, Custom, custom2 
  createFuseObject(user, getPlayerClass(), figure, locX, locY, locHeight, [1, 1, 1], void(), Custom, custom2)
end

on handleMessageContent content 
  if not stringp(content) or content.length <= 1 then
    return()
  end if
  firstline = content.line[1]
  if firstline contains "STATUS" then
    st = the ticks
    if voidp(gLastStatusOK) or the ticks - gLastStatusOK > 25 * 60 then
      sendFuseMsg("STATUSOK")
      gLastStatusOK = the ticks
    end if
    i = 2
    repeat while i <= the number of line in content
      the itemDelimiter = "/"
      ln = content.line[i]
      if ln.length > 2 then
        if not ln.char[1] = "*" then
          itemsCount = the number of item in ln
          user = doSpecialCharConversion(ln.word[1])
          locParam = ln.word[2]
          the itemDelimiter = ","
          currentMobilX = integer(locParam.item[1])
          currentMobilY = integer(locParam.item[2])
          currentMobilHeight = integer(locParam.item[3])
          dirHead = integer(locParam.item[4])
          dirBody = integer(locParam.item[5])
          moved = 0
          objectSpr = getObjectSprite(user)
          if objectSpr > 0 then
            sendSprite(objectSpr, #initiateForSync)
            if not voidp(currentMobilX) and not voidp(currentMobilY) then
              sendSprite(objectSpr, #setLocAndDir, currentMobilX, currentMobilY, currentMobilHeight, dirHead, dirBody)
            end if
            j = 2
            repeat while j <= itemsCount
              the itemDelimiter = "/"
              parseItem = ln.item[j]
              sendSprite(objectSpr, symbol("fuseAction_" & parseItem.word[1]), parseItem)
              if gConnectionShouldBeKilled = 1 then
                return()
              end if
              j = 1 + j
            end repeat
            exit repeat
          end if
          put("STATUS for nonexistent user!", user)
        else
          handleActiveObjects(ln)
        end if
      end if
      i = 1 + i
    end repeat
    if objectp(hiliter) then
      hiliteExitframe(hiliter)
    end if
  else
    if firstline contains "CHAT" then
      user = content.word[1]
      Message = content.word[2..the number of word in content.line[2]]
      createBalloon(user, Message, #normal)
    else
      if firstline contains "SHOUT" then
        user = content.word[1]
        Message = content.word[2..the number of word in content.line[2]]
        createBalloon(user, Message, #shout)
      else
        if firstline contains "WHISPER" then
          user = content.word[1]
          Message = content.word[2..the number of word in content.line[2]]
          createBalloon(user, Message, #whisper)
        else
          if firstline contains "LOGOUT" then
            userName = doSpecialCharConversion(content.word[1])
            put("LOGOUT", userName, getObjectSprite(userName))
            put("before", availablePuppetSpr.count)
            sendSprite(getObjectSprite(userName), #die)
            put("after", availablePuppetSpr.count)
          else
            if firstline contains "HELLO" then
              put(firstline)
              gKryptausOn = 0
              sendFuseMsg("versionid" && field(0))
              sendFuseMsg("CLIENTIP" && getNetAddressCookie(gConnectionInstance, 1))
            else
              if firstline contains "ENCRYPTION_ON" then
                gKryptausOn = #waiting
              else
                if firstline contains "ENCRYPTION_OFF" then
                  gKryptausOn = 0
                else
                  if firstline contains "SECRET_KEY" then
                    decodedKey = secretDecode(content.line[2])
                    RC4 = new(script("RC4"))
                    RC4.setKey(decodedKey)
                    if gKryptausOn = #waiting then
                      gKryptausOn = 1
                      put("Encryption enabled...!")
                    else
                      gKryptausOn = 0
                      put("Encryption disabled...!")
                    end if
                    sendFuseMsg("KEYENCRYPTED" && decodedKey)
                    gConnectionsSecured = 1
                  else
                    if firstline contains "ERROR" then
                      put(content)
                      if content contains "not move there" then
                      else
                        if content contains "inproper" and content contains "WARNING" = 0 then
                          ShowAlert(content.getProp(#line, 2))
                        else
                          if content contains "user already" then
                            ShowAlert("NameAlreadyUse")
                            e = 1
                            repeat while e <= 99
                              sprite(e).visible = 1
                              e = 1 + e
                            end repeat
                            go(1)
                          else
                            if content contains "incorrect flat password" or content contains "password required" then
                              flatPasswordIncorrect()
                            else
                              if content contains "login in" then
                                ShowAlert("WrongPassword")
                                e = 1
                                repeat while e <= 99
                                  sprite(e).visible = 1
                                  e = 1 + e
                                end repeat
                                go(1)
                              else
                                if content contains "Version not correct" then
                                  ShowAlert("Old client version, please reload." & "\r" & "Clear browser's cache if necessary.")
                                else
                                  if content contains "the room owner" then
                                    ShowAlert(content.getProp(#line, 2))
                                  else
                                    put("Error message:" && content)
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    else
                      if firstline contains "USERS" then
                        content = doSpecialCharConversion(content)
                        the itemDelimiter = "\t"
                        i = 2
                        repeat while i <= the number of line in content
                          ln = content.item[1]
                          if the number of word in ln <> 0 then
                            user = ln.word[1]
                            figure = ln.word[2]
                            locX = integer(ln.word[3])
                            locY = integer(ln.word[4])
                            locHeight = integer(ln.word[5])
                            if ln.word[ln.count(#word)] starts "ch=" then
                              Custom = doSpecialCharConversion(ln.word[6..ln.count(#word) - 1])
                              swimsuit = ln.word[ln.count(#word)]
                            else
                              Custom = doSpecialCharConversion(ln.word[6..the number of word in ln])
                              swimsuit = ""
                            end if
                            if content.item[2] <> "" then
                              score = content.word[1]
                              ranking = content.word[2]
                              Custom = Custom & "\r" & "\r" & "pisteet:" & score & " sijoitus:" & ranking & "."
                            end if
                            if not the movieName contains "pellehyppy" then
                              createAvatar(user, figure, locX, locY, locHeight, Custom)
                            else
                              if gpObjects.findPos(user) then
                                sendSprite(gpObjects.getProp(user), #updateSwimSuit, figure, swimsuit)
                              else
                                createAvatar(user, figure, locX, locY, locHeight, Custom, swimsuit)
                              end if
                            end if
                          end if
                          i = 1 + i
                        end repeat
                        the itemDelimiter = ","
                      else
                        if firstline contains "USEROBJECT" then
                          the itemDelimiter = "="
                          content = doSpecialCharConversion(content)
                          i = 2
                          repeat while i <= the number of line in content
                            ln = content.line[i]
                            sfield = ln.item[1]
                            sdata = ln.item[2]
                            put(sfield, sdata)
                            if sfield = "name" then
                            end if
                            if sprite(0).number > 0 and sfield.length > 0 then
                              if sdata <> "null" then
                              else
                              end if
                            end if
                            i = 1 + i
                          end repeat
                          the itemDelimiter = ","
                          goToFrame("change1")
                        else
                          if firstline contains "SYSTEMBROADCAST" then
                            ShowAlert("MessageFromAdmin", content.line[2])
                          else
                            if firstline contains "SHOWPROGRAM" then
                              commandLine = content.line[2]
                              spr = getaProp(gpShowSprites, commandLine.word[1])
                              if spr > 0 then
                                sendSprite(spr, symbol("fuseShow_" & commandLine.word[2]), commandLine.word[3..the number of word in commandLine])
                              end if
                            else
                              if firstline contains "TRIGGER" then
                                if content contains "openSplashKiosk" then
                                  openSplashKiosk()
                                end if
                              else
                                if firstline contains "DOOR_IN" then
                                  tItemDelim = the itemDelimiter
                                  the itemDelimiter = "/"
                                  tDoorID = content.getPropRef(#line, 2).getProp(#item, 1)
                                  tUsername = content.getPropRef(#line, 2).getProp(#item, 2)
                                  tDoorType = content.getPropRef(#line, 2).getProp(#item, 3)
                                  the itemDelimiter = tItemDelim
                                  tDoorObj = sprite(gpObjects.getAt(tDoorType & tDoorID)).getProp(#scriptInstanceList, 1)
                                  tDoorObj.animate(void(), #in)
                                  if gMyName = tUsername then
                                    tDoorObj.prepareToKick(tUsername)
                                  end if
                                else
                                  if firstline contains "DOOR_OUT" then
                                    tItemDelim = the itemDelimiter
                                    the itemDelimiter = "/"
                                    tDoorID = content.getPropRef(#line, 2).getProp(#item, 1)
                                    tUsername = content.getPropRef(#line, 2).getProp(#item, 2)
                                    tDoorType = content.getPropRef(#line, 2).getProp(#item, 3)
                                    the itemDelimiter = tItemDelim
                                    tDoorObj = sprite(gpObjects.getAt(tDoorType & tDoorID)).getProp(#scriptInstanceList, 1)
                                    tDoorObj.animate(void(), #out)
                                  else
                                    if firstline contains "HEIGHTMAP" then
                                      loadHeightMap(content.line[2..the number of line in content])
                                    else
                                      if firstline contains " OBJECTS" then
                                        content = doSpecialCharConversion(content)
                                        type = the last word in firstline
                                        AddStatistic(the movieName, type)
                                        if not the movieName contains "private" and type contains "model_" then
                                          goMovie("gf_private", type)
                                          init()
                                        end if
                                        sprMan_clearAll()
                                        gUserSprites = [:]
                                        gpObjects = [:]
                                        gWorldType = type
                                        goToFrame(type)
                                        checkOffsets()
                                        clickedUrl = 0
                                        sprite(99).visible = 1
                                        i = 2
                                        repeat while i <= the number of line in content
                                          ln = content.line[i]
                                          name = ln.word[1]
                                          objectClass = ln.word[2]
                                          if not objectClass contains "stair" and not objectClass contains "ignore" then
                                            locX = integer(ln.word[3])
                                            locY = integer(ln.word[4])
                                            locHeight = integer(ln.word[5])
                                            direction = void()
                                            dimensions = void()
                                            if the number of word in ln = 6 then
                                              dir = integer(ln.word[6])
                                              direction = [dir, dir, dir]
                                            else
                                              width = integer(ln.word[6])
                                              height = integer(ln.word[7])
                                              locX = locX + width - 1
                                              locY = locY + height - 1
                                              dimensions = [width, height]
                                            end if
                                            createFuseObject(name, objectClass, "0,0,0", locX, locY, locHeight, direction, dimensions)
                                            if rollover(2) and the mouseDown and clickedUrl <> 1 then
                                              clickedUrl = 1
                                              sendSprite(2, #mouseDown)
                                            end if
                                          end if
                                          if i mod 10 = 0 then
                                            sendFuseMsg("STATUSOK")
                                          end if
                                          i = 1 + i
                                        end repeat
                                        if getmemnum(gWorldType & ".firstAction") > 0 then
                                          sendFuseMsg(field(0))
                                        end if
                                        updateStage()
                                        sendEPFuseMsg("GETADFORME general")
                                      else
                                        handleSpecialMessages(content)
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on getZShift memberPrefix, partName, direction 
  if voidp(gzShifts) or the runMode = "Author" then
    gzShifts = [:]
  end if
  if not listp(getaProp(gzShifts, memberPrefix & "_" & partName)) then
    if getmemnum(memberPrefix & "_" & partName & ".zshift") > 0 then
      shiftData = NULL
    else
      return(0)
    end if
    l = []
    i = 1
    repeat while i <= the number of line in shiftData
      add(l, integer(shiftData.line[i]))
      i = 1 + i
    end repeat
    addProp(gzShifts, memberPrefix & "_" & partName, l)
  end if
  l = getaProp(gzShifts, memberPrefix & "_" & partName)
  if voidp(direction) then
    return(getAt(l, 1))
  else
    if count(l) > direction then
      return(getAt(l, direction + 1))
    else
      return(getAt(l, 1))
    end if
  end if
end

on getObjectSprite name 
  return(getaProp(gpObjects, name))
end
