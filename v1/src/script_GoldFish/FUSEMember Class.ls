property name, id, objectType, objectModel, locX, locY, locHe, direction, dimensions, altitude, lSprites, animFrame, zShifts, pData, partColors, showName, showDescription
global gpObjects, gChosenStuffId, gChosenStuffSprite, gChosenStuffType, gXFactor, gMyName

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, tpData, tpartColors
  name = tName
  id = char (tMemberPrefix.length + 1) to name.length of name
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
  repeat with t = 1 to the number of items in tpartColors
    add(partColors, string(item t of tpartColors))
  end repeat
  repeat with j = count(partColors) to 4
    add(partColors, "*ffffff")
  end repeat
  updateMembers(me)
  updateLocation(me)
  return me
end

on beginSprite me
  if voidp(gpObjects) then
    gpObjects = [:]
  end if
  deleteProp(gpObjects, name)
  addProp(gpObjects, name, me.spriteNum)
end

on getInk me, part
  inkField = getmemnum((((objectType & "_") & part) & ".ink"))
  if (inkField > 0) then
    return integer(field(inkField))
  end if
  return 8
end

on getBlend me, part
  blendField = getmemnum((((objectType & "_") & part) & ".blend"))
  if (blendField > 0) then
    return integer(field(blendField))
  end if
  return 100
end

on updateMembers me
  memNum = 0
  i = charToNum("a")
  j = 1
  repeat while (memNum >= 0)
    bFound = 0
    repeat while (bFound = 0)
      memNameA = ((((objectType & "_") & numToChar(i)) & "_") & "0")
      if not voidp(dimensions) then
        memNameA = ((((memNameA & "_") & dimensions[1]) & "_") & dimensions[2])
      end if
      if listp(direction) then
        if (count(direction) >= j) then
          memName = ((((memNameA & "_") & direction[j]) & "_") & animFrame)
        else
          memName = ((((memNameA & "_") & direction[1]) & "_") & animFrame)
        end if
      else
        memName = ((memNameA & "_") & animFrame)
      end if
      memNum = getmemnum(memName)
      oldMemName = memName
      if (memNum = -1) then
        memName = ((memNameA & "_0_") & animFrame)
        memNum = getmemnum(memName)
      end if
      if ((memNum = -1) and (j = 1)) then
        bFound = 0
        repeat with ee = 1 to count(direction)
          direction[ee] = integer((direction[ee] + 1))
        end repeat
        if (direction[1] = 8) then
          return 
        end if
        next repeat
      end if
      bFound = 1
    end repeat
    if (memNum <> -1) then
      if (count(lSprites) >= j) then
        spr = lSprites[j]
      else
        spr = sprite(sprMan_getPuppetSprite())
        add(lSprites, spr)
        spr.scriptInstanceList = [new(script("EventBroker Behavior"), me.lSprites[1])]
      end if
      if listp(direction) then
        if (count(direction) >= j) then
          add(zShifts, getZShift(objectType, numToChar(i), direction[j]))
        else
          add(zShifts, getZShift(objectType, numToChar(i), VOID))
        end if
      else
        add(zShifts, getZShift(objectType, numToChar(i), VOID))
      end if
      if (not voidp(spr) and (spr <> sprite(0))) then
        if (memNum < 1) then
          memNum = abs(memNum)
          spr.rotation = 180
          spr.skew = 180
        end if
        spr.castNum = memNum
        spr.ink = getInk(me, numToChar(i))
        spr.blend = getBlend(me, numToChar(i))
        if (j <= count(partColors)) then
          if (string(partColors[j]) starts "*") then
            spr.bgColor = rgb(("#" & char 2 to string(partColors[j]).length of string(partColors[j])))
          else
            spr.bgColor = paletteIndex(integer(partColors[j]))
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
  shadowName = (objectType & "_sd")
  if listp(direction) then
    shadowName = ((shadowName & "_") & direction[1])
  end if
  shadowNum = getmemnum(shadowName)
  if ((shadowNum = -1) and listp(direction)) then
    shadowNum = getmemnum((objectType & "_sd"))
  end if
  if (shadowNum <> -1) then
    spr = sprite(sprMan_getPuppetSprite())
    add(lSprites, spr)
    add(zShifts, -4000)
    if (shadowNum < 0) then
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
  repeat with spr in lSprites
    i = (i + 1)
    spr.locH = screenLocs[1]
    if (spr.rotation = 180) then
      spr.locH = (spr.locH + gXFactor)
    end if
    spr.locV = screenLocs[2]
    if (i <= count(zShifts)) then
      zs = zShifts[i]
    else
      zs = 0
    end if
    lz = ((screenLocs[3] + (altitude * 100)) + zs)
    if (lz < 0) then
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
  put ("Updating stuff data:" && tProp), tValue
end

on rotate me, change
  mname = sprite(lSprites[1]).member.name
  newDirection = direction
  repeat with j = 1 to 4
    newDirection = ((newDirection + change) mod 8)
    if (newDirection[1] < 0) then
      newDirection = (8 + newDirection)
    end if
    mTryName = ((char 1 to (mname.length - 3) of mname & newDirection[1]) & "_0")
    put mTryName, mname
    if (getmemnum(mTryName) <> -1) then
      exit repeat
    end if
  end repeat
  if (getmemnum(mTryName) = -1) then
    put "direction not found"
    return 
  end if
  sendFuseMsg((((("MOVESTUFF" && me.id) && me.locX) && me.locY) && newDirection[1]))
end

on die me
  deleteProp(gpObjects, me.name)
  repeat with iSpr in lSprites
    sprMan_releaseSprite(iSpr)
  end repeat
end

on mouseDown me
  global hiliter, gInfofieldIconSprite, gpUiButtons
  mouseDown(hiliter, 1)
  if (listp(gpUiButtons) and (the movieName contains "private")) then
    gChosenStuffId = id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
    if (myUserObj.controller = 1) then
      hilite(me)
      if (the optionDown and not voidp(value(id))) then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on Hide_hilitedAvatar me, whichSpr
  repeat with hidingSpr = whichSpr to (whichSpr + 12)
    sprite(hidingSpr).locH = -1000
  end repeat
end

on hilite me
  global hiliteStart
  hiliteStart = the ticks
  repeat with spr in lSprites
    sprite(spr).foreColor = 251
  end repeat
end

on unhilite me
  repeat with spr in lSprites
    sprite(spr).foreColor = 255
  end repeat
end

on hide me
  repeat with spr in lSprites
    sprite(spr).visible = 0
  end repeat
end

on show me
  repeat with spr in lSprites
    sprite(spr).visible = 1
  end repeat
end

on mouseEnter me
  if voidp(me.showName) then
    return 
  end if
  helpText_setText((me.showName && AddTextToField("SelectByClicking")))
end

on mouseLeave me
  if voidp(me.showName) then
    return 
  end if
  helpText_empty((me.showName && AddTextToField("SelectByClicking")))
end

on setInfoTexts me
  global gInfofieldIconSprite, gpUiButtons, gChosenUser, hiliter, gIAmOwner
  if stringp(gChosenUser) then
    return 
  end if
  Hide_hilitedAvatar(me, 712)
  emptyInfoFields(hiliter)
  sendSprite(gInfofieldIconSprite, #setIcon, me.objectType)
  if (me.showDescription = "NULL") then
    me.showDescription = EMPTY
  end if
  if (not voidp(me.showName) and not voidp(me.showDescription)) then
    member("item.info_name").text = me.showName
    member("item.info_text").text = me.showDescription
  end if
  if (listp(gpUiButtons) and (the movieName contains "private")) then
    myUserSprite = getaProp(gpObjects, gMyName)
    if (voidp(myUserSprite) or (myUserSprite < 1)) then
      return 
    end if
    myUserObj = sprite(myUserSprite).scriptInstanceList[1]
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
