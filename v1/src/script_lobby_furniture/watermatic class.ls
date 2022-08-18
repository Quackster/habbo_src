on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  return(me)
end

on mouseDown me 
  userObj = sprite(getProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
  if the doubleClick then
    if (me.getProp(#direction, 1) = 4) then
      if (me.locX = userObj.locX) and ((me.locY - userObj.locY) = -1) then
        giveDrink(me)
      else
        sendFuseMsg("Move" && me.locX && (me.locY + 1))
        return()
      end if
    else
      if (me.getProp(#direction, 1) = 0) then
        if (me.locX = userObj.locX) and ((me.locY - userObj.locY) = 1) then
          giveDrink(me)
        else
          sendFuseMsg("Move" && me.locX && (me.locY - 1))
          return()
        end if
      else
        if (me.getProp(#direction, 1) = 2) then
          if (me.locY = userObj.locY) and ((me.locX - userObj.locX) = -1) then
            giveDrink(me)
          else
            sendFuseMsg("Move" && (me.locX + 1) && me.locY)
            return()
          end if
        else
          if (me.getProp(#direction, 1) = 6) then
            if (me.locY = userObj.locY) and ((me.locX - userObj.locX) = 1) then
              giveDrink(me)
            else
              sendFuseMsg("Move" && (me.locX - 1) && me.locY)
            end if
          end if
        end if
      end if
    end if
    return()
  end if
  if listp(gpUiButtons) and the movieName contains "private" then
    mouseDown(hiliter, 1)
    gChosenStuffId = me.id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
    if (myUserObj.controller = 1) then
      hilite(me)
      if the optionDown then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on giveDrink me 
  put("CarryDrink" && getDrinkname(me))
  sendFuseMsg("LOOKTO" && me.locX && me.locY)
  sendFuseMsg("CarryDrink" && getDrinkname(me))
end

on getDrinkname me 
  return("Water")
end
