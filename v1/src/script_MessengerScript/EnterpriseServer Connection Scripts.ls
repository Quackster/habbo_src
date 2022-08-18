on epLogin user, password 
  gMyName = user
  member("messenger.my_name").text = gMyName
  sendEPFuseMsg("LOGIN" && user && password)
  sendEPFuseMsg("MESSENGERINIT")
  sendEPFuseMsg("UNIQUEMACHINEID" && getMachineID())
  if the runMode <> "Author" then
    sendEPFuseMsg("STAT /ShockwaveVersion/" & the productVersion)
    if (netDone(gHabboRep) = 1) and (netError(gHabboRep) = "OK") then
      tHabboRep = netTextResult(gHabboRep)
      sendEPFuseMsg("HABBOREP" && tHabboRep)
    end if
  end if
end

on EPLogon  
  gEPConnectionsSecured = 0
  if objectp(gEPConnectionInstance) then
    errCode = setNetMessageHandler(gEPConnectionInstance, 0, 0)
  end if
  gEPConnectionInstance = 0
  gEPlastContent = void()
  gEPConnectionInstance = new(xtra("Multiuser"))
  put(gEPConnectionInstance)
  errCode = setNetMessageHandler(gEPConnectionInstance, #EPMessageHandler, script("EnterpriseServer Connection Scripts"))
  if (errCode = 0) then
    gEPConnectionOk = 0
    hostname = gEPIp
    hostport = gEPPort
    put(hostname, hostport)
    connectToNetServer(gEPConnectionInstance, "*", "*", hostname, hostport, "*", 1)
  else
    ShowAlert("Creation of callback failed" & errCode)
  end if
  messengerInit()
end

on messengerInit  
  gBuddyList = new(script("BuddyLIst Class"))
  update(gBuddyList)
  gMessageManager = new(script("MessageManager Class"))
  member("messenger.new_buddy_requests").text = AddTextToField("ZerobuddyRequest")
  member("messenger.new_buddy_requests").font = "Volter (goldfish)"
  member("messenger.new_buddy_requests").fontStyle = [#plain]
  member("messenger.new_buddy_requests2").text = member("messenger.new_buddy_requests").text
  member("messenger.new_buddy_requests2").font = "Volter (goldfish)"
  member("messenger.new_buddy_requests2").fontStyle = [#plain]
  member("messenger.sms_account").text = " "
  member("messenger.no_of_new_messages").text = AddTextToField("ZerobuddyMessage")
  member("messenger.no_of_new_messages").font = "Volter (goldfish)"
  member("messenger.no_of_new_messages").fontStyle = [#plain]
  member("messenger.my_persistent_message").text = AddTextToField("MyPersistentMessage")
end

on sendEPFuseMsg s 
  if (gEPConnectionOk = 1) and objectp(gEPConnectionInstance) then
    s = stringReplace(s, "�", "&auml;")
    s = stringReplace(s, "�", "&ouml;")
    len = "" & s.length
    repeat while len.length < 4
      len = len & " "
    end repeat
    if (gEPKryptausOn = 1) and objectp(RC4EP) then
      tMsg = RC4EP.encipher(len & s)
    else
      tMsg = len & s
    end if
    sendNetMessage(gEPConnectionInstance, 0, 0, tMsg)
  else
    ShowAlert("ConnectionNotReady")
  end if
end

on fuseEPRegister update 
  phoneN = fieldOrEmpty("phonenumber")
  if (phoneN = void()) then
    gPhonenumberOk = 0
  else
    if phoneN > 7 then
      gPhonenumberOk = 1
    end if
  end if
  s = ""
  s = "loginname" & field(0) & "\r"
  s = s & "password=" & fieldOrEmpty("loginpw") & "\r"
  s = s & "email=" & fieldOrEmpty("email") & "\r"
  s = s & "figure=" & toOneLine(fieldOrEmpty("figure")) & "\r"
  s = s & "address=" & fieldOrEmpty("address") & "\r"
  s = s & "age=" & fieldOrEmpty("age") & "\r"
  s = s & "zipcode=" & fieldOrEmpty("zipcode") & "\r"
  s = s & "firstName=" & fieldOrEmpty("firstName") & "\r"
  s = s & "postLocation=" & fieldOrEmpty("postLocation") & "\r"
  s = s & "lastName=" & fieldOrEmpty("lastName") & "\r"
  s = s & "phonenumber=" & fieldOrEmpty("phonenumber") & "\r"
  s = s & "directMail=" & fieldOrEmpty("directMail") & "\r"
  s = s & "textMessages=" & "false" & "\r"
  s = s & "customData=" & fieldOrEmpty("customData") & "\r"
  s = s & "has_read_agreement=" & fieldOrEmpty("Agreement_field") & "\r"
  s = s & "sex=" & fieldOrEmpty("charactersex_field") & "\r"
  s = s & "country=" & fieldOrEmpty("countryname") & "\r"
  if the movieName contains "cr_entry" then
    s = s & "crossroads=1" & "\r"
  end if
  if voidp(update) or (update = 0) then
    sendEPFuseMsg("REGISTER" && s)
  else
    sendEPFuseMsg("UPDATE" && s)
  end if
end

on EPMessageHandler  
  if (gEPConnectionInstance = 0) then
    return()
  end if
  newMessage = getNetMessage(gEPConnectionInstance)
  errCode = getaProp(newMessage, #errorCode)
  content = getaProp(newMessage, #content)
  gEPConnectionOk = 1
  if errCode <> 0 then
    put("error" & errCode)
    if not the movieName contains "entry" and the frame >= 190 and the frame <= 205 then
      ShowAlert("ConnectionDisconnect")
    end if
  end if
  if stringp(content) then
    if not content contains "##" then
      if voidp(gEPlastContent) then
        gEPlastContent = ""
      end if
      gEPlastContent = gEPlastContent & content
      return()
    end if
    if not voidp(gEPlastContent) then
      content = gEPlastContent & content
    end if
    contentChunk = ""
    contentArray = []
    the itemDelimiter = "##"
    b = 0
    if not content.char[(content.length - 2)..content.length] contains "##" then
      b = 1
      put("last item not ##")
      put(content.char[(content.length - 2)..content.length])
    end if
    gEPlastContent = ""
    n = the number of item in content
    i = 1
    repeat while i <= n
      if i < n or (b = 0) then
        add(contentArray, content.item[i])
      else
        if (b = 1) and (i = n) then
          gEPlastContent = content.item[i]
        end if
      end if
      i = (1 + i)
    end repeat
    the itemDelimiter = ","
    i = 1
    repeat while i <= count(contentArray)
      handleEPMessageContent(getAt(contentArray, i))
      i = (1 + i)
    end repeat
  end if
end

on showUnitsInMsg  
  if listp(gUnits) then
    s = ""
    repeat while gUnits <= 1
      unit = getAt(1, count(gUnits))
    end repeat
  end if
end

on handleEPMessageContent content 
  if not stringp(content) or content.length <= 1 then
    return()
  end if
  firstline = content.line[1]
  content = doSpecialCharConversion(content)
  if firstline contains "HELLO" then
    put("HELLO")
    gEPKryptausOn = 0
    sendEPFuseMsg("versionid" && field(0))
  else
    if firstline contains "ENCRYPTION_ON" then
      put("EP Encryption enabled...!")
      gEPKryptausOn = #waiting
    else
      if firstline contains "ENCRYPTION_OFF" then
        put("EP Encryption disabled...!")
        gEPKryptausOn = 0
      else
        if firstline contains "SECRET_KEY" then
          decodedKey = secretDecode(content.line[2])
          RC4EP = new(script("RC4"))
          RC4EP.setKey(string(decodedKey))
          if (gEPKryptausOn = #waiting) then
            gEPKryptausOn = 1
            put("EP Encryption switched on...!")
          else
            gEPKryptausOn = 0
            put("EP Encryption switched off...!")
          end if
          sendEPFuseMsg("KEYENCRYPTED" && decodedKey)
          sendEPFuseMsg("CLIENTIP" && getNetAddressCookie(gEPConnectionInstance, 1))
          gEPConnectionsSecured = 1
        else
          if firstline contains "PERFORMREALLOGIN" then
            goContext("manual_login")
          else
            if firstline contains "NAME_APPROVED" then
              put("name OK")
            else
              if firstline contains "NAME" then
                ShowAlert("unacceptableName")
              else
                if firstline contains "ERROR" and not firstline contains "PURCHASE" then
                  put(content)
                  if content contains "login incorrect" then
                    put(content)
                    ShowAlert("WrongPassword")
                    goToFrame("sendMyPassword")
                  else
                    if content contains "Version not correct" then
                      ShowAlert("Too old client version, please reload page!" & "\r" & "Clear browser's cache if necessary.")
                    else
                      if content contains "inproper" and (content contains "WARNING" = 0) then
                        if the movieName contains "entry" then
                          goToFrame("public_places")
                        end if
                        gConfirmPopUp = new(script("PopUp Context Class"), 2140000000, 851, 865, point(0, 0))
                        displayFrame(gConfirmPopUp, "banned")
                      else
                        if content contains "User exists" then
                          ShowAlert("NameAlreadyUse")
                          goToFrame("figure")
                        else
                          if content contains "Only 10" then
                            alert(content)
                          else
                            if content contains "MODERATOR W" then
                              oldItemDelimiter = the itemDelimiter
                              the itemDelimiter = "/"
                              ShowAlert("ModeratorWarning", content.getProp(#item, 2))
                              the itemDelimiter = oldItemDelimiter
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                else
                  handleMessengerMessages(content)
                  handleSpecialMessages(content)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on handleMemberInfo data 
  name = data.line[1]
  customText = "\"" & data.line[2] & "\""
  lastAccess = AddTextToField("LastTime") && data.line[3]
  location = data.line[4]
  FigureData = data.line[5]
  if location.length < 2 then
    location = AddTextToField("BuddyNotHere")
  else
    if (location = "ENTERPRISESERVER") then
      location = AddTextToField("BuddyEntry")
    else
      if location starts "Floor1" then
        location = AddTextToField("BuddyPrivateRoom")
      end if
    end if
  end if
  
  
  
  field(0).textFont = "Volter-Bold (goldfish)"
  
  MyWireFace(FigureDataParser(FigureData), "face_icon")
end

on handleMessengerMessages content 
  firstline = content.line[1]
  if firstline contains "BUDDYLIST" then
    if voidp(gBuddyList) then
      gBuddyList = new(script("BuddyList Class"))
    end if
    handleFuseBuddyListMsg(gBuddyList, content.line[2..the number of line in content])
  else
    if firstline contains "MESSENGER_MSG" then
      if not objectp(gMessageManager) then
        gMessageManager = new(script("MessageManager Class"))
      end if
      handleFusePMessage(gMessageManager, content.line[2..the number of line in content])
      update(gBuddyList)
    else
      if firstline contains "USEROBJECT" then
        p = keyValueToPropList(content, "\r")
        put(content, p)
        if (getaProp(p, "phoneNumber") = void()) then
          gPhonenumberOk = 0
        else
          if length(getaProp(p, "phoneNumber")) > 7 then
            gPhonenumberOk = 1
          end if
        end if
        if (gUserLoginRetrieve = 1) then
          gUserLoginRetrieve = 0
          put(p, getaProp(p, "customData"))
          put("charactersex_field" && field(0))
          if (member("charactersex_field").text = "M") then
            member("charactersex_field").text = "Male"
          end if
          if (member("charactersex_field").text = "F") then
            member("charactersex_field").text = "Female"
          end if
          gMySex = field(0)
          if p.getPos("country") <> void() then
          else
            member(getmemnum("countryname")).text = ""
          end if
          MyfigurePartList = [:]
          MyfigureColorList = [:]
          MyfigurePartList = keyValueToPropList(getaProp(p, "figure"), "&")
          oldDelim = the itemDelimiter
          i = 1
          repeat while i <= count(MyfigurePartList)
            model = getAt(MyfigurePartList, i)
            the itemDelimiter = "/"
            if model.item[2].length > 3 then
              clothColor = value("color(#rgb," & model.item[2] & ")")
            else
              clothColor = paletteIndex(integer(model.item[2]))
            end if
            if (clothColor = void()) then
              clothColor = color(#rgb, 0, 0, 0)
            end if
            addProp(MyfigureColorList, getPropAt(MyfigurePartList, i), clothColor)
            setAt(MyfigurePartList, i, model.item[1])
            the itemDelimiter = oldDelim
            i = (1 + i)
          end repeat
          sendEPFuseMsg("GETCREDITS")
          return()
        else
          tmpStr = "figure=" & p.getAt("figure")
          tmpStr2 = ""
          the itemDelimiter = "="
          c = 1
          repeat while c <= tmpStr.count(#item)
            if c > 1 and c < tmpStr.count(#item) then
              tmpStr2 = tmpStr2 & tmpStr.getProp(#item, c) & "="
            else
              if c > 1 and (c = tmpStr.count(#item)) then
                tmpStr2 = tmpStr2 & tmpStr.getProp(#item, c)
              end if
            end if
            c = (1 + c)
          end repeat
          the itemDelimiter = ","
          tmpList = []
          figurePartList = [:]
          figureColorList = [:]
          the itemDelimiter = "&"
          c = 1
          repeat while c <= tmpStr2.count(#item)
            tmpList.add(tmpStr2.getProp(#item, c))
            c = (1 + c)
          end repeat
          the itemDelimiter = ","
          c = 1
          repeat while c <= tmpList.count
            the itemDelimiter = "/"
            tmpPart = tmpList.getAt(c)
            tName = tmpPart.getProp(#char, 1, 2)
            figurePartList.addProp(tName, tmpPart.getProp(#item, 1))
            figureColorList.addProp(tName, tmpPart.getProp(#item, 2))
            the itemDelimiter = ","
            c = (1 + c)
          end repeat
          put(figurePartList && "figurePartList <-----")
          put(figureColorList)
          if getaProp(p, "phoneNumber") <> "null" then
          else
          end if
          i = 2
          repeat while i <= the number of line in content
            ln = content.line[i]
            sfield = ln.item[1]
            sdata = ln.item[2]
            put(sfield, sdata)
            if sprite(0).number > 0 and sfield.length > 0 then
              if sdata <> "null" then
              else
              end if
            end if
            i = (1 + i)
          end repeat
          the itemDelimiter = ","
          goToFrame("change1")
        end if
      else
        if firstline contains "NOSUCHUSER" then
          member("messenger.member_match").text = AddTextToField("NoProfileFind")
          sendSprite(gBuddyRequestSprite, #disable)
        else
          if firstline contains "MEMBERINFO" then
            if the movieName contains "entry" and (the frameLabel = "regist_2") or (the frameLabel = "figure") then
              ShowAlert("NameAlreadyUse")
              goToFrame("regist")
              return()
            end if
            handleMemberInfo(content.line[2..the number of line in content])
            sendSprite(gBuddyRequestSprite, #enable)
          else
            if firstline contains "MESSENGERSMSACCOUNT" then
              ln2 = content.line[2]
              if ln2 contains "noaccount" then
                sText = "Tekstiviestipalvelua ei avattu"
              else
                numbers = value(ln2)
                if (count(numbers) = 1) then
                  sText = "Tekstiviestipalvelu avattu."
                else
                  sText = "Tekstiviestipalvelu avattu" && count(numbers) && "numeroon"
                end if
              end if
              
              
              field(0).textStyle = "underline"
            else
              if firstline contains "BUDDYADDREQUESTS" then
                requester = content.word[1]
                oldDelim = the itemDelimiter
                the itemDelimiter = "/"
                requesterName = requester.item[2]
                addBuddyRequest(gBuddyList, requesterName)
              else
                if firstline contains "MYPERSISTENTMSG" then
                  if (content.line[2] = "") then
                    member("messenger.my_persistent_message").text = AddTextToField("MyPersistentMessage")
                  else
                    member("messenger.my_persistent_message").text = content.line[2]
                  end if
                else
                  if firstline contains "USERPROFILE" then
                    parseUserProfile(content.line[2..the number of line in content])
                  else
                    if firstline contains "USERMATCH" then
                      put(content)
                      if (content.line[3] = "-1.0") then
                        member("messenger.member_match").text = AddTextToField("NoProfileFind")
                      else
                        member("messenger.member_match").text = AddTextToField("Profilematch") && integer((value(content.line[3]) * 100))
                      end if
                    else
                      if firstline contains "CRYFORHELP" then
                        put("Cry:" && content)
                        if (CryHelp = void()) then
                          CryHelp = [:]
                        end if
                        cryinguser = content.line[2]
                        cryurl = content.line[3]
                        oldI = the itemDelimiter
                        the itemDelimiter = ";"
                        CryMsg = content.line[4].getProp(#item, 3)
                        CryUnit = content.line[4].getProp(#item, 1)
                        CrygDoor = content.line[4].getProp(#item, 2)
                        Cryprivate_gChosenFlatId = stringReplace(content.line[4].getProp(#item, 4), "\t", "/")
                        the itemDelimiter = oldI
                        temp = []
                        f = 1
                        repeat while f <= count(CryHelp)
                          if CryHelp.getProp(CryHelp.getPropAt(f)).getProp("PickedCry") <> "<nobody>" then
                            temp.add(CryHelp.getPropAt(f))
                          end if
                          f = (1 + f)
                        end repeat
                        repeat while getaProp(p, "customData") <= gMyName
                          f = getAt(gMyName, "character_info_desc")
                          CryHelp.deleteProp(f)
                        end repeat
                        if CryCount > count(CryHelp) then
                          CryCount = count(CryHelp)
                        end if
                        if cryinguser <> "[AUTOMATIC]" then
                          CryHelp.addProp(cryurl, ["cryinguser":cryinguser, "url":content.line[3], "CryMsg":CryMsg, "Unit":CryUnit, "gDoor":CrygDoor, "PickedCry":"<nobody>", "CryPrivate":Cryprivate_gChosenFlatId])
                          put(CryHelp)
                          if PurseAndHelpContext <> void() then
                            if PurseAndHelpContext.frame <> "hobba_alert" then
                              CryCount = count(CryHelp)
                            end if
                          else
                            CryCount = count(CryHelp)
                          end if
                          if PurseAndHelpContext <> void() then
                            if PurseAndHelpContext.frame <> "cryForHelp" and PurseAndHelpContext.frame <> "cryDone" then
                              sprite(870).member = member(getmemnum("hobba_alert_anim"))
                              sprite(870).loc = point(30, 20)
                              sprite(870).height = member(getmemnum("hobba_alert_anim")).height
                              sprite(870).width = member(getmemnum("hobba_alert_anim")).width
                            end if
                          else
                            sprite(870).member = member(getmemnum("hobba_alert_anim"))
                            sprite(870).loc = point(30, 20)
                            sprite(870).height = member(getmemnum("hobba_alert_anim")).height
                            sprite(870).width = member(getmemnum("hobba_alert_anim")).width
                          end if
                        end if
                      else
                        if firstline contains "PICKED_CRY" then
                          put(content)
                          CryPickedBy = content.line[2]
                          cryurl = content.line[3]
                          if CryHelp <> void() then
                            if CryHelp.findPos(cryurl) <> void() then
                              CryHelp.getProp(cryurl).setProp("PickedCry", CryPickedBy)
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

on getUniqueID  
  e = script("RC4").new()
  e.setKey("sulake1Unique2Key3Generator")
  s = e.encipher(the date && the time && the milliSeconds)
  e = void()
  return(s)
end

on getMachineID  
  x = getPref("6FEB4C10")
  if voidp(x) then
    s = getUniqueID()
    setPref("6FEB4C10", s)
    return(s)
  else
    return(x)
  end if
end
