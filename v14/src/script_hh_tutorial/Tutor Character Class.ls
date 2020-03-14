property pTutorWindowID, pPose, pTutorWindow

on construct me 
  me.pTutorWindowID = "Tutor_character"
  createWindow(pTutorWindowID, "guide_character.window")
  me.pTutorWindow = getWindow(pTutorWindowID)
  me.pBubble = createObject(getUniqueID(), ["Bubble Class", "Link Bubble Class"])
  me.hide()
  me.pBubble.setProperty(#targetID, "guide_image")
  me.pBubble.setProperty([#offsetx:50])
  me.pBubble.update()
  me.pDefPosX = 20
  me.pDefPosY = 310
  me.pPose = 1
  return TRUE
end

on deconstruct me 
  removeObject(me.pBubble.getID())
  removeWindow(me.pTutorWindow.getProperty(#id))
end

on hideLinks me 
  me.pBubble.setLinks(void())
end

on update me 
  tWindowList = getWindowIDList()
  tPosTutor = tWindowList.getPos(me.pTutorWindowID)
  if tPosTutor > 0 then
    tWindowList.deleteAt(tPosTutor)
  end if
  tPosBubble = tWindowList.getPos(me.pBubble.getProperty(#windowId))
  if tPosBubble > 0 then
    tWindowList.deleteAt(tPosBubble)
  end if
  tWindowList.add(me.pTutorWindowID)
  tWindowList.add(me.pBubble.getProperty(#windowId))
  getWindowManager().reorder(tWindowList)
  me.pBubble.update()
end

on setProperties me, tProperties 
  if not listp(tProperties) then
    return FALSE
  end if
  i = 1
  repeat while i <= tProperties.count
    me.setProperty(tProperties.getPropAt(i), tProperties.getAt(i))
    i = (1 + i)
  end repeat
end

on getProperty me, tProp 
  if (tProp = #sex) then
    return(me.pSex)
  end if
end

on setProperty me, tProperty, tValue 
  if (tProperty = #textKey) then
    tText = getText(tValue)
    tText = replaceChunks(tText, "\\n", "\r" & "\r")
    me.pBubble.setText(tText)
  else
    if (tProperty = #offsetx) then
      tValue = value(tValue)
      if not tValue then
        me.pPosX = me.pDefPosX
      else
        me.pPosX = tValue
      end if
      me.pTutorWindow.moveTo(me.pPosX, me.pPosY)
    else
      if (tProperty = #offsety) then
        tValue = value(tValue)
        if not tValue then
          me.pPosY = me.pDefPosY
        else
          me.pPosY = tValue
        end if
        me.pTutorWindow.moveTo(me.pPosX, me.pPosY)
      else
        if (tProperty = #links) then
          me.pBubble.setLinks(tValue)
          if (tValue.ilk = #propList) then
            if not voidp(tValue.getaProp(#menu)) then
              me.pBubble.addText("tutorial_next")
            end if
          end if
        else
          if (tProperty = #sex) then
            me.pSex = tValue
            me.updateImage()
          else
            if tProperty <> #pose then
              if (tProperty = #direction) then
                me.pPose = tValue
                me.updateImage()
              else
                if (tProperty = #topics) then
                  me.pTopicList = tValue
                else
                  if (tProperty = #statuses) then
                    me.pBubble.setCheckmarks(tValue)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
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
    return FALSE
  end if
  me.updateImage()
  me.pTutorWindow.show()
  me.pBubble.show()
end

on updateImage me 
  if voidp(me.pSex) or voidp(pPose) then
    return FALSE
  end if
  tPose = integer(me.pPose)
  me.pFlipped = 0
  if tPose > 10 then
    return FALSE
  end if
  tImageElem = pTutorWindow.getElement("guide_image")
  if tPose < 0 then
    tPose = -tPose
    me.pFlipped = 1
  end if
  tMemberName = "tutor_" & me.pSex & "_" & string(tPose)
  me.pimage = member(getmemnum(tMemberName)).image
  if voidp(me.pimage) then
    return FALSE
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
  tShadow.copyPixels(tBlack, tShadow.rect, tBlack.rect, [#maskImage:me.pimage.createMatte()])
  tElem = me.pTutorWindow.getElement("guide_shadow")
  tElem.feedImage(tShadow)
  tElem.resizeTo(tShadow.width, tShadow.height, 1)
  if me.pFlipped then
    tElem.flipH()
    tElem.render()
  end if
end
