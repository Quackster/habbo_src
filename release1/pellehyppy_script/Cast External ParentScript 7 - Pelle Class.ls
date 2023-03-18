property name, Custom, locX, locY, height, direction, memberPrefix, memberModels, moving, destLScreen, startLScreen, moveStart, moveTime, talking, pModels, pDirections, pSprites, pInks, lParts, pActions, pColors, pLocZShifts, animFrame, dancing, danceLegAnim, danceHandAnim, counter, pAnimFixH, pAnimFixV, pFlipped, mainAction, restingHeight, changes, controller, userController, drink, drinkAnimFrame, drinkingAnimFrameDir, carryItem, carryItemSpr, drinking, food, myEy, specialXtras, pLocFix, iLocZFix, sleeping, swimSuitModels, swim, swimSdHeight, swimAnimCountDir, StayAndSwim, sign, signSpr, signDir, tSpr, pPelleswimSuitModels, pModLevel, isModerator
global gMyModLevel, OOO, gpObjects, gUserSprites, gMyName, gXFactor, gYFactor, peopleSize, goJumper

on new me, tName, tMemberPrefix, tMemberModels, tLocX, tLocY, tHeight, tdir, tlDimensions, tSpr2, tCustom, tswimsuit
  if tName = gMyName then
    gMyName = tName
  end if
  locX = tLocX
  locY = tLocY
  height = tHeight
  name = tName
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
  tSpr = tSpr2
  pSprites = [:]
  pLocFix = point(0, 0)
  iLocZFix = 0
  sleeping = 0
  pPelleswimSuitModels = tswimsuit
  if not (tswimsuit contains "ch=") then
    tswimsuit = EMPTY
  end if
  swimSuitModels = keyValueToPropList(tswimsuit, "&")
  if (Custom starts "ch=") or (Custom = "null") then
    Custom = EMPTY
  end if
  signSpr = VOID
  if tHeight < 7 then
    swim = 1
    swimSdHeight = tHeight
    height = 4
  end if
  swimsuit(me)
  figure(me)
  return me
end

on swimsuit me
  if swimSuitModels.findPos("ch") <> VOID then
    oldDelim = the itemDelimiter
    pModels.ch = swimSuitModels.ch
    the itemDelimiter = "/"
    pModels.sd = "s01" & "/" & pModels.sd.item[2]
    pModels.bd = "s01" & "/" & pModels.bd.item[2]
    pModels.lh = "s01" & "/" & pModels.lh.item[2]
    pModels.rh = "s01" & "/" & pModels.rh.item[2]
    the itemDelimiter = oldDelim
    pModels.deleteProp("rs")
    pModels.deleteProp("ls")
    pModels.deleteProp("sh")
    pModels.deleteProp("lg")
    repeat with f in ["rs", "ls", "sh", "lg"]
      if pSprites.findPos(f) <> VOID then
        delspr = pSprites.getProp(f)
        gUserSprites.deleteProp(delspr)
        pSprites.deleteProp(f)
        sprMan_releaseSprite(delspr)
      end if
    end repeat
  end if
end

on figure me
  if (the movieName).char[1..length(the movieName) - 4] <> "gf_private" then
    peopleSize = "sh"
  else
    peopleSize = "h"
  end if
  pAnimFixV = [[0, 0, 1, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0]]
  oldDelim = the itemDelimiter
  repeat with i = 1 to count(pModels)
    add(lParts, string(getPropAt(pModels, i)))
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
  pActions = [:]
  sort(pDirections)
  sort(pSprites)
  sort(pActions)
  repeat with i = 1 to count(lParts)
    part = lParts[i]
    addProp(pDirections, part, direction[1])
    if i > 1 then
      if pSprites.findPos(part) = VOID then
        newSpr = sprMan_getPuppetSprite()
        addProp(pSprites, part, newSpr)
        addProp(gUserSprites, newSpr, me)
      end if
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
  addProp(pLocZShifts, #sh, 5)
  addProp(pLocZShifts, #lg, 10)
  addProp(pLocZShifts, #ch, 15)
  addProp(pLocZShifts, #lh, 20)
  addProp(pLocZShifts, #ls, 30)
  addProp(pLocZShifts, #rh, 20)
  addProp(pLocZShifts, #rs, 30)
  addProp(pLocZShifts, #fc, 100)
  addProp(pLocZShifts, #ey, 111)
  addProp(pLocZShifts, #hr, 112)
  addProp(pLocZShifts, #hd, 31)
  animFrame = 0
  swimAnimCountDir = 0
  OOO = me
  if gXFactor < 33 then
    myEy = [:]
    addProp(myEy, #models, getaProp(pModels, #ey))
    addProp(myEy, #colors, getaProp(pColors, #ey))
    addProp(myEy, #Inks, getaProp(pInks, #ey))
    addProp(myEy, #LocZShifts, getaProp(pLocZShifts, #ey))
    deleteProp(pSprites, #ey)
    if getPos(lParts, "ey") > 0 then
      deleteAt(lParts, getPos(lParts, "ey"))
    end if
  end if
end

on updateSwimSuit me, tMemberModels, tswimsuit
  if not (tswimsuit contains "ch=") then
    tswimsuit = EMPTY
  end if
  pModels = keyValueToPropList(tMemberModels, "&")
  pColors = [:]
  pInks = [:]
  pFlipped = [:]
  sort(pInks)
  sort(pColors)
  sort(pModels)
  lParts = []
  swimSuitModels = keyValueToPropList(tswimsuit, "&")
  swimsuit(me)
  figure(me)
  return 
end

on PelleIsLife me, whichPelle
  if (whichPelle = name) and (voidp(pSprites) = 0) then
    return 1
  end if
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

on GetMyLoc me
  put me.name, locX, locY, height
end

on getCustom me
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
  if signSpr <> VOID then
    sprite(signSpr).locH = -1000
    sprMan_releaseSprite(signSpr)
    signSpr = VOID
  end if
  deleteProp(gpObjects, me.name)
end

on initiateForSync me
  moving = 0
  dancing = 0
  talking = 0
  drinking = 0
  swim = 0
  StayAndSwim = 0
  me.controller = 0
  carryItem = VOID
  food = EMPTY
  drink = VOID
  pLocFix = point(0, 0)
  iLocZFix = 0
  repeat with part in lParts
    setaProp(pActions, part, "std")
  end repeat
  mainAction = "std"
  changes = 1
  sign = VOID
end

on signCheck me
  if (moving = 1) or (swim = 1) then
    sing = VOID
  end if
  if sign = VOID then
    if signSpr <> VOID then
      sprite(signSpr).locH = -1000
      sprMan_releaseSprite(signSpr)
      signSpr = VOID
    end if
  else
    if abs(me.direction[2] - 2) < abs(me.direction[2] - 4) then
      signDir = 2
    else
      signDir = 4
    end if
    if signSpr = VOID then
      signSpr = sprMan_getPuppetSprite()
    end if
    signMem = getmemnum("sign" & sign)
    if signMem > 0 then
      sprite(signSpr).member = signMem
      dancing = 0
    else
      put "not found:", "pelle_" & "sign" & sign
    end if
  end if
end

on showSpecialInfo me
  global gpUiButtons
  put specialXtras && "<--- specialXtras"
  if not voidp(specialXtras) then
    matchem = getaProp(specialXtras, "matchem")
    if stringp(matchem) then
      member("matchem.user_name").text = doSpecialCharConversion(matchem)
    end if
  else
    member("matchem.user_name").text = " "
  end if
end

on hideSpecialInfo me
  global gpUiButtons
  member("matchem.user_name").text = " "
end

on fuseAction_mod me, prop
  if me.name = gMyName then
    gMeModerator = 1
  end if
  isModerator = 1
end

on exitFrame me
  global gWaterSpr
  signCheck(me)
  if voidp(goJumper) = 0 then
    if goJumper.name = name then
      setLocation(me, 1000, 1000, height)
      startLScreen = getScreenCoordinate(1000, 1000, height)
      destLScreen = getScreenCoordinate(1000, 1000, height)
    end if
  end if
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
  if getaProp(pActions, "ey") = "ley" then
    setaProp(pActions, "ey", mainAction)
    changes = 1
  end if
  if getaProp(pActions, "ey") = "eyb" then
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
    if random(30) = 3 then
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
    if height < 7 then
      swim = 1
    end if
    if (moving = 0) and (swim = 1) then
      StayAndSwim = 1
    end if
    if moving or StayAndSwim then
      if swim = 0 then
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
        if swimSuitModels.findPos("ch") <> VOID then
          setaProp(pActions, "ch", "wlk")
        end if
        if talking then
          setaProp(pActions, "fc", "spk")
          setaProp(pActions, "hd", "spk")
          setaProp(pActions, "hr", "spk")
        end if
      else
        dancing = 0
        if swimAnimCountDir = 0 then
          if StayAndSwim and ((counter mod 3) = 0) then
            nothing()
          else
            animFrame = animFrame + 1
          end if
          if animFrame > 3 then
            animFrame = 3
            swimAnimCountDir = 1
          end if
        else
          if StayAndSwim and ((counter mod 3) = 0) then
            nothing()
          else
            animFrame = animFrame - 1
          end if
          if animFrame < 0 then
            animFrame = 0
            swimAnimCountDir = 0
          end if
        end if
        factor = float(the milliSeconds - moveStart) / (moveTime * 1.0)
        if factor > 1.0 then
          factor = 1.0
        end if
        newLocs = ((destLScreen - startLScreen) * 1.0 * factor) + startLScreen
        if StayAndSwim then
          swimAc = "sws"
        else
          swimAc = "swm"
        end if
        setaProp(pActions, "ch", swimAc)
        setaProp(pActions, "ey", "std")
        setaProp(pActions, "fc", "std")
        setaProp(pActions, "hr", "std")
        setaProp(pActions, "hd", "std")
        setaProp(pActions, "bd", swimAc)
        setaProp(pActions, "lh", swimAc)
        setaProp(pActions, "rh", swimAc)
        if talking then
          setaProp(pActions, "fc", "spk")
          setaProp(pActions, "hd", "spk")
          setaProp(pActions, "hr", "spk")
        end if
      end if
      if (destLScreen = VOID) or (startLScreen = VOID) then
        newLocs = getScreenCoordinate(locX, locY, height)
      end if
      updateMembers(me)
      repeat with part in lParts
        spr = getaProp(pSprites, part)
        model = getaProp(pModels, part)
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
        if swim and ((counter mod 6) = 0) then
          sprite(spr).locV = sprite(spr).locV + 1
        end if
        if (part = "hd") or (part = "hr") or (part = "ey") or (part = "ch") or (part = "fc") then
          if swim = 0 then
            sprite(spr).locV = sprite(spr).locV + pAnimFixV[dir + 1][animFrame + 1]
            next repeat
          end if
          if part <> "ch" then
            sprite(spr).locZ = sprite(spr).locZ + 70000
          end if
        end if
      end repeat
      if (dir = 0) or (dir = 1) or (dir = 2) then
        sprite(pSprites.lh).locZ = sprite(pSprites.bd).locZ - 1
        if pSprites.findPos("ls") <> VOID then
          sprite(pSprites.ls).locZ = sprite(pSprites.ch).locZ - 10
        end if
      else
        if (dir = 4) or (dir = 5) or (dir = 6) then
          sprite(pSprites.rh).locZ = sprite(pSprites.bd).locZ - 1
          if pSprites.findPos("rs") <> VOID then
            sprite(pSprites.rs).locZ = sprite(pSprites.ch).locZ - 10
          end if
        end if
      end if
      if carryItem <> VOID then
        if dir <> 7 then
          sprite(carryItemSpr).locH = newLocs[1] + pLocFix[1]
          sprite(carryItemSpr).locV = newLocs[2] + pLocFix[2]
          if (dir = 1) or (dir = 2) or (dir = 6) or (dir = 3) or (dir = 0) then
            sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ - 1
            if dir = 6 then
              sprite(carryItemSpr).locH = 1000
            end if
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
      if swim then
        if swimSdHeight = VOID then
          swimSdHeight = height - 2
        end if
        sprite(getaProp(pSprites, "sd")).locV = sprite(getaProp(pSprites, "sd")).locV + ((4 - swimSdHeight) * gYFactor)
        if (moving and (random(5) = 1)) or (random(35) = 1) then
          if getaProp(pFlipped, #hd) then
            rippleLoc = sprite(pSprites.hd).loc - point(gXFactor + 5, 0)
          else
            rippleLoc = sprite(pSprites.hd).loc
          end if
          sendSprite(gWaterSpr, #NewRipple, rippleLoc - point(22, 36))
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
        if swim then
          sprite(getaProp(pSprites, "sd")).locV = sprite(getaProp(pSprites, "sd")).locV + ((4 - height) * gYFactor)
        end if
      end if
    end if
  end if
end

on setLocation me, x, y, h
  locX = x
  locY = y
  height = h
  if h < 7 then
    swim = 1
    swimSdHeight = h
    height = 4
  end if
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
  if drinking = 1 then
    drinkAnimFrame = 0
  end if
  if sleeping then
    setaProp(pActions, "ey", "eyb")
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
    if sign <> VOID then
      case part of
        "ls":
          action = "sig"
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
    if (skipLocation = 0) and (moving = 0) then
      if flipmember = 0 then
        sprite(spr).locH = screenLocs[1] + pLocFix[1]
        sprite(spr).locV = screenLocs[2] + pLocFix[2]
      else
        sprite(spr).locH = screenLocs[1] + integer(gXFactor) + pLocFix[1]
        sprite(spr).locV = screenLocs[2] + pLocFix[2]
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
          sprite(spr).locZ = sprite(pSprites.ch).locZ - 9
        end if
        if part = "lh" then
          sprite(spr).locZ = sprite(pSprites.ch).locZ - 10
        end if
      end if
    else
      if (part = "rh") or (part = "rs") then
        if (dir = 4) or (dir = 5) or (dir = 6) then
          if part = "rs" then
            sprite(spr).locZ = sprite(pSprites.ch).locZ - 9
          end if
          if part = "rh" then
            sprite(spr).locZ = sprite(pSprites.ch).locZ - 10
          end if
        end if
      end if
    end if
    if (part = "sh") and ((dir = 2) or (dir = 4)) then
      sprite(spr).locZ = sprite(pSprites.sh).locZ + 100
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
              if pSprites.findPos("rs") <> VOID then
                sprite(pSprites.rs).locZ = sprite(pSprites.fc).locZ + 3
              end if
          end case
        end if
        sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ - 1
        if dir = 6 then
          sprite(carryItemSpr).locH = 1000
        end if
      else
        if not drinking then
          sprite(carryItemSpr).locZ = sprite(pSprites.rh).locZ + 1
        else
          sprite(carryItemSpr).locZ = sprite(pSprites.hd).locZ + 1
        end if
        if dir = 5 then
          sprite(pSprites.rh).locZ = sprite(pSprites.bd).locZ - 1
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
  if (sign <> VOID) and (signSpr <> VOID) then
    if (moving <> 1) and (swim <> 1) then
      newLocH = screenLocs[1] + pLocFix[1]
      newLocV = screenLocs[2] + pLocFix[1]
      sprite(pSprites.lh).member = getmemnum("sh_sig_lh_s01_2_0")
      if mainAction = "sit" then
        if pDirections.bd = 0 then
          newLocH = newLocH - 20
          sprite(pSprites.lh).member = getmemnum("sh_sig_lh_s01_0_0")
        else
          if pDirections.bd = 6 then
            newLocH = newLocH - 20
            sprite(pSprites.lh).member = getmemnum("sh_sig_lh_s01_2_0")
          else
            if pDirections.bd = 4 then
              newLocH = newLocH - 1
              sprite(pSprites.lh).member = getmemnum("sh_sig_lh_s01_0_0")
            end if
          end if
        end if
      else
        if pDirections.bd = 4 then
          sprite(pSprites.lh).locZ = sprite(pSprites.hr).locZ + 1
        end if
        if FlipedOrNot(me) then
          sprite(pSprites.lh).member = getmemnum("sh_sig_lh_s01_0_0")
          if pSprites.findPos("ls") <> VOID then
            sprite(pSprites.ls).locZ = sprite(pSprites.lh).locZ + 1
          end if
        end if
      end if
      sprite(signSpr).locH = newLocH
      sprite(signSpr).locV = newLocV
      sprite(signSpr).locZ = sprite(pSprites.lh).locZ + 1
    else
      if signSpr <> VOID then
        sprite(signSpr).locH = -1000
      end if
    end if
  end if
end

on FlipedOrNot me
  if (pDirections.bd = 4) or (pDirections.bd = 5) or (pDirections.bd = 6) then
    return 1
  else
    return 0
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
  if startLScreen = VOID then
    startLScreen = getScreenCoordinate(curX, curY, height)
    destLScreen = startLScreen
  end if
  changes = 1
end

on closeEyes me
  dancing = 0
  sleeping = 1
  put name && "fell to sleep..."
end

on fuseAction_mv me, props
  oldDelim = the itemDelimiter
  destLocs = word 2 of props
  the itemDelimiter = ","
  destX = integer(item 1 of destLocs)
  destY = integer(item 2 of destLocs)
  destH = integer(item 3 of destLocs)
  if destH < 7 then
    swimSdHeight = destH
    destH = 4
  end if
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
  dancing = 0
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
end

on fuseAction_swim me, props
  swim = 1
end

on fuseAction_wave me, props
  setaProp(pActions, "lh", "wav")
  setaProp(pActions, "rh", "wav")
end

on fuseAction_sign me, p
  sign = word 2 of p
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
