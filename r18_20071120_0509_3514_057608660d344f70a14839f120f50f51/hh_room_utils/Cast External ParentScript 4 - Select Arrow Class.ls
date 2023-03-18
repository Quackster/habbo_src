property pArrowSpr, pSize, pLastLoc, pLastDir, pUserId, pCounter, pAnimFlag, pAnimCntr

on construct me
  pArrowSpr = sprite(reserveSprite(me.getID()))
  pArrowSpr.ink = 8
  pArrowSpr.visible = 0
  pLastLoc = VOID
  pLastDir = VOID
  pUserId = EMPTY
  pAnimFlag = 0
  pAnimCntr = 0
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  releaseSprite(pArrowSpr.spriteNum)
  return 1
end

on Init me
  tXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  pArrowSpr.locZ = getIntVariable("window.default.locz") - 2020
  pArrowSpr.visible = 0
  if integer(tXFactor) > 32 then
    pSize = "h"
  else
    pSize = "sh"
  end if
end

on show me, tUserID, tAnimFlag
  if stringp(tUserID) then
    pUserId = tUserID
  else
    pUserId = getThread(#room).getInterface().getSelectedObject()
  end if
  pArrowSpr.loc = point(-1000, -1000)
  pArrowSpr.visible = 1
  pCounter = 0
  pLastLoc = VOID
  pLastDir = VOID
  pAnimCntr = 0
  pAnimFlag = tAnimFlag = 1
  receiveUpdate(me.getID())
  return 1
end

on hide me
  removeUpdate(me.getID())
  pArrowSpr.loc = point(-1000, -1000)
  pArrowSpr.visible = 0
  return 1
end

on update me
  pCounter = not pCounter
  if pCounter then
    return 
  end if
  tHumanObj = getThread(#room).getComponent().getUserObject(pUserId)
  if tHumanObj = 0 then
    return me.hide()
  end if
  tHumanLoc = tHumanObj.getPartLocation("hd")
  tHumanDir = tHumanObj.getDirection()
  if voidp(pLastLoc) then
    pLastLoc = point(0, 0)
  end if
  if tHumanDir <> pLastDir then
    tChanges = 1
  else
    if tHumanLoc <> pLastLoc then
      if tHumanLoc[1] <> pLastLoc[1] then
        tChanges = 1
      else
        if abs(tHumanLoc[2] - pLastLoc[2]) > 1 then
          tChanges = 1
        end if
      end if
    end if
  end if
  if tChanges then
    pLastLoc = tHumanLoc
    pLastDir = tHumanDir
    tdir = [0, 1, 2, 3, 2, 1, 0, 3][tHumanDir + 1]
    if tHumanDir < 4 then
      pArrowSpr.flipH = 0
    else
      pArrowSpr.flipH = 1
    end if
    pArrowSpr.member = member(getmemnum("puppet_hilite_" & pSize & "_" & tdir))
    if pSize = "h" then
      tLocV = 60
    else
      tLocV = 40
    end if
    pArrowSpr.loc = point(tHumanLoc[1], tHumanLoc[2] - tLocV)
    return 1
  end if
  if pSize = "h" then
    tLocV = 60
  else
    tLocV = 40
  end if
  if pAnimFlag then
    pAnimCntr = (pAnimCntr + 4) mod 32
    tOffY = tHumanLoc[2] + (-8 * sin(float(pAnimCntr) / 10))
    pArrowSpr.locV = tOffY - tLocV
  end if
end
