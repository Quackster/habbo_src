property hiliteSprite

on beginSprite me 
  hiliteSprite = 0
  hiliteSprite = sprMan_getPuppetSprite()
  if hiliteSprite < 1 then
    return()
  end if
  sprite(hiliteSprite).undefined = "memberhilite_small"
  sprite(hiliteSprite).locZ = 9000000
  hiliter = me
  placingStuff = 0
end

on placeStuff me, tstuffType, stuffModel, tstuffX, tstuffY, tstuffDirection, stripId 
  beep(1)
end

on moveStuff me, stuffSprite 
  beep(1)
end

on placeItem me, titemType, stripId 
  beep(1)
end

on hiliteExitframe me 
  if voidp(gChosenUser) then
    sprite(hiliteSprite).undefined = point(-1000, 1000)
  else
    loc = sprite(getProp(gChosenObject.pSprites, #sh)).loc
    characterdir = getProp(gChosenObject.pDirections, #bd)
    if getProp(gChosenObject.pFlipped, #sh) = 1 then
      loc = loc - [gXFactor, 0]
    end if
    if characterdir > 3 then
      characterdir = characterdir - 4
    end if
    sprite(hiliteSprite).undefined = "memberhilite_small_" & characterdir
    sprite(hiliteSprite).undefined = loc
  end if
  if lasth = the mouseH and lastV = the mouseV then
    return()
  end if
  hils = getWorldCoordinate(the mouseH, the mouseV)
  lasth = the mouseH
  lastV = the mouseV
  if the optionDown then
    put(hils)
  end if
  if rollover(660) then
    hils = void()
  end if
  iSpr = me.spriteNum
  if not voidp(hils) then
    hilitex = getAt(hils, 1)
    hilitey = getAt(hils, 2)
    hiliteH = getAt(hils, 3)
    screenCoord = getScreenCoordinate(hilitex, hilitey, hiliteH)
    sprite(iSpr).locH = screenCoord.getAt(1)
    sprite(iSpr).locV = screenCoord.getAt(2)
  else
    sprite(iSpr).locH = -10000
    sprite(iSpr).locV = -10000
  end if
end

on mouseDown me, brokenClickFromItem 
  put("mdh")
  if rollover(660) then
    return()
  end if
  rollSpr = rollover()
  o = getaProp(gUserSprites, rollSpr)
  if voidp(o) then
    i = 1
    repeat while i <= count(gUserSprites)
      if rollover(getPropAt(gUserSprites, i)) then
        o = getAt(gUserSprites, i)
        rollSpr = getPropAt(gUserSprites, i)
      else
        i = 1 + i
      end if
    end repeat
  end if
  if voidp(o) then
    hils = getWorldCoordinate(the mouseH, the mouseV)
    if not voidp(hils) then
      if objectp(gGameContext) and the movieName contains "gf_gamehall" then
        if visible(gGameContext) = 1 then
          return()
        end if
      end if
      put("Move.." && getAt(hils, 1) && getAt(hils, 2))
      sendFuseMsg("Move" && getAt(hils, 1) && getAt(hils, 2))
    end if
    if objectp(gChosenObject) then
      call(#hideSpecialInfo, gChosenObject)
    end if
    emptyInfoFields(me)
    Hide_hilitedAvatar(me, 712)
    gChosenUser = void()
    member("item.info_name").text = " "
    member("item.info_text").text = " "
  else
    sprite(hiliteSprite).undefined = "memberhilite_small"
    gChosenUser = getName(o)
    gChosenObject = o
    gChosenUserSprite = rollSpr
    sprite(hiliteSprite).ink = 36
    hils = getWorldCoordinate(the mouseH, the mouseV)
    Custom = getCustom(o)
    hiliteAvatar(me, o, 712)
    myMatchEmName = ""
    if listp(gChosenObject.specialXtras) then
      put(gChosenObject.specialXtras)
      if stringp(getaProp(gChosenObject.specialXtras, "matchem")) then
        myMatchEmName = "\r" & "MatchEm-nimi:" && getaProp(gChosenObject.specialXtras, "matchem")
      end if
    end if
    member("item.info_text").text = getCustom(gChosenObject) & myMatchEmName
    if myMatchEmName.length > 0 then
      member("item.info_text").getPropRef(#word, the number of word in getCustom(gChosenObject) & myMatchEmName - 1).hyperlink = "http://kolumbus.fi/matchem/homman_nimi.jsp"
    end if
    member("item.info_name").text = getaProp(gChosenObject, #name)
    emptyInfoFields(me)
    fcolor = integer(getaProp(gUserColors, gChosenUser))
    if not voidp(hils) then
      hilitex = getAt(hils, 1)
      hilitey = getAt(hils, 2)
      sendFuseMsg("LOOKTO " & hilitex && hilitey)
    end if
  end if
end

on hiliteAvatar me, ChosenObject, whichSprite 
  if ChosenObject.name <> "kaija" and ChosenObject.name <> "Marco" and ChosenObject.name <> "Jessica" and ChosenObject.name <> "DjFuse" then
    repeat while ChosenObject.lParts <= whichSprite
      part = getAt(whichSprite, ChosenObject)
      memName = "h_" & "std" & "_" & part & "_" & getaProp(ChosenObject.pModels, part) & "_" & "2" & "_" & 0
      memNum = getmemnum(memName)
      sprite(whichSprite).member = memNum
      if part = "sd" then
        sprite(whichSprite).blend = 16
      end if
      sprite(whichSprite).bgColor = getaProp(ChosenObject.pColors, part)
      sprite(whichSprite).ink = getaProp(ChosenObject.pInks, part)
      sprite(whichSprite).loc = point(685, 392)
      sprite(whichSprite).locZ = getaProp(ChosenObject.pLocZShifts, part) + 100000
      sprite(whichSprite).rotation = 180
      sprite(whichSprite).skew = 180
      whichSprite = whichSprite + 1
    end repeat
    showMyEy(me, ChosenObject, whichSprite)
    showSpecialInfo(ChosenObject)
  else
    member("matchem.user_name").text = " "
    Hide_hilitedAvatar(me, 712)
  end if
end

on showMyEy me, ChosenObject, whichSprite 
  part = "ey"
  memName = "h_" & "std" & "_" & part & "_" & getaProp(ChosenObject.myEy, #models) & "_" & "2" & "_" & 0
  memNum = getmemnum(memName)
  sprite(whichSprite).member = memNum
  if part = "sd" then
    sprite(whichSprite).blend = 16
  end if
  sprite(whichSprite).bgColor = getaProp(ChosenObject.myEy, #colors)
  sprite(whichSprite).ink = getaProp(ChosenObject.myEy, #Inks)
  sprite(whichSprite).loc = point(685, 392)
  sprite(whichSprite).locZ = getaProp(ChosenObject.myEy, #LocZShifts) + 100000
  sprite(whichSprite).rotation = 180
  sprite(whichSprite).skew = 180
end

on Hide_hilitedAvatar me, whichSpr 
  hidingSpr = whichSpr
  repeat while hidingSpr <= whichSpr + 12
    sprite(hidingSpr).locH = -1000
    hidingSpr = 1 + hidingSpr
  end repeat
end

on emptyInfoFields me 
  sendSprite(gInfofieldIconSprite, #setIcon, "x")
end

on limitLoc coordinate, top 
end
