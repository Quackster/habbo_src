property id, location, spr, myColor, data

on new me, towner, tlocation, tid, tdata 
  gPostitCounter = (gPostitCounter + 1)
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
  return(me)
end

on updateItem me, tid, tlocation, tdata 
  if (id = tid) then
    location = tlocation
    data = tdata.word[2..the number of word in tdata]
    myColor = tdata.word[1]
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
  if (itemId = me.id) then
    sprMan_releaseSprite(spr)
    if (gOpenPostIt = me) then
      popupClose("post.it")
    end if
  end if
end

on getScreenLoc me 
  the itemDelimiter = ","
  if (location.word[1] = "leftwall") then
    x = 0
    y = location.word[2].item[1]
    h = location.word[2].item[2]
  else
    if (location.word[1] = "frontwall") then
      x = 0
      y = location.word[2].item[1]
      h = location.word[2].item[2]
    end if
  end if
  screenLocs = getScreenCoordinate(x, y, h)
  sprite(me.spriteNum).locH = screenLocs.getAt(1)
  sprite(me.spriteNum).locV = screenLocs.getAt(2)
  sprite(me.spriteNum).locZ = value(location.word[2].item[3])
  if sprite(me.spriteNum).locZ > 30000 then
    sprite(me.spriteNum).locZ = (screenLocs.getAt(3) - 1000)
  end if
end

on mouseDown me 
  gPostItColor = rgb(myColor)
  MyLineNum = (member("post.it field_NoAdding").height / member("post.it field_NoAdding").lineHeight)
  MyMaxLines = (12 - (member("post.it field_NoAdding").height / member("post.it field_NoAdding").lineHeight))
  if MyMaxLines < 1 then
    MyMaxLines = 0
  end if
  nextLineV = (-63 + member("post.it field_NoAdding").charPosToLoc(member("post.it field_NoAdding").text.length).locV)
  gOpenPostIt = me
  popupClose("post.it")
  popUpLoc = the mouseLoc
  put(popUpLoc)
  if popUpLoc.getAt(1) < 100 then
    popUpLoc.setAt(1, 120)
  end if
  if popUpLoc.getAt(2) < 100 then
    popUpLoc.setAt(2, 110)
  end if
  if popUpLoc.getAt(1) > 600 then
    popUpLoc.setAt(1, 570)
  end if
  if popUpLoc.getAt(2) > 400 then
    popUpLoc.setAt(2, 370)
  end if
  myUserSpr = getaProp(gpObjects, gMyName)
  if myUserSpr > 0 then
    myUserObj = sprite(myUserSpr).getProp(#scriptInstanceList, 1)
    if (myUserObj.controller = 0) then
      f = 1
      repeat while f <= member("post.it .pop").count(#line)
        if member("post.it .pop").text.getProp(#line, f) contains "post.it field_Add" then
          if MyLineNum > 11 then
          end if
          if (MyLineNum = 1) and (data = "") then
          end if
        else
          f = (1 + f)
        end if
      end repeat
      popup("post.it .pop", popUpLoc, "post.it")
      return()
    end if
  else
    return()
  end if
  f = 1
  repeat while f <= member("post.it .pop .controller").count(#line)
    if member("post.it .pop .controller").getProp(#line, f) contains "post.it field_Add" then
      if MyLineNum > 11 then
      end if
      if (MyLineNum = 1) and (data = "") then
      end if
    else
      f = (1 + f)
    end if
  end repeat
  popup("post.it .pop .controller", popUpLoc, "post.it")
end

on deletePostit me 
  sendFuseMsg("REMOVEITEM /" & id)
  gPostitCounter = (gPostitCounter - 1)
  put("Number of Postit" && gPostitCounter)
end

on savePostit me 
  data = "post.it field_Add" & field(0)
  sendFuseMsg("SETITEMDATA /" & id & "/" & myColor && data)
end
