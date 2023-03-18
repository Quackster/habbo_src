global gpStuffTypes, goUserStrip, gpObjects, gChosenStripLevel, gcatName, gWaitCatalog, gWaitCatStart, pictureNetId, pictureUrl, gChosenStuffSprite, gFloorHost, gFloorPort, gChosenFlatId, gGoTo, gUnits, gChosenFlat, gChosenFlatDoorMode, gFlats, gChosenUnitIp, gChosenUnitPort, gConnectionInstance, gpUiButtons, gMyName, gFlatLetIn, gWorldType, gUnit_otherRooms, gChosenRoomName, gPopUpContext2, gTraderWindow, gChosenFlatOwner

on handleSpecialMessages data
  global goJumper, gPellePlayer, gElevatorDoorSprite, gIAmOwner, gChosenFlatDoorMode, hiliter, gPopUpContext2, gpInteractiveItems, gProps, NowinUnit, UnitsIDNum, gAd, gPurchaseCode, gConfirmPopUp, gCredits, gChosenTeleport
  ln1 = line 1 of data
  data = doSpecialCharConversion(data)
  if ln1 contains "OPEN_UIMAKOPPI" then
    openUimakoppi()
  else
    if ln1 contains "CLOSE_UIMAKOPPI" then
      closeUimaKoppi()
    else
      if ln1 contains "PH_TICKETS_BUY" then
        put data
        member("JumpTICKETS").text = data.line[2].word[1]
        if the movieName contains "pellehyppy" then
          openHyppylippu()
        end if
      else
        if ln1 contains "PH_TICKETS" then
          put data
          member("JumpTICKETS").text = ln1.word[2]
        else
          if ln1 contains "PH_NOTICKETS" then
            if the movieName contains "pellehyppy" then
              openHyppylippu()
            end if
          else
            if ln1 contains "JUMPDATA" then
              goJumper = VOID
              gPellePlayer = VOID
              set the scriptInstanceList of sprite 40 to []
              if the frameLabel contains "jumpingplace" then
                gPellePlayer = new(script("PellePlayerParent"), data.line[2], data.line[3])
                go("jumpplay")
              else
                if the frameLabel contains "pool_b" then
                  gPellePlayer = new(script("PellePlayerParent"), data.line[2], data.line[3])
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
                      s1 = EMPTY
                      s2 = EMPTY
                      s3 = EMPTY
                      s4 = EMPTY
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
                      member("flat_results.doorstatus").text = EMPTY
                      member("flat_results.names").text = EMPTY
                      member("flat_results.load").text = EMPTY
                      member("flats_go").text = EMPTY
                      gFlats = []
                      the itemDelimiter = "/"
                      repeat with i = 2 to the number of lines in data
                        flat = line i of data
                        if flat.length > 1 then
                          ownerName = item 3 of flat
                          if ownerName = "-" then
                            ownerName = EMPTY
                          else
                            ownerName = "(" & ownerName & ")"
                          end if
                          doorMode = item 4 of flat
                          put "Go >>" & RETURN after ln1
                          if doorMode = "open" then
                            put RETURN after ln1
                          else
                            if doorMode = "password" then
                              if the platform contains "mac" then
                                put numToChar(237) & RETURN after ln1
                              else
                                put numToChar(204) & RETURN after ln1
                              end if
                            else
                              if the platform contains "mac" then
                                put numToChar(212) & RETURN after ln1
                              else
                                put numToChar(145) & RETURN after ln1
                              end if
                            end if
                          end if
                          put item 10 of flat & RETURN after ln1
                          put item 2 of flat & RETURN after ln1
                          add(gFlats, [line i of data])
                        end if
                      end repeat
                      the itemDelimiter = oldDelim
                      member("flat_results.load").text = s1
                      member("flat_results.names").text = s2
                      member("flat_results.doorstatus").text = s3
                      member("flats_go").text = s4
                    else
                      if ln1 contains "NOFLATS" then
                        put data
                        if not (the movieName contains "entry") then
                          return 
                        end if
                        member("flat_results.doorstatus").text = EMPTY
                        member("flat_results.names").text = EMPTY
                        member("flat_results.load").text = EMPTY
                        member("flats_go").text = EMPTY
                        gFlats = []
                      else
                        if ln1 contains "FLATINFO" then
                          p = keyValueToPropList(data, RETURN)
                          put getaProp(p, "name") into field "navigator.roomname"
                          put getaProp(p, "description") into field "navigator.description"
                          if voidp(gProps) then
                            gProps = [:]
                          end if
                          put gProps
                          setaProp(gProps, #doorMode, symbol(getaProp(p, "doormode")))
                          setaProp(gProps, #showOwnerName, getaProp(p, "showOwnerName") = "true")
                          setaProp(gProps, #superuser, getaProp(p, "allsuperuser") = "true")
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
                              if gChosenFlatDoorMode = "closed" then
                                goContext("flat_locked_opens", gPopUpContext2)
                              end if
                              if gChosenFlatDoorMode = "x" then
                                goContext("flat_password_ok", gPopUpContext2)
                              end if
                              updateStage()
                              gIAmOwner = 0
                              gFlatLetIn = 1
                              member("loading_txt").text = AddTextToField("LoadingRoom")
                              setBanner()
                              hiliter = 0
                              NowinUnit = "Private Room:" && member("goingto_roomname").text
                              member(getmemnum("room.info")).text = AddTextToField("Room") && member("goingto_roomname").text & RETURN & AddTextToField("Owner") && gChosenFlatOwner
                              startLoading()
                              goContext("FLAT_LOADING", gPopUpContext2)
                            else
                              if ln1 contains "DOORBELL_RINGING" then
                                openRingbellAlert(line 2 of data)
                              else
                                if ln1 contains "FLATPROPERTY" then
                                  ln2 = line 2 of data
                                  oldDelim = the itemDelimiter
                                  the itemDelimiter = "/"
                                  parType = item 1 of ln2
                                  parValue = item 2 of ln2
                                  the itemDelimiter = oldDelim
                                  put parType, parValue
                                  if parType = "wallpaper" then
                                    setWallPaper(integer(parValue))
                                  else
                                    if parType = "floor" then
                                      setFloor(integer(parValue))
                                    end if
                                  end if
                                else
                                  if ln1 contains "STUFFTYPES" then
                                    s = EMPTY
                                    oldDelim = the itemDelimiter
                                    the itemDelimiter = "/"
                                    gpStuffTypes = [:]
                                    repeat with i = 2 to the number of lines in data
                                      ln = line i of data
                                      addProp(gpStuffTypes, item 2 of ln, [item 1 of ln, item 4 of ln, item 5 of ln, 0])
                                      put item 2 of ln & RETURN after s1
                                    end repeat
                                    the itemDelimiter = oldDelim
                                    put s into field "stuff_type_list"
                                  else
                                    if (ln1 contains "ACTIVE_OBJECTS") or (ln1 contains "ACTIVEOBJECT_ADD") then
                                      repeat with i = 2 to the number of lines in data
                                        ln = line i of data
                                        if ln.length > 4 then
                                          createActiveObject(ln)
                                        end if
                                      end repeat
                                    else
                                      if ln1 contains "STUFFDATAUPDATE" then
                                        tSaveDelim = the itemDelimiter
                                        the itemDelimiter = "/"
                                        tid = data.line[2].item[1]
                                        ttype = data.line[2].item[2]
                                        tProp = data.line[2].item[3]
                                        tValue = data.line[2].item[4]
                                        the itemDelimiter = tSaveDelim
                                        tObj = sprite(getaProp(gpObjects, ttype & tid)).scriptInstanceList[1]
                                        tObj.updateStuffdata(tProp, tValue)
                                      else
                                        if ln1 contains "ACTIVEOBJECT_UPDATE" then
                                          oldDelim = the itemDelimiter
                                          the itemDelimiter = ","
                                          objectName = item 1 of word 1 of line 2 of data
                                          if offset("*", objectName) > 0 then
                                            objectName = char 1 to offset("*", objectName) - 1 of objectName & char offset("*", objectName) + 2 to objectName.length of objectName
                                          end if
                                          spr = getaProp(gpObjects, objectName)
                                          if spr > 0 then
                                            sendSprite(spr, #die)
                                          end if
                                          createActiveObject(line 2 of data, 1)
                                          the itemDelimiter = oldDelim
                                          gChosenStuffSprite = getObjectSprite(objectName)
                                        else
                                          if ln1 contains "ACTIVEOBJECT_REMOVE" then
                                            objectName = line 2 of data
                                            if offset("*", objectName) > 0 then
                                              objectName = char 1 to offset("*", objectName) - 1 of objectName & char offset("*", objectName) + 2 to objectName.length of objectName
                                            end if
                                            put "rem:", objectName
                                            spr = getaProp(gpObjects, objectName)
                                            if spr > 0 then
                                              sendSprite(spr, #die)
                                            end if
                                          else
                                            if ln1 contains "ITEMMSG" then
                                              itemId = integer(word 2 of ln1)
                                              o = getaProp(gpInteractiveItems, itemId)
                                              if objectp(o) then
                                                processItemMessage(o, data)
                                              end if
                                            else
                                              if ln1 contains "OPEN_GAMEBOARD" then
                                                openGameBoard(line 2 to the number of lines in data of data)
                                              else
                                                if ln1 contains "CLOSE_GAMEBOARD" then
                                                  closeGameBoard(line 2 to the number of lines in data of data)
                                                else
                                                  if (ln1 contains "STRIPUPDATED") or (ln1 contains "ADDSTRIPITEM") then
                                                    if not (the movieName contains "private") then
                                                      exit
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
                                                              loadCatalog(line 2 of data)
                                                              gWaitCatalog = 1
                                                            else
                                                              if ln1 contains "ITEMS" then
                                                                handleAddItems(line 2 to the number of lines in data of data)
                                                              else
                                                                if ln1 contains "ADDITEM" then
                                                                  oldDelim = the itemDelimiter
                                                                  createItem(line 2 to the number of lines in data of data)
                                                                  the itemDelimiter = oldDelim
                                                                else
                                                                  if ln1 contains "UPDATEITEM" then
                                                                    oldDelim = the itemDelimiter
                                                                    createItem(line 2 to the number of lines in data of data, 1)
                                                                    the itemDelimiter = oldDelim
                                                                  else
                                                                    if ln1 contains "STRIPINFO" then
                                                                      if goUserStrip = VOID then
                                                                        goUserStrip = new(script("UserStrip Class"))
                                                                      end if
                                                                      handleStripData(goUserStrip, line 2 to the number of lines in data of data)
                                                                      if label(gWorldType & "_hand_open") > the frame then
                                                                        gotoFrame(gWorldType & "_hand_open")
                                                                      else
                                                                        if (label(gWorldType & "_hand_open") < the frame) and (label(gWorldType & "_hand_open_b") > the frame) then
                                                                          gotoFrame(gWorldType & "_hand_open_b")
                                                                        else
                                                                          prepareHandItems(goUserStrip)
                                                                        end if
                                                                      end if
                                                                    else
                                                                      if ln1 contains "FLATCREATED" then
                                                                        put "FLATCREATED"
                                                                        id = word 1 of line 2 of data
                                                                        gChosenFlatId = id
                                                                        gFloorHost = word 2 of line 2 of data
                                                                        gFloorPort = word 3 of line 2 of data
                                                                        if getmemnum("roomkiosk.roomname") > 0 then
                                                                          s = "description=" & field("roomkiosk.description")
                                                                          s = s & RETURN & "password=" & field("room_password")
                                                                          s = s & RETURN & "allsuperuser=" & getaProp(gProps, #superuser)
                                                                          sendEPFuseMsg("SETFLATINFO /" & id & "/" & s)
                                                                          roomName = line 3 of data
                                                                          if roomName.length < 2 then
                                                                            roomName = field("roomkiosk.roomname")
                                                                          end if
                                                                          member("goingto_roomname").text = line 3 of data
                                                                          NowinUnit = "Private Room:" && member("goingto_roomname").text
                                                                          member(getmemnum("room.info")).text = AddTextToField("Room") && member("goingto_roomname").text & RETURN & AddTextToField("Owner") && gMyName
                                                                          s = member("roomkiosk.confirmtext").text
                                                                          put AddTextToField("RoomNum") && id into line 3 of s
                                                                          put AddTextToField("Name") && roomName into line 4 of s
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
                                                                          put data
                                                                          repeat with i = 2 to the number of lines in data
                                                                            unit = line i of data
                                                                            if (unit.length > 5) and not (unit contains "Floor1") then
                                                                              newUnit(unit, num)
                                                                              num = num + 1
                                                                              next repeat
                                                                            end if
                                                                            if unit contains "Floor1" then
                                                                              member("privaterooms.load").text = item 2 of unit
                                                                            end if
                                                                          end repeat
                                                                        else
                                                                          if ln1 contains "UNITUPDATED" then
                                                                            the itemDelimiter = ","
                                                                            unit = line 2 of data
                                                                            name = item 1 of unit
                                                                            l = getaProp(gUnits, name)
                                                                            if name contains "Floor1" then
                                                                              if the movieName contains "entry" then
                                                                                member("privaterooms.load").text = item 2 of unit
                                                                              end if
                                                                            else
                                                                              if l = VOID then
                                                                                nothing()
                                                                              else
                                                                                num = l[5]
                                                                                activeUsers = integer(item 2 of unit)
                                                                                maxUsers = integer(item 3 of unit)
                                                                                host = item 4 of unit
                                                                                port = integer(item 5 of unit)
                                                                                description = item 6 of unit
                                                                                UnitPropL = getaProp(gUnits, name)
                                                                                UnitPropL.activeUsers = activeUsers
                                                                                UnitPropL.maxUsers = maxUsers
                                                                                UnitPropL.host = host
                                                                                UnitPropL.port = port
                                                                                UnitPropL.description = description
                                                                                setProp(gUnits, name, UnitPropL)
                                                                                if not (name contains "Floor") then
                                                                                  setUnitActiveUsers(name)
                                                                                else
                                                                                  member("privaterooms.load").text = item 2 of unit
                                                                                end if
                                                                              end if
                                                                            end if
                                                                          else
                                                                            if ln1 contains "UNITMEMBERS" then
                                                                              s = line 2 to the number of lines in data of data
                                                                              s2 = EMPTY
                                                                              repeat with i = 1 to the number of lines in s
                                                                                put line i of s & " " after ln1
                                                                              end repeat
                                                                              if getmemnum("publicroom_peoplelist") > 0 then
                                                                                put s2 into field "publicroom_peoplelist"
                                                                              end if
                                                                              if the movieName contains "cr_entry" then
                                                                                put s2 into line 2 to the number of lines in field "crroom_who" of field "crroom_who"
                                                                              end if
                                                                            else
                                                                              if ln1 contains "REMOVEITEM" then
                                                                                itemId = integer(line 2 of data)
                                                                                sendAllSprites(#itemDie, itemId)
                                                                              else
                                                                                if ln1 contains "FLATINFO" then
                                                                                  the itemDelimiter = "="
                                                                                  repeat with i = 2 to the number of lines in data
                                                                                    ln = line i of data
                                                                                    sfield = item 1 of ln
                                                                                    sdata = item 2 of ln
                                                                                    if getmemnum("flatinfoshow." & sfield) > 0 then
                                                                                      member("flatinfoshow." & sfield).text = sdata
                                                                                    end if
                                                                                    put sfield, sdata
                                                                                    if sfield = "image" then
                                                                                      pictureUrl = sdata
                                                                                      put pictureUrl
                                                                                    end if
                                                                                    if sfield = "isOpen" then
                                                                                      if sdata = "true" then
                                                                                        member("flatinfoshow.open_info").text = "Door is open"
                                                                                        sprite(20).visible = 1
                                                                                      else
                                                                                        member("flatinfoshow.open_info").text = "Door is closed"
                                                                                        sprite(20).visible = 0
                                                                                      end if
                                                                                    end if
                                                                                    if sfield = "host" then
                                                                                      gFloorHost = char offset("/", sdata) + 1 to sdata.length of sdata
                                                                                    end if
                                                                                    if sfield = "port" then
                                                                                      gFloorPort = sdata
                                                                                    end if
                                                                                  end repeat
                                                                                  the itemDelimiter = ","
                                                                                else
                                                                                  if ln1 contains "ADVERTISEMENT" then
                                                                                    put "GOT AD", data
                                                                                    gAd = new(script("FUSE Advertisement Class"), line 2 to the number of lines in data of data)
                                                                                  else
                                                                                    if ln1 contains "OPLOGO" then
                                                                                      handleOpLogoMessage(data)
                                                                                    else
                                                                                      if ln1 contains "SYSTEMBROADCAST" then
                                                                                        ShowAlert("MessageFromAdmin", line 2 of data)
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
                                                                                                put data
                                                                                              else
                                                                                                if ln1 contains "ORDERINFO" then
                                                                                                  gPurchaseCode = line 2 of data
                                                                                                  price = integer(value(line 3 of data))
                                                                                                  description = line 5 of data
                                                                                                  put description && "costs" && price && "credits" into field "purchase_item_txt_e"
                                                                                                  put "You have" && gCredits && "in your purse." into field "purchase_confirm_txt_e"
                                                                                                  gConfirmPopUp = new(script("PopUp Context Class"), 2000020000, 851, 870, point(0, 0))
                                                                                                  if price > gCredits then
                                                                                                    displayFrame(gConfirmPopUp, "purchase_confirm_nocredits")
                                                                                                  else
                                                                                                    displayFrame(gConfirmPopUp, "purchase_confirm")
                                                                                                  end if
                                                                                                else
                                                                                                  if ln1 contains "WALLETBALANCE" then
                                                                                                    if ((the movieName contains "entry") and (the frame < 100)) or (the movieName contains "cr_entry") then
                                                                                                      nothing()
                                                                                                    else
                                                                                                      puppetSound(1, "cash1")
                                                                                                    end if
                                                                                                    gCredits = integer(value(line 2 of data))
                                                                                                    member("habbo_credits").text = integer(value(line 2 of data)) && AddTextToField("Credit(s)")
                                                                                                    member("credits_amount_e").text = "You have" && integer(value(line 2 of data)) && "Habbo Credits in your purse."
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
    end if
  end if
end

on handleAddItems itemList
  put itemList
  oldDelim = the itemDelimiter
  the itemDelimiter = "\__ITEM"
  c = the number of items in itemList
  repeat with i = 1 to c
    s = item i of itemList
    if s.length > 10 then
      if s starts "__ITEM" then
        s = char 7 to s.length of s
      end if
      createItem(s)
    end if
    the itemDelimiter = "\__ITEM"
  end repeat
  the itemDelimiter = oldDelim
end

on createItem s, update
  the itemDelimiter = ";"
  s1 = line 1 of s
  s2 = line 2 to the number of lines in s of s
  id = integer(item 1 of s1)
  itemType = item 2 of s1
  owner = item 3 of s1
  location = item 4 of s1
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
  global gmemnamedb
  sprMan_clearAll()
  gmemnamedb = VOID
  if the movieName contains "private" then
    sendFuseMsg("GOTOFLAT /" & gChosenFlatId)
  else
    sendFuseMsg("RELOGIN")
  end if
end

on createActiveObject ln, update
  oldDelim = the itemDelimiter
  the itemDelimiter = "/"
  state = item 1 of ln
  content = doSpecialCharConversion(ln)
  the itemDelimiter = ","
  name = item 1 of state
  other = char offset(",", state) + 1 to state.length of state
  type = word 1 of other
  x = integer(word 2 of other)
  y = integer(word 3 of other)
  w = integer(word 4 of other)
  h = integer(word 5 of other)
  dir = integer(word 6 of other)
  altitude = float(word 7 of other)
  partColors = word 8 of other
  put "altitude", altitude
  the itemDelimiter = "/"
  pData = [:]
  b = 1
  showName = item 2 of ln
  showDescription = item 3 of ln
  j = 4
  repeat while b
    key = item j of ln
    data = item j + 1 of ln
    if key.length = 0 then
      b = 0
    else
      addProp(pData, key, data)
    end if
    j = j + 2
  end repeat
  o = createFuseObject(name, type, "0", x, y, 0, [dir, dir, dir], [w, h], altitude, pData, partColors, update)
  the itemDelimiter = oldDelim
  if getaProp(o, #ancestor) = VOID then
    setaProp(o, #showName, showName)
    setaProp(o, #showDescription, showDescription)
  else
    setaProp(o.ancestor, #showName, showName)
    setaProp(o.ancestor, #showDescription, showDescription)
  end if
end

on getPlayerClass
  if the movieName contains "pellehyppy" then
    return "Pelle"
  else
    return "Human"
  end if
end

on buyStuff stuffType
  sendFuseMsg("BUYSTUFF" && stuffType)
end

on openFlatInfo num, gogo
  global gRoomModeIndicatorSpr
  if voidp(gFlats) then
    return 
  end if
  if (num > 0) and (num <= count(gFlats)) then
    s = gFlats[num][1]
    the itemDelimiter = "/"
    put s
    if s.length > 0 then
      gFloorHost = item 8 of s
      gFloorPort = integer(item 9 of s)
      doorOpen = item 4 of s
      if doorOpen = "open" then
        doorInfo = AddTextToField("DoorOpen")
      else
        if doorOpen = "closed" then
          doorInfo = AddTextToField("DoorClosed")
        else
          if doorOpen = "password" then
            doorInfo = AddTextToField("DoorPassword")
          end if
        end if
      end if
      gChosenFlatId = integer(item 1 of s)
      ownerName = item 3 of s
      if ownerName = "-" then
        ownerName = "not shown"
      end if
      gChosenFlatOwner = ownerName
      member("flatinfo.doormode").text = doorInfo
      member("privateroom_infotext").text = item 12 to the number of items in s of s
      member("flatinfo.head").text = item 2 of s && "(" & item 10 of s & "/25)" & RETURN & AddTextToField("Owner") && ownerName
      member("goingto_roomname").text = item 2 of s
      gChosenFlatDoorMode = doorOpen
      if item 11 of s = "1" then
        member("BobbaFilter.privateroom").text = AddTextToField("NoBobbaFilter")
      else
        member("BobbaFilter.privateroom").text = " "
      end if
      if gogo = 1 then
        nothing()
      else
        goContext("private_place.info", gPopUpContext2)
      end if
      if doorOpen = "closed" then
        sendSprite(getaProp(gpUiButtons, "ringbell"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "ringbell"), #disable)
      end if
      if (doorOpen <> "closed") or (item 3 of s = gMyName) then
        sendSprite(getaProp(gpUiButtons, "goflat"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "goflat"), #disable)
      end if
      sendSprite(gRoomModeIndicatorSpr, #setMode, doorOpen)
      if ownerName = gMyName then
        sendSprite(getaProp(gpUiButtons, "roommodify"), #enable)
      else
        sendSprite(getaProp(gpUiButtons, "roommodify"), #disable)
      end if
      if (doorOpen = "open") or (gMyName = ownerName) then
        member("doortxt_buttonin").text = AddTextToField("GoInside")
      else
        if doorOpen = "closed" then
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
  global gFloor, gWallPaper
  gConnectionInstance = 0
  gFloor = 111
  gWallPaper = 201
  gChosenUnitIp = gFloorHost
  gChosenUnitPort = integer(gFloorPort)
  gChosenFlatId = flatId
  put gChosenUnitIp, gChosenUnitPort, gChosenFlatId
  gGoTo = "one_room"
  goUnit("gf_private")
end

on GoToFlatWithNavi flatId
  global gPopUpContext2, gFlatWaitStart, gFloor, gWallPaper
  put gChosenFlatDoorMode
  gFloor = 111
  gWallPaper = 201
  member("flat_load.status").text = EMPTY
  if gChosenFlatDoorMode = "password" then
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
    if gChosenFlatDoorMode = "closed" then
      goContext("flat_load_locked", gPopUpContext2)
    end if
    if gChosenFlatDoorMode = "open" then
      goContext("flat_load", gPopUpContext2)
    end if
  end if
end

on newUnit unit, num
  global UnitsIDNum
  name = item 1 of unit
  activeUsers = integer(item 2 of unit)
  maxUsers = integer(item 3 of unit)
  host = item 4 of unit
  port = integer(item 5 of unit)
  description = item 6 of unit
  the itemDelimiter = TAB
  if gUnit_otherRooms = VOID then
    member("public_place.hierarchy").text = EMPTY
    gUnit_otherRooms = [:]
    UnitsIDNum = 0
  end if
  OtherR = []
  OtherRooms = []
  if unit.item.count > 2 then
    repeat with f = 2 to unit.item.count
      OtherR.append(item f of unit)
    end repeat
    gUnit_otherRooms.addProp(name, OtherR)
    OtherRooms = gUnit_otherRooms.getaProp(name)
  end if
  the itemDelimiter = ","
  UnitsIDNum = UnitsIDNum + 1
  addProp(gUnits, name, ["description": description, "maxUsers": maxUsers, "activeUsers": activeUsers, "host": host, "port": port, "num": num, "name": name, "UnitsIDNum": UnitsIDNum, "otherRooms": OtherRooms, "UnitsIDNum": UnitsIDNum])
  UnitsIDNum = UnitsIDNum + OtherR.count
  UnitHierarchyField(name, OtherR.count)
  if the movieName contains "cr_entry" then
    setUnitActiveUsers(name)
  end if
end

on UnitHierarchyField name, RoomS
  lineN = gUnits.getaProp(name).getaProp("UnitsIDNum")
  member("public_place.hierarchy").line[lineN] = name & ":" & RoomS + 1
  if RoomS > 1 then
    repeat with f = 1 to gUnit_otherRooms.getaProp(name).count
      member("public_place.hierarchy").line[lineN + f] = gUnit_otherRooms.getaProp(name)[f].item[1] & ":0"
    end repeat
  end if
end

on SetAllUnitUsers
  global gNaviWindowsSpr, gPlaceNamesGraph
  if (gUnits = VOID) or voidp(gPlaceNamesGraph) or (gNaviWindowsSpr = 0) then
    return 
  else
    repeat with NumOfUnits = 1 to gUnits.count
      setUnitActiveUsers(getAt(gUnits, NumOfUnits).name)
    end repeat
  end if
end

on setUnitActiveUsers name
  global gNaviWindowsSpr, gPlaceNamesGraph, ClickPlaceNum, ClickPlace, gNumGraph, gPalaceInsideNowGraph, UnitIsUpdated, gPopUpContext2
  if the movieName contains "cr_entry" then
    if getmemnum(name & ".info") > 0 then
      ni = name & ".info"
      ln1 = line 1 of field ni
      l = gUnits.getaProp(name)
      ln1 = ln1.word[1..ln1.word.count - 1] && "(" & getaProp(l, "activeUsers") & "/" & getaProp(l, "maxUsers") & ")"
      put ln1 into line 1 of field ni
      set the textFont of line 1 of field ni to "Volter-Bold (Goldfish)"
      return 
    end if
  end if
  if (gUnits <> VOID) and (gPlaceNamesGraph <> VOID) then
    UnitIsUpdated = 1
    l = gUnits.getaProp(name)
    InsideOfUnitNow(l.name, l.activeUsers, l.maxUsers)
    setProp(gPalaceInsideNowGraph, l.name, the result)
    if (l.getaProp("otherRooms") <> "[]") and not voidp(l.getaProp("otherRooms")) and (l.getaProp("otherRooms").count > 0) then
      oldItemLimiter = the itemDelimiter
      the itemDelimiter = ","
      repeat with f = 1 to l.getaProp("otherRooms").count
        UnitAUsers = getAt(l.getaProp("otherRooms"), f).item[2]
        MaxUnitAUsers = getAt(l.getaProp("otherRooms"), f).item[3]
        UnitAName = getAt(l.getaProp("otherRooms"), f).item[1]
        InsideOfUnitNow(UnitAName, UnitAUsers, MaxUnitAUsers)
        setProp(gPalaceInsideNowGraph, UnitAName, the result)
        if ClickPlaceNum = (l.UnitsIDNum + f) then
          sendSprite(gNaviWindowsSpr, #showInfo, UnitAName)
        end if
      end repeat
      the itemDelimiter = oldItemLimiter
    end if
    if gPopUpContext2 <> VOID then
      if (gNaviWindowsSpr <> VOID) and (gNaviWindowsSpr <> 0) and (gPopUpContext2.frame contains "public") then
        if ClickPlaceNum = l.UnitsIDNum then
          sendSprite(gNaviWindowsSpr, #showInfo, l.name)
        end if
      end if
    end if
  end if
end

on InsideOfUnitNow name, UnitactUsers, UnitMaxUsers
  global gNumGraph, gPalaceInsideNowGraph
  if value(UnitactUsers) > value(UnitMaxUsers) then
    UnitactUsers = "8"
  end if
  TempImg = image(gPalaceInsideNowGraph.getaProp(name).width, gPalaceInsideNowGraph.getaProp(name).height, 8)
  MakeImgToImg(TempImg, member("sulku.vasen").image, point(0, 0))
  TempImg = the result
  MakeImgToImg(TempImg, gNumGraph[UnitactUsers + 1], point(4, 0))
  TempImg = the result
  MakeImgToImg(TempImg, member("kauttaviiva").image, point(gNumGraph[UnitactUsers + 1].width + 4, 0))
  TempImg = the result
  MakeImgToImg(TempImg, gNumGraph[UnitMaxUsers + 1], point(gNumGraph[UnitactUsers + 1].width + 13, 0))
  TempImg = the result
  MakeImgToImg(TempImg, member("sulku.oikea").image, point(gNumGraph[UnitactUsers + 1].width + 13 + gNumGraph[UnitMaxUsers + 1].width, 0))
  TempImg = the result
  return TempImg
end

on reserveRoom
  global gProps, gFloorHost, gFloorPort
  if getaProp(gProps, #showOwnerName) = 0 then
    showName = 0
  else
    showName = 1
  end if
  put field("roomkiosk.roomname") & ":" && gProps
  fuseP = "first floor/" & field("roomkiosk.roomname") & "/" & getaProp(gProps, #roomModel) & "/" & string(getaProp(gProps, #doorMode)) & "/" & showName
  sendEPFuseMsg("CREATEFLAT /" & fuseP)
end

on updateFlatInfo
  global gProps, gFloorHost, gFloorPort
  if getaProp(gProps, #showOwnerName) = 0 then
    showName = 0
  else
    showName = 1
  end if
  fuseP = gChosenFlatId & "/" & field("navigator.roomname")
  fuseP = fuseP & "/" & string(getaProp(gProps, #doorMode))
  fuseP = fuseP & "/" & showName
  sendEPFuseMsg("UPDATEFLAT /" & fuseP)
  s = "description=" & field("navigator.description")
  s = s & RETURN & "password=" & field("roompassword")
  s = s & RETURN & "allsuperuser=" & getaProp(gProps, #superuser)
  s = s & RETURN & "wordfilter_disable=" & getaProp(gProps, #wordfilter_disable)
  put s
  sendEPFuseMsg("SETFLATINFO /" & gChosenFlatId & "/" & s)
end

on flatPasswordIncorrect
  member("flat_load.status").text = AddTextToField("WrongRoomPassword")
end

on handleActiveObjects ln
end

on WhichMember whichPart, small
  global MyfigurePartList, MyfigureColorList
  if small <> 1 then
    prefix = "h_"
  else
    prefix = "sh_"
  end if
  memName = prefix & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & "0"
  if the movieName contains "operatorlogo" then
    memName = prefix & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "2" & "_" & "0"
    if memName = "sh_std_hd_002_2_0" then
      memName = "sh_std_hd_001_2_0"
    end if
  end if
  memNum = the number of member memName
  return memNum
end
