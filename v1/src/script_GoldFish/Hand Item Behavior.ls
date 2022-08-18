property type, stripId, itemType, shadowSpr, partColors, myUserObj, helpText, origLoc
global gpStuffTypes, hiliter, gMyName, gpObjects, gpPostItNos

on beginSprite me
  if (count(sprite(getaProp(gpObjects, gMyName)).scriptInstanceList) > 0) then
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
  end if
  shadowSpr = (me.spriteNum - 1)
  sprite(me.spriteNum).blend = 100
  sprite(me.spriteNum).visible = 0
  sprite(shadowSpr).visible = 0
  if (myUserObj.controller = 1) then
    helpText = AddTextToField("SelectByClikingAndPlace")
  else
    helpText = AddTextToField("YouCantPlaceObjects")
  end if
  origLoc = sprite(me.spriteNum).loc
end

on setItem me, ttype, tid, titemType, tpartColors
  global gTraderWindow
  stripId = tid
  type = ttype
  itemType = titemType
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  partColors = tpartColors
  tlpartColors = []
  the itemDelimiter = ","
  repeat with t = 1 to the number of items in tpartColors
    add(tlpartColors, string(item t of tpartColors))
  end repeat
  put "itemtype", itemType
  if ((ttype = "post.it") and (gpPostItNos <> VOID)) then
    if (getProp(gpPostItNos, stripId) = VOID) then
      Postnums = 6
    else
      Postnums = integer((getProp(gpPostItNos, stripId) / (20.0 / 6.0)))
    end if
    if (Postnums > 6) then
      Postnums = 6
    end if
    if (Postnums <= 0) then
      Postnums = 0
    end if
    ttype = ((ttype & "_") & Postnums)
    put ttype
  end if
  if (getmemnum((ttype & "_small")) > 0) then
    sprite(me.spriteNum).castNum = getmemnum((ttype & "_small"))
  else
    if (offset("*", ttype) > 0) then
      ttype = char 1 to (offset("*", ttype) - 1) of ttype
      sprite(me.spriteNum).castNum = getmemnum((ttype & "_small"))
      put (ttype & "_small")
    end if
  end if
  if (string(tlpartColors[count(tlpartColors)]) starts "*") then
    sprite(me.spriteNum).bgColor = rgb(("#" & char 2 to string(tlpartColors[count(tlpartColors)]).length of string(tlpartColors[count(tlpartColors)])))
  else
    sprite(me.spriteNum).bgColor = paletteIndex(integer(tlpartColors[count(tlpartColors)]))
  end if
  if objectp(gTraderWindow) then
    tImInTradeBox = checkIfItemIsUnderTrade(gTraderWindow, stripId)
    if tImInTradeBox then
      sprite(me.spriteNum).blend = 0
      return 
    else
      if objectp(gTraderWindow.pItemMoverObj) then
        if (gTraderWindow.pItemMoverObj.pStripID = stripId) then
          sprite(me.spriteNum).blend = 0
          return 
        end if
      end if
    end if
  end if
  sprite(me.spriteNum).blend = 100
  sprite(me.spriteNum).visible = 1
  sprite(shadowSpr).visible = 1
end

on exitFrame me
  if ((type contains "post.it") and (gpPostItNos <> VOID)) then
    if (getProp(gpPostItNos, stripId) = VOID) then
      Postnums = 6
    else
      Postnums = integer((getProp(gpPostItNos, stripId) / (20.0 / 6.0)))
    end if
    if (Postnums > 6) then
      Postnums = 6
    end if
    if (Postnums <= 0) then
      Postnums = 0
    end if
    type = ((type & "_") & Postnums)
    if (getmemnum((type & "_small")) > 0) then
      sprite(me.spriteNum).castNum = getmemnum((type & "_small"))
    else
      if (offset("*", type) > 0) then
        type = char 1 to (offset("*", type) - 1) of type
        sprite(me.spriteNum).castNum = getmemnum((type & "_small"))
        put (type & "_small")
      end if
    end if
    sprite(me.spriteNum).visible = 1
    sprite(shadowSpr).visible = 1
  end if
end

on dieHandItem me
  sprite(me.spriteNum).visible = 0
  sprite(shadowSpr).visible = 0
end

on mouseEnter me
  helpText_setText(helpText)
end

on mouseLeave me
  helpText_empty(helpText)
end

on mouseUp me
  global gTraderWindow
  if voidp(gpStuffTypes) then
    return 
  end if
  l = getaProp(gpStuffTypes, stripId)
  if voidp(l) then
    return 
  end if
  hideItem = 1
  put ("Handitem:" && l)
  if objectp(gTraderWindow) then
    if (itemType <> #stuff) then
      helpText_setText(AddTextToField("NotATradeableItem"))
      pass()
    end if
    if (hiliter.placingStuffStripId <> stripId) then
      if (sprite(me.spriteNum).blend < 100) then
        pass()
      end if
      if (sprite(me.spriteNum).visible = 0) then
        pass()
      end if
    end if
    if (amIFull(gTraderWindow) = 1) then
      return 
    end if
    helpText_setText(AddTextToField("DragItemsToTradeWindow"))
    placeItemToTradeWindow(gTraderWindow, getAt(l, 2), stripId, me.spriteNum, sprite(me.spriteNum).bgColor)
    sprite(me.spriteNum).visible = 0
    if (type contains "post.it") then
      sprite(me.spriteNum).blend = 0
    end if
    sprite(shadowSpr).visible = 0
    return 
  end if
  if (itemType = #stuff) then
    placeStuff(hiliter, getAt(l, 2), "a", getAt(l, 3), getAt(l, 4), "0", partColors, stripId)
  else
    if (l.count > 2) then
      tValue = getAt(l, 3)
    else
      tValue = VOID
    end if
    hideItem = placeItem(hiliter, getAt(l, 2), stripId, tValue)
  end if
  if hideItem then
    sprite(me.spriteNum).visible = 0
    sprite(shadowSpr).visible = 0
  end if
end

on checkPos me, event
  if voidp(stripId) then
    return 
  end if
  if (sprite(me.spriteNum).blend < 100) then
    return 
  end if
  if (sprite(me.spriteNum).visible = 0) then
    return 
  end if
  if the mouseLoc.inside(sprite(me.spriteNum).rect) then
    return stripId
  end if
end

on returnSprByID me, tid
  if (tid = stripId) then
    return me.spriteNum
  end if
end
