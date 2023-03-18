property location, data, owner, spr, id, myColor
global popUpOn, gOpenPostIt, gpObjects, gMyName, gPostitCounter

on new me, towner, tlocation, tid, tdata
  gPostitCounter = gPostitCounter + 1
  id = tid
  spr = sprMan_getPuppetSprite()
  updateItem(me, id, tlocation, tdata)
  if location contains "leftwall" then
    sprite(spr).castNum = getmemnum("leftwall" && "post.it")
  else
    sprite(spr).castNum = getmemnum("rightwall" && "post.it")
  end if
  sprite(spr).scriptInstanceList = [me]
  setProp(me, #spriteNum, spr)
  beginSprite(me)
  popUpOn = 0
  update(me)
  return me
end

on updateItem me, tid, tlocation, tdata
  if id = tid then
    location = tlocation
    data = word 2 to the number of words in tdata of tdata
    myColor = word 1 of tdata
  end if
end

on update me
  sprite(me.spriteNum).loc = getScreenLoc(me)
  sprite(me.spriteNum).bgColor = rgb(myColor)
end

on beginSprite me
  me.spriteNum = spr
  update(me)
end

on itemDie me, itemId
  if itemId = me.id then
    sprMan_releaseSprite(spr)
    if gOpenPostIt = me then
      popupClose("post.it")
    end if
  end if
end

on getScreenLoc me
  the itemDelimiter = ","
  if word 1 of location = "leftwall" then
    x = 0
    y = item 1 of word 2 of location
    h = item 2 of word 2 of location
  else
    if word 1 of location = "frontwall" then
      x = 0
      y = item 1 of word 2 of location
      h = item 2 of word 2 of location
    end if
  end if
  screenLocs = getScreenCoordinate(x, y, h)
  sprite(me.spriteNum).locH = screenLocs[1]
  sprite(me.spriteNum).locV = screenLocs[2]
  sprite(me.spriteNum).locZ = value(item 3 of word 2 of location)
  if sprite(me.spriteNum).locZ > 30000 then
    sprite(me.spriteNum).locZ = screenLocs[3] - 1000
  end if
end

on mouseDown me
  global MyMaxLines, gPostItColor
  gPostItColor = rgb(myColor)
  put data into field "post.it field_NoAdding"
  put EMPTY into field "post.it field_Add"
  MyLineNum = member("post.it field_NoAdding").height / member("post.it field_NoAdding").lineHeight
  MyMaxLines = 12 - (member("post.it field_NoAdding").height / member("post.it field_NoAdding").lineHeight)
  if MyMaxLines < 1 then
    MyMaxLines = 0
  end if
  nextLineV = -63 + member("post.it field_NoAdding").charPosToLoc(member("post.it field_NoAdding").text.length).locV
  gOpenPostIt = me
  popupClose("post.it")
  popUpLoc = the mouseLoc
  put popUpLoc
  if popUpLoc[1] < 100 then
    popUpLoc[1] = 120
  end if
  if popUpLoc[2] < 100 then
    popUpLoc[2] = 110
  end if
  if popUpLoc[1] > 600 then
    popUpLoc[1] = 570
  end if
  if popUpLoc[2] > 400 then
    popUpLoc[2] = 370
  end if
  myUserSpr = getaProp(gpObjects, gMyName)
  if myUserSpr > 0 then
    myUserObj = sprite(myUserSpr).scriptInstanceList[1]
    if myUserObj.controller = 0 then
      repeat with f = 1 to member("post.it .pop").line.count
        if member("post.it .pop").text.line[f] contains "post.it field_Add" then
          member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91," & nextLineV & "):36:100:gPostItColor:FocusField"
          if MyLineNum > 11 then
            member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91,-1000):36:100:gPostItColor:FocusField"
          end if
          if (MyLineNum = 1) and (data = EMPTY) then
            member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91,-63):36:100:gPostItColor:FocusField"
          end if
          exit repeat
        end if
      end repeat
      popup("post.it .pop", popUpLoc, "post.it")
      return 
    end if
  else
    return 
  end if
  repeat with f = 1 to member("post.it .pop .controller").line.count
    if member("post.it .pop .controller").line[f] contains "post.it field_Add" then
      member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91," & nextLineV & "):36:100:gPostItColor:FocusField"
      if MyLineNum > 11 then
        member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91,-1000):36:100:gPostItColor:FocusField"
      end if
      if (MyLineNum = 1) and (data = EMPTY) then
        member("post.it .pop .controller").line[f] = "post.it field_Add:point(-91,-63):36:100:gPostItColor:FocusField"
      end if
      exit repeat
    end if
  end repeat
  popup("post.it .pop .controller", popUpLoc, "post.it")
end

on deletePostit me
  sendFuseMsg("REMOVEITEM /" & id)
  gPostitCounter = gPostitCounter - 1
  put "Number of Postit" && gPostitCounter
end

on savePostit me
  data = field("post.it field_NoAdding") & RETURN & field("post.it field_Add")
  sendFuseMsg("SETITEMDATA /" & id & "/" & myColor && data)
end
