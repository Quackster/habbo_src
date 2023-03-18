property hiliteSprite, giveStuffTo, placingStuff, stuffType, placingStuffStripId, placingType, stuffX, stuffY, stuffDirection, origCastMem, psOrigLocX, psOrigLocY, psOrigLocHe, placingObject
global xoffset, yoffset, xSize, ySize, hiliter, lasth, lastV, gUserSprites, gChosenUser, gChosenUserSprite, gChosenObject, gUserColors, gXtraFeatureSprite, gChosenStripLevel, gpObjects, gMyName, gXFactor, gYFactor, gHFactor, gpUiButtons, glObjectPlaceMap, gIAmOwner

on beginSprite me
  hiliteSprite = 0
  hiliteSprite = 890
  if hiliteSprite < 1 then
    Init()
    hiliteSprite = sprMan_getPuppetSprite()
  end if
  set the member of sprite hiliteSprite to "memberhilite_0"
  sprite(hiliteSprite).locZ = 9000000
  put "HILITESPR:" && hiliteSprite
  hiliter = me
  origCastMem = sprite(me.spriteNum).castNum
  placingStuff = 0
end

on placeStuff me, tstuffType, stuffModel, tstuffX, tstuffY, tstuffDirection, tStuffPartColors, stripId
  stuffType = tstuffType
  stuffX = tstuffX
  stuffY = tstuffY
  stuffDirection = tstuffDirection
  placingStuffStripId = stripId
  placingStuff = 1
  placingStuffType = stuffType
  placingObject = createFuseObject(tstuffType & ".place", stuffType, "0", 100, 100, 0, [stuffDirection, stuffDirection, stuffDirection], [stuffX, stuffY], 0.0, [:], tStuffPartColors)
  placingType = #stuff
  giveStuffTo = VOID
end

on moveStuff me, stuffSprite
  if count(sprite(stuffSprite).scriptInstanceList) = 0 then
    put "moveStuff: scriptInstanceList of  sprite", stuffSprite, "empty"
    return 
  end if
  placingStuff = 1
  placingObject = sprite(stuffSprite).scriptInstanceList[1]
  if voidp(value(placingObject.id)) then
    return 
  end if
  setaProp(placingObject, #altitude, 0.0)
  placingType = #stuffMove
  psOrigLocX = placingObject.locX
  psOrigLocY = placingObject.locY
  psOrigLocHe = placingObject.locHe
  if listp(placingObject.dimensions[2]) then
    dy = placingObject.dimensions[2]
  else
    dy = 1
  end if
  if listp(placingObject.dimensions[2]) then
    dx = placingObject.dimensions[1]
  else
    dx = 1
  end if
  repeat with yy = placingObject.locY to placingObject.locY + dy
    repeat with xx = placingObject.locX to placingObject.locX + dx
      if ((yy + 1) > 0) and ((yy + 1) <= count(glObjectPlaceMap)) then
        if ((xx + 1) > 0) and ((xx + 1) <= count(glObjectPlaceMap[yy + 1])) then
          glObjectPlaceMap[yy + 1][xx + 1] = 0
        end if
      end if
    end repeat
  end repeat
end

on placeItem me, titemType, stripId, tdata
  put "placeItem:" && titemType, stripId, tdata
  placingObject = new(script(titemType && "PlacerClass"), titemType, stripId, tdata)
  if not objectp(placingObject) then
    placingObject = VOID
    return 0
  end if
  placingStuffStripId = stripId
  placingStuffType = titemType
  placingType = #item
  return 1
end

on hiliteExitframe me
  if voidp(gChosenUser) then
    if not placingStuff then
      set the loc of sprite hiliteSprite to point(-1000, 1000)
    end if
  else
    loc = sprite(getProp(gChosenObject.pSprites, #sh)).loc
    characterdir = getProp(gChosenObject.pDirections, #bd)
    if getProp(gChosenObject.pFlipped, #sh) = 1 then
      loc = loc - [gXFactor, 0]
    end if
    if characterdir > 3 then
      characterdir = characterdir - 4
    end if
    set the member of sprite hiliteSprite to "memberhilite_" & characterdir
    set the loc of sprite hiliteSprite to loc
  end if
  if (lasth = the mouseH) and (lastV = the mouseV) then
    return 
  end if
  hils = getWorldCoordinate(the mouseH, the mouseV)
  lasth = the mouseH
  lastV = the mouseV
  if rollover(660) then
    hils = VOID
  end if
  if the optionDown then
    put hils
  end if
  iSpr = me.spriteNum
  if not voidp(hils) then
    sprite(me.spriteNum).locZ = me.spriteNum
    hilitex = getAt(hils, 1)
    hilitey = getAt(hils, 2)
    hiliteH = getAt(hils, 3)
    if placingStuff and (placingType <> #item) then
      rollSpr = rollover()
      o = getaProp(gUserSprites, rollSpr)
      if voidp(o) then
        repeat with i = 1 to count(gUserSprites)
          if rollover(getPropAt(gUserSprites, i)) then
            o = getAt(gUserSprites, i)
            rollSpr = getPropAt(gUserSprites, i)
            exit repeat
          end if
        end repeat
      end if
      if not voidp(o) and (placingType <> #stuffMove) then
        if o.name <> gMyName then
          loc = sprite(getProp(o.pSprites, #sh)).loc
          characterdir = getProp(o.pDirections, #bd)
          if characterdir > 3 then
            characterdir = characterdir - 4
          end if
          set the member of sprite hiliteSprite to "memberhilite_" & characterdir
          if getProp(o.pFlipped, #sh) = 1 then
            loc = loc - [gXFactor, 0]
          end if
          set the ink of sprite hiliteSprite to 36
          set the loc of sprite hiliteSprite to loc
          helpText_setText(AddTextToField("GiveItem") && o.name)
          giveStuffTo = o
          return 
        end if
      end if
      myUserSpr = getaProp(gpObjects, gMyName)
      if myUserSpr > 0 then
        myUserObj = sprite(myUserSpr).scriptInstanceList[1]
        if myUserObj.controller = 0 then
          return 
        end if
      else
        return 
      end if
      giveStuffTo = VOID
      set the loc of sprite hiliteSprite to point(-1000, 1000)
      helpText_setText(AddTextToField("PlaceItem"))
      if listp(placingObject.dimensions) then
        dy = placingObject.dimensions[2]
      else
        dy = 1
      end if
      if listp(placingObject.dimensions) then
        dx = placingObject.dimensions[1]
      else
        dx = 1
      end if
      repeat with yy = hilitey to hilitey + dy - 1
        repeat with xx = hilitex to hilitex + dx - 1
          if ((yy + 1) > 0) and ((yy + 1) <= count(glObjectPlaceMap)) then
            if ((xx + 1) > 0) and ((xx + 1) <= count(glObjectPlaceMap[yy + 1])) then
              if glObjectPlaceMap[yy + 1][xx + 1] > 1000 then
                hide(placingObject)
                return 
              end if
            end if
          end if
        end repeat
      end repeat
      show(placingObject)
      setLocation(placingObject, hilitex, hilitey, hiliteH)
      updateLocation(placingObject)
      sprite(me.spriteNum).castNum = origCastMem
    else
      if placingType = #item then
        show(placingObject)
        setLocation(placingObject, hilitex, hilitey, hiliteH)
        updateLocation(placingObject)
      end if
    end if
    screenCoord = getScreenCoordinate(hilitex, hilitey, hiliteH)
    set the locH of sprite iSpr to screenCoord[1]
    set the locV of sprite iSpr to screenCoord[2]
  else
    if not placingStuff then
      sprite(me.spriteNum).castNum = origCastMem
      set the locH of sprite iSpr to -10000
      set the locV of sprite iSpr to -10000
    else
      if placingType = #stuff then
        sprite(me.spriteNum).castNum = getmemnum(placingObject.objectType & "_small")
        hide(placingObject)
      end if
      sprite(me.spriteNum).loc = the mouseLoc
      sprite(me.spriteNum).locZ = 2220000000.0
    end if
  end if
end

on mouseDown me, brokenClickFromItem
  global gTraderWindow
  if rollover(660) then
    return 
  end if
  if placingStuff then
    placingStuff = 0
    hils = getWorldCoordinate(the mouseH, the mouseV)
    myUserSpr = getaProp(gpObjects, gMyName)
    if myUserSpr > 0 then
      myUserObj = sprite(myUserSpr).scriptInstanceList[1]
    end if
    if hils <> VOID then
      orderStrip = 0
      case placingType of
        #stuff:
          fusePString = "PLACESTUFFFROMSTRIP" && placingStuffStripId && hils[1] && hils[2] && stuffX && stuffY && stuffDirection
          die(placingObject)
          orderStrip = 1
          if objectp(giveStuffTo) then
            gTraderWindow = placingStuffStripId
            fusePString = "TRADE_OPEN " & TAB & giveStuffTo.name
          end if
        #item:
          fusePString = "PLACEITEMFROMSTRIP" && placingStuffStripId && getLocationString(placingObject)
          die(placingObject)
          sendFuseMsg("GETSTRIP" && "new")
          orderStrip = 1
        #stuffMove:
          if placingObject.id contains ".place" then
            return 
          end if
          fusePString = "MOVESTUFF" && placingObject.id && hils[1] && hils[2] && placingObject.direction[1]
          die(placingObject)
          if objectp(giveStuffTo) then
            gTraderWindow = placingObject.id
            fusePString = "TRADE_OPEN " & TAB & giveStuffTo.name
          end if
      end case
      sendFuseMsg(fusePString)
      if orderStrip then
        sendFuseMsg("GETSTRIP" && "new")
      end if
      sprite(me.spriteNum).castNum = origCastMem
    else
      if placingType = #stuffMove then
        setLocation(placingObject, psOrigLocX, psOrigLocY, psOrigLocHe)
        updateLocation(placingObject)
        show(placingObject)
      else
        sendFuseMsg("GETSTRIP" && "new")
      end if
      sprite(me.spriteNum).castNum = origCastMem
    end if
    return 
  end if
  if brokenClickFromItem and not placingStuff then
  end if
  rollSpr = rollover()
  o = getaProp(gUserSprites, rollSpr)
  if voidp(o) then
    repeat with i = 1 to count(gUserSprites)
      if rollover(getPropAt(gUserSprites, i)) then
        o = getAt(gUserSprites, i)
        rollSpr = getPropAt(gUserSprites, i)
        exit repeat
      end if
    end repeat
  end if
  if voidp(o) then
    hils = getWorldCoordinate(the mouseH, the mouseV)
    if not voidp(hils) then
      put "Move.." && getAt(hils, 1) && getAt(hils, 2)
      sendFuseMsg("Move" && getAt(hils, 1) && getAt(hils, 2))
      emptyInfoFields(me)
    end if
    gChosenUser = VOID
  else
    set the member of sprite hiliteSprite to "memberhilite_0"
    gChosenUser = getName(o)
    gChosenObject = o
    gChosenUserSprite = rollSpr
    set the ink of sprite hiliteSprite to 41
    hils = getWorldCoordinate(the mouseH, the mouseV)
    setUserInfoTexts(me)
    hiliteAvatar(me, o, 712)
    fcolor = integer(getaProp(gUserColors, gChosenUser))
    if not voidp(hils) then
      hilitex = getAt(hils, 1)
      hilitey = getAt(hils, 2)
      sendFuseMsg("LOOKTO " & hilitex && hilitey)
    end if
  end if
end

on hiliteAvatar me, ChosenObject, whichSprite
  repeat with part in ChosenObject.lParts
    memName = "h_" & "std" & "_" & part & "_" & getaProp(ChosenObject.pModels, part) & "_" & "2" & "_" & 0
    memNum = getmemnum(memName)
    sprite(whichSprite).member = memNum
    if part = "sd" then
      sprite(whichSprite).blend = 16
    end if
    sprite(whichSprite).bgColor = getaProp(ChosenObject.pColors, part)
    sprite(whichSprite).ink = getaProp(ChosenObject.pInks, part)
    sprite(whichSprite).loc = point(695, 390)
    sprite(whichSprite).locZ = getaProp(ChosenObject.pLocZShifts, part) + 10000
    sprite(whichSprite).rotation = 180
    sprite(whichSprite).skew = 180
    whichSprite = whichSprite + 1
  end repeat
  showSpecialInfo(ChosenObject)
end

on setUserInfoTexts me
  global gInfofieldIconSprite
  emptyInfoFields(me)
  myMatchEmName = EMPTY
  put myMatchEmName
  sendSprite(gInfofieldIconSprite, #setUser, gChosenObject)
  member("item.info_name").text = getaProp(gChosenObject, #name)
  myMatchEmName = EMPTY
  if listp(gChosenObject.specialXtras) then
    put gChosenObject.specialXtras
    if stringp(getaProp(gChosenObject.specialXtras, "matchem")) then
      myMatchEmName = RETURN & "MatchEm-nimi:" && getaProp(gChosenObject.specialXtras, "matchem")
    end if
  end if
  member("item.info_text").text = getCustom(gChosenObject) & myMatchEmName
  if myMatchEmName.length > 0 then
    member("item.info_text").word[the number of words in (getCustom(gChosenObject) & myMatchEmName) - 1].Hyperlink = "http://kolumbus.fi/matchem/homman_nimi.jsp"
  end if
  myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
  put gChosenObject.name
  if gChosenObject.name <> gMyName then
    if myUserObj.userController = 1 then
      sendSprite(getaProp(gpUiButtons, "killuser"), #enable)
      sendSprite(getaProp(gpUiButtons, "userrights"), #enable)
    end if
    if gChosenObject.controller = 1 then
      sprite(getaProp(gpUiButtons, "userrights")).member = getmemnum("delrights_btn")
    else
      sprite(getaProp(gpUiButtons, "userrights")).member = getmemnum("enablerights_btn")
    end if
  else
    sendSprite(getaProp(gpUiButtons, "Dance"), #enable)
  end if
end

on emptyInfoFields me
  global gInfofieldIconSprite
  sendSprite(gInfofieldIconSprite, #setIcon, "x")
  sendSprite(getaProp(gpUiButtons, "movestuff"), #disable)
  sendSprite(getaProp(gpUiButtons, "rotatestuff"), #disable)
  sendSprite(getaProp(gpUiButtons, "pickstuff"), #disable)
  sendSprite(getaProp(gpUiButtons, "removestuff"), #disable)
  sendSprite(getaProp(gpUiButtons, "killuser"), #disable)
  sendSprite(getaProp(gpUiButtons, "userrights"), #disable)
  sendSprite(getaProp(gpUiButtons, "Dance"), #disable)
end

on limitLoc coordinate, top
end
