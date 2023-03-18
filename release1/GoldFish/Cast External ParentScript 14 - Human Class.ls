property name, Custom, locX, locY, height, direction, memberPrefix, memberModels, moving, destLScreen, startLScreen, moveStart, moveTime, talking, pModels, pDirections, pSprites, pInks, lParts, pActions, pColors, pLocZShifts, animFrame, danceLegAnim, danceHandAnim, dancing, pSleeping, counter, pAnimFixH, pAnimFixV, pFlipped, mainAction, restingHeight, changes, controller, userController, drink, food, drinkAnimFrame, drinkingAnimFrameDir, carryItem, carryItemSpr, drinking, pTrading, myEy, specialXtras, isModerator, pLocFix, iLocZFix, pHeadLooseH, pHeadLooseV, pModLevel
global gMyModLevel, OOO, gpObjects, gUserSprites, gMyName, gXFactor, gYFactor, peopleSize, MeDancing, gBadgeOn, gMeModerator

on new me, tName, tMemberPrefix, tMemberModels, tLocX, tLocY, tHeight, tdir, tlDimensions, tSpr, tCustom
  if tName = gMyName then
    gMyName = tName
  end if
  locX = tLocX
  locY = tLocY
  height = tHeight
  name = tName
  dancing = 0
  pSleeping = 0
  isModerator = 0
  Custom = tCustom
  memberPrefix = "h"
  memberModels = tMemberModels
  direction = tdir
  moveTime = 500
  moving = 0
  counter = 0
  pModels = keyValueToPropList(tMemberModels, "&")
  pColors = [:]
  pInks = [:]
  pFlipped = [:]
  drinkingAnimFrameDir = 1
  sort(pInks)
  sort(pColors)
  sort(pModels)
  lParts = []
  pModLevel = EMPTY
  pLocFix = point(0, 0)
  iLocZFix = 0
  put (the movieName).char[1..length(the movieName) - 4]
  if the movieName contains "private" then
    peopleSize = "h"
  else
    peopleSize = "sh"
  end if
  pAnimFixV = [[0, 0, 1, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0]]
  if peopleSize = "h" then
    pHeadLooseH = [[-1, 0], [0, 2], [0, 2], [-1, 3], [-2, 0], [-2, 0], [0, 1], [0, 0]]
    pHeadLooseV = [[0, 1], [-1, 0], [1, 1], [1, 1], [1, 1], [0, -1], [1, 0], [0, 0]]
  else
    pHeadLooseH = [[0, 0], [1, 2], [-1, 0], [0, 0], [0, 1], [-2, -1], [0, 0], [1, -1]]
    pHeadLooseV = [[0, 0], [0, -1], [0, 0], [0, 0], [0, 0], [-1, 0], [0, 0], [0, 0]]
  end if
  oldDelim = the itemDelimiter
  repeat with i = 1 to count(pModels)
    add(lParts, getPropAt(pModels, i))
    model = getAt(pModels, i)
    the itemDelimiter = "/"
    if (item 2 of model).length > 3 then
      clothColor = value("color(#rgb," & item 2 of model & ")")
    else
      clothColor = paletteIndex(integer(item 2 of model))
    end if
    if clothColor = VOID then
      clothColor = color(#rgb, 0, 0, 0)
    end if
    addProp(pColors, getPropAt(pModels, i), clothColor)
    model = item 1 of model
    if ((getPropAt(pModels, i) = "fc") or (getPropAt(pModels, i) = "hd")) and (model = "002") and (gXFactor < 33) then
      model = "001"
    end if
    setAt(pModels, i, model)
    the itemDelimiter = oldDelim
  end repeat
  pDirections = [:]
  pSprites = [:]
  pActions = [:]
  sort(pDirections)
  sort(pSprites)
  sort(pActions)
  repeat with i = 1 to count(lParts)
    part = lParts[i]
    addProp(pDirections, part, direction[1])
    if i > 1 then
      newSpr = sprMan_getPuppetSprite()
      addProp(pSprites, part, newSpr)
      addProp(gUserSprites, newSpr, me)
    else
      addProp(pSprites, part, tSpr)
      addProp(gUserSprites, tSpr, me)
    end if
    addProp(pActions, part, "std")
    if part <> "sd" then
      addProp(pInks, part, 41)
      next repeat
    end if
    addProp(pInks, part, 8)
  end repeat
  pLocZShifts = [:]
  addProp(pLocZShifts, #sd, -100)
  addProp(pLocZShifts, #bd, 0)
  addProp(pLocZShifts, #sh, 2)
  addProp(pLocZShifts, #lg, 4)
  addProp(pLocZShifts, #ch, 8)
  addProp(pLocZShifts, #lh, 10)
  addProp(pLocZShifts, #ls, 12)
  addProp(pLocZShifts, #rh, 10)
  addProp(pLocZShifts, #rs, 12)
  addProp(pLocZShifts, #fc, 18)
  addProp(pLocZShifts, #ey, 19)
  addProp(pLocZShifts, #hr, 20)
  addProp(pLocZShifts, #hd, 17)
  put pSprites
  animFrame = 0
  OOO = me
  if gXFactor < 33 then
    myEy = [:]
    addProp(myEy, #models, getaProp(pModels, #ey))
    addProp(myEy, #colors, getaProp(pColors, #ey))
    addProp(myEy, #Inks, getaProp(pInks, #ey))
    addProp(myEy, #LocZShifts, getaProp(pLocZShifts, #ey))
    put "MyEy---------" && myEy
    deleteProp(pSprites, #ey)
    if getPos(lParts, "ey") > 0 then
      deleteAt(lParts, getPos(lParts, "ey"))
    end if
  end if
  return me
end

on beginSprite me
  if voidp(gpObjects) then
    gpObjects = [:]
  end if
  deleteProp(gpObjects, name)
  addProp(gpObjects, name, me.spriteNum)
  updateMembers(me)
  sprite(getaProp(pSprites, "sd")).blend = 16
end

on getName me
  return me.name
end

on getCustom me
  if pTrading = 1 then
    return me.Custom & RETURN & AddTextToField("TradingItems")
  end if
  if drink <> VOID then
    if drink contains "eat:" then
      return me.Custom & RETURN & AddTextToField("Food") & food
    else
      return me.Custom & RETURN & AddTextToField("Drink") && drink
    end if
  end if
  return me.Custom
end

on mouseEnter me
  helpText_setText(me.name)
end

on mouseLeave me
  helpText_empty(me.name)
end

on die me
  repeat with spr in pSprites
    sprMan_releaseSprite(spr)
  end repeat
  repeat with uspr in me.pSprites
    deleteProp(gUserSprites, uspr)
  end repeat
  if carryItemSpr > 0 then
    sprMan_releaseSprite(carryItemSpr)
  end if
  deleteProp(gpObjects, me.name)
end

on initiateForSync me
  moving = 0
  dancing = 0
  talking = 0
  drinking = 0
  pSleeping = 0
  isModerator = 0
  me.controller = 0
  carryItem = VOID
  food = EMPTY
  drink = VOID
  pLocFix = point(0, 0)
  iLocZFix = 0
  pTrading = 0
  repeat with part in lParts
    setaProp(pActions, part, "std")
  end repeat
  mainAction = "std"
  changes = 1
end

on fuseAction_mod me, prop
  if me.name = gMyName then
    gMeModerator = 1
  end if
  if voidp(gBadgeOn) then
    gBadgeOn = 1
  end if
  isModerator = 1
  if pModLevel = EMPTY then
    pModLevel = prop.word[2]
  end if
  if gMyName = name then
    gMyModLevel = pModLevel
  end if
end

on fuseAction_mv me, props
  oldDelim = the itemDelimiter
  destLocs = word 2 of props
  the itemDelimiter = ","
  destX = integer(item 1 of destLocs)
  destY = integer(item 2 of destLocs)
  destH = integer(item 3 of destLocs)
  startLScreen = getScreenCoordinate(locX, locY, height)
  destLScreen = getScreenCoordinate(destX, destY, destH)
  moveStart = the milliSeconds
  moving = 1
  the itemDelimiter = oldDelim
  mainAction = "wlk"
end

on fuseAction_sit me, props
  mainAction = "sit"
  restingHeight = float(word 2 of props)
end

on fuseAction_carryd me, props
  if props contains "eat:" then
    carryItem = "food"
    food = " " & word 3 of props
    drink = word 2 of props
  else
    carryItem = "drink"
    drink = word 2 of props
  end if
end

on fuseAction_drink me, props
  if props contains "eat:" then
    drinking = 1
    carryItem = "food"
    food = " " & word 3 of props
    drink = word 2 of props
  else
    drinking = 1
    carryItem = "drink"
    drink = word 2 of props
  end if
end

on fuseAction_lay me, props
  mainAction = "lay"
  put props
  restingHeight = float(word 2 of props)
  if word 3 of props <> "null" then
    oldDelim = the itemDelimiter
    the itemDelimiter = ":"
    fix = item (pDirections.bd / 2) + 1 of word 3 to the number of words in props of props
    if fix = EMPTY then
      fix = word 3 to the number of words in props of props
    end if
    pLocFix = point(integer(word 1 of fix), integer(word 2 of fix))
    iLocZFix = integer(word 3 of fix)
    the itemDelimiter = oldDelim
  else
    case pDirections.bd of
      2:
        pLocFix = point(40, 20)
        iLocZFix = 2000
      0:
        pLocFix = point(-40, 20)
        iLocZFix = 2000
    end case
  end if
end

on fuseAction_xtras me, props
  p = word 2 to the number of words in props of props
  specialXtras = keyValueToPropList(p)
end

on showSpecialInfo me
  global gpUiButtons
  put specialXtras && "<--- specialXtras"
  if not voidp(specialXtras) then
    matchem = getaProp(specialXtras, "matchem")
    if stringp(matchem) then
      member("matchem.user_name").text = matchem
    end if
  else
    member("matchem.user_name").text = " "
  end if
  if (isModerator = 1) or ((me.name = gMyName) and (gMeModerator = 1)) then
    sprite(726).castNum = getmemnum("sheriff_badge" & pModLevel)
    sprite(726).loc = point(694, 350)
    sprite(726).ink = 36
    if (gBadgeOn = 0) and ((me.name = gMyName) and (gMeModerator = 1)) then
      sprite(726).blend = 50
    else
      sprite(726).blend = 100
    end if
  else
    sprite(726).castNum = getmemnum("puppetsprite")
  end if
end

on hideSpecialInfo me
  global gpUiButtons
  member("matchem.user_name").text = " "
  sprite(726).castNum = getmemnum("puppetsprite")
end

on fuseAction_talk me, props
  talking = 1
  if mainAction = "lay" then
    setaProp(pActions, "fc", "lsp")
    setaProp(pActions, "hd", "lsp")
  else
    setaProp(pActions, "fc", "spk")
    setaProp(pActions, "hd", "spk")
    setaProp(pActions, "hr", "spk")
  end if
end

on fuseAction_gest me, props
  if mainAction = "lay" then
    gesture = "l" & (word 2 of props).char[1..2]
    setaProp(pActions, "ey", gesture)
    setaProp(pActions, "fc", gesture)
  else
    gesture = word 2 of props
    setaProp(pActions, "fc", gesture)
    setaProp(pActions, "hd", gesture)
    setaProp(pActions, "hr", gesture)
    setaProp(pActions, "ey", gesture)
  end if
  put "Gesture", props
end

on fuseAction_wave me, props
  setaProp(pActions, "lh", "wav")
  setaProp(pActions, "rh", "wav")
end

on fuseAction_dance me, props
  dancing = 1
end

on fuseAction_flatctrl me, props
  me.controller = 1
  if props contains "useradmin" then
    me.userController = 1
  else
    me.userController = 0
  end if
end

on exitFrame me
  counter = counter + 1
  if voidp(carryItem) and (carryItemSpr > 0) then
    sprMan_releaseSprite(carryItemSpr)
    carryItemSpr = 0
  end if
  if random(30) = 3 then
    if mainAction = "lay" then
      setaProp(pActions, "ey", "lay")
    else
      setaProp(pActions, "ey", "std")
    end if
  end if
  if (getaProp(pActions, "ey") = "ley") and not pSleeping then
    setaProp(pActions, "ey", mainAction)
    changes = 1
  end if
  if (getaProp(pActions, "ey") = "eyb") and not pSleeping then
    setaProp(pActions, "ey", mainAction)
    changes = 1
  end if
  if (counter mod 2) = 0 then
    if mainAction <> "std" then
      repeat with part in lParts
        if getaProp(pActions, part) = "std" then
          setaProp(pActions, part, mainAction)
        end if
      end repeat
    end if
    if (random(30) = 3) or pSleeping then
      if mainAction = "lay" then
        setaProp(pActions, "ey", "ley")
      else
        setaProp(pActions, "ey", "eyb")
      end if
      changes = 1
    end if
    if talking or drinking then
      changes = 1
    end if
    if moving then
      animFrame = animFrame + 1
      if animFrame > 3 then
        animFrame = 0
      end if
      factor = float(the milliSeconds - moveStart) / (moveTime * 1.0)
      if factor > 1.0 then
        factor = 1.0
      end if
      newLocs = ((destLScreen - startLScreen) * 1.0 * factor) + startLScreen
      setaProp(pActions, "ch", "std")
      setaProp(pActions, "ey", "std")
      setaProp(pActions, "fc", "std")
      setaProp(pActions, "hr", "std")
      setaProp(pActions, "hd", "std")
      updateMembers(me)
      repeat with part in lParts
        spr = getaProp(pSprites, part)
        dir = getaProp(pDirections, part)
        loczs = getaProp(pLocZShifts, part)
        flipmember = getaProp(pFlipped, part)
        if voidp(loczs) then
          loczs = 0
        end if
        if flipmember = 0 then
          sprite(spr).locH = integer(newLocs[1])
          sprite(spr).locV = integer(newLocs[2])
        else
          sprite(spr).locH = integer(newLocs[1]) + integer(gXFactor)
          sprite(spr).locV = integer(newLocs[2])
        end if
        sprite(spr).locZ = integer(newLocs[3]) + loczs
        if (part = "ey") or (part = "fc") then
          if (dir = 7) or (dir = 6) or (dir = 0) then
            sprite(spr).locH = 10000
          end if
        end if
        if flipmember = 1000 then
          sprite(spr).locH = 10000
          put part
        end if
        if (part = "hd") or (part = "hr") or (part = "ey") or (part = "ch") or (part = "fc") then
          sprite(spr).locV = sprite(spr).locV + pAnimFixV[dir + 1][animFrame + 1]
        end if
      end repeat
      if (dir = 0) or (dir = 1) or (dir = 2) then
        sprite(pSprites.lh).locZ = sprite(pSprites.ch).locZ - 3
        sprite(pSprites.ls).locZ = sprite(pSprites.ch).locZ - 1
      else
        if (dir = 4) or (dir = 5) or (dir = 6) then
          sprite(pSprites.rh).locZ = sprite(pSprites.ch).locZ - 3
          sprite(pSprites.rs).locZ = sprite(pSprites.ch).locZ - 1
        end if
      end if
      if carryItem <> VOID then
        if dir <> 7 then
          sprite(carryItemSpr).locH = newLocs[1] + pLocFix[1]
          sprite(carryItemSpr).locV = newLocs[2] + pLocFix[2]
          if (dir = 1) or (dir = 2) or (dir = 6) or (dir = 3) or (dir = 0) then
            sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ - 1
          else
            sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ + 1
          end if
          if drinking = 0 then
            sprite(carryItemSpr).castNum = getmemnum("drink_" & pDirections.bd & food)
          else
            sprite(carryItemSpr).castNum = getmemnum("drinking_" & pDirections.bd & food)
          end if
          if (gXFactor < 33) and (drinking = 0) then
            sprite(carryItemSpr).castNum = getmemnum("s_drink_" & pDirections.bd)
          else
            if gXFactor < 33 then
              sprite(carryItemSpr).castNum = getmemnum("ŠlŠ_nŠytŠ_drink_" & pDirections.bd)
            end if
          end if
        else
          sprite(carryItemSpr).locH = 10000
        end if
      end if
    else
      if dancing or drinking then
        animFrame = 0
        updateMembers(me)
      else
        if animFrame <> 0 then
          changes = 1
        end if
        animFrame = 0
        if changes then
          updateMembers(me)
        end if
        changes = 0
      end if
    end if
  end if
end

on setLocation me, x, y, h
  locX = x
  locY = y
  height = h
end

on setFix me, locf, loczf
  pLocFix = locf
  loczf = loczf
  updateMembers(me)
end

on updateMembers me
  tHeight = height
  if (mainAction = "sit") or (mainAction = "lay") then
    tHeight = restingHeight - 1.0
  end if
  if mainAction = "lay" then
    if getProp(pActions, #fc) = "spk" then
      setaProp(pActions, "fc", "lsp")
      setaProp(pActions, "hd", "lsp")
      setaProp(pActions, "hr", "lay")
      setaProp(pActions, "ey", "lay")
    else
      if getProp(pActions, #fc) <> "lay" then
        setaProp(pActions, "hr", "lay")
        setaProp(pActions, "hd", "lay")
      else
        if getProp(pActions, #fc) = "lay" then
          setaProp(pActions, "fc", "lay")
          setaProp(pActions, "ey", "lay")
          setaProp(pActions, "hr", "lay")
          setaProp(pActions, "hd", "lay")
        end if
      end if
    end if
    if getProp(pActions, #fc).char[1..1] <> "l" then
      gesture = "l" & getProp(pActions, #fc).char[1..2]
      setaProp(pActions, "ey", gesture)
      setaProp(pActions, "fc", gesture)
    end if
    pDirections.fc = pDirections.bd
    pDirections.hd = pDirections.bd
    pDirections.hr = pDirections.bd
    pDirections.ey = pDirections.bd
  end if
  screenLocs = getScreenCoordinate(locX, locY, tHeight)
  if dancing then
    if (counter mod 6) = 0 then
      if danceLegAnim = 2 then
        danceLegAnim = 0
      else
        danceLegAnim = 2
      end if
      danceHandAnim = (danceHandAnim mod 3) + 1
    end if
  end if
  if (carryItem <> VOID) and (carryItemSpr <= 0) then
    carryItemSpr = sprMan_getPuppetSprite()
  end if
  if drinking = (1 && carryItem) = "drink" then
    drinkAnimFrame = 0
  end if
  wave = random(30) = 2
  repeat with part in lParts
    spr = getaProp(pSprites, part)
    dir = getaProp(pDirections, part)
    model = getaProp(pModels, part)
    color = getaProp(pColors, part)
    action = getaProp(pActions, part)
    tAnimFrame = animFrame
    if ((part = "hd") or (part = "hr") or (part = "fc")) and talking then
      tAnimFrame = random(4) - 1
    end if
    flipmember = 0
    if dancing = 1 then
      case part of
        "bd", "lg", "sh":
          tAnimFrame = danceLegAnim
          action = "wlk"
        "hd", "fc", "hr", "ey":
          if random(24) = 2 then
            action = "ohd"
          end if
        "lh", "ls", "rh", "rs":
          if danceHandAnim = 1 then
            tAnimFrame = 0
            action = "crr"
            if ((part = "lh") or (part = "ls")) and not ((dir > 3) and (dir < 7)) then
              flipmember = 1
            end if
          else
            action = mainAction
          end if
      end case
    else
      if drinking = 1 then
        case part of
          "rh", "rs":
            tAnimFrame = drinkAnimFrame
            action = "drk"
        end case
      end if
    end if
    if (carryItem <> VOID) and not drinking then
      case part of
        "rh", "rs":
          action = "crr"
      end case
    end if
    memName = peopleSize & "_" & action & "_" & part & "_" & model & "_" & dir & "_" & tAnimFrame
    memNum = getmemnum(memName)
    if memNum < 1 then
      memName = peopleSize & "_" & action & "_" & part & "_" & model & "_" & dir & "_" & "0"
      memNum = getmemnum(memName)
    end if
    if memNum < 1 then
      if ((dir > 3) and (dir < 7)) or ((dir = 0) and (mainAction = "lay")) then
        flipmember = 1
      else
        memName = peopleSize & "_" & "std" & "_" & part & "_" & model & "_" & dir & "_" & "0"
        memNum = getmemnum(memName)
      end if
    end if
    if flipmember then
      if mainAction = "lay" then
        alternativeDir = 2
      else
        alternativeDir = 6 - dir
      end if
      if (part = "lh") or (part = "ls") or (part = "rh") or (part = "rs") then
        if part.char[1] = "l" then
          tmpPart = "r" & part.char[2]
        end if
        if part.char[1] = "r" then
          tmpPart = "l" & part.char[2]
        end if
        memName = peopleSize & "_" & action & "_" & tmpPart & "_" & model & "_" & alternativeDir & "_" & tAnimFrame
        memNum = getmemnum(memName)
      else
        memName = peopleSize & "_" & action & "_" & part & "_" & model & "_" & alternativeDir & "_" & tAnimFrame
        memNum = getmemnum(memName)
        if memNum < 1 then
          memName = peopleSize & "_" & action & "_" & part & "_" & model & "_" & alternativeDir & "_" & "0"
          memNum = getmemnum(memName)
          if memNum < 1 then
            memName = peopleSize & "_" & "std" & "_" & part & "_" & model & "_" & alternativeDir & "_" & "0"
            memNum = getmemnum(memName)
          end if
        end if
      end if
    end if
    skipLocation = 0
    sprite(spr).ink = getaProp(pInks, part)
    sprite(spr).bgColor = color
    if memNum > 0 then
      if flipmember then
        sprite(spr).rotation = 180
        sprite(spr).skew = 180
      else
        sprite(spr).rotation = 0
        sprite(spr).skew = 0
      end if
      sprite(spr).castNum = memNum
    else
      if (part = "lh") or (part = "ls") or (part = "rh") or (part = "rs") then
        flipmember = 0
      end if
      if ((part = "ey") or (part = "fc")) and ((dir = 7) or (dir = 6) or (dir = 0)) then
        sprite(spr).locH = 10000
        skipLocation = 1
      end if
      if part = "ch" then
        put "chest member not found"
      end if
    end if
    tmpHdDir = pDirections.hd
    tmpBdDir = pDirections.bd
    tmpHeadFixH = 0
    tmpHeadFixV = 0
    doHeadFix = 0
    if (part = "hd") or (part = "hr") or (part = "fc") or ((peopleSize = "h") and (part = "ey")) then
      doHeadFix = 1
    end if
    if (tmpBdDir <> tmpHdDir) and doHeadFix then
      if ((tmpHdDir < tmpBdDir) and ((tmpHdDir <> 0) and (tmpBdDir <> 7))) or ((tmpHdDir = 7) and (tmpBdDir = 0)) then
        tmpHeadFixH = pHeadLooseH[tmpBdDir + 1][1]
        tmpHeadFixV = pHeadLooseV[tmpBdDir + 1][1]
      else
        if ((tmpHdDir > tmpBdDir) and ((tmpHdDir <> 7) and (tmpBdDir <> 0))) or ((tmpHdDir = 0) and (tmpBdDir = 7)) then
          tmpHeadFixH = pHeadLooseH[tmpBdDir + 1][2]
          tmpHeadFixV = pHeadLooseV[tmpBdDir + 1][2]
        end if
      end if
    end if
    if (skipLocation = 0) and (moving = 0) then
      if flipmember = 0 then
        sprite(spr).locH = screenLocs[1] + pLocFix[1] + tmpHeadFixH
        sprite(spr).locV = screenLocs[2] + pLocFix[2] + tmpHeadFixV
      else
        sprite(spr).locH = screenLocs[1] + integer(gXFactor) + pLocFix[1] + tmpHeadFixH
        sprite(spr).locV = screenLocs[2] + pLocFix[2] + tmpHeadFixV
      end if
      loczs = getaProp(pLocZShifts, part)
      if voidp(loczs) then
        loczs = 0
      end if
      sprite(spr).locZ = integer(screenLocs[3]) + loczs + iLocZFix
    end if
    if (part = "lh") or (part = "ls") then
      if (dir = 0) or (dir = 1) or (dir = 2) then
        if part = "ls" then
          sprite(spr).locZ = sprite(pSprites.ch).locZ - 1
        end if
        if part = "lh" then
          sprite(spr).locZ = sprite(pSprites.ch).locZ - 3
        end if
      end if
    else
      if (part = "rh") or (part = "rs") then
        if (dir = 4) or (dir = 5) or (dir = 6) then
          if part = "rs" then
            sprite(spr).locZ = sprite(pSprites.ch).locZ - 1
          end if
          if part = "rh" then
            sprite(spr).locZ = sprite(pSprites.ch).locZ - 3
          end if
        end if
      end if
    end if
    if (part = "sh") and ((dir = 2) or (dir = 4)) then
      sprite(spr).locZ = sprite(pSprites.sh).locZ + 21
    end if
    setaProp(pFlipped, part, flipmember)
  end repeat
  if carryItem <> VOID then
    if dir <> 7 then
      sprite(carryItemSpr).locH = screenLocs[1] + pLocFix[1]
      sprite(carryItemSpr).locV = screenLocs[2] + pLocFix[2]
      if (dir = 1) or (dir = 2) or (dir = 6) or (dir = 3) or (dir = 0) then
        if drinking then
          case dir of
            2, 3:
              sprite(pSprites.rh).locZ = sprite(pSprites.fc).locZ + 2
              sprite(pSprites.rs).locZ = sprite(pSprites.fc).locZ + 3
          end case
        end if
        sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ - 1
      else
        if not drinking then
          sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ + 1
        else
          sprite(carryItemSpr).locZ = sprite(pSprites.hd).locZ + 1
        end if
      end if
      if drinking = 0 then
        sprite(carryItemSpr).castNum = getmemnum("drink_" & pDirections.bd & food)
      else
        sprite(carryItemSpr).castNum = getmemnum("drinking_" & pDirections.bd & food)
      end if
      if (gXFactor < 33) and (drinking = 0) then
        sprite(carryItemSpr).castNum = getmemnum("s_drink_" & pDirections.bd)
      else
        if gXFactor < 33 then
          sprite(carryItemSpr).castNum = getmemnum("ŠlŠ_nŠytŠ_drink_" & pDirections.bd)
        end if
      end if
    else
      sprite(carryItemSpr).locH = 10000
    end if
  end if
end

on setLocAndDir me, curX, curY, curHeight, dirHead, dirBody
  setLocation(me, curX, curY, curHeight)
  repeat with part in lParts
    setProp(pDirections, part, dirBody)
  end repeat
  if mainAction <> "lay" then
    setaProp(pDirections, "hd", dirHead)
    setaProp(pDirections, "ey", dirHead)
    setaProp(pDirections, "fc", dirHead)
    setaProp(pDirections, "hr", dirHead)
  end if
  changes = 1
end

on fuseAction_trd me
  pTrading = 1
end

on fuseAction_sleep me
  pSleeping = 1
end
