property pLocation, pOwner, pSprite, pID, objectType, showName, showDescription, pType
global gpObjects, gMyName

on new me, towner, tlocation, tid, ttype
  pType = value(ttype.word[1])
  pID = tid
  objectType = "poster"
  showName = EMPTY
  showDescription = EMPTY
  pSprite = sprMan_getPuppetSprite()
  updateItem(me, pID, tlocation, ttype)
  if pLocation contains "leftwall" then
    sprite(pSprite).castNum = getmemnum("leftwall poster" && pType)
  else
    sprite(pSprite).castNum = getmemnum("rightwall poster" && pType)
  end if
  sprite(pSprite).scriptInstanceList = [me]
  setProp(me, #spriteNum, pSprite)
  beginSprite(me)
  update(me)
  return me
end

on updateItem me, tid, tlocation, ttype
  if pID = tid then
    tDelim = the itemDelimiter
    the itemDelimiter = "/"
    pLocation = tlocation.item[1]
    the itemDelimiter = tDelim
  end if
end

on update me
  if pLocation contains "leftwall" then
    sprite(me.spriteNum).member = getmemnum("leftwall poster" && pType)
  else
    sprite(me.spriteNum).member = getmemnum("rightwall poster" && pType)
  end if
  sprite(me.spriteNum).loc = getScreenLoc(me)
end

on beginSprite me
  me.spriteNum = pSprite
end

on itemDie me, itemId
  if itemId = pID then
    sprMan_releaseSprite(pSprite)
  end if
end

on getScreenLoc me
  the itemDelimiter = ","
  if word 1 of pLocation = "leftwall" then
    x = 0
    y = item 1 of word 2 of pLocation
    h = item 2 of word 2 of pLocation
  else
    if word 1 of pLocation = "frontwall" then
      x = 0
      y = item 1 of word 2 of pLocation
      h = item 2 of word 2 of pLocation
    end if
  end if
  screenLocs = getScreenCoordinate(x, y, h)
  sprite(me.spriteNum).locH = screenLocs[1]
  sprite(me.spriteNum).locV = screenLocs[2]
  sprite(me.spriteNum).locZ = value(item 3 of word 2 of pLocation)
  if sprite(me.spriteNum).locZ > 30000 then
    sprite(me.spriteNum).locZ = screenLocs[3] - 1000
  end if
end

on mouseDown me
  global hiliter, gInfofieldIconSprite, gpUiButtons, gChosenStuffSprite, gChosenStuffType, gChosenStuffId
  if the doubleClick then
    return 
  end if
  if showName = EMPTY then
    getPosterInfo(me)
  end if
  mouseDown(hiliter, 1)
  myUserSpr = getaProp(gpObjects, gMyName)
  if listp(gpUiButtons) and (the movieName contains "private") then
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffId = string(pID)
    gChosenStuffType = #wallItem
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
  end if
end

on getPosterInfo me
  if member("posterlist").memberNum = -1 then
    return VOID
  end if
  tSaveDelimiter = the itemDelimiter
  the itemDelimiter = ":"
  tPosterData = member("posterlist").text
  repeat with i = 1 to tPosterData.line.count
    if tPosterData.line[i].item[1].word[1..tPosterData.line[i].item[1].word.count] = pType then
      showName = tPosterData.line[i].item[2].word[1..tPosterData.line[i].item[2].word.count]
      showDescription = tPosterData.line[i].item[6].word[1..tPosterData.line[i].item[6].word.count]
      the itemDelimiter = tSaveDelimiter
      return 
    end if
  end repeat
  the itemDelimiter = tSaveDelimiter
end

on setInfoTexts me
  global gInfofieldIconSprite, gpUiButtons, gChosenUser, hiliter, gIAmOwner
  if stringp(gChosenUser) then
    return 
  end if
  emptyInfoFields(hiliter)
  sendSprite(gInfofieldIconSprite, #setIcon, objectType)
  if not voidp(me.showName) and not voidp(me.showDescription) then
    member("item.info_name").text = me.showName
    member("item.info_text").text = me.showDescription
  end if
  if listp(gpUiButtons) and (the movieName contains "private") then
    myUserSprite = getaProp(gpObjects, gMyName)
    if voidp(myUserSprite) or (myUserSprite < 1) then
      return 
    end if
    myUserObj = sprite(myUserSprite).scriptInstanceList[1]
    if myUserObj.controller = 1 then
      sendSprite(getaProp(gpUiButtons, "movestuff"), #enable)
      sendSprite(getaProp(gpUiButtons, "rotatestuff"), #enable)
      if gIAmOwner = 1 then
        sendSprite(getaProp(gpUiButtons, "pickstuff"), #enable)
        sendSprite(getaProp(gpUiButtons, "removestuff"), #enable)
      end if
    end if
  end if
end

on deletePoster me
  sendFuseMsg("REMOVEITEM /" & pID)
end
