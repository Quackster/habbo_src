property pID, pLocation, pSprite, pType, showName, objectType

on new me, towner, tlocation, tid, ttype 
  pType = value(ttype.getProp(#word, 1))
  pID = tid
  objectType = "poster"
  showName = ""
  showDescription = ""
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
  return(me)
end

on updateItem me, tid, tlocation, ttype 
  if pID = tid then
    tDelim = the itemDelimiter
    the itemDelimiter = "/"
    pLocation = tlocation.getProp(#item, 1)
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
  if pLocation.word[1] = "leftwall" then
    x = 0
    y = pLocation.word[2].item[1]
    h = pLocation.word[2].item[2]
  else
    if pLocation.word[1] = "frontwall" then
      x = 0
      y = pLocation.word[2].item[1]
      h = pLocation.word[2].item[2]
    end if
  end if
  screenLocs = getScreenCoordinate(x, y, h)
  sprite(me.spriteNum).locH = screenLocs.getAt(1)
  sprite(me.spriteNum).locV = screenLocs.getAt(2)
  sprite(me.spriteNum).locZ = value(pLocation.word[2].item[3])
  if sprite(me.spriteNum).locZ > 30000 then
    sprite(me.spriteNum).locZ = screenLocs.getAt(3) - 1000
  end if
end

on mouseDown me 
  if the doubleClick then
    return()
  end if
  if showName = "" then
    getPosterInfo(me)
  end if
  mouseDown(hiliter, 1)
  myUserSpr = getaProp(gpObjects, gMyName)
  if listp(gpUiButtons) and the movieName contains "private" then
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffId = string(pID)
    gChosenStuffType = #wallItem
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
  end if
end

on getPosterInfo me 
  if member("posterlist").memberNum = -1 then
    return(void())
  end if
  tSaveDelimiter = the itemDelimiter
  the itemDelimiter = ":"
  tPosterData = member("posterlist").text
  i = 1
  repeat while i <= tPosterData.count(#line)
    if tPosterData.getPropRef(#line, i).getPropRef(#item, 1).getProp(#word, 1, tPosterData.getPropRef(#line, i).getPropRef(#item, 1).count(#word)) = pType then
      showName = tPosterData.getPropRef(#line, i).getPropRef(#item, 2).getProp(#word, 1, tPosterData.getPropRef(#line, i).getPropRef(#item, 2).count(#word))
      showDescription = tPosterData.getPropRef(#line, i).getPropRef(#item, 6).getProp(#word, 1, tPosterData.getPropRef(#line, i).getPropRef(#item, 6).count(#word))
      the itemDelimiter = tSaveDelimiter
      return()
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tSaveDelimiter
end

on setInfoTexts me 
  if stringp(gChosenUser) then
    return()
  end if
  emptyInfoFields(hiliter)
  sendSprite(gInfofieldIconSprite, #setIcon, objectType)
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
