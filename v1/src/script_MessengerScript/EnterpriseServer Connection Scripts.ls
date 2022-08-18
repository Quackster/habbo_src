global gEPConnectionsSecured, gEPConnectionInstance, gEPlastContent, gEPIp, gEPPort, gEPConnectionOk, gBuddyList, gMessageManager, gBuddyRequestSprite, gMyName, figurePartList, figureColorList, MyfigurePartList, MyfigureColorList, gPhonenumberOk, gEndLoadingTime, gStartLoadingTime, gHabboRep

on epLogin user, password
  gMyName = user
  member("messenger.my_name").text = gMyName
  sendEPFuseMsg((("LOGIN" && user) && password))
  sendEPFuseMsg("MESSENGERINIT")
  sendEPFuseMsg(("UNIQUEMACHINEID" && getMachineID()))
  if (the runMode <> "Author") then
    sendEPFuseMsg(("STAT /ShockwaveVersion/" & the productVersion))
    if ((netDone(gHabboRep) = 1) and (netError(gHabboRep) = "OK")) then
      tHabboRep = netTextResult(gHabboRep)
      sendEPFuseMsg(("HABBOREP" && tHabboRep))
    end if
  end if
end

on EPLogon
  gEPConnectionsSecured = 0
  if objectp(gEPConnectionInstance) then
    errCode = SetNetMessageHandler(gEPConnectionInstance, 0, 0)
  end if
  gEPConnectionInstance = 0
  gEPlastContent = VOID
  gEPConnectionInstance = new(xtra("Multiuser"))
  put gEPConnectionInstance
  errCode = SetNetMessageHandler(gEPConnectionInstance, #EPMessageHandler, script("EnterpriseServer Connection Scripts"))
  if (errCode = 0) then
    gEPConnectionOk = 0
    hostname = gEPIp
    hostport = gEPPort
    put hostname, hostport
    ConnectToNetServer(gEPConnectionInstance, "*", "*", hostname, hostport, "*", 1)
  else
    ShowAlert(("Creation of callback failed" & errCode))
  end if
  messengerInit()
end

on messengerInit
  global gEPPort, gEPIp, gBuddyList, gMessageManager
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
  global gcatName, RC4EP, gEPKryptausOn
  if ((gEPConnectionOk = 1) and objectp(gEPConnectionInstance)) then
    s = stringReplace(s, "�", "&auml;")
    s = stringReplace(s, "�", "&ouml;")
    len = (EMPTY & s.length)
    repeat while (len.length < 4)
      len = (len & " ")
    end repeat
    if ((gEPKryptausOn = 1) and objectp(RC4EP)) then
      tMsg = RC4EP.encipher((len & s))
    else
      tMsg = (len & s)
    end if
    SendNetMessage(gEPConnectionInstance, 0, 0, tMsg)
  else
    ShowAlert("ConnectionNotReady")
  end if
end

on fuseEPRegister update
  phoneN = fieldOrEmpty("phonenumber")
  if (phoneN = VOID) then
    gPhonenumberOk = 0
  else
    if (phoneN > 7) then
      gPhonenumberOk = 1
    end if
  end if
  s = EMPTY
  s = (((s & "name=") & field("loginname")) & RETURN)
  s = (((s & "password=") & fieldOrEmpty("loginpw")) & RETURN)
  s = (((s & "email=") & fieldOrEmpty("email")) & RETURN)
  s = (((s & "figure=") & toOneLine(fieldOrEmpty("figure"))) & RETURN)
  s = (((s & "address=") & fieldOrEmpty("address")) & RETURN)
  s = (((s & "age=") & fieldOrEmpty("age")) & RETURN)
  s = (((s & "zipcode=") & fieldOrEmpty("zipcode")) & RETURN)
  s = (((s & "firstName=") & fieldOrEmpty("firstName")) & RETURN)
  s = (((s & "postLocation=") & fieldOrEmpty("postLocation")) & RETURN)
  s = (((s & "lastName=") & fieldOrEmpty("lastName")) & RETURN)
  s = (((s & "phonenumber=") & fieldOrEmpty("phonenumber")) & RETURN)
  s = (((s & "directMail=") & fieldOrEmpty("directMail")) & RETURN)
  s = (((s & "textMessages=") & "false") & RETURN)
  s = (((s & "customData=") & fieldOrEmpty("customData")) & RETURN)
  s = (((s & "has_read_agreement=") & fieldOrEmpty("Agreement_field")) & RETURN)
  s = (((s & "sex=") & fieldOrEmpty("charactersex_field")) & RETURN)
  s = (((s & "country=") & fieldOrEmpty("countryname")) & RETURN)
  if (the movieName contains "cr_entry") then
    s = ((s & "crossroads=1") & RETURN)
  end if
  if (voidp(update) or (update = 0)) then
    sendEPFuseMsg(("REGISTER" && s))
  else
    sendEPFuseMsg(("UPDATE" && s))
  end if
end

on EPMessageHandler
  global contentChunk, gEPlastContent
  if (gEPConnectionInstance = 0) then
    return 
  end if
  newMessage = GetNetMessage(gEPConnectionInstance)
  errCode = getaProp(newMessage, #errorCode)
  content = getaProp(newMessage, #content)
  gEPConnectionOk = 1
  if (errCode <> 0) then
    put ("error" & errCode)
    if not (((the movieName contains "entry") and (the frame >= 190)) and (the frame <= 205)) then
      ShowAlert("ConnectionDisconnect")
    end if
  end if
  if stringp(content) then
    if not (content contains "##") then
      if voidp(gEPlastContent) then
        gEPlastContent = EMPTY
      end if
      gEPlastContent = (gEPlastContent & content)
      return 
    end if
    if not voidp(gEPlastContent) then
      content = (gEPlastContent & content)
    end if
    contentChunk = EMPTY
    contentArray = []
    the itemDelimiter = "##"
    b = 0
    if not (char (content.length - 2) to content.length of content contains "##") then
      b = 1
      put "last item not ##"
      put char (content.length - 2) to content.length of content
    end if
    gEPlastContent = EMPTY
    n = the number of items in content
    repeat with i = 1 to n
      if ((i < n) or (b = 0)) then
        add(contentArray, item i of content)
        next repeat
      end if
      if ((b = 1) and (i = n)) then
        gEPlastContent = item i of content
      end if
    end repeat
    the itemDelimiter = ","
    repeat with i = 1 to count(contentArray)
      handleEPMessageContent(getAt(contentArray, i))
    end repeat
  end if
end

on showUnitsInMsg
  global gUnits
  if listp(gUnits) then
    s = EMPTY
    repeat with unit in gUnits
      put ((((unit[1] && "(") & unit[2]) & ")") & RETURN) after s
    end repeat
    put s into field "messenger.member_info"
  end if
end

on handleEPMessageContent content
  global gBuddyRequestSprite, RC4EP, gEPKryptausOn, gConfirmPopUp
  if (not stringp(content) or (content.length <= 1)) then
    return 
  end if
  firstline = line 1 of content
  content = doSpecialCharConversion(content)
  if (firstline contains "HELLO") then
    put "HELLO"
    gEPKryptausOn = 0
    sendEPFuseMsg(("VERSIONCHECK" && field("versionid")))
  else
    if (firstline contains "ENCRYPTION_ON") then
      put "EP Encryption enabled...!"
      gEPKryptausOn = #waiting
    else
      if (firstline contains "ENCRYPTION_OFF") then
        put "EP Encryption disabled...!"
        gEPKryptausOn = 0
      else
        if (firstline contains "SECRET_KEY") then
          decodedKey = secretDecode(line 2 of content)
          RC4EP = new(script("RC4"))
          RC4EP.setKey(string(decodedKey))
          if (gEPKryptausOn = #waiting) then
            gEPKryptausOn = 1
            put "EP Encryption switched on...!"
          else
            gEPKryptausOn = 0
            put "EP Encryption switched off...!"
          end if
          sendEPFuseMsg(("KEYENCRYPTED" && decodedKey))
          sendEPFuseMsg(("CLIENTIP" && GetNetAddressCookie(gEPConnectionInstance, 1)))
          gEPConnectionsSecured = 1
        else
          if (firstline contains "PERFORMREALLOGIN") then
            goContext("manual_login")
          else
            if (firstline contains "NAME_APPROVED") then
              put "name OK"
            else
              if (firstline contains "NAME") then
                ShowAlert("unacceptableName")
                put EMPTY into field "charactername_field"
              else
                if ((firstline contains "ERROR") and not (firstline contains "PURCHASE")) then
                  put content
                  if (content contains "login incorrect") then
                    put content
                    ShowAlert("WrongPassword")
                    gotoFrame("sendMyPassword")
                  else
                    if (content contains "Version not correct") then
                      ShowAlert((("Too old client version, please reload page!" & RETURN) & "Clear browser's cache if necessary."))
                    else
                      if ((content contains "inproper") and ((content contains "WARNING") = 0)) then
                        if (the movieName contains "entry") then
                          gotoFrame("public_places")
                        end if
                        gConfirmPopUp = new(script("PopUp Context Class"), 2140000000, 851, 865, point(0, 0))
                        displayFrame(gConfirmPopUp, "banned")
                      else
                        if (content contains "User exists") then
                          ShowAlert("NameAlreadyUse")
                          put EMPTY into field "charactername_field"
                          gotoFrame("figure")
                        else
                          if (content contains "Only 10") then
                            alert(content)
                          else
                            if (content contains "MODERATOR W") then
                              oldItemDelimiter = the itemDelimiter
                              the itemDelimiter = "/"
                              ShowAlert("ModeratorWarning", content.item[2])
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
  name = line 1 of data
  customText = ((QUOTE & line 2 of data) & QUOTE)
  lastAccess = (AddTextToField("LastTime") && line 3 of data)
  location = line 4 of data
  FigureData = line 5 of data
  if (location.length < 2) then
    location = AddTextToField("BuddyNotHere")
  else
    if (location = "ENTERPRISESERVER") then
      location = AddTextToField("BuddyEntry")
    else
      if (location starts "Floor1") then
        location = AddTextToField("BuddyPrivateRoom")
      end if
    end if
  end if
  put EMPTY into field "messenger.member_info"
  set the textFont of field "messenger.member_info" to "Volter (goldfish)"
  put EMPTY into field "messenger.member_info2"
  set the textFont of field "messenger.member_info2" to "Volter (goldfish)"
  put (((name & RETURN) & customText) & RETURN) into field "messenger.member_info"
  put ((((lastAccess & RETURN) & RETURN) & AddTextToField("BuddyNow")) && location) into field "messenger.member_info2"
  set the textFont of field "messenger.member_info" to "Volter (goldfish)"
  set the textFont of line 1 of field "messenger.member_info" to "Volter-Bold (goldfish)"
  set the textFont of field "messenger.member_info2" to "Volter (goldfish)"
  MyWireFace(FigureDataParser(FigureData), "face_icon")
end

on handleMessengerMessages content
  global gUserLoginRetrieve, gMySex, CryCount, PurseAndHelpContext, CryHelp
  firstline = line 1 of content
  if (firstline contains "BUDDYLIST") then
    if voidp(gBuddyList) then
      gBuddyList = new(script("BuddyList Class"))
    end if
    handleFuseBuddyListMsg(gBuddyList, line 2 to the number of lines in content of content)
  else
    if (firstline contains "MESSENGER_MSG") then
      if not objectp(gMessageManager) then
        gMessageManager = new(script("MessageManager Class"))
      end if
      handleFusePMessage(gMessageManager, line 2 to the number of lines in content of content)
      update(gBuddyList)
    else
      if (firstline contains "USEROBJECT") then
        p = keyValueToPropList(content, RETURN)
        put content, p
        if (getaProp(p, "phoneNumber") = VOID) then
          gPhonenumberOk = 0
        else
          if (length(getaProp(p, "phoneNumber")) > 7) then
            gPhonenumberOk = 1
          end if
        end if
        if (gUserLoginRetrieve = 1) then
          gUserLoginRetrieve = 0
          put p, getaProp(p, "customData")
          put getaProp(p, "customData") into field "character_info_desc"
          put gMyName into field "character_info_name"
          put getaProp(p, "sex") into field "charactersex_field"
          put ("AND YOUR SEX WILL BE" && field("charactersex_field"))
          if (member("charactersex_field").text = "M") then
            member("charactersex_field").text = "Male"
          end if
          if (member("charactersex_field").text = "F") then
            member("charactersex_field").text = "Female"
          end if
          gMySex = field("charactersex_field")
          if (p.getPos("country") <> VOID) then
            put getaProp(p, "country") into field "countryname"
          else
            member(getmemnum("countryname")).text = EMPTY
          end if
          MyfigurePartList = [:]
          MyfigureColorList = [:]
          MyfigurePartList = keyValueToPropList(getaProp(p, "figure"), "&")
          oldDelim = the itemDelimiter
          repeat with i = 1 to count(MyfigurePartList)
            model = getAt(MyfigurePartList, i)
            the itemDelimiter = "/"
            if (item 2 of model.length > 3) then
              clothColor = value((("color(#rgb," & item 2 of model) & ")"))
            else
              clothColor = paletteIndex(integer(item 2 of model))
            end if
            if (clothColor = VOID) then
              clothColor = color(#rgb, 0, 0, 0)
            end if
            addProp(MyfigureColorList, getPropAt(MyfigurePartList, i), clothColor)
            setAt(MyfigurePartList, i, item 1 of model)
            the itemDelimiter = oldDelim
          end repeat
          sendEPFuseMsg("GETCREDITS")
          return 
        else
          tmpStr = ("figure=" & p["figure"])
          tmpStr2 = EMPTY
          the itemDelimiter = "="
          repeat with c = 1 to tmpStr.item.count
            if ((c > 1) and (c < tmpStr.item.count)) then
              tmpStr2 = ((tmpStr2 & tmpStr.item[c]) & "=")
              next repeat
            end if
            if ((c > 1) and (c = tmpStr.item.count)) then
              tmpStr2 = (tmpStr2 & tmpStr.item[c])
            end if
          end repeat
          the itemDelimiter = ","
          put tmpStr2 into field "figure_field"
          tmpList = []
          figurePartList = [:]
          figureColorList = [:]
          the itemDelimiter = "&"
          repeat with c = 1 to tmpStr2.item.count
            tmpList.add(tmpStr2.item[c])
          end repeat
          the itemDelimiter = ","
          repeat with c = 1 to tmpList.count
            the itemDelimiter = "/"
            tmpPart = tmpList[c]
            tName = tmpPart.char[1]
            figurePartList.addProp(tName, tmpPart.item[1])
            figureColorList.addProp(tName, tmpPart.item[2])
            the itemDelimiter = ","
          end repeat
          put (figurePartList && "figurePartList <-----")
          put figureColorList
          put getaProp(p, "name") into field "charactername_field"
          put getaProp(p, "email") into field "email_field"
          put getaProp(p, "directMail") into field "can_spam_field"
          put getaProp(p, "customData") into field "persistantmessage_field"
          put getaProp(p, "birthday") into field "birthday_field"
          put getaProp(p, "has_read_agreement") into field "Agreement_field"
          put getaProp(p, "sex") into field "charactersex_field"
          put getaProp(p, "country") into field "countryname"
          if (getaProp(p, "phoneNumber") <> "null") then
            put getaProp(p, "phoneNumber") into field "phonenumber"
          else
            put "+41" into field "phonenumber"
          end if
          put getaProp(p, "name") into field "loginname_locked"
          repeat with i = 2 to the number of lines in content
            ln = line i of content
            sfield = item 1 of ln
            sdata = item 2 of ln
            put sfield, sdata
            if ((the number of member sfield > 0) and (sfield.length > 0)) then
              if (sdata <> "null") then
                put doSpecialCharConversion(sdata) into field sfield
                next repeat
              end if
              put EMPTY into field sfield
            end if
          end repeat
          the itemDelimiter = ","
          gotoFrame("change1")
        end if
      else
        if (firstline contains "NOSUCHUSER") then
          put AddTextToField("CantFindYou") into field "messenger.member_info"
          member("messenger.member_match").text = AddTextToField("NoProfileFind")
          sendSprite(gBuddyRequestSprite, #disable)
        else
          if (firstline contains "MEMBERINFO") then
            if (((the movieName contains "entry") and (the frameLabel = "regist_2")) or (the frameLabel = "figure")) then
              ShowAlert("NameAlreadyUse")
              put EMPTY into field "charactername_field"
              gotoFrame("regist")
              return 
            end if
            handleMemberInfo(line 2 to the number of lines in content of content)
            sendSprite(gBuddyRequestSprite, #enable)
          else
            if (firstline contains "MESSENGERSMSACCOUNT") then
              ln2 = line 2 of content
              if (ln2 contains "noaccount") then
                sText = "Tekstiviestipalvelua ei avattu"
              else
                numbers = value(ln2)
                if (count(numbers) = 1) then
                  sText = "Tekstiviestipalvelu avattu."
                else
                  sText = (("Tekstiviestipalvelu avattu" && count(numbers)) && "numeroon")
                end if
              end if
              set the textStyle of field "messenger.sms_account" to "plain"
              set the textFont of field "messenger.sms_account" to "Volter (goldfish)"
              put sText into field "messenger.sms_account"
              set the textStyle of word 1 of field "messenger.sms_account" to "underline"
            else
              if (firstline contains "BUDDYADDREQUESTS") then
                requester = word 1 of content
                oldDelim = the itemDelimiter
                the itemDelimiter = "/"
                requesterName = item 2 of requester
                addBuddyRequest(gBuddyList, requesterName)
              else
                if (firstline contains "MYPERSISTENTMSG") then
                  if (line 2 of content = EMPTY) then
                    member("messenger.my_persistent_message").text = AddTextToField("MyPersistentMessage")
                  else
                    member("messenger.my_persistent_message").text = line 2 of content
                  end if
                else
                  if (firstline contains "USERPROFILE") then
                    parseUserProfile(line 2 to the number of lines in content of content)
                  else
                    if (firstline contains "USERMATCH") then
                      put content
                      if (line 3 of content = "-1.0") then
                        member("messenger.member_match").text = AddTextToField("NoProfileFind")
                      else
                        member("messenger.member_match").text = (AddTextToField("Profilematch") && integer((value(line 3 of content) * 100)))
                      end if
                    else
                      if (firstline contains "CRYFORHELP") then
                        put ("Cry:" && content)
                        if (CryHelp = VOID) then
                          CryHelp = [:]
                        end if
                        cryinguser = line 2 of content
                        cryurl = line 3 of content
                        oldI = the itemDelimiter
                        the itemDelimiter = ";"
                        CryMsg = line 4 of content.item[3]
                        CryUnit = line 4 of content.item[1]
                        CrygDoor = line 4 of content.item[2]
                        Cryprivate_gChosenFlatId = stringReplace(line 4 of content.item[4], TAB, "/")
                        the itemDelimiter = oldI
                        temp = []
                        repeat with f = 1 to count(CryHelp)
                          if (CryHelp.getProp(CryHelp.getPropAt(f)).getProp("PickedCry") <> "<nobody>") then
                            temp.add(CryHelp.getPropAt(f))
                          end if
                        end repeat
                        repeat with f in temp
                          CryHelp.deleteProp(f)
                        end repeat
                        if (CryCount > count(CryHelp)) then
                          CryCount = count(CryHelp)
                        end if
                        if (cryinguser <> "[AUTOMATIC]") then
                          CryHelp.addProp(cryurl, ["cryinguser": cryinguser, "url": line 3 of content, "CryMsg": CryMsg, "Unit": CryUnit, "gDoor": CrygDoor, "PickedCry": "<nobody>", "CryPrivate": Cryprivate_gChosenFlatId])
                          put CryHelp
                          if (PurseAndHelpContext <> VOID) then
                            if (PurseAndHelpContext.frame <> "hobba_alert") then
                              CryCount = count(CryHelp)
                            end if
                          else
                            CryCount = count(CryHelp)
                          end if
                          if (PurseAndHelpContext <> VOID) then
                            if ((PurseAndHelpContext.frame <> "cryForHelp") and (PurseAndHelpContext.frame <> "cryDone")) then
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
                        if (firstline contains "PICKED_CRY") then
                          put content
                          CryPickedBy = line 2 of content
                          cryurl = line 3 of content
                          if (CryHelp <> VOID) then
                            if (CryHelp.findPos(cryurl) <> VOID) then
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
  s = e.encipher(((the date && the time) && the milliSeconds))
  e = VOID
  return s
end

on getMachineID
  x = getPref("6FEB4C10")
  if voidp(x) then
    s = getUniqueID()
    setPref("6FEB4C10", s)
    return s
  else
    return x
  end if
end
