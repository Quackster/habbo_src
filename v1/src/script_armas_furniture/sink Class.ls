property ancestor, BarDoorOpentimer
global gpObjects, gChosenStuffId, gChosenStuffSprite, gMyName

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  if ((getaProp(me.pData, "DOOROPEN") = "TRUE") and (update = 1)) then
    BarDoorOpentimer = 43
  else
    BarDoorOpentimer = 0
  end if
  return me
end

on updateStuffdata me, tProp, tValue
  if (tValue = "TRUE") then
    BarDoorOpentimer = 43
  else
    BarDoorOpentimer = 0
  end if
end

on mouseDown me
  global hiliter, gInfofieldIconSprite, gpUiButtons
  userObj = sprite(getProp(gpObjects, gMyName)).scriptInstanceList[1]
  if the doubleClick then
    case me.direction[1] of
      4:
        if ((me.locX = userObj.locX) and ((me.locY - userObj.locY) = -1)) then
          giveDrink(me)
        else
          sendFuseMsg((("Move" && me.locX) && (me.locY + 1)))
          return 
        end if
      0:
        if ((me.locX = userObj.locX) and ((me.locY - userObj.locY) = 1)) then
          giveDrink(me)
        else
          sendFuseMsg((("Move" && me.locX) && (me.locY - 1)))
          return 
        end if
      2:
        if ((me.locY = userObj.locY) and ((me.locX - userObj.locX) = -1)) then
          giveDrink(me)
        else
          sendFuseMsg((("Move" && (me.locX + 1)) && me.locY))
          return 
        end if
      6:
        if ((me.locY = userObj.locY) and ((me.locX - userObj.locX) = 1)) then
          giveDrink(me)
        else
          sendFuseMsg((("Move" && (me.locX - 1)) && me.locY))
        end if
    end case
    return 
  end if
  if (listp(gpUiButtons) and (the movieName contains "private")) then
    mouseDown(hiliter, 1)
    gChosenStuffId = me.id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
    if (myUserObj.controller = 1) then
      hilite(me)
      if the optionDown then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on giveDrink me
  sendFuseMsg(((((("SETSTUFFDATA /" & me.id) & "/") & "DOOROPEN") & "/") & "TRUE"))
  put ("CarryDrink" && getDrinkname(me))
  sendFuseMsg((("LOOKTO" && me.locX) && me.locY))
  sendFuseMsg(("CarryDrink" && getDrinkname(me)))
end

on getDrinkname me
  return "Tap water"
end

on exitFrame me
  if (BarDoorOpentimer <> 0) then
    mNamer = me.lSprites[2].member.name
    newMNamer = (char 1 to (mNamer.length - 1) of mNamer & 1)
    me.lSprites[2].castNum = abs(getmemnum(newMNamer))
    BarDoorOpentimer = (BarDoorOpentimer - 1)
    if (BarDoorOpentimer = 0) then
      mNamer = me.lSprites[2].member.name
      newMNamer = (char 1 to (mNamer.length - 1) of mNamer & 0)
      me.lSprites[2].castNum = getmemnum(newMNamer)
    end if
  end if
end
