property pTopicList, pTutorWindowID, pTutorWindow, pBubble, pDefPosX, pDefPosY, pDefPose, pDefSex, pPosX, pPosY, pPose, pSex, pimage, pFlipped

on construct me
  me.pTutorWindowID = "Tutor_character"
  createWindow(pTutorWindowID, "guide_character.window")
  me.pTutorWindow = getWindow(pTutorWindowID)
  me.pBubble = createObject(getUniqueID(), ["Bubble Class", "Link Bubble Class"])
  me.hide()
  me.pBubble.setProperty(#targetID, "guide_image")
  me.pBubble.setProperty([#offsetx: 50])
  me.pBubble.update()
  me.pDefPosX = 20
  me.pDefPosY = 310
  me.pPose = 1
  return 1
end

on deconstruct me
  removeObject(me.pBubble.getID())
  removeWindow(me.pTutorWindow.getProperty(#id))
end

on hideLinks me
  me.pBubble.setLinks(VOID)
end

on update me
  me.pBubble.update()
  return [me.pTutorWindowID, me.pBubble.getProperty(#windowID)]
end

on setProperties me, tProperties
  if not listp(tProperties) then
    return 0
  end if
  repeat with i = 1 to tProperties.count
    me.setProperty(tProperties.getPropAt(i), tProperties[i])
  end repeat
end

on getProperty me, tProp
  case tProp of
    #sex:
      return me.pSex
  end case
end

on setProperty me, tProperty, tValue
  case tProperty of
    #textKey:
      tText = getText(tValue)
      tText = replaceChunks(tText, "\n", RETURN & RETURN)
      me.pBubble.setText(tText)
    #offsetx:
      tValue = value(tValue)
      if not tValue then
        me.pPosX = me.pDefPosX
      else
        me.pPosX = tValue
      end if
      me.pTutorWindow.moveTo(me.pPosX, me.pPosY)
    #offsety:
      tValue = value(tValue)
      if not tValue then
        me.pPosY = me.pDefPosY
      else
        me.pPosY = tValue
      end if
      me.pTutorWindow.moveTo(me.pPosX, me.pPosY)
    #links:
      me.pBubble.setLinks(tValue)
      if tValue.ilk = #propList then
        if not voidp(tValue.getaProp(#menu)) then
          me.pBubble.addText("tutorial_next")
        end if
      end if
    #sex:
      me.pSex = tValue
      me.updateImage()
    #pose, #direction:
      me.pPose = tValue
      me.updateImage()
    #topics:
      me.pTopicList = tValue
    #statuses:
      me.pBubble.setCheckmarks(tValue)
  end case
end

on moveTo me, tX, tY
  me.pPosX = tX
  me.pPosY = tY
  me.pTutorWindow.moveTo(me.pPosX, me.pPosY)
  me.pBubble.update()
end

on hide me
  me.pTutorWindow.hide()
  me.pBubble.hide()
end

on show me
  if voidp(me.pimage) then
    return 0
  end if
  me.updateImage()
  me.pTutorWindow.show()
  me.pBubble.show()
end

on updateImage me
  if voidp(me.pSex) or voidp(pPose) then
    return 0
  end if
  tPose = integer(me.pPose)
  me.pFlipped = 0
  if tPose > 10 then
    return 0
  end if
  tImageElem = pTutorWindow.getElement("guide_image")
  if tPose < 0 then
    tPose = -tPose
    me.pFlipped = 1
  end if
  tMemberName = "tutor_" & me.pSex & "_" & string(tPose)
  me.pimage = member(getmemnum(tMemberName)).image
  if voidp(me.pimage) then
    return 0
  end if
  tImageElem.feedImage(me.pimage)
  if me.pFlipped then
    tImageElem.flipH()
    tImageElem.render()
  end if
  tImageElem.resizeTo(me.pimage.width, me.pimage.height, 1)
  me.updateShadow()
end

on updateShadow me
  tShadow = image(me.pimage.width, me.pimage.height, 8)
  tBlack = image(me.pimage.width, me.pimage.height, 8)
  tBlack.fill(tBlack.rect, rgb("#000000"))
  tShadow.copyPixels(tBlack, tShadow.rect, tBlack.rect, [#maskImage: me.pimage.createMatte()])
  tElem = me.pTutorWindow.getElement("guide_shadow")
  tElem.feedImage(tShadow)
  tElem.resizeTo(tShadow.width, tShadow.height, 1)
  if me.pFlipped then
    tElem.flipH()
    tElem.render()
  end if
end
