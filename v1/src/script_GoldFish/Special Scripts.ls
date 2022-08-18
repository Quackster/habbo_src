on handleSpecialMessages data 
  ln1 = data.line[1]
  data = doSpecialCharConversion(data)
  if ln1 contains "OPEN_UIMAKOPPI" then
    openUimakoppi()
  else
    if ln1 contains "CLOSE_UIMAKOPPI" then
      closeUimaKoppi()
    else
      if ln1 contains "PH_TICKETS_BUY" then
        put(data)
        member("JumpTICKETS").text = data.getPropRef(#line, 2).getProp(#word, 1)
        if the movieName contains "pellehyppy" then
          openHyppylippu()
        end if
      else
        if ln1 contains "PH_TICKETS" then
          put(data)
          member("JumpTICKETS").text = ln1.getProp(#word, 2)
        else
          if ln1 contains "PH_NOTICKETS" then
            if the movieName contains "pellehyppy" then
              openHyppylippu()
            end if
          else
            if ln1 contains "JUMPDATA" then
              goJumper = void()
              gPellePlayer = void()
              sprite(40).undefined = []
              if the frameLabel contains "jumpingplace" then
                gPellePlayer = new(script("PellePlayerParent"), data.getProp(#line, 2), data.getProp(#line, 3))
                go("jumpplay")
              else
                if the frameLabel contains "pool_b" then
                  gPellePlayer = new(script("PellePlayerParent"), data.getProp(#line, 2), data.getProp(#line, 3))
                end if
              end if
            else
              if ln1 contains "JUMPLIFTDOOR_OPEN" then
                sendSprite(gElevatorDoorSprite, #open)
              else
                if ln1 contains "JUMPLIFTDOOR_CLOSE" then
                  sendSprite(gElevatorDoorSprite, #close)
                else
                  if ln1 contains "JUMPINGPLACE_OK" then
                    go("jumpingplace")
                  else
                    if ln1 contains "FLAT_RESULTS" then
                      s1 = ""
                      s2 = ""
                      s3 = ""
                      s4 = ""
                      oldDelim = the itemDelimiter
                      if ln1 contains "BUSY" then
                        member("flat_results.description").text = AddTextToField("MostPopularRooms")
                      else
                        if ln1 contains "FAVORITE" then
                          member("flat_results.description").text = AddTextToField("FavoriteRooms")
                        else
                          member("flat_results.description").text = AddTextToField("SearchResults")
                        end if
                      end if
                      member("flat_results.doorstatus").text = ""
                      member("flat_results.names").text = ""
                      member("flat_results.load").text = ""
                      member("flats_go").text = ""
                      gFlats = []
                      the itemDelimiter = "/"
                      i = 2
                      repeat while i <= the number of line in data
                        flat = data.line[i]
                        if flat.length > 1 then
                          ownerName = flat.item[3]
                          if (ownerName = "-") then
                            ownerName = ""
                          else
                            ownerName = "(" & ownerName & ")"
                          end if
                          doorMode = flat.item[4]
                          if (doorMode = "open") then
                          else
                            if (doorMode = "password") then
                              if the platform contains "mac" then
                              else
                              end if
                            else
                              if the platform contains "mac" then
                              else
                              end if
                            end if
                          end if
                          add(gFlats, [data.line[i]])
                        end if
                        i = (1 + i)
                      end repeat
                      the itemDelimiter = oldDelim
                      member("flat_results.load").text = s1
                      member("flat_results.names").text = s2
                      member("flat_results.doorstatus").text = s3
                      member("flats_go").text = s4
                    else
                      if ln1 contains "NOFLATS" then
                        put(data)
                        if not the movieName contains "entry" then
                          return()
                        end if
                        member("flat_results.doorstatus").text = ""
                        member("flat_results.names").text = ""
                        member("flat_results.load").text = ""
                        member("flats_go").text = ""
                        gFlats = []
                      else
                        if ln1 contains "FLATINFO" then
                          p = keyValueToPropList(data, "\r")
                          if voidp(gProps) then
                            gProps = [:]
                          end if
                          put(gProps)
                          setaProp(gProps, #doorMode, symbol(getaProp(p, "doormode")))
                          setaProp(gProps, #showOwnerName, (getaProp(p, "showOwnerName") = "true"))
                          setaProp(gProps, #superuser, (getaProp(p, "allsuperuser") = "true"))
                          sFrame = "roominfochange"
                          goContext(sFrame, gPopUpContext2)
                        else
                          if ln1 contains "YOUAREOWNER" then
                            gIAmOwner = 1
                          else
                            if ln1 contains "FLAT_LETIN" then
                              if the movieName contains "entry" then
                                member("flat_load.status").text = AddTextToField("DoorOpenLoading")
                              end if
                              if (gChosenFlatDoorMode = "closed") then
                                goContext("flat_locked_opens", gPopUpContext2)
                              end if
                              if (gChosenFlatDoorMode = "x") then
                                goContext("flat_password_ok", gPopUpContext2)
                              end if
                              updateStage()
                              gIAmOwner = 0
                              gFlatLetIn = 1
                              member("loading_txt").text = AddTextToField("LoadingRoom")
                              setBanner()
                              hiliter = 0
                              NowinUnit = "Private Room:" && member("goingto_roomname").text
                              member(getmemnum("room.info")).text = AddTextToField("Room") && member("goingto_roomname").text & "\r" & AddTextToField("Owner") && gChosenFlatOwner
                              startLoading()
                              goContext("FLAT_LOADING", gPopUpContext2)
                            else
                              if ln1 contains "DOORBELL_RINGING" then
                                openRingbellAlert(data.line[2])
                              else
                                if ln1 contains "FLATPROPERTY" then
                                  ln2 = data.line[2]
                                  oldDelim = the itemDelimiter
                                  the itemDelimiter = "/"
                                  parType = ln2.item[1]
                                  parValue = ln2.item[2]
                                  the itemDelimiter = oldDelim
                                  put(parType, parValue)
                                  if (parType = "wallpaper") then
                                    setWallPaper(integer(parValue))
                                  else
                                    if (parType = "floor") then
                                      setFloor(integer(parValue))
                                    end if
                                  end if
                                else
                                  if ln1 contains "STUFFTYPES" then
                                    s = ""
                                    oldDelim = the itemDelimiter
                                    the itemDelimiter = "/"
                                    gpStuffTypes = [:]
                                    i = 2
                                    repeat while i <= the number of line in data
                                      ln = data.line[i]
                                      addProp(gpStuffTypes, ln.item[2], [ln.item[1], ln.item[4], ln.item[5], 0])
                                      i = (1 + i)
                                    end repeat
                                    the itemDelimiter = oldDelim
                                  else
                                    if ln1 contains "ACTIVE_OBJECTS" or ln1 contains "ACTIVEOBJECT_ADD" then
                                      i = 2
                                      repeat while i <= the number of line in data
                                        ln = data.line[i]
                                        if ln.length > 4 then
                                          createActiveObject(ln)
                                        end if
                                        i = (1 + i)
                                      end repeat
                                      exit repeat
                                    end if
                                    if ln1 contains "STUFFDATAUPDATE" then
                                      tSaveDelim = the itemDelimiter
                                      the itemDelimiter = "/"
                                      tid = data.getPropRef(#line, 2).getProp(#item, 1)
                                      ttype = data.getPropRef(#line, 2).getProp(#item, 2)
                                      tProp = data.getPropRef(#line, 2).getProp(#item, 3)
                                      tValue = data.getPropRef(#line, 2).getProp(#item, 4)
                                      the itemDelimiter = tSaveDelim
                                      tObj = sprite(getaProp(gpObjects, ttype & tid)).getProp(#scriptInstanceList, 1)
                                      tObj.updateStuffdata(tProp, tValue)
                                    else
                                      if ln1 contains "ACTIVEOBJECT_UPDATE" then
                                        oldDelim = the itemDelimiter
                                        the itemDelimiter = ","
                                        objectName = data.word[1].item[1]
                                        if offset("*", objectName) > 0 then
                                          objectName = objectName.char[1..(offset("*", objectName) - 1)] & objectName.char[(offset("*", objectName) + 2)..objectName.length]
                                        end if
                                        spr = getaProp(gpObjects, objectName)
                                        if spr > 0 then
                                          sendSprite(spr, #die)
                                        end if
                                        createActiveObject(data.line[2], 1)
                                        the itemDelimiter = oldDelim
                                        gChosenStuffSprite = getObjectSprite(objectName)
                                      else
                                        if ln1 contains "ACTIVEOBJECT_REMOVE" then
                                          objectName = data.line[2]
                                          if offset("*", objectName) > 0 then
                                            objectName = objectName.char[1..(offset("*", objectName) - 1)] & objectName.char[(offset("*", objectName) + 2)..objectName.length]
                                          end if
                                          put("rem:", objectName)
                                          spr = getaProp(gpObjects, objectName)
                                          if spr > 0 then
                                            sendSprite(spr, #die)
                                          end if
                                        else
                                          if ln1 contains "ITEMMSG" then
                                            itemId = integer(ln1.word[2])
                                            o = getaProp(gpInteractiveItems, itemId)
                                            if objectp(o) then
                                              processItemMessage(o, data)
                                            end if
                                          else
                                            if ln1 contains "OPEN_GAMEBOARD" then
                                              openGameBoard(data.line[2..the number of line in data])
                                            else
                                              if ln1 contains "CLOSE_GAMEBOARD" then
                                                closeGameBoard(data.line[2..the number of line in data])
                                              else
                                                if ln1 contains "STRIPUPDATED" or ln1 contains "ADDSTRIPITEM" then
                                                  if not the movieName contains "private" then
                                                  end if
                                                  sendFuseMsg("GETSTRIP new")
                                                  gChosenStripLevel = "new"
                                                else
                                                  if ln1 contains "TRADE_ITEMS" then
                                                    if not objectp(gTraderWindow) then
                                                      gConfirmPopUp = new(script("PopUp Context Class"), 2000000000, 871, 887, point(0, 0))
                                                      displayFrame(gConfirmPopUp, "tradeItem_dialog")
                                                      sprite(882).initTrade()
                                                      sendFuseMsg("GETSTRIP new")
                                                    end if
                                                    if objectp(gTraderWindow) then
                                                      if gTraderWindow.pClosing then
                                                        sprite(882).initTrade()
                                                        sendFuseMsg("GETSTRIP new")
                                                      else
                                                        tradeItems(gTraderWindow, data)
                                                      end if
                                                    end if
                                                  else
                                                    if ln1 contains "TRADE_ACCEPT" then
                                                      if objectp(gTraderWindow) then
                                                        tradeAccept(gTraderWindow, data)
                                                      end if
                                                    else
                                                      if ln1 contains "TRADE_CLOSE" then
                                                        if objectp(gTraderWindow) then
                                                          tradeClose(gTraderWindow, data)
                                                        end if
                                                      else
                                                        if ln1 contains "TRADE_COMPLETED" then
                                                          if objectp(gTraderWindow) then
                                                            tradeCompleted(gTraderWindow, data)
                                                          end if
                                                        else
                                                          if ln1 contains "CATALOGURL" then
                                                            gWaitCatStart = the ticks
                                                            loadCatalog(data.line[2])
                                                            gWaitCatalog = 1
                                                          else
                                                            if ln1 contains "ITEMS" then
                                                              handleAddItems(data.line[2..the number of line in data])
                                                            else
                                                              if ln1 contains "ADDITEM" then
                                                                oldDelim = the itemDelimiter
                                                                createItem(data.line[2..the number of line in data])
                                                                the itemDelimiter = oldDelim
                                                              else
                                                                if ln1 contains "UPDATEITEM" then
                                                                  oldDelim = the itemDelimiter
                                                                  createItem(data.line[2..the number of line in data], 1)
                                                                  the itemDelimiter = oldDelim
                                                                else
                                                                  if ln1 contains "STRIPINFO" then
                                                                    if (goUserStrip = void()) then
                                                                      goUserStrip = new(script("UserStrip Class"))
                                                                    end if
                                                                    handleStripData(goUserStrip, data.line[2..the number of line in data])
                                                                    if label(gWorldType & "_hand_open") > the frame then
                                                                      goToFrame(gWorldType & "_hand_open")
                                                                    else
                                                                      if label(gWorldType & "_hand_open") < the frame and label(gWorldType & "_hand_open_b") > the frame then
                                                                        goToFrame(gWorldType & "_hand_open_b")
                                                                      else
                                                                        prepareHandItems(goUserStrip)
                                                                      end if
                                                                    end if
                                                                  else
                                                                    if ln1 contains "FLATCREATED" then
                                                                      put("FLATCREATED")
                                                                      id = data.word[1]
                                                                      gChosenFlatId = id
                                                                      gFloorHost = data.word[2]
                                                                      gFloorPort = data.word[3]
                                                                      if getmemnum("roomkiosk.roomname") > 0 then
                                                                        s = "roomkiosk.description" & field(0)
                                                                        s = "room_password" & field(0)
                                                                        s = s & "\r" & "allsuperuser=" & getaProp(gProps, #superuser)
                                                                        sendEPFuseMsg("SETFLATINFO /" & id & "/" & s)
                                                                        roomName = data.line[3]
                                                                        if roomName.length < 2 then
                                                                          roomName = field(0)
                                                                        end if
                                                                        member("goingto_roomname").text = data.line[3]
                                                                        NowinUnit = "Private Room:" && member("goingto_roomname").text
                                                                        member(getmemnum("room.info")).text = AddTextToField("Room") && member("goingto_roomname").text & "\r" & AddTextToField("Owner") && gMyName
                                                                        s = member("roomkiosk.confirmtext").text
                                                                        member("roomkiosk.confirmtext").text = s
                                                                        goContext("confirm")
                                                                      end if
                                                                    else
                                                                      if ln1 contains "ALLUNITS" then
                                                                        UnitsIDNum = 0
                                                                        the itemDelimiter = ","
                                                                        gUnits = [:]
                                                                        sort(gUnits)
                                                                        num = 1
                                                                        put(data)
                                                                        i = 2
                                                                        repeat while i <= the number of line in data
                                                                          unit = data.line[i]
                                                                          if unit.length > 5 and not unit contains "Floor1" then
                                                                            newUnit(unit, num)
                                                                            num = (num + 1)
                                                                          else
                                                                            if unit contains "Floor1" then
                                                                              member("privaterooms.load").text = unit.item[2]
                                                                            end if
                                                                          end if
                                                                          i = (1 + i)
                                                                        end repeat
                                                                        exit repeat
                                                                      end if
                                                                      if ln1 contains "UNITUPDATED" then
                                                                        the itemDelimiter = ","
                                                                        unit = data.line[2]
                                                                        name = unit.item[1]
                                                                        l = getaProp(gUnits, name)
                                                                        if name contains "Floor1" then
                                                                          if the movieName contains "entry" then
                                                                            member("privaterooms.load").text = unit.item[2]
                                                                          end if
                                                                        else
                                                                          if (l = void()) then
                                                                            nothing()
                                                                          else
                                                                            num = l.getAt(5)
                                                                            activeUsers = integer(unit.item[2])
                                                                            maxUsers = integer(unit.item[3])
                                                                            host = unit.item[4]
                                                                            port = integer(unit.item[5])
                                                                            description = unit.item[6]
                                                                            UnitPropL = getaProp(gUnits, name)
                                                                            UnitPropL.activeUsers = activeUsers
                                                                            UnitPropL.maxUsers = maxUsers
                                                                            UnitPropL.host = host
                                                                            UnitPropL.port = port
                                                                            UnitPropL.description = description
                                                                            setProp(gUnits, name, UnitPropL)
                                                                            if not name contains "Floor" then
                                                                              setUnitActiveUsers(name)
                                                                            else
                                                                              member("privaterooms.load").text = unit.item[2]
                                                                            end if
                                                                          end if
                                                                        end if
                                                                      else
                                                                        if ln1 contains "UNITMEMBERS" then
                                                                          s = data.line[2..the number of line in data]
                                                                          s2 = ""
                                                                          i = 1
                                                                          repeat while i <= the number of line in s
                                                                            i = (1 + i)
                                                                          end repeat
                                                                          if getmemnum("publicroom_peoplelist") > 0 then
                                                                          end if
                                                                          if the movieName contains "cr_entry" then
                                                                          end if
                                                                        else
                                                                          if ln1 contains "REMOVEITEM" then
                                                                            itemId = integer(data.line[2])
                                                                            sendAllSprites(#itemDie, itemId)
                                                                          else
                                                                            if ln1 contains "FLATINFO" then
                                                                              the itemDelimiter = "="
                                                                              i = 2
                                                                              repeat while i <= the number of line in data
                                                                                ln = data.line[i]
                                                                                sfield = ln.item[1]
                                                                                sdata = ln.item[2]
                                                                                if getmemnum("flatinfoshow." & sfield) > 0 then
                                                                                  member("flatinfoshow." & sfield).text = sdata
                                                                                end if
                                                                                put(sfield, sdata)
                                                                                if (sfield = "image") then
                                                                                  pictureUrl = sdata
                                                                                  put(pictureUrl)
                                                                                end if
                                                                                if (sfield = "isOpen") then
                                                                                  if (sdata = "true") then
                                                                                    member("flatinfoshow.open_info").text = "Door is open"
                                                                                    sprite(20).visible = 1
                                                                                  else
                                                                                    member("flatinfoshow.open_info").text = "Door is closed"
                                                                                    sprite(20).visible = 0
                                                                                  end if
                                                                                end if
                                                                                if (sfield = "host") then
                                                                                  gFloorHost = sdata.char[(offset("/", sdata) + 1)..sdata.length]
                                                                                end if
                                                                                if (sfield = "port") then
                                                                                  gFloorPort = sdata
                                                                                end if
                                                                                i = (1 + i)
                                                                              end repeat
                                                                              the itemDelimiter = ","
                                                                            else
                                                                              if ln1 contains "ADVERTISEMENT" then
                                                                                put("GOT AD", data)
                                                                                gAd = new(script("FUSE Advertisement Class"), data.line[2..the number of line in data])
                                                                              else
                                                                                if ln1 contains "OPLOGO" then
                                                                                  handleOpLogoMessage(data)
                                                                                else
                                                                                  if ln1 contains "SYSTEMBROADCAST" then
                                                                                    ShowAlert("MessageFromAdmin", data.line[2])
                                                                                  else
                                                                                    if ln1 contains "PURCHASE_NOBALANCE" then
                                                                                      ShowAlert("nobalance", "You don't have enough credits!")
                                                                                    else
                                                                                      if ln1 contains "PURCHASE_OK" then
                                                                                        ShowAlert("BuyingOK")
                                                                                      else
                                                                                        if ln1 contains "PURCHASE_ERROR" then
                                                                                          ShowAlert("purchasingerror", "Purchasing error")
                                                                                        else
                                                                                          if ln1 contains "ORDERINFO_ERROR" then
                                                                                            put(data)
                                                                                          else
                                                                                            if ln1 contains "ORDERINFO" then
                                                                                              gPurchaseCode = data.line[2]
                                                                                              price = integer(value(data.line[3]))
                                                                                              description = data.line[5]
                                                                                              gConfirmPopUp = new(script("PopUp Context Class"), 2000020000, 851, 870, point(0, 0))
                                                                                              if price > gCredits then
                                                                                                displayFrame(gConfirmPopUp, "purchase_confirm_nocredits")
                                                                                              else
                                                                                                displayFrame(gConfirmPopUp, "purchase_confirm")
                                                                                              end if
                                                                                            else
                                                                                              if ln1 contains "WALLETBALANCE" then
                                                                                                if the movieName contains "entry" and the frame < 100 or the movieName contains "cr_entry" then
                                                                                                  nothing()
                                                                                                else
                                                                                                  puppetSound(1, "cash1")
                                                                                                end if
                                                                                                gCredits = integer(value(data.line[2]))
                                                                                                member("habbo_credits").text = integer(value(data.line[2])) && AddTextToField("Credit(s)")
                                                                                                member("credits_amount_e").text = "You have" && integer(value(data.line[2])) && "Habbo Credits in your purse."
                                                                                              else
                                                                                                if ln1 contains "DOORFLAT" then
                                                                                                  gChosenTeleport.startTeleport(data)
                                                                                                else
                                                                                                  if ln1 contains "DOORNOTINSTALLED" then
                                                                                                    gChosenTeleport.error(data)
                                                                                                  else
                                                                                                    if ln1 contains "DOORDELETED" then
                                                                                                      gChosenTeleport.error(data)
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

on handleAddItems itemList 
  put(itemList)
  oldDelim = the itemDelimiter
  the itemDelimiter = "\\__ITEM"
  c = the number of item in itemList
  i = 1
  repeat while i <= c
    s = itemList.item[i]
    if s.length > 10 then
      if s starts "__ITEM" then
        s = s.char[7..s.length]
      end if
      createItem(s)
    end if
    the itemDelimiter = "\\__ITEM"
    i = (1 + i)
  end repeat
  the itemDelimiter = oldDelim
end

on createItem s, update 
  the itemDelimiter = ";"
  s1 = s.line[1]
  s2 = s.line[2..the number of line in s]
  id = integer(s1.item[1])
  itemType = s1.item[2]
  owner = s1.item[3]
  location = s1.item[4]
  data = s2
  if not update then
    if getmemnum(itemType && "ItemClass") > 0 then
      o = new(script(itemType && "ItemClass"), owner, location, id, data)
    end if
  else
    sendAllSprites(#updateItem, id, location, data)
  end if
end

on relogin  
  sprMan_clearAll()
  gmemnamedb = void()
  if the movieName contains "private" then
    sendFuseMsg("GOTOFLAT /" & gChosenFlatId)
  else
    sendFuseMsg("RELOGIN")
  end if
end

on createActiveObject ln, update 
  oldDelim = the itemDelimiter
  the itemDelimiter = "/"
  state = ln.item[1]
  content = doSpecialCharConversion(ln)
  the itemDelimiter = ","
  name = state.item[1]
  other = state.char[(offset(",", state) + 1)..state.length]
  type = other.word[1]
  x = integer(other.word[2])
  y = integer(other.word[3])
  w = integer(other.word[4])
  h = integer(other.word[5])
  dir = integer(other.word[6])
  altitude = float(other.word[7])
  partColors = other.word[8]
  put("altitude", altitude)
  the itemDelimiter = "/"
  pData = [:]
  b = 1
  showName = ln.item[2]
  showDescription = ln.item[3]
  j = 4
  repeat while b
    key = ln.item[j]
    data = ln.item[(j + 1)]
    if (key.length = 0) then
      b = 0
    else
      addProp(pData, key, data)
    end if
    j = (j + 2)
  end repeat
  o = createFuseObject(name, type, "0", x, y, 0, [dir, dir, dir], [w, h], altitude, pData, partColors, update)
  the itemDelimiter = oldDelim
  if (getaProp(o, #ancestor) = void()) then
    setaProp(o, #showName, showName)
    setaProp(o, #showDescription, showDescription)
  else
    setaProp(o.ancestor, #showName, showName)
    setaProp(o.ancestor, #showDescription, showDescription)
  end if
end

on getPlayerClass  
  if the movieName contains "pellehyppy" then
    return("Pelle")
  else
    return("Human")
  end if
end

on buyStuff stuffType 
  sendFuseMsg("BUYSTUFF" && stuffType)
end

on openFlatInfo num, gogo 
  if voidp(gFlats) then
    return()
  end if
  if num > 0 and num <= count(gFlats) then
    s = gFlats.getAt(num).getAt(1)
    the itemDelimiter = "/"
    put(s)
    if s.length > 0 then
      gFloorHost = s.item[8]
      gFloorPort = integer(s.item[9])
      doorOpen = s.item[4]
      if (doorOpen = "open") then
        doorInfo = AddTextToField("DoorOpen")
      else
        if (doorOpen = "closed") then
          doorInfo = AddTextToField("DoorClosed")
        else
          if (doorOpen = "password") then
            doorInfo = AddTextToField("DoorPassword")
          end if
        end if
      end if
      gChosenFlatId = integer(s.item[1])
      ownerName = s.item[3]
      if (ownerName = "-") then
        ownerName = "not shown"
      end if
      gChosenFlatOwner = ownerName
      member("flatinfo.doormode").text = doorInfo
      member("privateroom_infotext").text = s.item[12..the number of item in s]
      member("flatinfo.head").text = s.item[2] && "(" & s.item[10] & "/25)" & "\r" & AddTextToField("Owner") && ownerName
      member("goingto_roomname").text = s.item[2]
      gChosenFlatDoorMode = doorOpen
      if (s.item[11] = "1") then
        member("BobbaFilter.privateroom").text = AddTextToField("NoBobbaFilter")
      else
        member("BobbaFilter.privateroom").text = " "
      end if
      if (gogo = 1) then
        nothing()
      else
        goContext("private_place.info", gPopUpContext2)
      end if
      if (doorOpen = "closed") then
        sendSprite(getaProp(gpUiButtons, "ringbell"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "ringbell"), #disable)
      end if
      if doorOpen <> "closed" or (s.item[3] = gMyName) then
        sendSprite(getaProp(gpUiButtons, "goflat"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "goflat"), #disable)
      end if
      sendSprite(gRoomModeIndicatorSpr, #setMode, doorOpen)
      if (ownerName = gMyName) then
        sendSprite(getaProp(gpUiButtons, "roommodify"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "roommodify"), #disable)
      end if
      if (doorOpen = "open") or (gMyName = ownerName) then
        member("doortxt_buttonin").text = AddTextToField("GoInside")
      else
        if (doorOpen = "closed") then
          member("doortxt_buttonin").text = AddTextToField("RingDoorBell")
        else
          member("doortxt_buttonin").text = AddTextToField("InsidePassword")
        end if
      end if
    end if
  end if
  the itemDelimiter = ","
end

on flatScroll num 
  scrollByLine(member("flat_results.load"), num)
  scrollByLine(member("flat_results.names"), num)
  scrollByLine(member("flat_results.doorstatus"), num)
end

on emptyFlatInfo  
  member("flatinfo.head").text = " "
  member("flatinfo.text").text = " "
end

on goToFlat flatId 
  gConnectionInstance = 0
  gFloor = 111
  gWallPaper = 201
  gChosenUnitIp = gFloorHost
  gChosenUnitPort = integer(gFloorPort)
  gChosenFlatId = flatId
  put(gChosenUnitIp, gChosenUnitPort, gChosenFlatId)
  gGoTo = "one_room"
  goUnit("gf_private")
end

on GoToFlatWithNavi flatId 
  put(gChosenFlatDoorMode)
  gFloor = 111
  gWallPaper = 201
  member("flat_load.status").text = ""
  if (gChosenFlatDoorMode = "password") then
    goContext("flat_load_password", gPopUpContext2)
  else
    gConnectionInstance = 0
    gChosenUnitIp = gFloorHost
    gChosenUnitPort = integer(gFloorPort)
    gChosenFlatId = flatId
    Logon()
    gFlatWaitStart = the milliSeconds
    if (gChosenFlatDoorMode = "x") and (gPopUpContext2.frame = "flat_load_password") then
      goContext("flat_trying_password", gPopUpContext2)
    end if
    if (gChosenFlatDoorMode = "closed") then
      goContext("flat_load_locked", gPopUpContext2)
    end if
    if (gChosenFlatDoorMode = "open") then
      goContext("flat_load", gPopUpContext2)
    end if
  end if
end

on newUnit unit, num 
  name = unit.item[1]
  activeUsers = integer(unit.item[2])
  maxUsers = integer(unit.item[3])
  host = unit.item[4]
  port = integer(unit.item[5])
  description = unit.item[6]
  the itemDelimiter = "\t"
  if (gUnit_otherRooms = void()) then
    member("public_place.hierarchy").text = ""
    gUnit_otherRooms = [:]
    UnitsIDNum = 0
  end if
  OtherR = []
  OtherRooms = []
  if unit.count(#item) > 2 then
    f = 2
    repeat while f <= unit.count(#item)
      OtherR.append(unit.item[f])
      f = (1 + f)
    end repeat
    gUnit_otherRooms.addProp(name, OtherR)
    OtherRooms = gUnit_otherRooms.getaProp(name)
  end if
  the itemDelimiter = ","
  UnitsIDNum = (UnitsIDNum + 1)
  addProp(gUnits, name, ["description":description, "maxUsers":maxUsers, "activeUsers":activeUsers, "host":host, "port":port, "num":num, "name":name, "UnitsIDNum":UnitsIDNum, "otherRooms":OtherRooms, "UnitsIDNum":UnitsIDNum])
  UnitsIDNum = (UnitsIDNum + OtherR.count)
  UnitHierarchyField(name, OtherR.count)
  if the movieName contains "cr_entry" then
    setUnitActiveUsers(name)
  end if
end

on UnitHierarchyField name, RoomS 
  lineN = gUnits.getaProp(name).getaProp("UnitsIDNum")
  if RoomS > 1 then
    f = 1
    repeat while f <= gUnit_otherRooms.getaProp(name).count
      f = (1 + f)
    end repeat
  end if
end

on SetAllUnitUsers  
  if (gUnits = void()) or voidp(gPlaceNamesGraph) or (gNaviWindowsSpr = 0) then
    return()
  else
    NumOfUnits = 1
    repeat while NumOfUnits <= gUnits.count
      setUnitActiveUsers(getAt(gUnits, NumOfUnits).name)
      NumOfUnits = (1 + NumOfUnits)
    end repeat
  end if
end

on setUnitActiveUsers name 
  if the movieName contains "cr_entry" then
    if getmemnum(name & ".info") > 0 then
      ni = name & ".info"
      ln1 = NULL
      l = gUnits.getaProp(name)
      ln1 = ln1.getProp(#word, 1, (ln1.count(#word) - 1)) && "(" & getaProp(l, "activeUsers") & "/" & getaProp(l, "maxUsers") & ")"
      field(0).textFont = "Volter-Bold (Goldfish)"
      return()
    end if
  end if
  if gUnits <> void() and gPlaceNamesGraph <> void() then
    UnitIsUpdated = 1
    l = gUnits.getaProp(name)
    InsideOfUnitNow(l.name, l.activeUsers, l.maxUsers)
    setProp(gPalaceInsideNowGraph, l.name, the result)
    if l.getaProp("otherRooms") <> "[]" and not voidp(l.getaProp("otherRooms")) and l.getaProp("otherRooms").count > 0 then
      oldItemLimiter = the itemDelimiter
      the itemDelimiter = ","
      f = 1
      repeat while f <= l.getaProp("otherRooms").count
        UnitAUsers = getAt(l.getaProp("otherRooms"), f).getProp(#item, 2)
        MaxUnitAUsers = getAt(l.getaProp("otherRooms"), f).getProp(#item, 3)
        UnitAName = getAt(l.getaProp("otherRooms"), f).getProp(#item, 1)
        InsideOfUnitNow(UnitAName, UnitAUsers, MaxUnitAUsers)
        setProp(gPalaceInsideNowGraph, UnitAName, the result)
        if (ClickPlaceNum = (l.UnitsIDNum + f)) then
          sendSprite(gNaviWindowsSpr, #showInfo, UnitAName)
        end if
        f = (1 + f)
      end repeat
      the itemDelimiter = oldItemLimiter
    end if
    if gPopUpContext2 <> void() then
      if gNaviWindowsSpr <> void() and gNaviWindowsSpr <> 0 and gPopUpContext2.frame contains "public" then
        if (ClickPlaceNum = l.UnitsIDNum) then
          sendSprite(gNaviWindowsSpr, #showInfo, l.name)
        end if
      end if
    end if
  end if
end

on InsideOfUnitNow name, UnitactUsers, UnitMaxUsers 
  if value(UnitactUsers) > value(UnitMaxUsers) then
    UnitactUsers = "8"
  end if
  TempImg = image(gPalaceInsideNowGraph.getaProp(name).width, gPalaceInsideNowGraph.getaProp(name).height, 8)
  MakeImgToImg(TempImg, member("sulku.vasen").image, point(0, 0))
  TempImg = the result
  MakeImgToImg(TempImg, gNumGraph.getAt((UnitactUsers + 1)), point(4, 0))
  TempImg = the result
  MakeImgToImg(TempImg, member("kauttaviiva").image, point((gNumGraph.getAt((UnitactUsers + 1)).width + 4), 0))
  TempImg = the result
  MakeImgToImg(TempImg, gNumGraph.getAt((UnitMaxUsers + 1)), point((gNumGraph.getAt((UnitactUsers + 1)).width + 13), 0))
  TempImg = the result
  MakeImgToImg(TempImg, member("sulku.oikea").image, point(((gNumGraph.getAt((UnitactUsers + 1)).width + 13) + gNumGraph.getAt((UnitMaxUsers + 1)).width), 0))
  TempImg = the result
  return(TempImg)
end

on reserveRoom  
  if (getaProp(gProps, #showOwnerName) = 0) then
    showName = 0
  else
    showName = 1
  end if
  put(field(0) & ":" && gProps)
  fuseP = "roomkiosk.roomname" & field(0) & "/" & getaProp(gProps, #roomModel) & "/" & string(getaProp(gProps, #doorMode)) & "/" & showName
  sendEPFuseMsg("CREATEFLAT /" & fuseP)
end

on updateFlatInfo  
  if (getaProp(gProps, #showOwnerName) = 0) then
    showName = 0
  else
    showName = 1
  end if
  fuseP = "navigator.roomname" & field(0)
  fuseP = fuseP & "/" & string(getaProp(gProps, #doorMode))
  fuseP = fuseP & "/" & showName
  sendEPFuseMsg("UPDATEFLAT /" & fuseP)
  s = "navigator.description" & field(0)
  s = "roompassword" & field(0)
  s = s & "\r" & "allsuperuser=" & getaProp(gProps, #superuser)
  s = s & "\r" & "wordfilter_disable=" & getaProp(gProps, #wordfilter_disable)
  put(s)
  sendEPFuseMsg("SETFLATINFO /" & gChosenFlatId & "/" & s)
end

on flatPasswordIncorrect  
  member("flat_load.status").text = AddTextToField("WrongRoomPassword")
end

on handleActiveObjects ln 
end

on WhichMember whichPart, small 
  if small <> 1 then
    prefix = "h_"
  else
    prefix = "sh_"
  end if
  memName = prefix & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & "0"
  if the movieName contains "operatorlogo" then
    memName = prefix & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "2" & "_" & "0"
    if (memName = "sh_std_hd_002_2_0") then
      memName = "sh_std_hd_001_2_0"
    end if
  end if
  memNum = sprite(0).number
  return(memNum)
end
