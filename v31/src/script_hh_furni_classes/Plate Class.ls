property pPlateID, pNumberOfStars, pStarProps, pFrameCounter

on construct me 
  pPlateID = "trophyplate"
  pStarProps = [:]
  pNumberOfStars = 3
end

on deconstruct me 
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  removeUpdate(me.getID())
  me.hideStars()
  return TRUE
end

on hidePlate me 
  if windowExists(pPlateID) then
    removeWindow(pPlateID)
  end if
  return(removeObject(me.getID()))
end

on show me, tName, tDate, tMsg, tWindowName 
  if windowExists(pPlateID) then
    removeWindow(pPlateID)
  end if
  if not createWindow(pPlateID, tWindowName) then
    return(error(me, "Failed to open trophy plate window!!!", #show, #major))
  else
    tWndObj = getWindow(pPlateID)
    tWndObj.center()
    repeat while ["dedication_text_1", "dedication_text_2"] <= tDate
      tElemID = getAt(tDate, tName)
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tMsg)
      end if
    end repeat
    repeat while ["dedication_text_1", "dedication_text_2"] <= tDate
      tElemID = getAt(tDate, tName)
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tName)
      end if
    end repeat
    repeat while ["dedication_text_1", "dedication_text_2"] <= tDate
      tElemID = getAt(tDate, tName)
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tDate)
      end if
    end repeat
    registerMessage(#leaveRoom, me.getID(), #hidePlate)
    registerMessage(#changeRoom, me.getID(), #hidePlate)
    receiveUpdate(me.getID())
  end if
  return TRUE
end

on showStars me 
  pStarProps = [:]
  f = 1
  repeat while f <= pNumberOfStars
    tSprNum = reserveSprite(me.getID())
    if tSprNum > 0 then
      pStarProps.addProp(f, ["sprite":tSprNum, "frame":1, "loc":point(-10, -10)])
      sprite(tSprNum).ink = 8
      sprite(tSprNum).locZ = (getWindow(pPlateID).getProperty(#locZ) + getWindow(pPlateID).getProperty(#spriteList).count)
    end if
    f = (1 + f)
  end repeat
end

on hideStars me 
  if (pStarProps.ilk = #propList) then
    if pStarProps.count > 0 then
      f = 1
      repeat while f <= pStarProps.count
        if not voidp(pStarProps.getAt(f).getAt("sprite")) then
          tSpr = pStarProps.getAt(f).getAt("sprite")
          releaseSprite(tSpr)
        end if
        f = (1 + f)
      end repeat
    end if
  end if
  pStarProps = [:]
end

on update me 
  if windowExists(pPlateID) then
    if pFrameCounter > 1 then
      if (pStarProps.count = 0) then
        showStars(me)
      end if
      tWndObj = getWindow(pPlateID)
      tminX = (tWndObj.getProperty(#locX) + 10)
      tMaxX = (tWndObj.getProperty(#width) - 10)
      tMinY = (tWndObj.getProperty(#locY) + 10)
      tMaxY = (tWndObj.getProperty(#height) - 10)
      me.animateStars(tminX, tMaxX, tMinY, tMaxY)
      pFrameCounter = 0
    else
      pFrameCounter = (pFrameCounter + 1)
    end if
  else
    me.deconstruct()
  end if
end

on animateStars me, tminX, tMaxX, tMinY, tMaxY 
  if (pStarProps.ilk = #propList) then
    if pStarProps.count > 0 then
      f = 1
      repeat while f <= pStarProps.count
        tSpr = sprite(pStarProps.getAt(f).getAt("sprite"))
        tFrame = pStarProps.getAt(f).getAt("frame")
        if (tFrame = 1) then
          pStarProps.getAt(f).setAt("loc", point((tminX + random(tMaxX)), (tMinY + random(tMaxY))))
          sprite(tSpr).blend = (40 + random(40))
        end if
        if tFrame > 9 then
          sprite(tSpr).blend = 0
          if (random(10) = 1) then
            pStarProps.getAt(f).setAt("frame", 1)
          end if
        else
          sprite(tSpr).loc = pStarProps.getAt(f).getAt("loc")
          if memberExists("starblink" & tFrame) then
            sprite(tSpr).member = member(getmemnum("starblink" & tFrame))
          end if
          pStarProps.getAt(f).setAt("frame", (tFrame + 1))
        end if
        f = (1 + f)
      end repeat
    end if
  end if
end
