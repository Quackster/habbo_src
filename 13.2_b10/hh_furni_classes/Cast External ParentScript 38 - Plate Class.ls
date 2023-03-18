property pPlateID, pFrameCounter, pStarProps, pNumberOfStars

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
  return 1
end

on hidePlate me
  if windowExists(pPlateID) then
    removeWindow(pPlateID)
  end if
  return removeObject(me.getID())
end

on show me, tName, tDate, tMsg, tWindowName
  if windowExists(pPlateID) then
    removeWindow(pPlateID)
  end if
  if not createWindow(pPlateID, tWindowName) then
    return error(me, "Failed to open trophy plate window!!!", #show)
  else
    tWndObj = getWindow(pPlateID)
    tWndObj.center()
    repeat with tElemID in ["dedication_text_1", "dedication_text_2"]
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tMsg)
      end if
    end repeat
    repeat with tElemID in ["plate_name_1", "plate_name_2"]
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tName)
      end if
    end repeat
    repeat with tElemID in ["plate_date_1", "plate_date_2"]
      if tWndObj.elementExists(tElemID) then
        tWndObj.getElement(tElemID).setText(tDate)
      end if
    end repeat
    registerMessage(#leaveRoom, me.getID(), #hidePlate)
    registerMessage(#changeRoom, me.getID(), #hidePlate)
    receiveUpdate(me.getID())
  end if
  return 1
end

on showStars me
  pStarProps = [:]
  repeat with f = 1 to pNumberOfStars
    tSprNum = reserveSprite(me.getID())
    if tSprNum > 0 then
      pStarProps.addProp(f, ["sprite": tSprNum, "frame": 1, "loc": point(-10, -10)])
      sprite(tSprNum).ink = 8
      sprite(tSprNum).locZ = getWindow(pPlateID).getProperty(#locZ) + getWindow(pPlateID).getProperty(#spriteList).count
    end if
  end repeat
end

on hideStars me
  if pStarProps.ilk = #propList then
    if pStarProps.count > 0 then
      repeat with f = 1 to pStarProps.count
        if not voidp(pStarProps[f]["sprite"]) then
          tSpr = pStarProps[f]["sprite"]
          releaseSprite(tSpr)
        end if
      end repeat
    end if
  end if
  pStarProps = [:]
end

on update me
  if windowExists(pPlateID) then
    if pFrameCounter > 1 then
      if pStarProps.count = 0 then
        showStars(me)
      end if
      tWndObj = getWindow(pPlateID)
      tminX = tWndObj.getProperty(#locX) + 10
      tMaxX = tWndObj.getProperty(#width) - 10
      tMinY = tWndObj.getProperty(#locY) + 10
      tMaxY = tWndObj.getProperty(#height) - 10
      me.animateStars(tminX, tMaxX, tMinY, tMaxY)
      pFrameCounter = 0
    else
      pFrameCounter = pFrameCounter + 1
    end if
  else
    me.deconstruct()
  end if
end

on animateStars me, tminX, tMaxX, tMinY, tMaxY
  if pStarProps.ilk = #propList then
    if pStarProps.count > 0 then
      repeat with f = 1 to pStarProps.count
        tSpr = sprite(pStarProps[f]["sprite"])
        tFrame = pStarProps[f]["frame"]
        if tFrame = 1 then
          pStarProps[f]["loc"] = point(tminX + random(tMaxX), tMinY + random(tMaxY))
          sprite(tSpr).blend = 40 + random(40)
        end if
        if tFrame > 9 then
          sprite(tSpr).blend = 0
          if random(10) = 1 then
            pStarProps[f]["frame"] = 1
          end if
          next repeat
        end if
        sprite(tSpr).loc = pStarProps[f]["loc"]
        if memberExists("starblink" & tFrame) then
          sprite(tSpr).member = member(getmemnum("starblink" & tFrame))
        end if
        pStarProps[f]["frame"] = tFrame + 1
      end repeat
    end if
  end if
end
