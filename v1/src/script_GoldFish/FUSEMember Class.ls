property name, partColors, objectType, dimensions, direction, animFrame, lSprites, zShifts, locX, locY, locHe, altitude, id

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, tpData, tpartColors 
  name = tName
  id = name.char[(tMemberPrefix.length + 1)..name.length]
  objectType = tMemberPrefix
  objectModel = tMemberFigureType
  locX = tLocX
  locY = tLocY
  locHe = (tHeight + taltitude)
  direction = tDirection
  dimensions = lDimensions
  altitude = taltitude
  pData = tpData
  animFrame = 0
  lSprites = [sprite(spr)]
  zShifts = []
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  partColors = []
  the itemDelimiter = ","
  t = 1
  repeat while t <= the number of item in tpartColors
    add(partColors, string(tpartColors.item[t]))
    t = (1 + t)
  end repeat
  j = count(partColors)
  repeat while j <= 4
    add(partColors, "*ffffff")
    j = (1 + j)
  end repeat
  updateMembers(me)
  updateLocation(me)
  return(me)
end

on beginSprite me 
  if voidp(gpObjects) then
    gpObjects = [:]
  end if
  deleteProp(gpObjects, name)
  addProp(gpObjects, name, me.spriteNum)
end

on getInk me, part 
  inkField = getmemnum(objectType & "_" & part & ".ink")
  if inkField > 0 then
    return(integer(field(0)))
  end if
  return(8)
end

on getBlend me, part 
  blendField = getmemnum(objectType & "_" & part & ".blend")
  if blendField > 0 then
    return(integer(field(0)))
  end if
  return(100)
end

on updateMembers me 
  memNum = 0
  i = charToNum("a")
  j = 1
  repeat while memNum >= 0
    bFound = 0
    repeat while (bFound = 0)
      memNameA = objectType & "_" & numToChar(i) & "_" & "0"
      if not voidp(dimensions) then
        memNameA = memNameA & "_" & dimensions.getAt(1) & "_" & dimensions.getAt(2)
      end if
      if listp(direction) then
        if count(direction) >= j then
          memName = memNameA & "_" & direction.getAt(j) & "_" & animFrame
        else
          memName = memNameA & "_" & direction.getAt(1) & "_" & animFrame
        end if
      else
        memName = memNameA & "_" & animFrame
      end if
      memNum = getmemnum(memName)
      oldMemName = memName
      if (memNum = -1) then
        memName = memNameA & "_0_" & animFrame
        memNum = getmemnum(memName)
      end if
      if (memNum = -1) and (j = 1) then
        bFound = 0
        ee = 1
        repeat while ee <= count(direction)
          direction.setAt(ee, integer((direction.getAt(ee) + 1)))
          ee = (1 + ee)
        end repeat
        if (direction.getAt(1) = 8) then
          return()
        end if
        next repeat
      end if
      bFound = 1
    end repeat
    if memNum <> -1 then
      if count(lSprites) >= j then
        spr = lSprites.getAt(j)
      else
        spr = sprite(sprMan_getPuppetSprite())
        add(lSprites, spr)
        spr.scriptInstanceList = [new(script("EventBroker Behavior"), me.getProp(#lSprites, 1))]
      end if
      if listp(direction) then
        if count(direction) >= j then
          add(zShifts, getZShift(objectType, numToChar(i), direction.getAt(j)))
        else
          add(zShifts, getZShift(objectType, numToChar(i), void()))
        end if
      else
        add(zShifts, getZShift(objectType, numToChar(i), void()))
      end if
      if not voidp(spr) and spr <> sprite(0) then
        if memNum < 1 then
          memNum = abs(memNum)
          spr.rotation = 180
          spr.skew = 180
        end if
        spr.castNum = memNum
        spr.ink = getInk(me, numToChar(i))
        spr.blend = getBlend(me, numToChar(i))
        if j <= count(partColors) then
          if string(partColors.getAt(j)) starts "*" then
            spr.bgColor = rgb("#" & string(partColors.getAt(j)).char[2..string(partColors.getAt(j)).length])
          else
            spr.bgColor = paletteIndex(integer(partColors.getAt(j)))
          end if
        end if
      else
        ShowAlert("NO SPRITES AVAILABLE")
      end if
    else
    end if
    i = (i + 1)
    j = (j + 1)
  end repeat
  shadowName = objectType & "_sd"
  if listp(direction) then
    shadowName = shadowName & "_" & direction.getAt(1)
  end if
  shadowNum = getmemnum(shadowName)
  if (shadowNum = -1) and listp(direction) then
    shadowNum = getmemnum(objectType & "_sd")
  end if
  if shadowNum <> -1 then
    spr = sprite(sprMan_getPuppetSprite())
    add(lSprites, spr)
    add(zShifts, -4000)
    if shadowNum < 0 then
      shadowNum = abs(shadowNum)
      spr.rotation = 180
      spr.skew = 180
      spr.locH = (spr.locH + gXFactor)
    end if
    spr.castNum = shadowNum
    spr.ink = getInk(me, "sd")
    spr.blend = getBlend(me, "sd")
    if (spr.blend = 100) then
      spr.blend = 20
    end if
  end if
end

on updateLocation me 
  screenLocs = getScreenCoordinate(locX, locY, locHe)
  i = 0
  repeat while lSprites <= 1
    spr = getAt(1, count(lSprites))
    i = (i + 1)
    spr.locH = screenLocs.getAt(1)
    if (spr.rotation = 180) then
      spr.locH = (spr.locH + gXFactor)
    end if
    spr.locV = screenLocs.getAt(2)
    if i <= count(zShifts) then
      zs = zShifts.getAt(i)
    else
      zs = 0
    end if
    lz = ((screenLocs.getAt(3) + (altitude * 100)) + zs)
    if lz < 0 then
      lz = 100
    end if
    spr.locZ = lz
  end repeat
end

on setLocation me, x, y, tHeight 
  locX = x
  locY = y
  locHe = (tHeight + altitude)
end

on updateStuffdata me, tProp, tValue 
  put("Updating stuff data:" && tProp, tValue)
end

on rotate me, change 
  mname = sprite(lSprites.getAt(1)).member.name
  newDirection = direction
  j = 1
  repeat while j <= 4
    newDirection = ((newDirection + change) mod 8)
    if newDirection.getAt(1) < 0 then
      newDirection = (8 + newDirection)
    end if
    mTryName = mname.char[1..(mname.length - 3)] & newDirection.getAt(1) & "_0"
    put(mTryName, mname)
    if getmemnum(mTryName) <> -1 then
    else
      j = (1 + j)
    end if
  end repeat
  if (getmemnum(mTryName) = -1) then
    put("direction not found")
    return()
  end if
  sendFuseMsg("MOVESTUFF" && me.id && me.locX && me.locY && newDirection.getAt(1))
end

on die me 
  deleteProp(gpObjects, me.name)
  repeat while lSprites <= 1
    iSpr = getAt(1, count(lSprites))
    sprMan_releaseSprite(iSpr)
  end repeat
end

on mouseDown me 
  mouseDown(hiliter, 1)
  if listp(gpUiButtons) and the movieName contains "private" then
    gChosenStuffId = id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
    if (myUserObj.controller = 1) then
      hilite(me)
      if the optionDown and not voidp(value(id)) then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on Hide_hilitedAvatar me, whichSpr 
  hidingSpr = whichSpr
  repeat while hidingSpr <= (whichSpr + 12)
    sprite(hidingSpr).locH = -1000
    hidingSpr = (1 + hidingSpr)
  end repeat
end

on hilite me 
  hiliteStart = the ticks
  repeat while lSprites <= 1
    spr = getAt(1, count(lSprites))
    sprite(spr).foreColor = 251
  end repeat
end

on unhilite me 
  repeat while lSprites <= 1
    spr = getAt(1, count(lSprites))
    sprite(spr).foreColor = 255
  end repeat
end

on hide me 
  repeat while lSprites <= 1
    spr = getAt(1, count(lSprites))
    sprite(spr).visible = 0
  end repeat
end

on show me 
  repeat while lSprites <= 1
    spr = getAt(1, count(lSprites))
    sprite(spr).visible = 1
  end repeat
end

on mouseEnter me 
  if voidp(me.showName) then
    return()
  end if
  helpText_setText(me.showName && AddTextToField("SelectByClicking"))
end

on mouseLeave me 
  if voidp(me.showName) then
    return()
  end if
  helpText_empty(me.showName && AddTextToField("SelectByClicking"))
end

on setInfoTexts me 
  if stringp(gChosenUser) then
    return()
  end if
  Hide_hilitedAvatar(me, 712)
  emptyInfoFields(hiliter)
  sendSprite(gInfofieldIconSprite, #setIcon, me.objectType)
  if (me.showDescription = "NULL") then
    me.showDescription = ""
  end if
  if not voidp(me.showName) and not voidp(me.showDescription) then
    member("item.info_name").text = me.showName
    member("item.info_text").text = me.showDescription
  end if
  if listp(gpUiButtons) and the movieName contains "private" then
    myUserSprite = getaProp(gpObjects, gMyName)
    if voidp(myUserSprite) or myUserSprite < 1 then
      return()
    end if
    myUserObj = sprite(myUserSprite).getProp(#scriptInstanceList, 1)
    if (myUserObj.controller = 1) then
      sendSprite(getaProp(gpUiButtons, "movestuff"), #enable)
      sendSprite(getaProp(gpUiButtons, "rotatestuff"), #enable)
      if (gIAmOwner = 1) then
        sendSprite(getaProp(gpUiButtons, "pickstuff"), #enable)
        sendSprite(getaProp(gpUiButtons, "removestuff"), #enable)
      end if
    end if
  end if
end
